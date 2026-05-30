import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'onboarding_sex.dart';
import 'package:flutter/gestures.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cwficgymseewxmadzwfu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3ZmljZ3ltc2Vld3htYWR6d2Z1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ5MTg3MTEsImV4cCI6MjA5MDQ5NDcxMX0.fNoyk5-BH_A-jyb1hTbKXCLDF80whdj9k_vddqhnYTE',
  );

  runApp(const BUDiningApp());
}

class BUDiningApp extends StatelessWidget {
  const BUDiningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BU Dining Tracker',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCC0000),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirect();
    });
  }

  Future<void> _redirect() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
      return;
    }

    final userId = session.user.id;
    final profile = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (!mounted) return;

    final onboardingComplete = profile?['onboarding_complete'] ?? false;

    if (onboardingComplete) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingSexPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFCC0000)),
      ),
    );
  }
}