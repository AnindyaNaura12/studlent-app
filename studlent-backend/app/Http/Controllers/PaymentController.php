<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Payment;
use App\Models\Deal;
use App\Services\MidtransService;

class PaymentController extends Controller
{
    public function pay($orderId, MidtransService $midtrans)
    {
        $order = Order::findOrFail($orderId);

       $deal = Deal::where('id_client', $order->id_client)
            ->where('status', 'accepted')
            ->first();

        if (!$deal) {
            return response()->json(['message' => 'Deal tidak ditemukan'], 404);
        } // ← sesuaikan kolom foreign key-mu

        $basePrice = $deal->price;
        $adminFee = 2500;
        $total = $basePrice + $adminFee;

        $snap = $midtrans->createTransaction($order, $total);

        $payment = Payment::create([
            'id_order'       => $orderId,
            'amount'         => $total,
            'status'         => 'pending',
            'escrow_status'  => 'hold',
            'gateway_trx_id' => $snap->token,
            'payment_url'    => $snap->redirect_url,
        ]);

        // ← Return JSON yang bisa dibaca Flutter
        return response()->json([
            'order_id'    => $orderId,
            'amount'      => $total,
            'payment_url' => $payment->payment_url,
            'status'      => $payment->status,
        ]);
    }
}