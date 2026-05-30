import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'onboarding_sex.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  String? _errorMessage;

  final _supabase = Supabase.instance.client;

  bool _isValidBUEmail(String email) {
    return email.trim().toLowerCase().endsWith('@bu.edu') && email.length > 7;
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() => _errorMessage = null);

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }
    if (!_isValidBUEmail(email)) {
      setState(() => _errorMessage = 'Only BU email addresses are allowed (@bu.edu).');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        // Sign up → always go to onboarding
        await _supabase.auth.signUp(email: email, password: password);
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingSexPage()),
          );
        }
      } else {
        // Login → check if onboarding complete
        await _supabase.auth.signInWithPassword(email: email, password: password);
        if (!mounted) return;

        final userId = _supabase.auth.currentUser!.id;
        final profile = await _supabase
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
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              Color(0xFF2A1215),
              Color(0xFF161616),
              Color(0xFF111111),
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text('🍽️', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  const Text(
                    'BU Dining',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Marciano · Warren · West · Fenway',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 48),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignUp ? 'Create Account' : 'Welcome Back',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Email
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'BU Email (you@bu.edu)',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: const Color(0xFF333333),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: Colors.white38),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: const Color(0xFF333333),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.lock_outlined,
                                color: Colors.white38),
                          ),
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCC0000),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white12,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text(
                                  _isSignUp ? 'Create Account' : 'Log In',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),

                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () => setState(() {
                            _isSignUp = !_isSignUp;
                            _errorMessage = null;
                          }),
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Log in'
                                : 'New here? Create account',
                            style:
                                const TextStyle(color: Color(0xFFCC0000)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}