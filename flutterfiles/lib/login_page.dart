import 'package:flutter/material.dart';
import 'menu_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 23, 23),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome",
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height:40),
            // The email box
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255, 255),
                hintText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //goes to menu page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MenuPage()),
                  );
                },
                child: const Text("Login"), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}