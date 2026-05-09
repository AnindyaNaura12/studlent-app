<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\DealController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\MidtransWebhookController;
use App\Http\Controllers\EscrowController;
use App\Http\Controllers\RevisionController;

/*
|--------------------------------------------------------------------------
| AUTH
|--------------------------------------------------------------------------
*/
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

/*
|--------------------------------------------------------------------------
| PROTECTED ROUTES
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    /*
    |--------------------------------------------------------------------------
    | CHAT SYSTEM
    |--------------------------------------------------------------------------
    */
    Route::post('/chat/send', [ChatController::class, 'send']);
    Route::get('/chat/{orderId}', [ChatController::class, 'get']);

    /*
    |--------------------------------------------------------------------------
    | DEAL SYSTEM
    |--------------------------------------------------------------------------
    */
    Route::post('/deal', [DealController::class, 'create']);
    Route::post('/deal/accept/{id}', [DealController::class, 'accept']);

    /*
    |--------------------------------------------------------------------------
    | ORDER SYSTEM
    |--------------------------------------------------------------------------
    */
    Route::post('/order/{dealId}', [OrderController::class, 'createFromDeal']);

    /*
    |--------------------------------------------------------------------------
    | PAYMENT SYSTEM (MIDTRANS)
    |--------------------------------------------------------------------------
    */
    Route::get('/pay/{orderId}', [PaymentController::class, 'pay']);

    /*
    |--------------------------------------------------------------------------
    | REVISION SYSTEM
    |--------------------------------------------------------------------------
    */
    Route::post('/revision', [RevisionController::class, 'request']);

    /*
    |--------------------------------------------------------------------------
    | ESCROW RELEASE (ADMIN ONLY)
    |--------------------------------------------------------------------------
    */
    Route::middleware('role:admin')->group(function () {
        Route::post('/escrow/release/{paymentId}', [EscrowController::class, 'release']);
    });
});

/*
|--------------------------------------------------------------------------
| MIDTRANS WEBHOOK (NO AUTH)
|--------------------------------------------------------------------------
*/
Route::post('/midtrans/callback', [MidtransWebhookController::class, 'callback']);