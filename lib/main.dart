import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/pages/home_pages.dart';
import 'config.dart'; // pastikan sudah buat ini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );

  runApp(const MyApp());
}

// biar gampang dipakai di seluruh app
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studlent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
  // ── Cek apakah user sudah login ──────────────────────────
  Widget _getHomePage() {
    final session = supabase.auth.currentSession;
    if (session != null) {
      return const HomePage(); // ← sudah login, langsung ke home
    }
    return const HomePage(); // ← belum login, ke home (dengan guest mode)
  }

}