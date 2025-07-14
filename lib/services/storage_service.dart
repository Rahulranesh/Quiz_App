import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_models.dart';

class StorageService {
  static const String _quizSessionsKey = 'quiz_sessions';
  static const String _userProgressKey = 'user_progress';
  static const String _settingsKey = 'settings';

  // Generic data storage methods
  static Future<void> saveData(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data is String) {
      await prefs.setString(key, data);
    } else if (data is int) {
      await prefs.setInt(key, data);
    } else if (data is double) {
      await prefs.setDouble(key, data);
    } else if (data is bool) {
      await prefs.setBool(key, data);
    } else if (data is List) {
      await prefs.setString(key, jsonEncode(data));
    } else if (data is Map) {
      await prefs.setString(key, jsonEncode(data));
    }
  }

  static Future<dynamic> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.get(key);
    
    if (value == null) return null;
    
    // Try to decode JSON if it's a string
    if (value is String) {
      try {
        return jsonDecode(value);
      } catch (e) {
        return value;
      }
    }
    
    return value;
  }

  static Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // User-specific data methods
  static String _getUserKey(String userId, String key) {
    return 'user_${userId}_$key';
  }

  static Future<void> saveUserData(String userId, String key, dynamic data) async {
    final userKey = _getUserKey(userId, key);
    await saveData(userKey, data);
  }

  static Future<dynamic> getUserData(String userId, String key) async {
    final userKey = _getUserKey(userId, key);
    return await getData(userKey);
  }

  static Future<void> removeUserData(String userId, String key) async {
    final userKey = _getUserKey(userId, key);
    await removeData(userKey);
  }

  // Quiz Sessions
  static Future<void> saveQuizSession(QuizSession session, {String? userId}) async {
    if (userId != null) {
      final sessions = await getUserQuizSessions(userId);
      sessions.add(session);
      await saveUserData(userId, _quizSessionsKey, sessions.map((s) => s.toJson()).toList());
    } else {
      final sessions = await getQuizSessions();
      sessions.add(session);
      final sessionsJson = sessions.map((s) => s.toJson()).toList();
      await saveData(_quizSessionsKey, sessionsJson);
    }
  }

  static Future<List<QuizSession>> getQuizSessions({String? userId}) async {
    if (userId != null) {
      return await getUserQuizSessions(userId);
    }
    
    final sessionsString = await getData(_quizSessionsKey);
    if (sessionsString == null) return [];
    
    final sessionsJson = sessionsString as List;
    return sessionsJson.map((json) => QuizSession.fromJson(json)).toList();
  }

  static Future<List<QuizSession>> getUserQuizSessions(String userId) async {
    final sessionsString = await getUserData(userId, _quizSessionsKey);
    if (sessionsString == null) return [];
    
    final sessionsJson = sessionsString as List;
    return sessionsJson.map((json) => QuizSession.fromJson(json)).toList();
  }

  static Future<void> clearQuizSessions({String? userId}) async {
    if (userId != null) {
      await removeUserData(userId, _quizSessionsKey);
    } else {
      await removeData(_quizSessionsKey);
    }
  }

  // User Progress
  static Future<void> saveUserProgress(UserProgress progress, {String? userId}) async {
    if (userId != null) {
      await saveUserData(userId, _userProgressKey, progress.toJson());
    } else {
      await saveData(_userProgressKey, progress.toJson());
    }
  }

  static Future<UserProgress> getUserProgress({String? userId}) async {
    if (userId != null) {
      return await getUserSpecificProgress(userId);
    }
    
    final progressString = await getData(_userProgressKey);
    if (progressString == null) {
      return UserProgress(
        totalQuizzesTaken: 0,
        totalQuestionsAnswered: 0,
        totalCorrectAnswers: 0,
        averageScore: 0.0,
        completedCategories: [],
        categoryScores: {},
      );
    }
    
    final progressJson = progressString;
    return UserProgress.fromJson(progressJson);
  }

  static Future<UserProgress> getUserSpecificProgress(String userId) async {
    final progressString = await getUserData(userId, _userProgressKey);
    if (progressString == null) {
      return UserProgress(
        totalQuizzesTaken: 0,
        totalQuestionsAnswered: 0,
        totalCorrectAnswers: 0,
        averageScore: 0.0,
        completedCategories: [],
        categoryScores: {},
      );
    }
    
    final progressJson = progressString;
    return UserProgress.fromJson(progressJson);
  }

  static Future<void> updateUserProgress(QuizSession session, {String? userId}) async {
    final progress = await getUserProgress(userId: userId);
    final questions = session.questions;
    final userAnswers = session.userAnswers;
    
    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }
    
    // Update category scores
    final categoryScores = Map<String, int>.from(progress.categoryScores);
    for (Question question in questions) {
      final category = question.category;
      categoryScores[category] = (categoryScores[category] ?? 0) + 1;
    }
    
    // Calculate new average score
    final totalSessions = progress.totalQuizzesTaken + 1;
    final totalScore = (progress.averageScore * progress.totalQuizzesTaken) + session.score;
    final newAverageScore = totalScore / totalSessions;
    
    // Update completed categories
    final completedCategories = List<String>.from(progress.completedCategories);
    for (Question question in questions) {
      if (!completedCategories.contains(question.category)) {
        completedCategories.add(question.category);
      }
    }
    
    final updatedProgress = UserProgress(
      totalQuizzesTaken: totalSessions,
      totalQuestionsAnswered: progress.totalQuestionsAnswered + questions.length,
      totalCorrectAnswers: progress.totalCorrectAnswers + correctAnswers,
      averageScore: newAverageScore,
      completedCategories: completedCategories,
      categoryScores: categoryScores,
    );
    
    await saveUserProgress(updatedProgress, userId: userId);
  }

  // Settings
  static Future<void> saveSettings(Map<String, dynamic> settings, {String? userId}) async {
    if (userId != null) {
      await saveUserData(userId, _settingsKey, settings);
    } else {
      await saveData(_settingsKey, settings);
    }
  }

  static Future<Map<String, dynamic>> getSettings({String? userId}) async {
    if (userId != null) {
      return await getUserSettings(userId);
    }
    
    final settingsString = await getData(_settingsKey);
    if (settingsString == null) {
      return {
        'questionsPerQuiz': 5,
        'showExplanations': true,
        'darkMode': false,
        'soundEnabled': true,
      };
    }
    
    return Map<String, dynamic>.from(settingsString);
  }

  static Future<Map<String, dynamic>> getUserSettings(String userId) async {
    final settingsString = await getUserData(userId, _settingsKey);
    if (settingsString == null) {
      return {
        'questionsPerQuiz': 5,
        'showExplanations': true,
        'darkMode': false,
        'soundEnabled': true,
      };
    }
    
    return Map<String, dynamic>.from(settingsString);
  }

  static Future<void> updateSetting(String key, dynamic value, {String? userId}) async {
    final settings = await getSettings(userId: userId);
    settings[key] = value;
    await saveSettings(settings, userId: userId);
  }

  // Clear all data
  static Future<void> clearAllData({String? userId}) async {
    if (userId != null) {
      // Clear only user-specific data
      await removeUserData(userId, _quizSessionsKey);
      await removeUserData(userId, _userProgressKey);
      await removeUserData(userId, _settingsKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }

  // Debug method to get all stored data
  static Future<Map<String, dynamic>> getAllStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, dynamic> allData = {};
    
    for (String key in keys) {
      final value = prefs.get(key);
      if (value is String) {
        try {
          // Try to decode JSON
          allData[key] = jsonDecode(value);
        } catch (e) {
          // If not JSON, store as string
          allData[key] = value;
        }
      } else {
        allData[key] = value;
      }
    }
    
    return allData;
  }

  // Debug method to get formatted data for display
  static Future<Map<String, String>> getFormattedStoredData() async {
    final allData = await getAllStoredData();
    final Map<String, String> formattedData = {};
    
    for (String key in allData.keys) {
      final value = allData[key];
      if (value is Map || value is List) {
        formattedData[key] = const JsonEncoder.withIndent('  ').convert(value);
      } else {
        formattedData[key] = value.toString();
      }
    }
    
    return formattedData;
  }
} 