import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:slide_to_act/slide_to_act.dart';
import 'package:untitled1/Selfie%20Smile/sign_in_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'admin_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final List<String> clinicImages = [
    'assets/images/asnan.jpg',
    'assets/images/drimage.jpg',
    'assets/images/holoud.png',
    'assets/images/drimage.jpg',
    'assets/images/asnan.jpg',
  ];

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // إخفاء زر الرجوع التلقائي
        actions: [
          if (user != null) // يظهر زر الخروج فقط إذا كان المستخدم مسجل الدخول
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
              tooltip: 'تسجيل الخروج',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section: Auto-scrolling Clinic Images
            SizedBox(
              height: screenHeight * 0.3,
              child: carousel.CarouselSlider(
                options: carousel.CarouselOptions(
                  height: double.infinity,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.4,
                ),
                items: clinicImages.map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Container(
                            width: screenWidth * 0.4,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(imagePath),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),

            // Middle Section: Map
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Find Us Here',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    GestureDetector(
                      onTap: () async {
                        const String googleMapsUrl =
                            'https://maps.app.goo.gl/1G5G7YUWFMVtC6ek8?g_st=com.google.maps.preview.copy';
                        if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
                          await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
                        } else {
                          debugPrint('Could not launch Google Maps');
                        }
                      },
                      child: Container(
                        width: screenWidth * 0.8,
                        height: screenHeight * 0.2,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/images/img.png'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    const Text(
                      'Tap the map to get directions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Slide to Enter Button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.1,
                vertical: screenHeight * 0.02,
              ),
              child: SlideAction(
                text: 'Slide to Enter App',
                textStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                outerColor: Colors.grey[200],
                innerColor: Colors.blue,
                sliderButtonIcon: const Icon(Icons.arrow_forward, color: Colors.white),
                onSubmit: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
            ),

            // Admin Button (Visible only to admin)
            if (user != null && user.email == AdminPage.adminEmail)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1,
                  vertical: screenHeight * 0.01,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth * 0.8, screenHeight * 0.06),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Admin Panel',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}