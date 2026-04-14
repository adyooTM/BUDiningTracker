import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});
  final List<String> diningHalls = const [
    'Warren',
    'West',
    'Marciano',
    'Fenway',
    'Granby Commons',
  ];

  @override
  Widget build(BuildContext context) {
    final double boxHeight = MediaQuery.of(context).size.height / 3;

    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: const Text("BU Dining Halls"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20), // Extra space at the bottom
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            // Horizontal margin makes it 'almost' screen width
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            height: boxHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                print("Tapped on ${diningHalls[index]}");
              },
              borderRadius: BorderRadius.circular(20),
              child: Center(
                child: Text(
                  diningHalls[index], // Pulls the name from the list above
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 28, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}