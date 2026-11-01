import 'package:flutter/material.dart';
import 'category_screen.dart';
import 'profile_screens.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 1; // start on Search/Category like the screenshots

  final _tabs = const [
    CategoryScreen(),
    CategoryScreen(),
    _Placeholder('Orders'),
    _Placeholder('Wallet'),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder(this.title);
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('$title coming soon', style: const TextStyle(fontSize: 18)));
}
