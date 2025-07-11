import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatOptionsPage extends StatelessWidget {
  const ChatOptionsPage({super.key});

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You can communicate with the clinic via the following applications:',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _openUrl('https://wa.me/201066471507'),
              child: contactTile('assets/images/wahts.png', 'WhatsApp'),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _openUrl('https://www.instagram.com/omr17_/'),
              child: contactTile('assets/images/insta.png', 'Instagram'),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _openUrl('tel:+201066471507'),
              child: contactTile('assets/images/phone.png', 'Phone'),
            ),
          ],
        ),
      ),
    );
  }

  Widget contactTile(String iconPath, String label) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(iconPath, width: 40, height: 40),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}