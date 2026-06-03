<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'nama'             => 'required|string|max:255',
            'email'            => 'required|email|unique:users,email',
            'no_hp'            => 'required|string',
            'password'         => 'required|string|min:6',
            'product_interest' => 'required|string',
        ]);

        $user = User::create([
            'nama'             => $request->nama,   // ← fix: bukan $request->username
            'email'            => $request->email,
            'no_hp'            => $request->no_hp,
            'password'         => Hash::make($request->password),
            'product_interest' => $request->product_interest,
            'role'             => 'client',
            'joined_at'        => now(),
        ]);

        $token = $user->createToken('auth')->plainTextToken;

        // Langsung return token setelah register,
        // supaya Flutter tidak perlu login lagi setelah daftar
        return response()->json([
            'user'  => $user,
            'token' => $token,
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Email atau password salah'], 401);
        }

        // Hapus token lama supaya tidak numpuk
        $user->tokens()->delete();

        $token = $user->createToken('auth')->plainTextToken;

        return response()->json([
            'user'  => $user,
            'token' => $token,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out']);
    }

    public function me(Request $request)
    {
        return response()->json($request->user());
    }
}