<?php
// app/Http/Controllers/MidtransWebhookController.php
 
namespace App\Http\Controllers;
 
use App\Models\Escrow;
use App\Models\Order;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
 
class MidtransWebhookController extends Controller
{
    /**
     * Endpoint POST /api/midtrans/callback
     * Dipanggil server Midtrans — bukan Flutter.
     * Tidak perlu auth Sanctum, tapi harus verifikasi signature key.
     */
    public function callback(Request $request)
    {
        $payload = $request->all();
 
        Log::info('Midtrans webhook received', $payload);
 
        $transactionStatus = $payload['transaction_status'] ?? '';
        $gatewayTrxId      = $payload['order_id'] ?? ''; // ini adalah midtrans_order_id kita
 
        // ── Verifikasi Signature (WAJIB aktif di production) ──────────
        if (config('midtrans.is_production')) {
            $expectedSignature = hash('sha512',
                ($payload['order_id']      ?? '') .
                ($payload['status_code']   ?? '') .
                ($payload['gross_amount']  ?? '') .
                config('midtrans.server_key')
            );
 
            if ($expectedSignature !== ($payload['signature_key'] ?? '')) {
                Log::warning('Midtrans webhook: invalid signature', [
                    'order_id' => $gatewayTrxId,
                ]);
                return response()->json(['message' => 'Invalid signature'], 403);
            }
        }
 
        // ── Cari payment berdasarkan midtrans_order_id ────────────────
        $payment = Payment::where('midtrans_order_id', $gatewayTrxId)->first();
 
        if (!$payment) {
            Log::warning('Midtrans webhook: payment not found', [
                'midtrans_order_id' => $gatewayTrxId,
            ]);
            return response()->json(['message' => 'Payment tidak ditemukan'], 404);
        }
 
        // Idempotency: kalau sudah paid, jangan update lagi
        if ($payment->status === 'paid') {
            return response()->json(['message' => 'Already processed']);
        }
 
        DB::transaction(function () use ($transactionStatus, $payment, $payload) {
            $order = Order::find($payment->id_order);
 
            if (in_array($transactionStatus, ['settlement', 'capture'])) {
                // ── SUKSES ─────────────────────────────────────────────
                $payment->status        = 'paid';
                $payment->escrow_status = 'hold';
                $payment->tanggal_bayar = now();
 
                // Simpan metode pembayaran aktual dari Midtrans
                if (!empty($payload['payment_type'])) {
                    $payment->metode = $payload['payment_type'];
                }
                $payment->save();
 
                // Pastikan escrow ada (bisa sudah dibuat Flutter, atau buat baru)
                Escrow::firstOrCreate(
                    ['id_payment' => $payment->id_payment],
                    [
                        'amount'           => $payment->amount,
                        'platform_fee'     => 0,
                        'freelancer_amount' => 0,
                        'status'           => 'hold',
                    ]
                );
 
                if ($order) {
                    $order->status = 'diproses';
                    $order->save();
                }
 
                // TODO: Kirim notifikasi ke freelancer
                // NotificationService::send($order->id_freelancer, 'Ada order baru masuk!');
 
                Log::info('Payment SUCCESS', ['order_id' => $payment->id_order]);
 
            } elseif ($transactionStatus === 'pending') {
                // ── PENDING (transfer bank belum selesai) ──────────────
                // Tidak perlu ubah status — biarkan polling yang handle
                $payment->save(); // trigger updated_at
 
                Log::info('Payment PENDING', ['order_id' => $payment->id_order]);
 
            } elseif (in_array($transactionStatus, ['cancel', 'deny', 'expire'])) {

                $payment->status = 'paid';
                $payment->save();

                if ($order) {
                    $order->status = 'diperoses';
                    $order->save();
                }

                Log::info('Payment EXPIRED', [
                    'order_id' => $payment->id_order,
                    'status'   => $transactionStatus,
                ]);
            }
        });
 
        return response()->json(['message' => 'OK']);
    }
}