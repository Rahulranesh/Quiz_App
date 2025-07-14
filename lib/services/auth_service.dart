import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/auth_models.dart';
import 'storage_service.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _usersKey = 'users';

  // Simple password hashing (in production, use proper hashing)
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Check if user exists
  static Future<bool> userExists(String email) async {
    final users = await _getUsers();
    return users.any((user) => user.email.toLowerCase() == email.toLowerCase());
  }

  // Register new user
  static Future<User?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Check if user already exists
      if (await userExists(email)) {
        throw Exception('User with this email already exists');
      }

      // Validate input
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw Exception('All fields are required');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Please enter a valid email address');
      }

      // Create new user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email.toLowerCase(),
        name: name.trim(),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        preferences: {
          'questionsPerQuiz': 5,
          'showExplanations': true,
          'language': 'en',
        },
      );

      // Save user with hashed password
      final users = await _getUsers();
      users.add(user);
      await _saveUsers(users);

      // Save hashed password separately
      final userPasswords = await _getUserPasswords();
      userPasswords[user.id] = _hashPassword(password);
      await _saveUserPasswords(userPasswords);

      // Set as current user
      await _setCurrentUser(user);

      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Login user
  static Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      // Find user
      final users = await _getUsers();
      final user = users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      // Verify password
      final userPasswords = await _getUserPasswords();
      final hashedPassword = userPasswords[user.id];
      
      if (hashedPassword != _hashPassword(password)) {
        throw Exception('Invalid password');
      }

      // Update last login
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      final updatedUsers = users.map((u) => u.id == user.id ? updatedUser : u).toList();
      await _saveUsers(updatedUsers);

      // Set as current user
      await _setCurrentUser(updatedUser);

      return updatedUser;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Logout user
  static Future<void> logout() async {
    await StorageService.removeData(_userKey);
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    final userData = await StorageService.getData(_userKey);
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  // Update user preferences
  static Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    final user = await getCurrentUser();
    if (user != null) {
      final updatedUser = user.copyWith(preferences: preferences);
      await _setCurrentUser(updatedUser);
      
      // Update in users list
      final users = await _getUsers();
      final updatedUsers = users.map((u) => u.id == user.id ? updatedUser : u).toList();
      await _saveUsers(updatedUsers);
    }
  }

  // Get user by ID
  static Future<User?> getUserById(String userId) async {
    final users = await _getUsers();
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Helper methods
  static Future<List<User>> _getUsers() async {
    final usersData = await StorageService.getData(_usersKey);
    if (usersData != null) {
      final List<dynamic> usersList = usersData;
      return usersList.map((userData) => User.fromJson(userData)).toList();
    }
    return [];
  }

  static Future<void> _saveUsers(List<User> users) async {
    final usersData = users.map((user) => user.toJson()).toList();
    await StorageService.saveData(_usersKey, usersData);
  }

  static Future<Map<String, String>> _getUserPasswords() async {
    final passwordsData = await StorageService.getData('user_passwords');
    if (passwordsData != null) {
      final Map<String, dynamic> passwords = passwordsData;
      return passwords.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }

  static Future<void> _saveUserPasswords(Map<String, String> passwords) async {
    await StorageService.saveData('user_passwords', passwords);
  }

  static Future<void> _setCurrentUser(User user) async {
    await StorageService.saveData(_userKey, user.toJson());
  }
} 