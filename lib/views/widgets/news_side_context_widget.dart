import 'package:MotionReach/utils/lorem_ipsum.dart';
import 'package:flutter/material.dart';

class NewsSideContextWidget extends StatelessWidget {
  const NewsSideContextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 75.0),
                child: Text(
                  '฿322 Million',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
              Text(
                LoremIpsum.generateWords(15),
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/QR.png', width: 80, height: 80),
              SizedBox(height: 8),
              Text(
                'Read Full Story',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
