<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WalletLedger extends Model
{
    protected $primaryKey = 'id_ledger';

    protected $fillable = [
        'id_user',
        'type', // credit / debit
        'amount',
        'source',
        'reference_id'
    ];
}