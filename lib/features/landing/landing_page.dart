import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'InCampus',
          style: TextStyle(
            color: const Color(0xFF4285F4),
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 20 : 24,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text('Login', style: TextStyle(color: const Color(0xFF8E24AA), fontSize: isSmallScreen ? 13 : 15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 16, vertical: isSmallScreen ? 8 : 12),
              ),
              onPressed: () => context.go('/signup'),
              child: const Text('Sign Up'),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 20, vertical: isSmallScreen ? 16 : 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Headline and buttons
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Never Miss Campus Updates Again.',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 22 : 30,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4285F4),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        Text(
                          'All official announcements, club updates, and campus events in one organized app for MFU students.',
                          style: TextStyle(fontSize: isSmallScreen ? 13 : 16, color: Colors.black87),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 24),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4285F4),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 22, vertical: isSmallScreen ? 8 : 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => context.go('/login'),
                                child: Text('Get Started', style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
                              ),
                              SizedBox(width: isSmallScreen ? 8 : 12),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF4285F4),
                                  side: const BorderSide(color: Color(0xFF4285F4)),
                                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 22, vertical: isSmallScreen ? 8 : 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {},
                                child: Text('View Demo', style: TextStyle(fontSize: isSmallScreen ? 14 : 16)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 10 : 20),
                  // Right: Announcement Feed Card Illustration
                  Flexible(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      height: isSmallScreen ? 110 : 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Announcement Feed', style: TextStyle(fontSize: isSmallScreen ? 14 : 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                            SizedBox(height: 6),
                            Text('Event Cards', style: TextStyle(fontSize: isSmallScreen ? 10 : 13, color: Colors.black45)),
                            Text('Clean Organized Layout', style: TextStyle(fontSize: isSmallScreen ? 10 : 13, color: Colors.black45)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Why Students Miss Important Updates
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const Text(
                    'Why Students Miss Important Updates',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _infoCard('Scattered Information', 'Students check Line, Facebook, Instagram, and emails for updates.'),
                        _infoCard('Missed Announcements', 'Important updates get buried or missed.'),
                        _infoCard('Low Event Awareness', 'Students don’t know what’s happening on campus.'),
                        _infoCard('Information Overload', 'Too many unrelated posts.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // One Platform. All Campus Information.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
              child: Column(
                children: [
                  const Text(
                    'One Platform. All Campus Information.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8E24AA),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'InCampus centralizes official campus announcements and events into a structured, reliable feed designed specifically for MFU students.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _featurePill('Campus-only feed', Icons.feed, color: Color(0xFFE1BEE7)),
                        const SizedBox(width: 16),
                        _featurePill('Organized event listings', Icons.event, color: Color(0xFFE1BEE7)),
                        const SizedBox(width: 16),
                        _featurePill('Subscription-based filtering', Icons.filter_alt, color: Color(0xFFE1BEE7)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Core Features
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const Text(
                    'Core Features',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _coreFeatureCard(
                          'Campus Announcement Feed',
                          'Displays official MFU and club announcements in a structured, chronological format so students never miss important updates.',
                          Icons.campaign,
                        ),
                        _coreFeatureCard(
                          'Event Listing',
                          'Shows upcoming campus events with date, time, and location, helping students plan and participate.',
                          Icons.event,
                        ),
                        _coreFeatureCard(
                          'Group Subscription',
                          'Students can follow faculties or clubs to filter information based on their interests.',
                          Icons.group,
                        ),
                        _coreFeatureCard(
                          'Student Profile',
                          'Basic student profile (name, faculty, year) to personalize content without complex social features.',
                          Icons.person,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _infoCard(String title, String desc) {
  final screenWidth = WidgetsBinding.instance.window.physicalSize.width / WidgetsBinding.instance.window.devicePixelRatio;
  final isSmallScreen = screenWidth < 400;
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4.0 : 8.0),
    child: SizedBox(
      width: isSmallScreen ? 140 : 180,
      child: Card(
        elevation: 0,
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 14)),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 10.0 : 14.0),
          child: Column(
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 13 : 15, color: Colors.black54)),
              SizedBox(height: isSmallScreen ? 4 : 6),
              Text(desc, style: TextStyle(fontSize: isSmallScreen ? 10 : 12, color: Colors.black45)),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _featurePill(String label, IconData icon, {Color color = Colors.purple}) {
  final screenWidth = WidgetsBinding.instance.window.physicalSize.width / WidgetsBinding.instance.window.devicePixelRatio;
  final isSmallScreen = screenWidth < 400;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 20, vertical: isSmallScreen ? 8 : 12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 14),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.12),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.purple, size: isSmallScreen ? 18 : 22),
        SizedBox(width: isSmallScreen ? 6 : 10),
        Text(label, style: TextStyle(fontSize: isSmallScreen ? 12 : 15, color: Colors.black54, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

Widget _coreFeatureCard(String title, String desc, IconData icon) {
  final screenWidth = WidgetsBinding.instance.window.physicalSize.width / WidgetsBinding.instance.window.devicePixelRatio;
  final isSmallScreen = screenWidth < 400;
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 4.0 : 8.0),
    child: SizedBox(
      width: isSmallScreen ? 120 : 160,
      child: Card(
        elevation: 0,
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 14)),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF8E24AA), size: isSmallScreen ? 20 : 28),
              SizedBox(height: isSmallScreen ? 6 : 10),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 11 : 13, color: Colors.black54)),
              SizedBox(height: isSmallScreen ? 4 : 6),
              Text(desc, style: TextStyle(fontSize: isSmallScreen ? 8 : 10, color: Colors.black45)),
            ],
          ),
        ),
      ),
    ),
  );
}
