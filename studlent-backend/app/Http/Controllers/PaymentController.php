<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Payment;
use App\Models\Deal;
use App\Models\Escrow;
use App\Models\User;
use App\Services\MidtransService;
use App\Services\FeeService;
use App\Services\WalletService;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    // ─────────────────────────────────────────────────────────────
    // METHOD LAMA — tetap tidak diubah
    // ─────────────────────────────────────────────────────────────
    public function pay($orderId, MidtransService $midtrans)
    {
        $order = Order::findOrFail($orderId);

        $deal = Deal::where('id_client', $order->id_client)
            ->where('status', 'accepted')
            ->first();

        if (!$deal) {
            return response()->json(['message' => 'Deal tidak ditemukan'], 404);
        }

        $basePrice = $deal->price;
        $adminFee  = 2500;
        $total     = $basePrice + $adminFee;

        $snap = $midtrans->createTransaction($order, $total);

        $payment = Payment::create([
            'id_order'       => $orderId,
            'amount'         => $total,
            'status'         => 'pending',
            'escrow_status'  => 'hold',
            'gateway_trx_id' => $snap->token,
            'payment_url'    => $snap->redirect_url,
        ]);

        return response()->json([
            'order_id'    => $orderId,
            'amount'      => $total,
            'payment_url' => $payment->payment_url,
            'status'      => $payment->status,
        ]);
    }

    // ─────────────────────────────────────────────────────────────
    // METHOD BARU — dipanggil Flutter setelah insert order & payment
    // Flutter kirim: order_id, payment_id, amount, customer, item
    // ─────────────────────────────────────────────────────────────
   public function initiatePayment(Request $request, MidtransService $midtrans)
    {
        $request->validate([
            'order_id'   => 'required|integer|exists:orders,id_order',
            'payment_id' => 'required|integer|exists:payments,id_payment',
            'amount'     => 'required|integer|min:1000',
            'customer'   => 'required|array',
            'item'       => 'required|array',
        ]);

        // ← load relasi client agar bisa dipakai di MidtransService
        $order = Order::with('client')->findOrFail($request->order_id);

        $payment = Payment::where('id_payment', $request->payment_id)
            ->where('id_order', $request->order_id)
            ->where('status', 'pending')
            ->firstOrFail();

        try {
            $snap = $midtrans->createTransaction($order, (int) $request->amount);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Midtrans error: ' . $e->getMessage(),
            ], 500);
        }

        $payment->gateway_trx_id = $snap->token;
        $payment->payment_url    = $snap->redirect_url;
        $payment->save();

        return response()->json([
            'payment_url'    => $snap->redirect_url,
            'transaction_id' => $snap->token,
            'amount'         => $payment->amount,
        ]);
    }
    // ─────────────────────────────────────────────────────────────
    // METHOD BARU — dipanggil client saat tekan "Pesanan Selesai"
    // ─────────────────────────────────────────────────────────────
    public function completeOrder(Request $request, FeeService $feeService, WalletService $walletService)
    {
        $request->validate([
            'id_order' => 'required|integer|exists:orders,id_order',
        ]);

        $order   = Order::with('payment')->findOrFail($request->id_order);
        $payment = $order->payment;

        if (!$payment || $payment->status !== 'paid') {
            return response()->json(['message' => 'Payment belum lunas'], 400);
        }

        if ($order->status === 'completed') {
            return response()->json(['message' => 'Order sudah selesai'], 400);
        }

        // Hitung fee berdasarkan waktu bergabung freelancer
        $freelancer = User::findOrFail($order->id_freelancer);
        $baseAmount = $payment->amount - ($payment->admin_fee ?? 2000);
        $fee        = $feeService->calculate($baseAmount, $freelancer->created_at);

        // Release escrow
        $escrow = Escrow::where('id_payment', $payment->id_payment)->first();
        if ($escrow) {
            $escrow->platform_fee      = $fee['platform_fee'];
            $escrow->freelancer_amount = $fee['freelancer_amount'];
            $escrow->status            = 'released';
            $escrow->released_at       = now();
            $escrow->save();
        }

        // Credit ke wallet freelancer
        $walletService->credit(
            $order->id_freelancer,
            $fee['freelancer_amount'],
            'order_complete',
            $order->id_order
        );

        // Update status
        $order->status          = 'completed';
        $order->save();

        $payment->escrow_status = 'released';
        $payment->save();

        return response()->json([
            'message'            => 'Order selesai, dana berhasil dicairkan',
            'freelancer_receive' => $fee['freelancer_amount'],
            'platform_fee'       => $fee['platform_fee'],
        ]);
    }
}