// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static const String _prefUserIdKey = 'auth_user_id';

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Check if a user is logged in (called on app startup)
  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_prefUserIdKey);

      if (userId != null) {
        final db = await DatabaseHelper.instance.database;
        final results = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [userId],
        );

        if (results.isNotEmpty) {
          _currentUser = UserModel.fromMap(results.first);
        } else {
          // Stored ID no longer exists in DB (e.g. database cleared)
          await prefs.remove(_prefUserIdKey);
          _currentUser = null;
        }
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Check if email already exists
      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.trim().toLowerCase()],
      );

      if (existing.isNotEmpty) {
        throw Exception('An account with this email already exists.');
      }

      final userId = const Uuid().v4();
      final newUser = UserModel(
        id: userId,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password, // In a real app, hash this!
        role: role,
      );

      await db.insert('users', newUser.toMap());

      // Log in automatically after registration
      _currentUser = newUser;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefUserIdKey, userId);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  /// Log in an existing user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final results = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email.trim().toLowerCase(), password],
      );

      if (results.isEmpty) {
        throw Exception('Invalid email or password.');
      }

      final loggedInUser = UserModel.fromMap(results.first);
      _currentUser = loggedInUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefUserIdKey, loggedInUser.id);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  /// Log out
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefUserIdKey);
    notifyListeners();
  }
}
