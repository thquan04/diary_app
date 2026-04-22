import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/index.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({Key? key}) : super(key: key);

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
