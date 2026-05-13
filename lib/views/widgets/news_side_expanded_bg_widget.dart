import 'package:flutter/material.dart';

class NewsSideExpandedBGWidget extends StatelessWidget {
  const NewsSideExpandedBGWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base color for expanded state
        
        Opacity(opacity: 0.9, child: Container(color: const Color.fromARGB(255, 26, 53, 126))),
        // Different background image for expanded state
        Opacity(
          opacity: 0.4,
          child: Image.asset(
            'assets/images/news.png', // Change this to your expanded background
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Darker gradient for expanded state
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 2,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
        ),
      ],
    );
  }
}
