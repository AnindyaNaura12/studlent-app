<?php

namespace App\Services;

use Midtrans\Snap;
use Midtrans\Config;
use Illuminate\Support\Facades\Log;

class MidtransService
{
    public function __construct()
    {
        $key = config('midtrans.server_key');
        Log::info('Midtrans key: ' . $key);
        Config::$serverKey = $key;
        Config::$isProduction = false;
        Config::$isSanitized = true;
        Config::$is3ds = true;
        Config::$curlOptions = [
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_SSL_VERIFYHOST => false,
            CURLOPT_HTTPHEADER => [], // ← tambah ini
        ];
    }

    public function createTransaction($order, $amount)
    {
        $params = [
            'transaction_details' => [
                'order_id' => 'ORDER-' . $order->id_order . '-' . time(),
                'gross_amount' => $amount
            ],
            'customer_details' => [
                'first_name' => $order->client->nama ?? 'Client',
                'email' => $order->client->email ?? 'email@mail.com'
            ]
        ];

        return Snap::createTransaction($params);
    }
}