import 'package:flutter/material.dart';
import 'login_page.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp( 
      debugShowCheckedModeBanner: false, // Optional: hides the slow-mode banner
      home: LoginPage(), // 2. Set this as the starting screen
    );
  }
}