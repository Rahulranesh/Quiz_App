class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String category;

  // Optionally, add a hint field if you want to support hints in the future
  final String? hint;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.category,
    this.hint,
  });

  // Getter for compatibility
  String get text => question;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      explanation: json['explanation'],
      category: json['category'],
      hint: json['hint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'category': category,
      'hint': hint,
    };
  }
}

class QuizSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<Question> questions;
  final List<int> userAnswers;
  final int score;
  final int totalQuestions;

  QuizSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.questions,
    required this.userAnswers,
    required this.score,
    required this.totalQuestions,
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      userAnswers: List<int>.from(json['userAnswers']),
      score: json['score'],
      totalQuestions: json['totalQuestions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'userAnswers': userAnswers,
      'score': score,
      'totalQuestions': totalQuestions,
    };
  }
}

class UserProgress {
  final int totalQuizzesTaken;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final double averageScore;
  final List<String> completedCategories;
  final Map<String, int> categoryScores;

  UserProgress({
    required this.totalQuizzesTaken,
    required this.totalQuestionsAnswered,
    required this.totalCorrectAnswers,
    required this.averageScore,
    required this.completedCategories,
    required this.categoryScores,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalQuizzesTaken: json['totalQuizzesTaken'] ?? 0,
      totalQuestionsAnswered: json['totalQuestionsAnswered'] ?? 0,
      totalCorrectAnswers: json['totalCorrectAnswers'] ?? 0,
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      completedCategories: List<String>.from(json['completedCategories'] ?? []),
      categoryScores: Map<String, int>.from(json['categoryScores'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuizzesTaken': totalQuizzesTaken,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'totalCorrectAnswers': totalCorrectAnswers,
      'averageScore': averageScore,
      'completedCategories': completedCategories,
      'categoryScores': categoryScores,
    };
  }
} 

class QuizStats {
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final Duration timeSpent;

  QuizStats({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.timeSpent,
  });

  factory QuizStats.fromJson(Map<String, dynamic> json) {
    return QuizStats(
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      timeSpent: Duration(milliseconds: json['timeSpentMs'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
      'timeSpentMs': timeSpent.inMilliseconds,
    };
  }
} 