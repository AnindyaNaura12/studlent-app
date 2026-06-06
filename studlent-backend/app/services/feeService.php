<?php

namespace App\Services;

use Carbon\Carbon;

class FeeService
{
    public function calculate($amount, $userJoinedAt)
    {
        $joinedAt = Carbon::parse($userJoinedAt);
        $months   = $joinedAt->diffInMonths(now());

        // 2 bulan pertama: 5%, setelahnya: 8%
        $feePercent = ($months < 2) ? 0.05 : 0.08;

        $platformFee      = (int) round($amount * $feePercent);
        $freelancerAmount = $amount - $platformFee;

        return [
            'fee_percent'       => $feePercent,
            'platform_fee'      => $platformFee,
            'freelancer_amount' => $freelancerAmount,
        ];
    }
}