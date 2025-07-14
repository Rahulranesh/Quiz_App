import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'controllers/enhanced_quiz_controller.dart';
import 'controllers/progress_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/language_controller.dart';
import 'controllers/auth_controller.dart';
import 'l10n/app_localizations.dart';
import 'views/home_view.dart';
import 'views/interactive_quiz_view.dart';
import 'views/progress_view.dart';
import 'views/settings_view.dart';
import 'views/quiz_result_view.dart';
import 'views/auth_view.dart';

class AppLocalizationsConfig {
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('ja', ''), // Japanese
  ];

  static const String defaultLocale = 'en';

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocalesList = supportedLocales;

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      default:
        return 'English';
    }
  }

  static String getLanguageCode(String languageName) {
    switch (languageName) {
      case 'English':
        return 'en';
      case '日本語':
        return 'ja';
      default:
        return 'en';
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AdTech Quiz App',
      debugShowCheckedModeBanner: false,
      
      // Internationalization
      localizationsDelegates: AppLocalizationsConfig.localizationsDelegates,
      supportedLocales: AppLocalizationsConfig.supportedLocalesList,
      locale: const Locale('en', ''),
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/auth',
      getPages: [
        GetPage(name: '/auth', page: () => const AuthView()),
        GetPage(name: '/', page: () => const HomeView()),
        GetPage(name: '/quiz', page: () => const InteractiveQuizView()),
        GetPage(name: '/progress', page: () => const ProgressView()),
        GetPage(name: '/settings', page: () => const SettingsView()),
        GetPage(name: '/result', page: () => const QuizResultView()),
      ],
      initialBinding: BindingsBuilder(() {
        // Initialize controllers
        Get.put(AuthController());
        Get.put(EnhancedQuizController());
        Get.put(ProgressController());
        Get.put(SettingsController());
        Get.put(LanguageController());
      }),
    );
  }
}
