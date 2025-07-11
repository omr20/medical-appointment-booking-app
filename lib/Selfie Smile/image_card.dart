import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const ImageCard({super.key, required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}