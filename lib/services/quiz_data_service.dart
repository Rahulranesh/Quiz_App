import '../models/quiz_models.dart';
import 'dynamic_question_generator.dart';
import 'pdf_content_extractor.dart';

class QuizDataService {
  static final QuizDataService _instance = QuizDataService._internal();
  factory QuizDataService() => _instance;
  QuizDataService._internal();

  static const List<String> categories = [
      'Advertising Basics',
      'AdTech Platforms',
      'Targeting and Data',
      'Media Buying',
      'User Identification',
      'Ad Fraud and Privacy',
      'Attribution',
      // MarTech categories
      'Marketing Automation',
      'CRM',
      'Email Marketing',
      'Content Marketing',
      'Social Media Marketing',
      'Web Analytics',
      'Customer Data Platforms',
      'Personalization & A/B Testing',
    ];
    
  Future<List<Question>> getQuestionsForCategory(String category, {int count = 5, String language = 'en'}) async {
    try {
      print('Getting questions for category: $category (count: $count)');
      
      // Get content from the book for this category
      final content = await PDFContentExtractor.getContentForCategory(category);
      
      if (content.isEmpty) {
        print('No content found for category: $category - using fallback questions');
        // Even if no content, try to generate fallback questions
        final fallbackQuestions = DynamicQuestionGenerator.generateFallbackQuestions(category, language: language);
        return fallbackQuestions.take(count).toList();
      }
      
      print('Content found for category: $category (${content.length} characters)');
      
      // Generate questions using AI from book content only
      final questions = await DynamicQuestionGenerator.generateQuestionsFromContent(content, category, language: language);
      
      print('Generated ${questions.length} questions for category: $category');
      
      // Limit to requested count
      final limitedQuestions = questions.take(count).toList();
      print('Returning ${limitedQuestions.length} questions for category: $category');
      
      return limitedQuestions;
    } catch (e) {
      print('Error getting questions for category $category: $e');
      print('Using fallback questions due to error');
      // Return fallback questions even on error
      final fallbackQuestions = DynamicQuestionGenerator.generateFallbackQuestions(category, language: language);
      return fallbackQuestions.take(count).toList();
    }
  }

  Future<List<Question>> getRandomQuestions({int count = 10, String language = 'en'}) async {
    try {
      final allQuestions = <Question>[];
    
      // Get questions from each category - distribute count across categories
      final questionsPerCategory = (count / categories.length).ceil();
      
      for (final category in categories) {
        final categoryQuestions = await getQuestionsForCategory(category, count: questionsPerCategory, language: language);
        allQuestions.addAll(categoryQuestions);
      }
      
      // Shuffle and return requested count
      allQuestions.shuffle();
      return allQuestions.take(count).toList();
    } catch (e) {
      print('Error getting random questions: $e');
      return [];
    }
  }

  Future<List<Question>> getQuestionsByDifficulty(String category, String difficulty, {int count = 5, String language = 'en'}) async {
    try {
      // Get content from the book
      final content = await PDFContentExtractor.getContentForCategory(category);
    
      if (content.isEmpty) {
        return [];
      }
      
      // Generate questions with difficulty specification
      final questions = await DynamicQuestionGenerator.generateQuestionsFromContent(content, category, language: language);
      
      // For now, return all questions as difficulty filtering would require more sophisticated AI prompts
      // In the future, we could modify the AI prompt to generate questions of specific difficulty levels
      return questions.take(count).toList();
    } catch (e) {
      print('Error getting questions by difficulty: $e');
      return [];
    }
  }

  Future<List<Question>> getQuestionsForChapter(String chapter, {String language = 'en'}) async {
    try {
      // Get content for the specific chapter
      final content = await PDFContentExtractor.getContentForCategory(chapter);
      
      if (content.isEmpty) {
        return [];
      }
      
      // Generate questions from chapter content
      return await DynamicQuestionGenerator.generateQuestionsFromContent(content, chapter, language: language);
    } catch (e) {
      print('Error getting questions for chapter: $e');
      return [];
  }
  }

  Future<Map<String, List<Question>>> getAllQuestionsByCategory({String language = 'en'}) async {
    final questionsByCategory = <String, List<Question>>{};
    
    for (final category in categories) {
      questionsByCategory[category] = await getQuestionsForCategory(category, language: language);
    }
    
    return questionsByCategory;
  }

  Future<List<String>> getAvailableCategories() async {
    return categories;
  }

  Future<List<String>> getAvailableChapters() async {
    return await PDFContentExtractor.getAvailableChapters();
  }

  Future<bool> validateAnswer(String questionId, int selectedAnswerIndex, List<Question> questions) async {
    try {
      final question = questions.firstWhere((q) => q.id == questionId);
      final userAnswer = question.options[selectedAnswerIndex];
      final correctAnswer = question.options[question.correctAnswerIndex];
      
      // Get book content for validation
      final content = await PDFContentExtractor.getContentForCategory(question.category);
      
      if (content.isNotEmpty) {
        // Use AI validation
        return await DynamicQuestionGenerator.validateAnswerWithAI(
          question.question,
          userAnswer,
          correctAnswer,
          content
        );
      } else {
        // Fallback to exact match
        return selectedAnswerIndex == question.correctAnswerIndex;
      }
    } catch (e) {
      print('Error validating answer: $e');
      return false;
    }
  }

  Future<String> getExplanation(String questionId, List<Question> questions) async {
    try {
      final question = questions.firstWhere((q) => q.id == questionId);
      final correctAnswer = question.options[question.correctAnswerIndex];
      
      // Get book content for explanation
      final content = await PDFContentExtractor.getContentForCategory(question.category);
      
      if (content.isNotEmpty) {
        // Generate AI explanation
        return await DynamicQuestionGenerator.generateExplanationWithAI(
          question.question,
          correctAnswer,
          content
        );
      } else {
        // Return stored explanation
        return question.explanation;
      }
    } catch (e) {
      print('Error getting explanation: $e');
      return 'Explanation not available.';
    }
  }

  Future<QuizStats> getQuizStats(List<Question> questions, List<int> userAnswers) async {
    int correctAnswers = 0;
    int totalQuestions = questions.length;
    
    for (int i = 0; i < questions.length && i < userAnswers.length; i++) {
      final question = questions[i];
      final userAnswer = userAnswers[i];
      
      if (userAnswer == question.correctAnswerIndex) {
        correctAnswers++;
      }
    }
    
    final accuracy = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
    
    return QuizStats(
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      accuracy: accuracy,
      timeSpent: Duration.zero, // This would be tracked by the controller
    );
  }
} 