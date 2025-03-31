import 'package:flutter/material.dart';
import 'package:videocall/supabaseChannel/ChannelScreen.dart';

class ScreenMain extends StatefulWidget {
  const ScreenMain({super.key});

  @override
  State<ScreenMain> createState() => _ScreenMainState();
}

class _ScreenMainState extends State<ScreenMain> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    Center(child: Text("Главная", style: TextStyle(fontSize: 24),),),
    ChatScreen(),
    Center(child: Text("Вы", style: TextStyle(fontSize: 24),),),
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Главное"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Каналы"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Вы"),
        ],
      ),
    );
  }
}
