import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/pages/home_pages.dart';
import 'config.dart';

final ValueNotifier<String> globalUsername = ValueNotifier<String>('');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? startupError;

  try {
    await Supabase.initialize(
      url: Config.supabaseUrl,
      anonKey: Config.supabaseAnonKey,
    );
  } catch (e) {
    startupError = e.toString();
    debugPrint('Supabase init error: $e');
  }

  runApp(MyApp(startupError: startupError));
}

class MyApp extends StatelessWidget {
  final String? startupError;

  const MyApp({super.key, this.startupError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studlent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: startupError == null
          ? const HomePage()
          : StartupErrorPage(message: startupError!),
    );
  }
}

class StartupErrorPage extends StatelessWidget {
  final String message;

  const StartupErrorPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Aplikasi gagal mulai:\n\n$message',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
