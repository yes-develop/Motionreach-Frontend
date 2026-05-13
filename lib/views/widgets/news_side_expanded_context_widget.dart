import 'package:MotionReach/utils/lorem_ipsum.dart';
import 'package:flutter/material.dart';

class NewsSideExpandedContextWidget extends StatelessWidget {
  const NewsSideExpandedContextWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 30.0,
        right: 10.0,
        bottom: 40.0,
        top: 50.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset(
              'assets/images/breakingNews.png',
              fit: BoxFit.contain,
              width: 170,
            ),
          ),
          SizedBox(height: 5,),
          Expanded(
            child: Row(
              children: [
                // Left side - Image and News Heading
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Main Image
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            'assets/images/news.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // News Heading and QR Code section
                      Container(
                        height: 120,
                        padding: const EdgeInsets.all(15.0),
                        // color: Colors.black,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                'News Heading should be here lorem ipsum massa',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/QR.png',
                                  width: 60,
                                  height: 60,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Read Full Story',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side - Sub News Headings
                SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Container(
                    // color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSubNewsSection('Sub News Heading'),
                        const SizedBox(height: 15),
                        _buildSubNewsSection('Sub News Heading'),
                        const SizedBox(height: 15),
                        _buildSubNewsSection('Sub News Heading'),
                        const SizedBox(height: 15),
                        _buildSubNewsSection('Sub News Heading'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubNewsSection(String heading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          LoremIpsum.generateWords(30),
          style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.0),
        ),
      ],
    );
  }
}
