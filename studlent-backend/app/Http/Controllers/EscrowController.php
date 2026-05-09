<?php

namespace App\Http\Controllers;

use App\Models\Payment;
use App\Services\FeeService;

class EscrowController extends Controller
{
    public function release($paymentId, FeeService $feeService)
    {
        $payment = Payment::findOrFail($paymentId);

        $fee = $feeService->calculate(
            $payment->amount - 2000,
            $payment->created_at
        );

        $payment->platform_fee = $fee['platform_fee'];
        $payment->freelancer_receive = $fee['freelancer_amount'];
        $payment->escrow_status = 'released';
        $payment->save();

        return response()->json([
            'message' => 'Dana berhasil dilepas',
            'data' => $fee
        ]);
    }
}