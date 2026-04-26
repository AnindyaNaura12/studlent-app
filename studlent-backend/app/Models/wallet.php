<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Wallet extends Model
{
    protected $primaryKey = 'id_wallet';

    protected $fillable = [
        'id_user',
        'balance'
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }
}