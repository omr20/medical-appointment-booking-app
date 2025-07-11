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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
              _pageController.jumpToPage(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'HOME',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_outlined),
                activeIcon: Icon(Icons.chat),
                label: 'CHAT',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'DOCTOR',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
          ),
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
                icon: const Icon(Icons.arrow_back, color: Colors.blue),
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
                    'assets/images/Grey.png',
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
              title: 'Tartar Cleaning',
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