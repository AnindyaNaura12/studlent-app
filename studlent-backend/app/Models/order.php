<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $primaryKey = 'id_order';

    protected $fillable = [
        'id_client',
        'id_service',
        'detail_pesanan',
        'deadline',
        'status'
    ];

    public function client()
    {
        return $this->belongsTo(User::class, 'id_client');
    }

    public function payment()
    {
        return $this->hasOne(Payment::class, 'id_order');
    }
}