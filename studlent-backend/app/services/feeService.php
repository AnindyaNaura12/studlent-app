<?php

namespace App\Services;

use Carbon\Carbon;

class FeeService
{
    public function calculate($amount, $userJoinedAt)
    {
        // Pastikan jadi Carbon instance (bisa dari string DB maupun object)
        $joinedAt = Carbon::parse($userJoinedAt);

        // Berapa bulan sejak freelancer bergabung?
        // joined_at → now(), bukan now() → joined_at
        $months = $joinedAt->diffInMonths(now());

        // 2 bulan pertama: 5%, setelahnya: 8%
        $feePercent = ($months < 2) ? 0.05 : 0.08;

        $platformFee       = (int) round($amount * $feePercent);
        $freelancerAmount  = $amount - $platformFee;

        return [
            'fee_percent'        => $feePercent,
            'platform_fee'       => $platformFee,
            'freelancer_amount'  => $freelancerAmount,
        ];
    }
}