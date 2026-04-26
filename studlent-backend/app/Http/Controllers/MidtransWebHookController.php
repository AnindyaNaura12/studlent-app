<?php

namespace App\Services;

use Midtrans\Snap;
use Midtrans\Config;

class MidtransService
{
    public function __construct()
    {
        Config::$serverKey = config('midtrans.server_key');
        Config::$isProduction = false;
        Config::$isSanitized = true;
        Config::$is3ds = true;
    }

    /**
     * Create Midtrans transaction
     * @return object
     */
    public function createTransaction($order, $amount)
    {
        $params = [
            'transaction_details' => [
                'order_id' => $order->id_order,
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