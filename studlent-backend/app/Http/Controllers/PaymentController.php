<?php

namespace App\Http\Controllers;

use App\Models\Deal;
use App\Models\Escrow;
use App\Models\Order;
use App\Models\Payment;
use App\Models\User;
use App\Services\FeeService;
use App\Services\MidtransService;
use App\Services\WalletService;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    // Dipanggil Flutter setelah insert order & payment ke Supabase/DB
    // Route ini PUBLIC — Flutter pakai Supabase Auth bukan Sanctum
    public function initiatePayment(Request $request, MidtransService $midtrans)
    {
        $request->validate([
            'order_id'   => 'required|integer|exists:orders,id_order',
            'payment_id' => 'required|integer|exists:payments,id_payment',
            'amount'     => 'required|integer|min:1000',
            'customer'   => 'required|array',
            'item'       => 'required|array',
        ]);

        $order = Order::with('client')->findOrFail($request->order_id);

        $payment = Payment::where('id_payment', $request->payment_id)
            ->where('id_order', $request->order_id)
            ->where('status', 'pending')
            ->firstOrFail();

        try {
            $snap = $midtrans->createTransaction($order, (int) $request->amount);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Midtrans error: ' . $e->getMessage(),
            ], 500);
        }

        $payment->gateway_trx_id = $snap['token'];
        $payment->midtrans_order_id = $snap['midtrans_order_id'];
        $payment->payment_url = $snap['redirect_url'];

        $payment->save();

        return response()->json([
            'payment_url' => $snap['redirect_url'],
            'snap_token' => $snap['token'],
            'midtrans_order_id' => $snap['midtrans_order_id'],
            'amount' => $payment->amount,
        ]);
    }

    // Dipanggil client saat tekan "Pesanan Selesai"
    public function completeOrder(
        Request $request,
        FeeService $feeService,
        WalletService $walletService
    ) {
        $request->validate([
            'id_order' => 'required|integer|exists:orders,id_order',
        ]);

        $order   = Order::with('payment')->findOrFail($request->id_order);
        $payment = $order->payment;

        if (!$payment || $payment->status !== 'paid') {
            return response()->json(['message' => 'Payment belum lunas'], 400);
        }

        if ($order->status === 'selesai') {
            return response()->json(['message' => 'Order sudah selesai'], 400);
        }

        $freelancer = User::findOrFail($order->id_freelancer);
        $baseAmount = $payment->amount - ($payment->admin_fee ?? 2500);
        $fee        = $feeService->calculate($baseAmount, $freelancer->joined_at);

        $escrow = Escrow::where('id_payment', $payment->id_payment)->first();
        if ($escrow) {
            $escrow->platform_fee      = $fee['platform_fee'];
            $escrow->freelancer_amount = $fee['freelancer_amount'];
            $escrow->status            = 'released';
            $escrow->released_at       = now();
            $escrow->save();
        }

        $walletService->credit(
            $order->id_freelancer,
            $fee['freelancer_amount'],
            'order_complete',
            $order->id_order
        );

        $order->status          = 'selesai';
        $order->save();

        $payment->escrow_status  = 'released';
        $payment->fee_percent    = $fee['fee_percent'] * 100;
        $payment->platform_fee   = $fee['platform_fee'];
        $payment->freelancer_receive = $fee['freelancer_amount'];
        $payment->save();

        return response()->json([
            'message'            => 'Order selesai, dana berhasil dicairkan',
            'freelancer_receive' => $fee['freelancer_amount'],
            'platform_fee'       => $fee['platform_fee'],
        ]);
    }
}