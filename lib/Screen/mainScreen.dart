import 'package:flutter/material.dart';
import 'package:videocall/Screen/profileScreen.dart';
import 'channelScreen.dart';
import 'homeScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    ChannelsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Главное"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Каналы"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_outlined), label: "Вы"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}