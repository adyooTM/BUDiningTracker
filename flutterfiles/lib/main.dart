import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cwficgymseewxmadzwfu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3ZmljZ3ltc2Vld3htYWR6d2Z1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5MTg3MTEsImV4cCI6MjA5MDQ5NDcxMX0.fNoyk5-BH_A-jyb1hTbKXCLDF80whdj9k_vddqhnYTE', // paste your regenerated key here
  );

  runApp(const BUDiningApp());
}

class BUDiningApp extends StatelessWidget {
  const BUDiningApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'BU Dining Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCC0000),
        ),
        useMaterial3: true,
      ),
      home: session != null ? const HomePage() : const LoginPage(),
    );
  }
}