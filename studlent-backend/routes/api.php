<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DealController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\EscrowController;
use App\Http\Controllers\RevisionController;
use App\Http\Controllers\MidtransWebhookController;

// ─────────────────────────────────────────────────────────────
// PUBLIC
// ─────────────────────────────────────────────────────────────
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// Midtrans callback — dipanggil server Midtrans, bukan Flutter
Route::post('/midtrans/callback', [MidtransWebhookController::class, 'callback']);

// Flutter pakai Supabase Auth, bukan Sanctum → semua payment route PUBLIC
Route::post('/payment/initiate',  [PaymentController::class, 'initiatePayment']);
Route::get('/orders/{id}/status', [OrderController::class, 'getStatus']);

// ← FIX: dipindah ke public — Flutter tidak punya Sanctum token
Route::post('/payment/complete',  [PaymentController::class, 'completeOrder']);

// ─────────────────────────────────────────────────────────────
// PROTECTED — Sanctum (untuk fitur admin/panel)
// ─────────────────────────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    Route::post('/deals',             [DealController::class, 'create']);
    Route::post('/deals/{id}/accept', [DealController::class, 'accept']);

    Route::post('/orders/from-deal/{dealId}', [OrderController::class, 'createFromDeal']);

    Route::post('/payments/{orderId}/pay',     [PaymentController::class, 'pay']);
    Route::post('/escrow/{paymentId}/release', [EscrowController::class, 'release']);
    Route::post('/revisions',                  [RevisionController::class, 'request']);
});