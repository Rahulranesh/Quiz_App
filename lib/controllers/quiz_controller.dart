import 'package:get/get.dart';
import '../models/quiz_models.dart';
import '../services/quiz_data_service.dart';
import '../services/storage_service.dart';
import '../controllers/auth_controller.dart';

class QuizController extends GetxController {
  // Observable variables
  final RxList<Question> questions = <Question>[].obs;
  final RxList<int> userAnswers = <int>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxInt score = 0.obs;
  final RxBool isQuizCompleted = false.obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = ''.obs;
  final RxInt questionsPerQuiz = 5.obs; // Default to 5 questions
  final RxString loadingMessage = 'Loading questions...'.obs;

  // Quiz session
  QuizSession? currentSession;

  // Services
  final QuizDataService _quizDataService = QuizDataService();
  late AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final userId = _authController.currentUser?.id;
    final settings = await StorageService.getSettings(userId: userId);
    questionsPerQuiz.value = settings['questionsPerQuiz'] ?? 5;
  }

  Future<void> startQuiz({String? category, int? questionCount}) async {
    isLoading.value = true;
    loadingMessage.value = 'Generating questions from AdTech book...';
    
    try {
      List<Question> quizQuestions;
      if (category != null && category.isNotEmpty) {
        selectedCategory.value = category;
        loadingMessage.value = 'Loading $category questions from AdTech book...';
        quizQuestions = await _quizDataService.getQuestionsForCategory(category, count: questionCount ?? questionsPerQuiz.value);
      } else {
        selectedCategory.value = '';
        loadingMessage.value = 'Generating random questions from AdTech book...';
        quizQuestions = await _quizDataService.getRandomQuestions(count: questionCount ?? questionsPerQuiz.value);
      }

      if (quizQuestions.isEmpty) {
        loadingMessage.value = 'No questions available. Please try again.';
        await Future.delayed(const Duration(seconds: 2));
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
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error starting quiz: $e');
      loadingMessage.value = 'Error loading questions. Please try again.';
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      isLoading.value = false;
    }
  }

  void answerQuestion(int answerIndex) {
    if (currentQuestionIndex.value < questions.length) {
      userAnswers[currentQuestionIndex.value] = answerIndex;
      
      // Check if answer is correct
      final currentQuestion = questions[currentQuestionIndex.value];
      if (answerIndex == currentQuestion.correctAnswerIndex) {
        score.value++;
      }
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    } else {
      completeQuiz();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      currentQuestionIndex.value = index;
    }
  }

  Future<void> completeQuiz() async {
    isQuizCompleted.value = true;
    
    // Update current session
    if (currentSession != null) {
      final session = currentSession!;
      final updatedSession = QuizSession(
        id: session.id,
        startTime: session.startTime,
        endTime: DateTime.now(),
        questions: questions,
        userAnswers: userAnswers,
        score: score.value,
        totalQuestions: questions.length,
      );
      currentSession = updatedSession;

      // Save session and update progress with user ID
      final userId = _authController.currentUser?.id;
      await StorageService.saveQuizSession(updatedSession, userId: userId);
      await StorageService.updateUserProgress(updatedSession, userId: userId);
    }
  }

  void resetQuiz() {
    questions.clear();
    userAnswers.clear();
    currentQuestionIndex.value = 0;
    score.value = 0;
    isQuizCompleted.value = false;
    selectedCategory.value = '';
    currentSession = null;
  }

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

  Future<void> updateQuestionsPerQuiz(int count) async {
    questionsPerQuiz.value = count;
    final userId = _authController.currentUser?.id;
    await StorageService.updateSetting('questionsPerQuiz', count, userId: userId);
  }

  Future<void> refreshQuestions() async {
    if (selectedCategory.value.isNotEmpty) {
      await startQuiz(category: selectedCategory.value);
    } else {
      await startQuiz();
    }
  }
} 