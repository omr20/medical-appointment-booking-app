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
      // Remove default appBar and use gradient custom one
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00B4DB).withOpacity(0.4), // سماوي شفاف
              const Color(0xFF8E2DE2).withOpacity(0.4), // بنفسجي شفاف
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Custom AppBar
            Container(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
              width: double.infinity,
              child: const Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You can communicate with the clinic via the following applications:',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _openUrl('https://wa.me/201221257661'),
                      child: contactTile('assets/images/App.png', 'WhatsApp'),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _openUrl('https://www.instagram.com/selfiesmile57/'),
                      child: contactTile('assets/images/insta.png', 'Instagram'),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _openUrl('tel:+201221257661'),
                      child: contactTile('assets/images/phone.png', 'Phone'),
                    ),
                  ],
                ),
              ),
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
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00B4DB).withOpacity(0.3),
            const Color(0xFF8E2DE2).withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(iconPath, width: 40, height: 40),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
