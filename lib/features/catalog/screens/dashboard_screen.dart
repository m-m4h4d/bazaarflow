import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../cart/screens/cart_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Widget> _screens = const [
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final currentIndex = navProvider.currentIndex;

    if (kIsWeb) {
      final themeProvider = context.watch<ThemeProvider>();
      final isSmallScreen = MediaQuery.of(context).size.width < 800;

      return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo.png', height: 32),
              if (!isSmallScreen) ...[
                const SizedBox(width: 8),
                const Text('BazaarFlow', style: TextStyle(fontWeight: FontWeight.bold)),
              ]
            ],
          ),
          actions: isSmallScreen
              ? null
              : [
                  TextButton.icon(
                    onPressed: () => navProvider.setTab(0),
                    icon: Icon(Icons.home_outlined, color: currentIndex == 0 ? Theme.of(context).colorScheme.secondary : Colors.white),
                    label: Text('Home', style: TextStyle(color: currentIndex == 0 ? Theme.of(context).colorScheme.secondary : Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () => navProvider.setTab(1),
                    icon: Icon(Icons.shopping_cart_outlined, color: currentIndex == 1 ? Theme.of(context).colorScheme.secondary : Colors.white),
                    label: Text('Cart', style: TextStyle(color: currentIndex == 1 ? Theme.of(context).colorScheme.secondary : Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () => navProvider.setTab(2),
                    icon: Icon(Icons.person_outline, color: currentIndex == 2 ? Theme.of(context).colorScheme.secondary : Colors.white),
                    label: Text('Profile', style: TextStyle(color: currentIndex == 2 ? Theme.of(context).colorScheme.secondary : Colors.white)),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                    onPressed: () {
                      themeProvider.toggleTheme(!themeProvider.isDarkMode);
                    },
                  ),
                  const SizedBox(width: 16),
                ],
        ),
        endDrawer: isSmallScreen
            ? Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'BazaarFlow',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: const Text('Home'),
                      selected: currentIndex == 0,
                      onTap: () {
                        navProvider.setTab(0);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_cart_outlined),
                      title: const Text('Cart'),
                      selected: currentIndex == 1,
                      onTap: () {
                        navProvider.setTab(1);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Profile'),
                      selected: currentIndex == 2,
                      onTap: () {
                        navProvider.setTab(2);
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      value: themeProvider.isDarkMode,
                      onChanged: (val) {
                        themeProvider.toggleTheme(val);
                      },
                    ),
                  ],
                ),
              )
            : null,
        body: _screens[currentIndex],
      );
    }

    return Scaffold(
      body: _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => navProvider.setTab(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
