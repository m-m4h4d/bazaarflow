import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String _name = 'Guest';
  String _email = '';
  bool _isGuest = true;

  String get name => _name;
  String get email => _email;
  bool get isGuest => _isGuest;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _isGuest = prefs.getBool('is_guest') ?? true;
    _name = prefs.getString('user_name') ?? 'Guest';
    _email = prefs.getString('user_email') ?? '';
    notifyListeners();
  }

  Future<void> loginAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    _isGuest = true;
    _name = 'Guest';
    _email = '';
    await prefs.setBool('is_guest', true);
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    notifyListeners();
  }

  Future<void> login(String email) async {
    final prefs = await SharedPreferences.getInstance();
    _email = email;
    _name = prefs.getString('user_name') ?? email.split('@')[0];
    _isGuest = false;
    await prefs.setString('user_email', _email);
    await prefs.setBool('is_guest', false);
    notifyListeners();
  }

  Future<void> signUp(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    _name = name;
    _email = email;
    _isGuest = false;
    await prefs.setString('user_name', _name);
    await prefs.setString('user_email', _email);
    await prefs.setBool('is_guest', false);
    notifyListeners();
  }

  Future<void> logout() async {
    await loginAsGuest();
  }

  String get initials {
    if (_isGuest || _name.isEmpty) {
      if (_email.isNotEmpty) return _email[0].toUpperCase();
      return 'G';
    }
    List<String> parts = _name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
    } else {
      return _name[0].toUpperCase();
    }
  }

  Color get avatarColor {
    final str = _email.isNotEmpty ? _email : _name;
    if (str.isEmpty || _isGuest) return Colors.grey;
    final hash = str.hashCode;
    return Colors.primaries[hash.abs() % Colors.primaries.length];
  }
}
