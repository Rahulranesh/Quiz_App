import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/quiz_data_service.dart';
import '../services/storage_service.dart';
import '../services/interactive_gesture_service.dart';
import '../services/pdf_content_extractor.dart';
import '../services/dynamic_question_generator.dart';
import 'language_controller.dart';
import 'auth_controller.dart';
import 'progress_controller.dart';

class EnhancedQuizController extends GetxController {
  // Core quiz state
  final RxList<Question> questions = <Question>[].obs;
  final RxList<int> userAnswers = <int>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxInt score = 0.obs;
  final RxBool isQuizCompleted = false.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = ''.obs;
  final RxInt questionsPerQuiz = 5.obs; // Default to 5 questions
  final RxString loadingMessage = 'Loading questions...'.obs;
  final RxString errorMessage = ''.obs;
  final RxBool quizStarted = false.obs;
  final RxBool quizCompleted = false.obs;

  // Interactive state
  final RxBool isInteractiveMode = true.obs;
  final RxString lastGestureAction = ''.obs;

  // Interactive features
  final RxBool showHints = false.obs;
  final RxBool showExplanations = false.obs;
  final RxBool isQuestionRevealed = false.obs;
  final RxBool isAnswerRevealed = false.obs;
  final RxDouble questionConfidence = 0.0.obs;
  final RxInt streakCount = 0.obs;
  final RxInt totalStreak = 0.obs;

  // Animation controllers
  late AnimationController questionAnimationController;
  late AnimationController answerAnimationController;
  late AnimationController gestureAnimationController;

  // Services
  final InteractiveGestureService _gestureService = InteractiveGestureService();
  final QuizDataService _quizDataService = QuizDataService();
  late AuthController _authController;

  // Stream subscriptions
  StreamSubscription<InteractiveAction>? _gestureActionSubscription;

  // Quiz session
  QuizSession? currentSession;

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

  @override
  void onReady() {
    super.onReady();
    setupAnimationControllers();
  }

  Future<void> loadSettings() async {
    final userId = _authController.currentUser?.id;
    final settings = await StorageService.getSettings(userId: userId);
    questionsPerQuiz.value = settings['questionsPerQuiz'] ?? 5;
    isInteractiveMode.value = settings['interactiveMode'] ?? true;
  }

  Future<void> initializeGestures() async {
    // Subscribe to gesture actions
    _gestureActionSubscription = _gestureService.gestureStream.listen((action) {
      handleGestureAction(action);
    });
  }

  void setupAnimationControllers() {
    // These will be initialized in the view with TickerProvider
  }

  void setAnimationControllers({
    required AnimationController questionController,
    required AnimationController answerController,
    required AnimationController gestureController,
  }) {
    questionAnimationController = questionController;
    answerAnimationController = answerController;
    gestureAnimationController = gestureController;
  }

  Future<void> startQuiz({String? category, int? questionCount}) async {
    isLoading.value = true;
    loadingMessage.value = 'Generating questions from AdTech book...';
    
    try {
      // Use the setting from storage or provided count
      final count = questionCount ?? questionsPerQuiz.value;
      
      // Get current language
      final languageController = Get.find<LanguageController>();
      final currentLanguage = languageController.currentLanguage.value;
      
      List<Question> quizQuestions;
      if (category != null && category.isNotEmpty) {
        selectedCategory.value = category;
        loadingMessage.value = 'Loading $category questions from AdTech book...';
        quizQuestions = await _quizDataService.getQuestionsForCategory(
          category, 
          count: count,
          language: currentLanguage
        );
      } else {
        selectedCategory.value = '';
        loadingMessage.value = 'Generating random questions from AdTech book...';
        quizQuestions = await _quizDataService.getRandomQuestions(
          count: count,
          language: currentLanguage
        );
      }

      if (quizQuestions.isEmpty) {
        loadingMessage.value = 'No questions available. Please try again.';
        isLoading.value = false;
        return;
      }

      // Shuffle questions for variety
      quizQuestions.shuffle();

      questions.value = quizQuestions;
      userAnswers.value = List.filled(quizQuestions.length, -1);
      currentQuestionIndex.value = 0;
      score.value = 0;
      isQuizCompleted.value = false;

      // Create new quiz session
      currentSession = QuizSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
        questions: quizQuestions,
        userAnswers: userAnswers,
        score: 0,
        totalQuestions: quizQuestions.length,
      );

      loadingMessage.value = 'Quiz ready!';
    } catch (e) {
      print('Error starting quiz: $e');
      loadingMessage.value = 'Error loading questions. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void handleGestureAction(InteractiveAction action) {
    lastGestureAction.value = action.type;
    
    switch (action.type) {
      case 'swipe_right':
        nextQuestion();
        break;
      case 'swipe_left':
        previousQuestion();
        break;
      case 'swipe_up':
        showHints.value = !showHints.value;
        break;
      case 'swipe_down':
        showExplanations.value = !showExplanations.value;
        break;
      case 'double_tap':
        if (getCurrentQuestion() != null) {
          final userAnswer = getUserAnswerForCurrentQuestion();
          if (userAnswer != null) {
            submitAnswer(userAnswer);
          }
        }
        break;
      case 'long_press':
        // Show question details or explanation
        break;
      case 'pinch_in':
        // Zoom out question view
        break;
      case 'pinch_out':
        // Zoom in question view
        break;
    }
  }

  Future<void> answerQuestion(int answerIndex) async {
    if (currentQuestionIndex.value < questions.length && 
        userAnswers[currentQuestionIndex.value] == -1) { // Only answer if not already answered
      
      userAnswers[currentQuestionIndex.value] = answerIndex;
      
      final currentQuestion = questions[currentQuestionIndex.value];
      final userAnswer = currentQuestion.options[answerIndex];
      final correctAnswer = currentQuestion.options[currentQuestion.correctAnswerIndex];
      
      // Get book content for validation
      String bookContent = '';
      try {
        bookContent = await PDFContentExtractor.getContentForCategory(currentQuestion.category);
      } catch (e) {
        print('Error getting book content for validation: $e');
      }
      
      // Validate answer with AI if book content is available
      bool isCorrect = false;
      if (bookContent.isNotEmpty) {
        try {
          isCorrect = await DynamicQuestionGenerator.validateAnswerWithAI(
            currentQuestion.question,
            userAnswer,
            correctAnswer,
            bookContent
          );
        } catch (e) {
          print('Error validating with AI, using fallback: $e');
          isCorrect = answerIndex == currentQuestion.correctAnswerIndex;
        }
      } else {
        // Fallback to exact match
        isCorrect = answerIndex == currentQuestion.correctAnswerIndex;
      }
      
      if (isCorrect) {
        score.value++;
        streakCount.value++;
        totalStreak.value = max(totalStreak.value, streakCount.value);
        _gestureService.provideHapticFeedback('medium');
      } else {
        streakCount.value = 0;
        _gestureService.provideHapticFeedback('light');
      }
    }
  }

  void selectOption(int optionIndex) {
    if (currentQuestionIndex.value < questions.length && optionIndex < 4) {
      userAnswers[currentQuestionIndex.value] = optionIndex;
    }
  }

  Future<void> submitAnswer(int answerIndex) async {
    await answerQuestion(answerIndex);
    
    // Auto-advance after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!isQuizCompleted.value) {
        nextQuestion();
      }
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      resetQuestionState();
    } else {
      // This is the last question, complete the quiz immediately
      completeQuiz();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      resetQuestionState();
    }
  }

  void resetQuestionState() {
    showHints.value = false;
    showExplanations.value = false;
    isQuestionRevealed.value = false;
    isAnswerRevealed.value = false;
  }

  void pauseQuiz() {
    // Implement quiz pause functionality
  }

  void resumeQuiz() {
    // Implement quiz resume functionality
  }

  Future<void> toggleInteractiveMode() async {
    isInteractiveMode.value = !isInteractiveMode.value;
    final userId = _authController.currentUser?.id;
    await StorageService.updateSetting('interactiveMode', isInteractiveMode.value, userId: userId);
  }

  // Inherit other methods from original QuizController
  void goToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      currentQuestionIndex.value = index;
      resetQuestionState();
    }
  }

  Future<void> completeQuiz() async {
    isQuizCompleted.value = true;
    
    // Calculate final score
    final correctAnswers = score.value;
    
    // Save session and update progress with user ID
    if (currentSession != null) {
      // Create a new session with updated data
      final session = currentSession!;
      final updatedSession = QuizSession(
        id: session.id,
        startTime: session.startTime,
        endTime: DateTime.now(),
        questions: session.questions,
        userAnswers: session.userAnswers,
        score: correctAnswers,
        totalQuestions: session.totalQuestions,
      );
      
      // Save session and update progress with user ID
      final userId = _authController.currentUser?.id;
      await StorageService.saveQuizSession(updatedSession, userId: userId);
      await StorageService.updateUserProgress(updatedSession, userId: userId);
      
      // Refresh progress data immediately
      try {
        final progressController = Get.find<ProgressController>();
        await progressController.refreshProgress();
      } catch (e) {
        print('Error refreshing progress: $e');
      }
    }
  }

  void resetQuiz() {
    questions.clear();
    userAnswers.clear();
    currentQuestionIndex.value = 0;
    score.value = 0;
    isQuizCompleted.value = false;
    selectedCategory.value = '';
    streakCount.value = 0;
    totalStreak.value = 0;
    currentSession = null;
    resetQuestionState();
  }

  // Utility methods
  bool isQuestionAnswered(int questionIndex) {
    return questionIndex < userAnswers.length && userAnswers[questionIndex] != -1;
  }

  bool isCurrentQuestionAnswered() {
    return isQuestionAnswered(currentQuestionIndex.value);
  }

  int getAnsweredQuestionsCount() {
    return userAnswers.where((answer) => answer != -1).length;
  }

  double getProgressPercentage() {
    if (questions.isEmpty) return 0.0;
    return getAnsweredQuestionsCount() / questions.length;
  }

  Question? getCurrentQuestion() {
    if (currentQuestionIndex.value < questions.length) {
      return questions[currentQuestionIndex.value];
    }
    return null;
  }
  
  
  
int? getUserAnswerForCurrentQuestion() {
    if (currentQuestionIndex.value < userAnswers.length) {
      final answer = userAnswers[currentQuestionIndex.value];
      return answer == -1 ? null : answer;
    }
    return null;
  }

  bool isAnswerCorrect(int questionIndex, int answerIndex) {
    if (questionIndex < questions.length) {
      return questions[questionIndex].correctAnswerIndex == answerIndex;
    }
    return false;
  }

  List<String> getCategories() {
    return QuizDataService.categories;
  }

  Future<void> refreshQuestions() async {
    if (selectedCategory.value.isNotEmpty) {
      await startQuiz(category: selectedCategory.value, questionCount: questionsPerQuiz.value);
    } else {
      await startQuiz(questionCount: questionsPerQuiz.value);
    }
  }

  @override
  void onClose() {
    // Cancel subscriptions
    _gestureActionSubscription?.cancel();
    
    // Dispose of services
    _gestureService.dispose();
    
    super.onClose();
  }
} 