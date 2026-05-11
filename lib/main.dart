import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/pages/home_pages.dart';
import 'config.dart';

// ← PINDAH KE SINI: setelah initialize, sebelum runApp
final supabase = Supabase.instance.client;
final ValueNotifier<String> globalUsername = ValueNotifier<String>('');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Config.supabaseUrl,
    anonKey: Config.supabaseAnonKey,
  );

  runApp(const MyApp());
}

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
      home: _getHomePage(), // ← PANGGIL _getHomePage(), bukan const HomePage()
    );
  }

  // ── Cek apakah user sudah login ──────────────────────────
  Widget _getHomePage() {
    final session = supabase.auth.currentSession;
    if (session != null) {
      return const HomePage(); // sudah login
    }
    return const HomePage(); // belum login (guest mode)
  }
}
