<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Payment;
use App\Models\Order;

class MidtransWebhookController extends Controller
{
    public function callback(Request $request)
    {
        $payload           = $request->all();
        $transactionStatus = $payload['transaction_status'] ?? '';
        $gatewayTrxId      = $payload['order_id'] ?? '';

        // ── Verifikasi signature Midtrans ──────────────────────────
        // Wajib aktifkan di production, sekarang di-comment untuk sandbox
        //
        // $signatureKey = hash('sha512',
        //     $payload['order_id'] .
        //     $payload['status_code'] .
        //     $payload['gross_amount'] .
        //     config('midtrans.server_key')
        // );
        // if ($signatureKey !== ($payload['signature_key'] ?? '')) {
        //     return response()->json(['message' => 'Invalid signature'], 403);
        // }

        // ── Cari payment berdasarkan gateway_trx_id ────────────────
        $payment = Payment::where('gateway_trx_id', $gatewayTrxId)->first();

        if (!$payment) {
            return response()->json(['message' => 'Payment tidak ditemukan'], 404);
        }

        // ── Handle status dari Midtrans ────────────────────────────
        if (in_array($transactionStatus, ['settlement', 'capture'])) {

            // Update payment → paid
            $payment->status        = 'paid';
            $payment->escrow_status = 'hold';
            $payment->tanggal_bayar = now();
            $payment->save();

            // Update order → in_progress
            // Sekaligus sinyal ke Flutter bahwa polling bisa stop
            $order = Order::find($payment->id_order);
            if ($order) {
                $order->status = 'in_progress';
                $order->save();
            }

        } elseif ($transactionStatus === 'pending') {
            // Midtrans masih nunggu pembayaran, tidak perlu update apa-apa
            // status di DB tetap 'pending'

        } elseif (in_array($transactionStatus, ['cancel', 'deny', 'expire'])) {

            // Update payment → failed
            $payment->status = 'failed';
            $payment->save();

            // Kembalikan order ke status awal supaya client bisa coba lagi
            $order = Order::find($payment->id_order);
            if ($order) {
                $order->status = 'menunggu_pembayaran';
                $order->save();
            }
        }

        // Midtrans butuh response 200 OK, kalau tidak akan retry terus
        return response()->json(['message' => 'OK']);
    }
}