<?php

namespace App\Http\Controllers;

use App\Models\Deal;
use Illuminate\Http\Request;

class DealController extends Controller
{
    public function create(Request $request)
    {
        return Deal::create([
            'id_client' => auth()->id(),
            'id_freelancer' => $request->id_freelancer,
            'price' => $request->price, // 500000
            'status' => 'pending'
        ]);
    }

    public function accept($dealId)
    {
        $deal = Deal::findOrFail($dealId);
        $deal->status = 'accepted';
        $deal->save();

        return $deal;
    }
}