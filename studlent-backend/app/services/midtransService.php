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

        Config::$serverKey    = $key;
        Config::$isProduction = false;
        Config::$isSanitized  = true;
        Config::$is3ds        = true;

        Config::$curlOptions  = [
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_SSL_VERIFYHOST => false,
            CURLOPT_TIMEOUT        => 30,   // ← tambah ini
            CURLOPT_CONNECTTIMEOUT => 15,   // ← tambah ini
            CURLOPT_HTTPHEADER     => [],
        ];
    }

    public function createTransaction($order, $amount)
    {
        $params = [
            'transaction_details' => [
                'order_id'     => 'ORDER-' . $order->id_order . '-' . time(),
                'gross_amount' => (int) $amount,  // ← cast ke int, Midtrans wajib integer
            ],
            'customer_details' => [
                'first_name' => $order->client->nama  ?? 'Client',
                'email'      => $order->client->email ?? 'email@mail.com',
                'phone'      => $order->client->no_hp ?? '',
            ],
            'item_details' => [  // ← tambah ini, Midtrans kadang reject tanpa item_details
                [
                    'id'       => 'SVC-' . $order->id_service,
                    'price'    => (int) $amount,
                    'quantity' => 1,
                    'name'     => $order->detail_pesanan ?? 'Studlent Service',
                ],
            ],
        ];

        return Snap::createTransaction($params);
    }
}