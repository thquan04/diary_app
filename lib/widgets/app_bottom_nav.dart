import 'package:flutter/material.dart';
import '../utils/index.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppStrings.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_bag),
          label: AppStrings.orders,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: AppStrings.profile,
        ),
      ],
    );
  }
}
