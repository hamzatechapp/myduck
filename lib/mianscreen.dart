import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myduck/customs/navigatorbar.dart';
import 'package:myduck/homepage.dart';

import 'package:myduck/uploadpage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // ✅ Sirf 2 screens ki list (Home aur Settings)
  final List<Widget> _screens = [
    const HomePage(),      // Index 0
    const UploadScreen(),  // Index 1
  ];

  void _onNavTap(int index) {
    if (index == 2) {
      // ✅ Upload button (Duck) - Direct navigate karo
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UploadScreen()),
      );
    } else {
      // Home ya Settings ke liye index change karo
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return    Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );

  }
}
