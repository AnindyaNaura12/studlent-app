<?php

namespace App\Services;

class FeeService
{
    public function calculate($amount, $userJoinedAt)
    {
        $months = now()->diffInMonths($userJoinedAt);

        $feePercent = ($months < 2) ? 0.05 : 0.08;

        $platformFee = $amount * $feePercent;
        $freelancerReceive = $amount - $platformFee;

        return [
            'fee_percent' => $feePercent,
            'platform_fee' => $platformFee,
            'freelancer_amount' => $freelancerReceive
        ];
    }
}