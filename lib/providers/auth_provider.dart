import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/index.dart';
import '../models/app_user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      ApiService.setToken(token);
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final appUser = await ApiService.register(email, password, name);
      _user = appUser;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final appUser = await ApiService.login(email, password);
      _user = appUser;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _user = null;
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> updateUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await ApiService.updateUser(user as AppUser);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
