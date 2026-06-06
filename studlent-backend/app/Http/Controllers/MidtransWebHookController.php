<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Payment;
use Illuminate\Http\Request;
use App\Models\Escrow; 

class MidtransWebhookController extends Controller
{
    public function callback(Request $request)
    {
        $payload           = $request->all();
        $transactionStatus = $payload['transaction_status'] ?? '';
        $gatewayTrxId      = $payload['order_id'] ?? '';

        // Aktifkan di production:
        // $signatureKey = hash('sha512',
        //     $payload['order_id'] .
        //     $payload['status_code'] .
        //     $payload['gross_amount'] .
        //     config('midtrans.server_key')
        // );
        // if ($signatureKey !== ($payload['signature_key'] ?? '')) {
        //     return response()->json(['message' => 'Invalid signature'], 403);
        // }

        $payment = Payment::where(
            'midtrans_order_id',
            $gatewayTrxId
        )->first();
        if (!$payment) {
            return response()->json(['message' => 'Payment tidak ditemukan'], 404);
        }

        if (in_array($transactionStatus, ['settlement', 'capture'])) {

            $payment->status        = 'paid';
            $payment->escrow_status = 'hold';
            $payment->tanggal_bayar = now();
            $payment->save();
            
            Escrow::firstOrCreate(
                [
                    'id_payment' => $payment->id_payment
                ],
                [
                    'amount' => $payment->amount,
                    'status' => 'hold'
                ]
            );
            $order = Order::find($payment->id_order);
            if ($order) {
                $order->status = 'diproses'; // bukan 'in_progress'
                $order->save();
            }

        } elseif ($transactionStatus === 'pending') {
            // tidak perlu update

        } elseif (in_array($transactionStatus, ['cancel', 'deny', 'expire'])) {

            $payment->status = 'failed';
            $payment->save();

            $order = Order::find($payment->id_order);
            if ($order) {
                $order->status = 'menunggu_pembayaran';
                $order->save();
            }
        }

        return response()->json(['message' => 'OK']);
    }
}