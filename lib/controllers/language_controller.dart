import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'package:quiz_app/controllers/enhanced_quiz_controller.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();
  
  final RxString currentLanguage = 'en'.obs;
  final Rx<Locale> currentLocale = const Locale('en', '').obs;

  @override
  void onInit() {
    super.onInit();
    loadLanguage();
  }

  Future<void> loadLanguage() async {
    final settings = await StorageService.getSettings();
    final savedLanguage = settings['language'] ?? 'en';
    await changeLanguage(savedLanguage);
  }

  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    currentLocale.value = Locale(languageCode, '');
    
    // Save to storage
    await StorageService.updateSetting('language', languageCode);
    
    // Update app locale immediately
    Get.updateLocale(currentLocale.value);
    
    // Force immediate update
    Get.forceAppUpdate();
    
    // Refresh quiz controller if it exists
    try {
      final quizController = Get.find<EnhancedQuizController>();
      quizController.loadSettings();
    } catch (e) {
      print('Quiz controller not found during language change: $e');
    }
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      default:
        return 'English';
    }
  }

  List<String> get availableLanguages => ['en', 'ja'];
  List<String> get availableLanguageNames => ['English', '日本語'];
} 