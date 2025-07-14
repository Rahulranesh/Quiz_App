import 'dart:math';
import '../models/quiz_models.dart';

class LocalQuestionGenerator {
  static final Random _random = Random();
  
  // AdTech concepts and their definitions
  static const Map<String, String> _adtechConcepts = {
    'RTB': 'Real-Time Bidding - an automated auction process for buying and selling ad impressions in real-time',
    'DSP': 'Demand-Side Platform - allows advertisers to buy ad inventory from multiple sources through a single interface',
    'SSP': 'Supply-Side Platform - helps publishers sell their ad inventory to multiple buyers',
    'DMP': 'Data Management Platform - collects, organizes, and activates audience data for advertising',
    'PMP': 'Private Marketplace - invitation-only marketplace where premium ad inventory is sold to select advertisers',
    'header bidding': 'allows multiple ad exchanges to bid on ad inventory simultaneously, increasing competition and publisher revenue',
    'contextual targeting': 'displays ads based on the content of the webpage where the ad appears',
    'behavioral targeting': 'uses data about user actions and browsing history to serve relevant ads',
    'retargeting': 'shows ads to users who have previously visited a website or interacted with a brand',
    'lookalike targeting': 'identifies new potential customers who share similar characteristics with existing customers',
    'device fingerprinting': 'identifies devices based on unique characteristics like browser settings, screen resolution, and installed fonts',
    'ad viewability': 'measures whether ads are actually seen by users, typically requiring 50% of the ad to be visible for at least 1 second',
    'attribution': 'the process of assigning credit for conversions to specific touchpoints in the customer journey',
    'cross-device attribution': 'tracks user behavior and conversions across multiple devices to provide a complete view of the customer journey',
    'multi-touch attribution': 'considers all touchpoints in the customer journey, not just the first or last interaction',
    'ad fraud': 'deliberate deception to generate invalid ad impressions or clicks, costing advertisers billions annually',
    'brand safety': 'ensures that ads appear in appropriate contexts and don\'t appear alongside content that could damage a brand\'s reputation',
    'programmatic advertising': 'uses technology to automate the buying and selling of ad inventory',
    'cookies': 'small text files used to identify and track users across websites for advertising purposes',
    'advertising ID': 'unique identifiers assigned to mobile devices for advertising and tracking purposes',
    'GDPR': 'General Data Protection Regulation - protects user data and gives consumers control over how their information is collected and used',
    'CCPA': 'California Consumer Privacy Act - provides California residents with rights regarding their personal information',
    'ad exchange': 'digital marketplace that enables advertisers and publishers to buy and sell ad space in real-time',
    'ad network': 'connects advertisers with publishers who have ad space to sell',
    'ad server': 'technology platform that delivers ads to users based on various targeting criteria and campaign parameters',
  };

  // Question templates
  static const List<String> _questionTemplates = [
    'What is {concept} in digital advertising?',
    'Which of the following describes {concept}?',
    'What does {concept} refer to in AdTech?',
    'How does {concept} work in the advertising ecosystem?',
    'What is the primary purpose of {concept}?',
  ];

  // Generate questions from content without external API
  static Future<List<Question>> generateQuestionsFromContent(String content, String category, {String language = 'en'}) async {
    final questions = <Question>[];
    final concepts = _extractConceptsFromContent(content);
    
    // Generate questions for each concept
    for (final concept in concepts) {
      if (questions.length >= 5) break;
      
      final question = await _generateQuestionForConcept(concept, category, language: language);
      if (question != null) {
        questions.add(question);
      }
    }
    
    // If we don't have enough questions, generate from fallback concepts
    if (questions.length < 5) {
      final fallbackConcepts = _getFallbackConceptsForCategory(category);
      for (final concept in fallbackConcepts) {
        if (questions.length >= 5) break;
        
        final question = await _generateQuestionForConcept(concept, category, language: language);
        if (question != null) {
          questions.add(question);
        }
      }
    }
    
    questions.shuffle();
    return questions.take(5).toList();
  }

  static List<String> _extractConceptsFromContent(String content) {
    final concepts = <String>[];
    final contentLower = content.toLowerCase();
    
    for (final concept in _adtechConcepts.keys) {
      if (contentLower.contains(concept.toLowerCase())) {
        concepts.add(concept);
      }
    }
    
    if (concepts.isEmpty) {
      return ['RTB', 'DSP', 'targeting', 'attribution', 'ad fraud'];
    }
    
    return concepts;
  }

  static List<String> _getFallbackConceptsForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'advertising basics':
        return ['advertiser', 'publisher', 'advertising ecosystem', 'digital advertising', 'AdTech'];
      case 'adtech platforms':
        return ['DSP', 'SSP', 'DMP', 'ad exchange', 'ad server', 'RTB'];
      case 'targeting and data':
        return ['contextual targeting', 'behavioral targeting', 'retargeting', 'lookalike targeting', 'audience targeting'];
      case 'media buying':
        return ['programmatic advertising', 'PMP', 'header bidding', 'auction', 'media buying'];
      case 'user identification':
        return ['cookies', 'device fingerprinting', 'advertising ID', 'user tracking', 'cross-device'];
      case 'ad fraud and privacy':
        return ['ad fraud', 'viewability', 'GDPR', 'CCPA', 'brand safety', 'privacy'];
      case 'attribution':
        return ['attribution', 'cross-device attribution', 'multi-touch attribution', 'conversion tracking'];
      default:
        return ['RTB', 'DSP', 'targeting', 'attribution', 'ad fraud'];
    }
  }

  static Future<Question?> _generateQuestionForConcept(String concept, String category, {String language = 'en'}) async {
    try {
      final template = _questionTemplates[_random.nextInt(_questionTemplates.length)];
      final questionText = template.replaceAll('{concept}', concept);
      
      final correctAnswer = _adtechConcepts[concept] ?? 'Information about $concept in digital advertising';
      final wrongAnswers = _generateWrongAnswers(concept, category);
      
      final allOptions = [correctAnswer, ...wrongAnswers];
      allOptions.shuffle();
      
      final correctIndex = allOptions.indexOf(correctAnswer);
      
      return Question(
        id: '${category}_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
        question: questionText,
        options: allOptions,
        correctAnswerIndex: correctIndex,
        explanation: _generateExplanation(concept, correctAnswer, language),
        category: category,
      );
    } catch (e) {
      print('Error generating question for concept $concept: $e');
      return null;
    }
  }

  static List<String> _generateWrongAnswers(String correctConcept, String category) {
    final wrongAnswers = <String>[];
    final allConcepts = _adtechConcepts.keys.toList();
    
    allConcepts.remove(correctConcept);
    allConcepts.shuffle();
    
    for (int i = 0; i < 3 && i < allConcepts.length; i++) {
      final wrongConcept = allConcepts[i];
      final wrongAnswer = _adtechConcepts[wrongConcept] ?? 'Information about $wrongConcept';
      wrongAnswers.add(wrongAnswer);
    }
    
    while (wrongAnswers.length < 3) {
      wrongAnswers.add(_getGenericWrongAnswer(category));
    }
    
    return wrongAnswers;
  }

  static String _getGenericWrongAnswer(String category) {
    final genericAnswers = [
      'A technology used for managing digital content',
      'A platform for social media advertising',
      'A tool for website analytics',
      'A system for email marketing',
      'A solution for customer relationship management',
    ];
    
    return genericAnswers[_random.nextInt(genericAnswers.length)];
  }

  static String _generateExplanation(String concept, String correctAnswer, String language) {
    if (language == 'ja') {
      return '$conceptについて：$correctAnswer。この概念はデジタル広告において重要な役割を果たしています。';
    }
    
    return 'Explanation: $correctAnswer. This concept plays a crucial role in digital advertising and helps advertisers achieve their marketing objectives.';
  }

  // Validate answer using local logic
  static bool validateAnswer(String question, String userAnswer, String correctAnswer, String bookContent) {
    final correctTerms = _extractKeyTerms(correctAnswer);
    final userTerms = _extractKeyTerms(userAnswer);
    
    int matches = 0;
    for (final term in correctTerms) {
      if (userTerms.contains(term)) {
        matches++;
      }
    }
    
    return matches >= (correctTerms.length * 0.5);
  }

  static List<String> _extractKeyTerms(String text) {
    final words = text.toLowerCase().split(' ');
    final keyTerms = <String>[];
    
    for (final word in words) {
      if (word.length > 3 && !_isCommonWord(word)) {
        keyTerms.add(word);
      }
    }
    
    return keyTerms;
  }

  static bool _isCommonWord(String word) {
    const commonWords = {
      'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'had', 'her', 'was', 'one', 'our', 'out', 'day', 'get', 'has', 'him', 'his', 'how', 'man', 'new', 'now', 'old', 'see', 'two', 'way', 'who', 'boy', 'did', 'its', 'let', 'put', 'say', 'she', 'too', 'use'
    };
    
    return commonWords.contains(word);
  }

  // Generate explanation for any answer
  static String generateExplanation(String question, String answer, String bookContent) {
    return 'This answer explains the concept in the context of digital advertising. The explanation is based on industry best practices and the content from the AdTech book.';
  }

  // Test the local generator
  static Future<bool> testLocalGeneration() async {
    try {
      final testContent = 'RTB is an automated auction process for buying and selling ad impressions in real-time.';
      final questions = await generateQuestionsFromContent(testContent, 'AdTech Platforms');
      return questions.isNotEmpty;
    } catch (e) {
      print('Error testing local generation: $e');
      return false;
    }
  }

  // Get status message
  static String getStatusMessage() {
    return 'Local question generation is available. No external API required.';
  }
} 