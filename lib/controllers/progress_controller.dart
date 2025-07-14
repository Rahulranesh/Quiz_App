import 'package:get/get.dart';
import '../models/quiz_models.dart';
import '../services/storage_service.dart';
import '../controllers/auth_controller.dart';

class ProgressController extends GetxController {
  final Rx<UserProgress> userProgress = UserProgress(
    totalQuizzesTaken: 0,
    totalQuestionsAnswered: 0,
    totalCorrectAnswers: 0,
    averageScore: 0.0,
    completedCategories: [],
    categoryScores: {},
  ).obs;

  final RxList<QuizSession> quizHistory = <QuizSession>[].obs;
  final RxBool isLoading = false.obs;
  late AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    
    // Listen for authentication changes to refresh data
    ever(_authController.authState, (authState) {
      if (authState.isAuthenticated) {
        loadProgress();
      } else {
        // Clear data when user logs out
        userProgress.value = UserProgress(
          totalQuizzesTaken: 0,
          totalQuestionsAnswered: 0,
          totalCorrectAnswers: 0,
          averageScore: 0.0,
          completedCategories: [],
          categoryScores: {},
        );
        quizHistory.clear();
      }
    });
    
    loadProgress();
  }

  Future<void> loadProgress() async {
    isLoading.value = true;
    try {
      final userId = _authController.currentUser?.id;
      final progress = await StorageService.getUserProgress(userId: userId);
      userProgress.value = progress;
      
      final history = await StorageService.getQuizSessions(userId: userId);
      // Sort by start time, most recent first
      history.sort((a, b) => b.startTime.compareTo(a.startTime));
      quizHistory.value = history;
    } catch (e) {
      print('Error loading progress: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to be called when navigating to progress view
  Future<void> onProgressViewOpened() async {
    await loadProgress();
  }

  // Method to refresh progress data immediately
  Future<void> refreshProgress() async {
    await loadProgress();
  }

  double getAccuracyPercentage() {
    if (userProgress.value.totalQuestionsAnswered == 0) return 0.0;
    return (userProgress.value.totalCorrectAnswers / userProgress.value.totalQuestionsAnswered) * 100;
  }

  String getAccuracyText() {
    final accuracy = getAccuracyPercentage();
    if (accuracy >= 90) return 'Excellent';
    if (accuracy >= 80) return 'Very Good';
    if (accuracy >= 70) return 'Good';
    if (accuracy >= 60) return 'Fair';
    return 'Needs Improvement';
  }

  String getAverageScoreText() {
    final avg = userProgress.value.averageScore;
    if (avg >= 9) return 'Outstanding';
    if (avg >= 8) return 'Excellent';
    if (avg >= 7) return 'Very Good';
    if (avg >= 6) return 'Good';
    if (avg >= 5) return 'Fair';
    return 'Needs Practice';
  }

  List<MapEntry<String, int>> getTopCategories() {
    final categoryScores = userProgress.value.categoryScores;
    final sortedCategories = categoryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedCategories.take(5).toList();
  }

  int getCategoryScore(String category) {
    return userProgress.value.categoryScores[category] ?? 0;
  }

  bool isCategoryCompleted(String category) {
    return userProgress.value.completedCategories.contains(category);
  }

  List<QuizSession> getRecentSessions(int count) {
    return quizHistory.take(count).toList();
  }

  QuizSession? getBestSession() {
    if (quizHistory.isEmpty) return null;
    
    QuizSession bestSession = quizHistory.first;
    double bestScore = bestSession.score / bestSession.totalQuestions;
    
    for (final session in quizHistory) {
      final score = session.score / session.totalQuestions;
      if (score > bestScore) {
        bestScore = score;
        bestSession = session;
      }
    }
    
    return bestSession;
  }

  QuizSession? getLatestSession() {
    return quizHistory.isNotEmpty ? quizHistory.first : null;
  }

  double getSessionScore(QuizSession session) {
    return (session.score / session.totalQuestions) * 100;
  }
 //we will keep it dummy for now
  String getSessionScoreText(QuizSession session) {
    final score = getSessionScore(session);
    if (score >= 90) return 'A+';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  Duration getSessionDuration(QuizSession session) {
    if (session.endTime == null) return Duration.zero;
    return session.endTime!.difference(session.startTime);
  }

  Future<void> clearAllData() async {
    final userId = _authController.currentUser?.id;
    await StorageService.clearAllData(userId: userId);
    await loadProgress();
  }

  Map<String, dynamic> getProgressStats() {
    return {
      'totalQuizzes': userProgress.value.totalQuizzesTaken,
      'totalQuestions': userProgress.value.totalQuestionsAnswered,
      'correctAnswers': userProgress.value.totalCorrectAnswers,
      'accuracy': getAccuracyPercentage(),
      'averageScore': userProgress.value.averageScore,
      'completedCategories': userProgress.value.completedCategories.length,
      'totalCategories': 7, // Total categories in our quiz
    };
  }
} 