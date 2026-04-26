<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Deal;

class OrderController extends Controller
{
    public function createFromDeal($dealId)
    {
        $deal = Deal::findOrFail($dealId);

        return Order::create([
            'id_client' => $deal->id_client,
            'id_service' => null,
            'detail_pesanan' => 'Project dari deal',
            'status' => 'menunggu_pembayaran'
        ]);
    }
}