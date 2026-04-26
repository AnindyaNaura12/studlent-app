<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Deal extends Model
{
    protected $primaryKey = 'id_deal';

    protected $fillable = [
        'id_client',
        'id_freelancer',
        'price',
        'status'
    ];
}