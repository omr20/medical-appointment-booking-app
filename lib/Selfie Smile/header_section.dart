import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Selfie', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text('smile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text('DENTAL CLINIC', style: TextStyle(fontSize: 14, letterSpacing: 2)),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}