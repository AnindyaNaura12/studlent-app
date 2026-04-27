<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class MidtransWebhookController extends Controller
{
    public function callback(Request $request)
    {
        $payload = $request->all();
        
        // Handle webhook dari Midtrans
        $orderId = $payload['order_id'];
        $transactionStatus = $payload['transaction_status'];

        if ($transactionStatus == 'settlement') {
            // Update status payment
            \App\Models\Payment::where('gateway_trx_id', $orderId)
                ->update([
                    'status' => 'paid',
                    'escrow_status' => 'hold'
                ]);
        }

        return response()->json(['message' => 'OK']);
    }
}