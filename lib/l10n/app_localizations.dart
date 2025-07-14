import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AdTech Quiz'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to AdTech Quiz!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge of digital advertising technology'**
  String get welcomeSubtitle;

  /// No description provided for @quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @averageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get averageScore;

  /// No description provided for @totalQuestions.
  ///
  /// In en, this message translates to:
  /// **'Total Questions'**
  String get totalQuestions;

  /// No description provided for @completedQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Completed Quizzes'**
  String get completedQuizzes;

  /// No description provided for @quizCategories.
  ///
  /// In en, this message translates to:
  /// **'Quiz Categories'**
  String get quizCategories;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @randomQuiz.
  ///
  /// In en, this message translates to:
  /// **'Random Quiz'**
  String get randomQuiz;

  /// No description provided for @viewProgress.
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get viewProgress;

  /// No description provided for @refreshQuestions.
  ///
  /// In en, this message translates to:
  /// **'Refresh Questions'**
  String get refreshQuestions;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get questions;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  /// No description provided for @previousQuestion.
  ///
  /// In en, this message translates to:
  /// **'Previous Question'**
  String get previousQuestion;

  /// No description provided for @submitAnswer.
  ///
  /// In en, this message translates to:
  /// **'Submit Answer'**
  String get submitAnswer;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @quizCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed!'**
  String get quizCompleted;

  /// No description provided for @youScored.
  ///
  /// In en, this message translates to:
  /// **'You scored {score} out of {total}'**
  String youScored(Object score, Object total);

  /// No description provided for @viewResults.
  ///
  /// In en, this message translates to:
  /// **'View Results'**
  String get viewResults;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @exitQuiz.
  ///
  /// In en, this message translates to:
  /// **'Exit Quiz?'**
  String get exitQuiz;

  /// No description provided for @exitQuizMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit? Your progress will be lost.'**
  String get exitQuizMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @loadingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Loading questions...'**
  String get loadingQuestions;

  /// No description provided for @generatingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Generating questions from AdTech book...'**
  String get generatingQuestions;

  /// No description provided for @quizReady.
  ///
  /// In en, this message translates to:
  /// **'Quiz ready!'**
  String get quizReady;

  /// No description provided for @errorGeneratingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Error generating questions from the AdTech book. Please check your internet connection and try again.'**
  String get errorGeneratingQuestions;

  /// No description provided for @errorLoadingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Error loading questions. Please try again.'**
  String get errorLoadingQuestions;

  /// No description provided for @noQuestionsGenerated.
  ///
  /// In en, this message translates to:
  /// **'No questions could be generated for this category. This might be due to network issues or API limitations. The app will use fallback questions instead.'**
  String get noQuestionsGenerated;

  /// No description provided for @usingFallbackQuestions.
  ///
  /// In en, this message translates to:
  /// **'Using fallback questions'**
  String get usingFallbackQuestions;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again!'**
  String get tryAgain;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @unableToGenerateQuestions.
  ///
  /// In en, this message translates to:
  /// **'Unable to Generate Questions'**
  String get unableToGenerateQuestions;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @listeningContinuously.
  ///
  /// In en, this message translates to:
  /// **'Listening continuously...'**
  String get listeningContinuously;

  /// No description provided for @command.
  ///
  /// In en, this message translates to:
  /// **'Command'**
  String get command;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japanese;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @questionsPerQuiz.
  ///
  /// In en, this message translates to:
  /// **'Questions per Quiz'**
  String get questionsPerQuiz;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @interactiveMode.
  ///
  /// In en, this message translates to:
  /// **'Interactive Mode'**
  String get interactiveMode;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'A comprehensive quiz app for learning AdTech concepts'**
  String get description;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgress;

  /// No description provided for @resetProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all your progress? This action cannot be undone.'**
  String get resetProgressMessage;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @progressReset.
  ///
  /// In en, this message translates to:
  /// **'Progress Reset'**
  String get progressReset;

  /// No description provided for @progressResetMessage.
  ///
  /// In en, this message translates to:
  /// **'All progress has been reset successfully.'**
  String get progressResetMessage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @advertisingBasics.
  ///
  /// In en, this message translates to:
  /// **'Advertising Basics'**
  String get advertisingBasics;

  /// No description provided for @adtechPlatforms.
  ///
  /// In en, this message translates to:
  /// **'AdTech Platforms'**
  String get adtechPlatforms;

  /// No description provided for @targetingAndData.
  ///
  /// In en, this message translates to:
  /// **'Targeting and Data'**
  String get targetingAndData;

  /// No description provided for @mediaBuying.
  ///
  /// In en, this message translates to:
  /// **'Media Buying'**
  String get mediaBuying;

  /// No description provided for @userIdentification.
  ///
  /// In en, this message translates to:
  /// **'User Identification'**
  String get userIdentification;

  /// No description provided for @adFraudAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Ad Fraud and Privacy'**
  String get adFraudAndPrivacy;

  /// No description provided for @attribution.
  ///
  /// In en, this message translates to:
  /// **'Attribution'**
  String get attribution;

  /// No description provided for @optionA.
  ///
  /// In en, this message translates to:
  /// **'Option A'**
  String get optionA;

  /// No description provided for @optionB.
  ///
  /// In en, this message translates to:
  /// **'Option B'**
  String get optionB;

  /// No description provided for @optionC.
  ///
  /// In en, this message translates to:
  /// **'Option C'**
  String get optionC;

  /// No description provided for @optionD.
  ///
  /// In en, this message translates to:
  /// **'Option D'**
  String get optionD;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @selectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Select Answer'**
  String get selectAnswer;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get yourAnswer;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct Answer'**
  String get correctAnswer;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @totalCorrect.
  ///
  /// In en, this message translates to:
  /// **'Total Correct'**
  String get totalCorrect;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @timeTaken.
  ///
  /// In en, this message translates to:
  /// **'Time Taken'**
  String get timeTaken;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @categoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get categoryBreakdown;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @quizHistory.
  ///
  /// In en, this message translates to:
  /// **'Quiz History'**
  String get quizHistory;

  /// No description provided for @noQuizzesYet.
  ///
  /// In en, this message translates to:
  /// **'No quizzes taken yet'**
  String get noQuizzesYet;

  /// No description provided for @takeYourFirstQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take your first quiz to see your progress here!'**
  String get takeYourFirstQuiz;

  /// No description provided for @categoryPerformance.
  ///
  /// In en, this message translates to:
  /// **'Category Performance'**
  String get categoryPerformance;

  /// No description provided for @questionsAnswered.
  ///
  /// In en, this message translates to:
  /// **'Questions Answered'**
  String get questionsAnswered;

  /// No description provided for @averageAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Average Accuracy'**
  String get averageAccuracy;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get notStarted;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @needsImprovement.
  ///
  /// In en, this message translates to:
  /// **'Needs Improvement'**
  String get needsImprovement;

  /// No description provided for @perfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get perfect;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get greatJob;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get keepGoing;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostThere;

  /// No description provided for @noExplanationAvailable.
  ///
  /// In en, this message translates to:
  /// **'No explanation available.'**
  String get noExplanationAvailable;

  /// No description provided for @explanationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Explanation not available.'**
  String get explanationNotAvailable;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing'**
  String get refreshing;

  /// No description provided for @generatingNewQuestions.
  ///
  /// In en, this message translates to:
  /// **'Generating new questions from AdTech book...'**
  String get generatingNewQuestions;

  /// No description provided for @noContentFound.
  ///
  /// In en, this message translates to:
  /// **'No content found for this category'**
  String get noContentFound;

  /// No description provided for @aiGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'AI generation failed'**
  String get aiGenerationFailed;

  /// No description provided for @usingFallbackQuestionsDueToError.
  ///
  /// In en, this message translates to:
  /// **'Using fallback questions due to error'**
  String get usingFallbackQuestionsDueToError;

  /// No description provided for @errorGettingQuestions.
  ///
  /// In en, this message translates to:
  /// **'Error getting questions for category'**
  String get errorGettingQuestions;

  /// No description provided for @errorGettingRandomQuestions.
  ///
  /// In en, this message translates to:
  /// **'Error getting random questions'**
  String get errorGettingRandomQuestions;

  /// No description provided for @errorValidatingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Error validating answer'**
  String get errorValidatingAnswer;

  /// No description provided for @errorGettingExplanation.
  ///
  /// In en, this message translates to:
  /// **'Error getting explanation'**
  String get errorGettingExplanation;

  /// No description provided for @errorExtractingPdfContent.
  ///
  /// In en, this message translates to:
  /// **'Error extracting PDF content'**
  String get errorExtractingPdfContent;

  /// No description provided for @errorCallingOpenaiApi.
  ///
  /// In en, this message translates to:
  /// **'Error calling OpenAI API'**
  String get errorCallingOpenaiApi;

  /// No description provided for @openaiApiKeyNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'OpenAI API key not configured - using fallback questions'**
  String get openaiApiKeyNotConfigured;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed - check API key'**
  String get authenticationFailed;

  /// No description provided for @rateLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Rate limit exceeded'**
  String get rateLimitExceeded;

  /// No description provided for @failedToExtractJson.
  ///
  /// In en, this message translates to:
  /// **'Failed to extract JSON from OpenAI response'**
  String get failedToExtractJson;

  /// No description provided for @openaiApiError.
  ///
  /// In en, this message translates to:
  /// **'OpenAI API error'**
  String get openaiApiError;

  /// No description provided for @successfullyGeneratedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Successfully generated {count} questions for category'**
  String successfullyGeneratedQuestions(Object count);

  /// No description provided for @contentLength.
  ///
  /// In en, this message translates to:
  /// **'Content length'**
  String get contentLength;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'characters'**
  String get characters;

  /// No description provided for @openaiResponseContentLength.
  ///
  /// In en, this message translates to:
  /// **'OpenAI response content length'**
  String get openaiResponseContentLength;

  /// No description provided for @fallingBackToGeneratedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Falling back to generated questions for category'**
  String get fallingBackToGeneratedQuestions;

  /// No description provided for @errorValidatingWithAi.
  ///
  /// In en, this message translates to:
  /// **'Error validating with AI, using fallback'**
  String get errorValidatingWithAi;

  /// No description provided for @errorGeneratingAiExplanation.
  ///
  /// In en, this message translates to:
  /// **'Error generating AI explanation'**
  String get errorGeneratingAiExplanation;

  /// No description provided for @errorGettingBookContentForValidation.
  ///
  /// In en, this message translates to:
  /// **'Error getting book content for validation'**
  String get errorGettingBookContentForValidation;

  /// No description provided for @errorGettingBookContentForExplanation.
  ///
  /// In en, this message translates to:
  /// **'Error getting book content for explanation'**
  String get errorGettingBookContentForExplanation;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
