import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../controllers/enhanced_quiz_controller.dart';
import '../controllers/auth_controller.dart';

class SettingsController extends GetxController {
  final RxBool isDarkMode = false.obs;
  final RxBool showExplanations = true.obs;
  final RxBool soundEnabled = true.obs;
  final RxInt questionsPerQuiz = 5.obs; // Default to 5 questions
  final RxBool isLoading = false.obs;
  late AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    
    // Listen for authentication changes to refresh settings
    ever(_authController.authState, (authState) {
      if (authState.isAuthenticated) {
        loadSettings();
      }
    });
    
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      final userId = _authController.currentUser?.id;
      final settings = await StorageService.getSettings(userId: userId);
      isDarkMode.value = settings['darkMode'] ?? false;
      showExplanations.value = settings['showExplanations'] ?? true;
      soundEnabled.value = settings['soundEnabled'] ?? true;
      questionsPerQuiz.value = settings['questionsPerQuiz'] ?? 5;
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    final userId = _authController.currentUser?.id;
    await StorageService.updateSetting('darkMode', isDarkMode.value, userId: userId);
    _updateTheme();
  }

  Future<void> toggleShowExplanations() async {
    showExplanations.value = !showExplanations.value;
    final userId = _authController.currentUser?.id;
    await StorageService.updateSetting('showExplanations', showExplanations.value, userId: userId);
  }

  Future<void> toggleSound() async {
    soundEnabled.value = !soundEnabled.value;
    final userId = _authController.currentUser?.id;
    await StorageService.updateSetting('soundEnabled', soundEnabled.value, userId: userId);
  }

  Future<void> updateQuestionsPerQuiz(int count) async {
    questionsPerQuiz.value = count;
    final userId = _authController.currentUser?.id;
    await StorageService.updateSetting('questionsPerQuiz', count, userId: userId);
    
    // Immediately update the quiz controller
    try {
      final quizController = Get.find<EnhancedQuizController>();
      quizController.questionsPerQuiz.value = count;
      quizController.loadSettings();
    } catch (e) {
      print('Quiz controller not found: $e');
    }
  }

  void _updateTheme() {
    if (isDarkMode.value) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
  }

  List<int> getQuestionsPerQuizOptions() {
    return [5, 10, 15, 20, 25];
  }

  String getQuestionsPerQuizText() {
    return '${questionsPerQuiz.value} questions per quiz';
  }

  Map<String, dynamic> getCurrentSettings() {
    return {
      'darkMode': isDarkMode.value,
      'showExplanations': showExplanations.value,
      'soundEnabled': soundEnabled.value,
      'questionsPerQuiz': questionsPerQuiz.value,
    };
  }
} 