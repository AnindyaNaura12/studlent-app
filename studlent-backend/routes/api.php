<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DealController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\EscrowController;
use App\Http\Controllers\RevisionController;
use App\Http\Controllers\MidtransWebhookController;

// ─────────────────────────────────────────────────────────────
// PUBLIC ROUTES — tanpa auth
// ─────────────────────────────────────────────────────────────
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// Webhook Midtrans — TANPA auth, yang hit adalah server Midtrans
Route::post('/midtrans/callback', [MidtransWebhookController::class, 'callback']);

// ─────────────────────────────────────────────────────────────
// PROTECTED ROUTES — wajib login (Sanctum)
// ─────────────────────────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    // ── Auth ──────────────────────────────────────────────────
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // ── Deal ──────────────────────────────────────────────────
    Route::post('/deals',             [DealController::class, 'create']);
    Route::post('/deals/{id}/accept', [DealController::class, 'accept']);

    // ── Order ─────────────────────────────────────────────────
    Route::post('/orders/from-deal/{dealId}', [OrderController::class, 'createFromDeal']);

    // Polling status — dicek Flutter tiap 4 detik di PaymentWebViewPage
    Route::get('/orders/{id}/status', [OrderController::class, 'getStatus']);

    // ── Payment ───────────────────────────────────────────────
    Route::post('/payments/{orderId}/pay', [PaymentController::class, 'pay']);

    // Flutter hit ini untuk dapat payment_url dari Midtrans
    Route::post('/payment/initiate',  [PaymentController::class, 'initiatePayment']);

    // Flutter hit ini saat client tekan "Pesanan Selesai"
    Route::post('/payment/complete',  [PaymentController::class, 'completeOrder']);

    // ── Escrow ────────────────────────────────────────────────
    Route::post('/escrow/{paymentId}/release', [EscrowController::class, 'release'])
        ->middleware('ensure.payment.paid');

    // ── Revision ──────────────────────────────────────────────
    Route::post('/revisions', [RevisionController::class, 'request']);
});