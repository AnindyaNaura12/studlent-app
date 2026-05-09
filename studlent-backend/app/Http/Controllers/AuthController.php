<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        //validasi input
        $request->validate([
            'nama' => 'required',
            'phone' => 'required',
            'password' => 'required',
            'product_interest' => 'required'
        ]);

        $user = User::create([
            'nama' => $request->username,
            'email' => $request->email,
            'phone' => $request->phone, 
            'password' => Hash::make($request->password),
            'product_interest' => $request->product_interest,
            'role' => 'client', // client 
            'joined_at' => now()
        ]);

        return response()->json($user);
    }

    public function login(Request $request)
    {
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid login'], 401);
        }

        $token = $user->createToken('auth')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token
        ]);
    }

    public function me(Request $request)
    {
        return response()->json($request->user());
    }
}