<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->increments('id_user');
            $table->string('nama', 100)->nullable();
            $table->string('email', 100)->unique();
            $table->string('password', 255);
            $table->enum('role', ['client', 'freelancer', 'admin'])->nullable();
            $table->string('foto', 255)->nullable();
            $table->timestamp('joined_at')->useCurrent();
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};