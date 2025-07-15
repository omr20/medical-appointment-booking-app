import 'package:flutter/material.dart';
import 'chat_options_page.dart';
import 'doctors_page.dart';
import 'service_tile.dart';
import 'landing_page.dart';
import 'service_details_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  String? _selectedService; // Track the selected service

  final List<Widget> _pages = [
    _HomeContent(),
    const ChatOptionsPage(),
    const DoctorsPage(), // Pass service via state management or navigation
  ];

  void _setSelectedService(String service) {
    setState(() {
      _selectedService = service;
    });
    _pageController.jumpToPage(2); // Navigate to DoctorsPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages.map((page) {
          if (page is DoctorsPage) {
            return DoctorsPage(service: _selectedService);
          }
          return page;
        }).toList(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00B4DB).withOpacity(0.4),
              const Color(0xFF8E2DE2).withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (index) {
            final icons = [
              Icons.home,
              Icons.chat,
              Icons.person,
            ];

            final labels = [
              "HOME",
              "CHAT",
              "DOCTOR",
            ];

            final isSelected = _currentIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = index;
                });
                _pageController.jumpToPage(index);
              },
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: isSelected ? 1.2 : 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icons[index],
                            color: isSelected ? Colors.black : Colors.black54,
                            size: 26,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            labels[index],
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.black54,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final _homeScreenState = context.findAncestorStateOfType<_HomeScreenState>()!;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LandingPage()),
                  );
                },
              ),
            ),
            Center(
              child: Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.9,
                constraints: const BoxConstraints(
                  maxWidth: 200,
                  maxHeight: 100,
                  minWidth: 120,
                  minHeight: 100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            ServiceTile(
              title: 'Dental Implants',
              imagePath: 'assets/images/zeraa.png',
              onTap: () => _homeScreenState._setSelectedService('Dental Implants'),
            ),
            ServiceTile(
              title: 'Dental Fillings',
              imagePath: 'assets/images/ashoo.png',
              onTap: () => _homeScreenState._setSelectedService('Dental Fillings'),
            ),
            ServiceTile(
              title: 'Dental Braces',
              imagePath: 'assets/images/takwem.png',
              onTap: () => _homeScreenState._setSelectedService('Dental Braces'),
            ),
            ServiceTile(
              title: 'Teeth Whitening',
              imagePath: 'assets/images/tapyed.jpg',
              onTap: () => _homeScreenState._setSelectedService('Teeth Whitening'),
            ),
            ServiceTile(
              title: 'scaling and Polishing',
              imagePath: 'assets/images/er.png',
              onTap: () => _homeScreenState._setSelectedService('Tartar Cleaning'),
            ),
            ServiceTile(
              title: 'Fixed and Removable Prosthetics',
              imagePath: 'assets/images/tarkeb.png',
              onTap: () => _homeScreenState._setSelectedService('Fixed and Removable Prosthetics'),
            ),
            ServiceTile(
              title: 'Pediatric Dentistry',
              imagePath: 'assets/images/atfal.png',
              onTap: () => _homeScreenState._setSelectedService('Pediatric Dentistry'),
            ),
            ServiceTile(
              title: 'Hollywood Smile',
              imagePath: 'assets/images/holoud.png',
              onTap: () => _homeScreenState._setSelectedService('Hollywood Smile'),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const ServiceTile({
    required this.title,
    required this.imagePath,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00B4DB).withOpacity(0.4), // سماوي شفاف
              const Color(0xFF8E2DE2).withOpacity(0.4), // بنفسجي شفاف
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
