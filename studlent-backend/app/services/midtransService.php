<?php

namespace App\Services;

use Midtrans\Config;
use Midtrans\Snap;

class MidtransService
{
    public function __construct()
    {
        Config::$serverKey    = config('midtrans.server_key');
        Config::$isProduction = config('midtrans.is_production');
        Config::$isSanitized  = true;
        Config::$is3ds        = true;

        // ← FIX: bypass SSL untuk sandbox/local dev, hindari curl timeout
        if (!config('midtrans.is_production')) {
            Config::$curlOptions = [CURLOPT_SSL_VERIFYPEER => false];
        }
    }

    public function createTransaction($order, int $amount): array
    {
        $midtransOrderId = 'ORDER-' . $order->id_order . '-' . time();

        $params = [
            'transaction_details' => [
                'order_id'     => $midtransOrderId,
                'gross_amount' => $amount,
            ],
            'customer_details' => [
                'first_name' => $order->client->nama  ?? 'Client',
                'email'      => $order->client->email ?? 'client@studlent.com',
                'phone'      => $order->client->no_hp ?? '',
            ],
            'item_details' => [
                [
                    'id'       => 'ORDER-' . $order->id_order,
                    'price'    => $amount,
                    'quantity' => 1,
                    'name'     => substr($order->detail_pesanan ?? 'Studlent Service', 0, 50),
                ],
            ],
            // ← FIX: WAJIB ADA — URL ini yang diintercept WebView Flutter
            'callbacks' => [
                'finish'  => 'https://studlent.app/payment/finish',
                'error'   => 'https://studlent.app/payment/error',
                'pending' => 'https://studlent.app/payment/pending',
            ],
        ];

        try {
            $snap = Snap::createTransaction($params);
        } catch (\Throwable $e) {
            dd($e->getMessage(), $e->getFile(), $e->getLine());
        }

        return [
            'token'             => $snap->token,
            'redirect_url'      => $snap->redirect_url,
            'midtrans_order_id' => $midtransOrderId,
        ];
    }
}