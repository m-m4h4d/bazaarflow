import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/web_footer.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb ? null : AppBar(title: const Text('Profile')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          color: Theme.of(context).colorScheme.primary,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: authProvider.avatarColor,
                                child: Text(
                                  authProvider.initials,
                                  style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                authProvider.name,
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              if (!authProvider.isGuest && authProvider.email.isNotEmpty)
                                Text(
                                  authProvider.email,
                                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                              if (authProvider.isGuest)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Theme.of(context).colorScheme.primary,
                                    ),
                                    child: const Text('Login / Sign Up'),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return SwitchListTile(
                          title: const Text('Dark Mode'),
                          secondary: const Icon(Icons.dark_mode_outlined),
                          value: themeProvider.isDarkMode,
                          onChanged: (val) {
                            themeProvider.toggleTheme(val);
                          },
                        );
                      },
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.isGuest) return const SizedBox.shrink();
                        return ListTile(
                          leading: const Icon(Icons.exit_to_app),
                          title: const Text('Logout'),
                          onTap: () {
                            context.read<AuthProvider>().logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (Route<dynamic> route) => false,
                            );
                          },
                        );
                      },
                    ),
                    const Spacer(),
                    if (kIsWeb) const WebFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
