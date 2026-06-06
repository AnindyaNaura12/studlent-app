<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Deal;
use App\Models\Payment;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    /**
     * Buat Order + Payment (pending) dari Deal yang sudah accepted.
     * Flutter hit ini setelah client klik "Confirm & Pay".
     * Response: order_id + payment_id → Flutter lanjut hit /payment/initiate
     */
    public function createFromDeal(Request $request, $dealId)
    {
        $request->validate([
            'catatan'  => 'nullable|string|max:1000',
            'deadline' => 'nullable|date',
        ]);

        $deal = Deal::findOrFail($dealId);

        // Deal harus sudah accepted sebelum bisa order
        if ($deal->status !== 'accepted') {
            return response()->json([
                'message' => 'Deal belum disetujui freelancer',
            ], 400);
        }

        // Cek apakah sudah ada order aktif untuk deal ini
        $existing = Order::where('id_deal', $dealId)
            ->whereNotIn('status', ['cancelled', 'failed'])
            ->first();

        if ($existing) {
            return response()->json([
                'message'  => 'Order untuk deal ini sudah ada',
                'order_id' => $existing->id_order,
            ], 409);
        }

        $adminFee = 2500;
        $total    = $deal->price + $adminFee;

        // 1. Buat Order
        $order = Order::create([
            'id_client'      => $deal->id_client,
            'id_freelancer'  => $deal->id_freelancer,   // ← wajib dari Deal
            'id_service'     => null,
            'id_package'     => null,
            'id_deal'        => $deal->id_deal,
            'detail_pesanan' => $deal->deskripsi ?? 'Project dari deal',
            'catatan'        => $request->catatan,
            'deadline'       => $request->deadline,
            'status'         => 'menunggu_pembayaran',
            'progress'       => 0,
        ]);

        // 2. Buat Payment (pending) — WAJIB sebelum hit /payment/initiate
        $payment = Payment::create([
            'id_order'      => $order->id_order,
            'amount'        => $total,
            'admin_fee'     => $adminFee,
            'status'        => 'pending',
            'escrow_status' => 'hold',
        ]);

        return response()->json([
            'message'    => 'Order berhasil dibuat',
            'order_id'   => $order->id_order,
            'payment_id' => $payment->id_payment,
            'amount'     => $total,
            'breakdown'  => [
                'base_price' => $deal->price,
                'admin_fee'  => $adminFee,
                'total'      => $total,
            ],
        ], 201);
    }

    /**
     * Polling status — Flutter hit ini tiap 4 detik
     * setelah client selesai bayar di WebView.
     */
    public function getStatus($id)
    {
        $order = Order::with('payment')
            ->where('id_order', $id)
            ->firstOrFail();

        return response()->json([
            'order_id'       => $order->id_order,
            'status'         => $order->status,
            'payment_status' => $order->payment?->status ?? 'pending',
            // Flutter pakai ini untuk tahu kapan harus stop polling
            'is_paid'        => $order->payment?->status === 'paid',
        ]);
    }
}