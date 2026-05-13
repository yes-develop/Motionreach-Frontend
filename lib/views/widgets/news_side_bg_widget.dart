import 'package:flutter/material.dart';

class NewsSideBGWidget extends StatelessWidget {
  const NewsSideBGWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(opacity: 0.9, child: Container(color: const Color.fromARGB(255, 26, 53, 126))),
        Opacity(
          opacity: 0.3,
          child: Image.asset(
            'assets/images/newsSide.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
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

