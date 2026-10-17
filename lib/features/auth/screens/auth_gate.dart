import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../catalog/screens/dashboard_screen.dart';
import 'login_screen.dart';

/// Root screen that picks between login and the dashboard based on the saved session.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return auth.hasSession ? const DashboardScreen() : const LoginScreen();
  }
}
