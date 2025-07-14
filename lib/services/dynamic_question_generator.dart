import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz_models.dart';
import 'local_question_generator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DynamicQuestionGenerator {
  // You can set your OpenAI API key here or use environment variables
  static const String _openaiUrl = 'https://api.openai.com/v1/chat/completions';
  
  // Check if API key is valid
  static bool get isApiKeyValid {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    return apiKey != null && apiKey.isNotEmpty && 
           apiKey != 'YOUR_OPENAI_API_KEY' && 
           apiKey.length > 20;
  }
  
  static Future<List<Question>> generateQuestionsFromContent(String content, String category, {String language = 'en'}) async {
    try {
      // First try to generate questions using AI from book content
      if (isApiKeyValid) {
        final questions = await _generateQuestionsWithAI(content, category, language: language);
        if (questions.isNotEmpty) {
          print('Successfully generated ${questions.length} questions for category: $category in $language using AI');
          return questions;
        }
      }
    } catch (e) {
      print('AI generation failed: $e');
    }
    
    // If AI fails or API key is invalid, use local generation
    print('Using local question generation for category: $category in $language');
    try {
      final questions = await LocalQuestionGenerator.generateQuestionsFromContent(content, category, language: language);
      if (questions.isNotEmpty) {
        print('Successfully generated ${questions.length} questions for category: $category in $language using local generation');
        return questions;
      }
    } catch (e) {
      print('Local generation failed: $e');
    }
    
    // If both fail, use fallback questions
    print('Using fallback questions for category: $category in $language');
    return generateFallbackQuestions(category, language: language);
  }
  
  static Future<List<Question>> _generateQuestionsWithAI(String content, String category, {String language = 'en'}) async {
    if (!isApiKeyValid) {
      print('OpenAI API key not configured - using fallback questions');
      return generateFallbackQuestions(category);
    }
    
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not found. Please set OPENAI_API_KEY in your .env file.');
    }

    // Truncate content if too long but keep more content for better questions
    final truncatedContent = content.length > 3000 ? content.substring(0, 3000) + '...' : content;
    
    final languageInstruction = language == 'ja' 
        ? 'Generate all content in Japanese (日本語). Questions, options, and explanations must be in Japanese.'
        : 'Generate all content in English.';
    
    final prompt = '''
    Generate 5 multiple choice questions based on the following AdTech book content. 
    Each question should have 4 options (A, B, C, D) with only one correct answer.
    Also provide a brief explanation for the correct answer.
    
    $languageInstruction
    
    Content from AdTech Book: $truncatedContent
    Category: $category
    
    Requirements:
    - Questions must be based ONLY on the provided book content
    - All options should be plausible but only one should be correct
    - Explanations should reference specific parts of the book content
    - Questions should test understanding, not just memorization
    - Make questions challenging but fair
    - Ensure all questions are directly related to the category
    - All text must be in $language
    
    Format the response as JSON:
    {
      "questions": [
        {
          "question": "Question text here?",
          "options": ["Option A", "Option B", "Option C", "Option D"],
          "correctAnswerIndex": 0,
          "explanation": "Explanation for why this is correct based on the book content"
        }
      ]
    }
    ''';
    
    try {
      print('Attempting to generate questions for category: $category');
      print('Content length: ${content.length} characters');
      
      final response = await http.post(
        Uri.parse(_openaiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      ).timeout(const Duration(seconds: 30));
      
      print('OpenAI API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        print('OpenAI response content length: ${content.length}');
        
        // Extract JSON from the response
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          final jsonData = jsonDecode(jsonMatch.group(0)!);
          final questions = jsonData['questions'] as List;
          print('Successfully generated ${questions.length} questions for category: $category');
          
          return questions.asMap().entries.map((entry) {
            final index = entry.key;
            final q = entry.value;
            return Question(
              id: '${category}_${DateTime.now().millisecondsSinceEpoch}_$index',
              question: q['question'] as String,
              options: List<String>.from(q['options'] as List),
              correctAnswerIndex: q['correctAnswerIndex'] as int,
              explanation: q['explanation'] as String,
              category: category,
            );
          }).toList();
        } else {
          print('Failed to extract JSON from OpenAI response');
          print('Response content: $content');
        }
      } else {
        print('OpenAI API error: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 401) {
          print('Authentication failed - check API key');
        } else if (response.statusCode == 429) {
          print('Rate limit exceeded');
        }
      }
    } catch (e) {
      print('Error calling OpenAI API: $e');
    }
    
    print('Falling back to generated questions for category: $category');
    return generateFallbackQuestions(category, language: language);
  }

  // Validate answer against book content using AI
  static Future<bool> validateAnswerWithAI(String question, String userAnswer, String correctAnswer, String bookContent) async {
    if (!isApiKeyValid) {
      // Use local validation when API is not available
      return LocalQuestionGenerator.validateAnswer(question, userAnswer, correctAnswer, bookContent);
    }
    
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not found. Please set OPENAI_API_KEY in your .env file.');
    }

    final prompt = '''
    Based on the following AdTech book content, validate if the user's answer is correct.
    
    Book Content: $bookContent
    
    Question: $question
    Correct Answer: $correctAnswer
    User's Answer: $userAnswer
    
    Determine if the user's answer is correct based on the book content. 
    Consider partial correctness and alternative phrasings.
    
    Respond with only "true" if the answer is correct, or "false" if incorrect.
    ''';
    
    try {
      final response = await http.post(
        Uri.parse(_openaiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.1,
          'max_tokens': 10,
        }),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].trim().toLowerCase();
        return content == 'true';
      }
    } catch (e) {
      print('Error validating answer with AI: $e');
    }
    
    // Fallback to local validation
    return LocalQuestionGenerator.validateAnswer(question, userAnswer, correctAnswer, bookContent);
  }

  // Generate explanation for any answer using book content
  static Future<String> generateExplanationWithAI(String question, String answer, String bookContent) async {
    if (!isApiKeyValid) {
      // Use local explanation generation when API is not available
      return LocalQuestionGenerator.generateExplanation(question, answer, bookContent);
    }
    
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not found. Please set OPENAI_API_KEY in your .env file.');
    }

    final prompt = '''
    Based on the following AdTech book content, provide a clear explanation for the answer to this question.
    
    Book Content: $bookContent
    
    Question: $question
    Answer: $answer
    
    Provide a concise explanation that references the book content and explains why this answer is correct or incorrect.
    ''';
    
    try {
      final response = await http.post(
        Uri.parse(_openaiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      ).timeout(const Duration(seconds: 20));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      }
    } catch (e) {
      print('Error generating explanation with AI: $e');
    }
    
    // Fallback to local explanation generation
    return LocalQuestionGenerator.generateExplanation(question, answer, bookContent);
  }

  // Extract content from PDF file
  static Future<String> extractContentFromPDF(String pdfPath) async {
    try {
      // This would require a PDF parsing library
      // For now, we'll return a placeholder
      return 'AdTech content placeholder';
    } catch (e) {
      print('Error extracting PDF content: $e');
      return '';
    }
  }
  
  // Generate questions by chapter
  static Future<List<Question>> generateQuestionsByChapter(String chapter) async {
    // This would extract content from specific chapters
    return [];
  }
  
  // Fallback questions when AI generation fails
  static List<Question> generateFallbackQuestions(String category, {String language = 'en'}) {
    final fallbackQuestions = language == 'ja' 
        ? _getJapaneseFallbackQuestions()
        : _getEnglishFallbackQuestions();
    final questions = fallbackQuestions[category] ?? fallbackQuestions['Advertising Basics']!;
    return questions.asMap().entries.map((entry) {
      final index = entry.key;
      final q = entry.value;
      final options = List<String>.from(q['options'] as List);
      final correctAnswer = options[q['correctAnswerIndex'] as int];
      options.shuffle();
      final newCorrectIndex = options.indexOf(correctAnswer);
      return Question(
        id: '${category}_fallback_${DateTime.now().millisecondsSinceEpoch}_$index',
        question: q['question'] as String,
        options: options,
        correctAnswerIndex: newCorrectIndex,
        explanation: q['explanation'] as String,
        category: category,
      );
    }).toList();
  }

  static Map<String, List<Map<String, dynamic>>> _getEnglishFallbackQuestions() {
    return <String, List<Map<String, dynamic>>>{
      'Advertising Basics': [
        {
          'question': 'What are the two key players in the digital advertising ecosystem?',
          'options': ['Advertiser and Publisher', 'Buyer and Seller', 'Brand and Agency', 'Platform and User'],
          'correctAnswerIndex': 0,
          'explanation': 'The advertiser-publisher relationship is fundamental to digital advertising, where advertisers want to reach their target audience and publishers provide the content that attracts that audience.'
        },
        {
          'question': 'What is the primary goal of an advertiser in digital advertising?',
          'options': ['To build brand awareness and increase sales', 'To create content', 'To manage technology', 'To collect data'],
          'correctAnswerIndex': 0,
          'explanation': 'Advertisers want to get their product or service in front of their target audience to build brand awareness, develop brand loyalty, and increase sales.'
        },
        {
          'question': 'What does AdTech refer to in digital advertising?',
          'options': ['Software and tools for digital advertising', 'Advertising content', 'User data', 'Marketing strategies'],
          'correctAnswerIndex': 0,
          'explanation': 'Advertising technology refers to the software and tools used to create, run, manage, measure, and optimize digital advertising campaigns.'
        },
        {
          'question': 'Which of the following is NOT a typical participant in the digital advertising ecosystem?',
          'options': ['Content creators', 'Ad networks', 'Data providers', 'Technology platforms'],
          'correctAnswerIndex': 0,
          'explanation': 'While content creators may be involved, the main ecosystem participants are advertisers, agencies, publishers, ad networks, ad exchanges, data providers, and technology platforms.'
        },
        {
          'question': 'What has significantly evolved the digital advertising ecosystem?',
          'options': ['Programmatic advertising', 'Social media', 'Mobile devices', 'Video content'],
          'correctAnswerIndex': 0,
          'explanation': 'The ecosystem has evolved significantly with the introduction of programmatic advertising, which automates the buying and selling of ad inventory.'
        }
      ],
      'AdTech Platforms': [
        {
          'question': 'What are the two main types of ad servers?',
          'options': ['First-party and third-party', 'Primary and secondary', 'Direct and indirect', 'Internal and external'],
          'correctAnswerIndex': 0,
          'explanation': 'First-party ad servers are owned and operated by publishers, while third-party ad servers are independent technology platforms.'
        },
        {
          'question': 'What does RTB stand for in programmatic advertising?',
          'options': ['Real-Time Bidding', 'Real-Time Buying', 'Real-Time Budgeting', 'Real-Time Broadcasting'],
          'correctAnswerIndex': 0,
          'explanation': 'Real-Time Bidding (RTB) is an automated auction process for buying and selling ad impressions in real-time.'
        },
        {
          'question': 'What is the primary function of a DSP?',
          'options': ['To buy ad inventory from multiple sources', 'To sell ad inventory', 'To collect user data', 'To create ad content'],
          'correctAnswerIndex': 0,
          'explanation': 'Demand-Side Platforms (DSPs) allow advertisers to buy ad inventory from multiple sources through a single interface.'
        },
        {
          'question': 'What is the main purpose of header bidding?',
          'options': ['To increase competition and publisher revenue', 'To reduce ad load times', 'To improve user experience', 'To save bandwidth'],
          'correctAnswerIndex': 0,
          'explanation': 'Header bidding allows multiple ad exchanges to bid on ad inventory simultaneously, increasing competition and publisher revenue.'
        },
        {
          'question': 'What type of marketplace is an ad exchange?',
          'options': ['Digital marketplace for ad space', 'Physical marketplace', 'Social media platform', 'Content management system'],
          'correctAnswerIndex': 0,
          'explanation': 'Ad exchanges are digital marketplaces that enable advertisers and publishers to buy and sell ad space in real-time.'
        }
      ],
      'Targeting and Data': [
        {
          'question': 'What is contextual targeting based on?',
          'options': ['The content of the webpage', 'User behavior', 'Demographics', 'Geographic location'],
          'correctAnswerIndex': 0,
          'explanation': 'Contextual targeting displays ads based on the content of the webpage where the ad appears.'
        },
        {
          'question': 'What does behavioral targeting use to serve relevant ads?',
          'options': ['User actions and browsing history', 'Webpage content', 'Geographic data', 'Demographic information'],
          'correctAnswerIndex': 0,
          'explanation': 'Behavioral targeting uses data about user actions and browsing history to serve relevant ads.'
        },
        {
          'question': 'What is retargeting?',
          'options': ['Showing ads to previous website visitors', 'Targeting new audiences', 'Changing ad content', 'Optimizing ad placement'],
          'correctAnswerIndex': 0,
          'explanation': 'Retargeting shows ads to users who have previously visited a website or interacted with a brand.'
        },
        {
          'question': 'What is the main function of a DMP?',
          'options': ['To collect, organize, and activate audience data', 'To create ad content', 'To manage ad campaigns', 'To track conversions'],
          'correctAnswerIndex': 0,
          'explanation': 'Data Management Platforms (DMPs) collect, organize, and activate audience data for advertising.'
        },
        {
          'question': 'What is lookalike targeting used for?',
          'options': ['Finding new potential customers similar to existing ones', 'Targeting competitors', 'Creating new audiences', 'Analyzing market trends'],
          'correctAnswerIndex': 0,
          'explanation': 'Lookalike targeting identifies new potential customers who share similar characteristics with existing customers.'
        }
      ],
      'Media Buying': [
        {
          'question': 'What is programmatic media buying?',
          'options': ['Automated buying and selling of ad inventory', 'Manual ad buying', 'Direct publisher relationships', 'Traditional advertising'],
          'correctAnswerIndex': 0,
          'explanation': 'Programmatic media buying uses technology to automate the buying and selling of ad inventory.'
        },
        {
          'question': 'What is a Private Marketplace (PMP)?',
          'options': ['Invitation-only marketplace for premium inventory', 'Public auction marketplace', 'Direct buying platform', 'Social media advertising'],
          'correctAnswerIndex': 0,
          'explanation': 'Private Marketplaces (PMP) are invitation-only marketplaces where premium ad inventory is sold to select advertisers.'
        },
        {
          'question': 'In a second-price auction, what does the winner pay?',
          'options': ['The second-highest bid amount', 'Their own bid amount', 'The average of all bids', 'A fixed price'],
          'correctAnswerIndex': 0,
          'explanation': 'In second-price auctions, the winner pays the second-highest bid amount.'
        },
        {
          'question': 'What is the main advantage of header bidding for publishers?',
          'options': ['Increased competition and higher revenue', 'Faster ad loading', 'Better user experience', 'Lower costs'],
          'correctAnswerIndex': 0,
          'explanation': 'Header bidding allows publishers to offer their inventory to multiple ad exchanges simultaneously, increasing competition and revenue.'
        },
        {
          'question': 'Which method is NOT typically part of programmatic advertising?',
          'options': ['Manual negotiation', 'Real-Time Bidding', 'Private Marketplaces', 'Programmatic Direct'],
          'correctAnswerIndex': 0,
          'explanation': 'Manual negotiation is not part of programmatic advertising, which is automated. RTB, PMP, and Programmatic Direct are all programmatic methods.'
        }
      ],
      'User Identification': [
        {
          'question': 'What are cookies used for in advertising?',
          'options': ['To identify and track users across websites', 'To store user preferences', 'To improve website performance', 'To create user accounts'],
          'correctAnswerIndex': 0,
          'explanation': 'Cookies are small text files used to identify and track users across websites for advertising purposes.'
        },
        {
          'question': 'What is device fingerprinting?',
          'options': ['Identifying devices based on unique characteristics', 'Creating device profiles', 'Tracking device location', 'Managing device settings'],
          'correctAnswerIndex': 0,
          'explanation': 'Device fingerprinting identifies devices based on unique characteristics like browser settings, screen resolution, and installed fonts.'
        },
        {
          'question': 'What are Advertising IDs used for?',
          'options': ['Tracking user behavior across apps and websites', 'Creating user accounts', 'Managing app permissions', 'Storing user data'],
          'correctAnswerIndex': 0,
          'explanation': 'Advertising IDs are unique identifiers assigned to mobile devices for advertising and tracking purposes.'
        },
        {
          'question': 'What challenge is user identification facing?',
          'options': ['Privacy regulations and browser restrictions', 'Technology limitations', 'Cost constraints', 'User resistance'],
          'correctAnswerIndex': 0,
          'explanation': 'User identification is becoming more challenging due to privacy regulations and browser restrictions on third-party cookies.'
        },
        {
          'question': 'What is cross-device identification used for?',
          'options': ['Recognizing the same user across multiple devices', 'Creating device profiles', 'Managing multiple accounts', 'Tracking device performance'],
          'correctAnswerIndex': 0,
          'explanation': 'Cross-device identification allows advertisers to recognize the same user across multiple devices.'
        }
      ],
      'Ad Fraud and Privacy': [
        {
          'question': 'What is ad fraud?',
          'options': ['Deliberate deception to generate invalid impressions', 'Accidental ad misplacement', 'Poor ad performance', 'Technical errors'],
          'correctAnswerIndex': 0,
          'explanation': 'Ad fraud involves deliberate deception to generate invalid ad impressions or clicks, costing advertisers billions annually.'
        },
        {
          'question': 'What is ad viewability?',
          'options': ['Whether ads are actually seen by users', 'Ad click-through rates', 'Ad performance metrics', 'Ad placement quality'],
          'correctAnswerIndex': 0,
          'explanation': 'Ad viewability measures whether ads are actually seen by users, typically requiring 50% of the ad to be visible for at least 1 second.'
        },
        {
          'question': 'What do privacy regulations like GDPR protect?',
          'options': ['User data and consumer control', 'Advertiser interests', 'Publisher revenue', 'Technology platforms'],
          'correctAnswerIndex': 0,
          'explanation': 'Privacy regulations like GDPR protect user data and give consumers control over how their information is collected and used.'
        },
        {
          'question': 'What is brand safety?',
          'options': ['Ensuring ads appear in appropriate contexts', 'Protecting brand logos', 'Managing brand reputation', 'Creating brand guidelines'],
          'correctAnswerIndex': 0,
          'explanation': 'Brand safety measures ensure that ads appear in appropriate contexts and don\'t appear alongside content that could damage a brand\'s reputation.'
        },
        {
          'question': 'What is the typical viewability standard for display ads?',
          'options': ['50% visible for 1 second', '100% visible for 1 second', '25% visible for 2 seconds', '75% visible for 0.5 seconds'],
          'correctAnswerIndex': 0,
          'explanation': 'Viewability standards typically require 50% of the ad to be visible for at least 1 second.'
        }
      ],
      'Attribution': [
        {
          'question': 'What is attribution in advertising?',
          'options': ['Assigning credit for conversions to touchpoints', 'Tracking ad performance', 'Measuring ROI', 'Analyzing user behavior'],
          'correctAnswerIndex': 0,
          'explanation': 'Attribution is the process of assigning credit for conversions to specific touchpoints in the customer journey.'
        },
        {
          'question': 'What is cross-device attribution?',
          'options': ['Tracking behavior across multiple devices', 'Single device tracking', 'Multi-channel marketing', 'Device-specific campaigns'],
          'correctAnswerIndex': 0,
          'explanation': 'Cross-device attribution tracks user behavior and conversions across multiple devices to provide a complete view of the customer journey.'
        },
        {
          'question': 'What do multi-touch attribution models consider?',
          'options': ['All touchpoints in the customer journey', 'Only the first touchpoint', 'Only the last touchpoint', 'Only direct traffic'],
          'correctAnswerIndex': 0,
          'explanation': 'Multi-touch attribution models consider all touchpoints in the customer journey, not just the first or last interaction.'
        },
        {
          'question': 'What is last-click attribution?',
          'options': ['Giving all credit to the final touchpoint', 'Giving credit to all touchpoints', 'Giving credit to the first touchpoint', 'Giving equal credit'],
          'correctAnswerIndex': 0,
          'explanation': 'Last-click attribution gives all credit to the final touchpoint before conversion.'
        },
        {
          'question': 'What is the limitation of first-click attribution?',
          'options': ['It may not reflect true contribution of each touchpoint', 'It\'s too complex to implement', 'It requires too much data', 'It\'s not accurate'],
          'correctAnswerIndex': 0,
          'explanation': 'First-click attribution gives all credit to the initial touchpoint, which may not accurately reflect the true contribution of each touchpoint.'
        }
      ],
      'Personalization & A/B Testing': [
        {
          'question': 'What is the main goal of personalization in marketing?',
          'options': ['To tailor messages to individual users', 'To automate workflows', 'To increase ad spend', 'To reduce content creation'],
          'correctAnswerIndex': 0,
          'explanation': 'Personalization aims to deliver relevant content and experiences to each user based on their preferences and behavior.'
        },
        {
          'question': 'What does A/B testing help marketers determine?',
          'options': ['Which version of content performs better', 'How to automate emails', 'The best CRM vendor', 'The most popular social network'],
          'correctAnswerIndex': 0,
          'explanation': 'A/B testing compares two versions of a webpage or app to see which one achieves better results.'
        },
        {
          'question': 'Which of the following is NOT a use case for A/B testing?',
          'options': ['Choosing a subject line', 'Optimizing landing pages', 'Managing customer data', 'Testing call-to-action buttons'],
          'correctAnswerIndex': 2,
          'explanation': 'Managing customer data is not a direct use case for A/B testing.'
        },
      ],
      'Marketing Automation': [
        {
          'question': 'What is marketing automation primarily used for?',
          'options': ['Automating repetitive marketing tasks', 'Designing websites', 'Managing payroll', 'Creating ad creatives'],
          'correctAnswerIndex': 0,
          'explanation': 'Marketing automation platforms help automate tasks like email campaigns, lead nurturing, and workflow management.'
        },
        {
          'question': 'Which of the following is a feature of marketing automation?',
          'options': ['Lead nurturing', 'Manual data entry', 'Offline advertising', 'Print media management'],
          'correctAnswerIndex': 0,
          'explanation': 'Lead nurturing is a core feature of marketing automation platforms.'
        },
        {
          'question': 'What is a drip campaign?',
          'options': ['A series of automated emails sent over time', 'A type of social media ad', 'A CRM feature', 'A web analytics tool'],
          'correctAnswerIndex': 0,
          'explanation': 'Drip campaigns are automated sets of emails sent based on specific timelines or user actions.'
        },
      ],
      'CRM': [
        {
          'question': 'What does CRM stand for?',
          'options': ['Customer Relationship Management', 'Content Resource Management', 'Campaign Reporting Mechanism', 'Customer Retention Model'],
          'correctAnswerIndex': 0,
          'explanation': 'CRM stands for Customer Relationship Management.'
        },
        {
          'question': 'Which of the following is a primary function of a CRM system?',
          'options': ['Managing customer data', 'Sending mass emails', 'Designing websites', 'Running A/B tests'],
          'correctAnswerIndex': 0,
          'explanation': 'CRM systems are used to manage and analyze customer interactions and data.'
        },
        {
          'question': 'Which company is known for its CRM platform?',
          'options': ['Salesforce', 'Mailchimp', 'Google Analytics', 'WordPress'],
          'correctAnswerIndex': 0,
          'explanation': 'Salesforce is a leading CRM platform.'
        },
      ],
      'Email Marketing': [
        {
          'question': 'What is a common metric to measure email marketing success?',
          'options': ['Open rate', 'Page load time', 'Ad impressions', 'Bounce rate'],
          'correctAnswerIndex': 0,
          'explanation': 'Open rate measures how many recipients open an email.'
        },
        {
          'question': 'Which tool is widely used for email marketing?',
          'options': ['Mailchimp', 'Salesforce', 'Google Ads', 'Figma'],
          'correctAnswerIndex': 0,
          'explanation': 'Mailchimp is a popular email marketing platform.'
        },
        {
          'question': 'What is a subscriber list?',
          'options': ['A list of people who have opted in to receive emails', 'A list of website pages', 'A list of ad campaigns', 'A list of CRM contacts only'],
          'correctAnswerIndex': 0,
          'explanation': 'A subscriber list is a collection of email addresses of people who have opted in to receive communications.'
        },
      ],
      'Content Marketing': [
        {
          'question': 'What is the main goal of content marketing?',
          'options': ['To attract and retain a clearly defined audience', 'To increase ad spend', 'To automate emails', 'To manage payroll'],
          'correctAnswerIndex': 0,
          'explanation': 'Content marketing aims to attract and retain customers by creating valuable content.'
        },
        {
          'question': 'Which of the following is a content marketing format?',
          'options': ['Blog post', 'TV commercial', 'Billboard', 'Direct mail'],
          'correctAnswerIndex': 0,
          'explanation': 'Blog posts are a common format in content marketing.'
        },
        {
          'question': 'What is an editorial calendar used for?',
          'options': ['Planning and scheduling content', 'Tracking ad spend', 'Managing CRM contacts', 'Running A/B tests'],
          'correctAnswerIndex': 0,
          'explanation': 'Editorial calendars help marketers plan and schedule content publication.'
        },
      ],
      'Social Media Marketing': [
        {
          'question': 'Which platform is commonly used for B2B social media marketing?',
          'options': ['LinkedIn', 'Instagram', 'Snapchat', 'Pinterest'],
          'correctAnswerIndex': 0,
          'explanation': 'LinkedIn is widely used for B2B social media marketing.'
        },
        {
          'question': 'What is a social media campaign?',
          'options': ['A coordinated marketing effort on one or more platforms', 'A type of email automation', 'A CRM feature', 'A web analytics tool'],
          'correctAnswerIndex': 0,
          'explanation': 'A social media campaign is a coordinated effort to reinforce or assist with a business goal using one or more social media platforms.'
        },
        {
          'question': 'What does engagement mean in social media marketing?',
          'options': ['Interactions such as likes, comments, and shares', 'Number of emails sent', 'Website bounce rate', 'CRM pipeline stages'],
          'correctAnswerIndex': 0,
          'explanation': 'Engagement refers to how users interact with social media content.'
        },
      ],
      'Web Analytics': [
        {
          'question': 'What is bounce rate in web analytics?',
          'options': ['The percentage of visitors who leave after viewing one page', 'The number of emails opened', 'The number of social media likes', 'The number of CRM contacts'],
          'correctAnswerIndex': 0,
          'explanation': 'Bounce rate measures the percentage of visitors who navigate away after viewing only one page.'
        },
        {
          'question': 'Which tool is commonly used for web analytics?',
          'options': ['Google Analytics', 'Salesforce', 'Mailchimp', 'HubSpot'],
          'correctAnswerIndex': 0,
          'explanation': 'Google Analytics is a leading web analytics tool.'
        },
        {
          'question': 'What does a conversion rate measure?',
          'options': ['The percentage of visitors who complete a desired action', 'The number of emails sent', 'The number of social posts', 'The number of CRM deals'],
          'correctAnswerIndex': 0,
          'explanation': 'Conversion rate measures how many visitors complete a desired goal out of the total number of visitors.'
        },
      ],
      'Customer Data Platforms': [
        {
          'question': 'What is a Customer Data Platform (CDP)?',
          'options': ['A system that unifies customer data from multiple sources', 'A type of CRM', 'An email marketing tool', 'A web analytics platform'],
          'correctAnswerIndex': 0,
          'explanation': 'A CDP collects and unifies customer data from multiple sources to create a single customer profile.'
        },
        {
          'question': 'Which of the following is a benefit of using a CDP?',
          'options': ['Better segmentation and personalization', 'Increased ad spend', 'Automated payroll', 'Manual data entry'],
          'correctAnswerIndex': 0,
          'explanation': 'CDPs enable better segmentation and personalization for marketing.'
        },
        {
          'question': 'What is identity resolution in the context of CDPs?',
          'options': ['Matching data from different sources to the same customer', 'Sending automated emails', 'Running A/B tests', 'Managing social media'],
          'correctAnswerIndex': 0,
          'explanation': 'Identity resolution is the process of matching data from different sources to a single customer profile.'
        },
      ],
    };
  }

  static Map<String, List<Map<String, dynamic>>> _getJapaneseFallbackQuestions() {
    return <String, List<Map<String, dynamic>>>{
      'Advertising Basics': [
        {
          'question': 'デジタル広告エコシステムの2つの主要プレイヤーは何ですか？',
          'options': ['広告主とパブリッシャー', 'バイヤーとセラー', 'ブランドとエージェンシー', 'プラットフォームとユーザー'],
          'correctAnswerIndex': 0,
          'explanation': '広告主とパブリッシャーの関係はデジタル広告の基本であり、広告主はターゲットオーディエンスにリーチしたいと考え、パブリッシャーはそのオーディエンスを引き付けるコンテンツを提供します。'
        },
        {
          'question': 'デジタル広告における広告主の主な目標は何ですか？',
          'options': ['ブランド認知度の向上と売上の増加', 'コンテンツの作成', '技術の管理', 'データの収集'],
          'correctAnswerIndex': 0,
          'explanation': '広告主は、ターゲットオーディエンスの前に自社の製品やサービスを提示して、ブランド認知度を高め、ブランドロイヤルティを育成し、売上を増やしたいと考えています。'
        },
        {
          'question': 'デジタル広告におけるAdTechとは何を指しますか？',
          'options': ['デジタル広告のためのソフトウェアとツール', '広告コンテンツ', 'ユーザーデータ', 'マーケティング戦略'],
          'correctAnswerIndex': 0,
          'explanation': '広告技術（AdTech）とは、デジタル広告キャンペーンの作成、実行、管理、測定、最適化に使用されるソフトウェアとツールを指します。'
        },
        {
          'question': 'デジタル広告エコシステムの典型的な参加者でないものはどれですか？',
          'options': ['コンテンツクリエイター', 'アドネットワーク', 'データプロバイダー', '技術プラットフォーム'],
          'correctAnswerIndex': 0,
          'explanation': 'コンテンツクリエイターも関与する場合がありますが、主要なエコシステム参加者は広告主、エージェンシー、パブリッシャー、アドネットワーク、アドエクスチェンジ、データプロバイダー、技術プラットフォームです。'
        },
        {
          'question': 'デジタル広告エコシステムを大きく進化させたものは何ですか？',
          'options': ['プログラム化広告', 'ソーシャルメディア', 'モバイルデバイス', '動画コンテンツ'],
          'correctAnswerIndex': 0,
          'explanation': 'エコシステムは、広告在庫の売買を自動化するプログラム化広告の導入により大きく進化しました。'
        }
      ],
      'AdTech Platforms': [
        {
          'question': 'アドサーバーの2つの主要タイプは何ですか？',
          'options': ['ファーストパーティとサードパーティ', 'プライマリとセカンダリ', 'ダイレクトとインダイレクト', '内部と外部'],
          'correctAnswerIndex': 0,
          'explanation': 'ファーストパーティアドサーバーはパブリッシャーが所有・運営し、サードパーティアドサーバーは独立した技術プラットフォームです。'
        },
        {
          'question': 'プログラム化広告におけるRTBは何を表しますか？',
          'options': ['リアルタイム入札', 'リアルタイム購入', 'リアルタイム予算管理', 'リアルタイム放送'],
          'correctAnswerIndex': 0,
          'explanation': 'リアルタイム入札（RTB）は、広告インプレッションの売買をリアルタイムで行う自動化されたオークションプロセスです。'
        },
        {
          'question': 'DSPの主な機能は何ですか？',
          'options': ['複数のソースから広告在庫を購入する', '広告在庫を販売する', 'ユーザーデータを収集する', '広告コンテンツを作成する'],
          'correctAnswerIndex': 0,
          'explanation': 'デマンドサイドプラットフォーム（DSP）は、広告主が単一のインターフェースを通じて複数のソースから広告在庫を購入できるようにします。'
        },
        {
          'question': 'ヘッダー入札の主な目的は何ですか？',
          'options': ['競争とパブリッシャーの収益を増加させる', '広告の読み込み時間を短縮する', 'ユーザーエクスペリエンスを向上させる', '帯域幅を節約する'],
          'correctAnswerIndex': 0,
          'explanation': 'ヘッダー入札により、複数のアドエクスチェンジが同時に広告在庫に入札でき、競争とパブリッシャーの収益が増加します。'
        },
        {
          'question': 'アドエクスチェンジはどのような種類のマーケットプレイスですか？',
          'options': ['広告スペースのデジタルマーケットプレイス', '物理的マーケットプレイス', 'ソーシャルメディアプラットフォーム', 'コンテンツ管理システム'],
          'correctAnswerIndex': 0,
          'explanation': 'アドエクスチェンジは、広告主とパブリッシャーがリアルタイムで広告スペースを売買できるデジタルマーケットプレイスです。'
        }
      ],
      'Targeting and Data': [
        {
          'question': 'コンテキストターゲティングは何に基づいていますか？',
          'options': ['ウェブページのコンテンツ', 'ユーザーの行動', '人口統計', '地理的位置'],
          'correctAnswerIndex': 0,
          'explanation': 'コンテキストターゲティングは、広告が表示されるウェブページのコンテンツに基づいて広告を表示します。'
        },
        {
          'question': '行動ターゲティングは関連広告を配信するために何を使用しますか？',
          'options': ['ユーザーの行動とブラウジング履歴', 'ウェブページのコンテンツ', '地理的データ', '人口統計情報'],
          'correctAnswerIndex': 0,
          'explanation': '行動ターゲティングは、ユーザーの行動とブラウジング履歴に関するデータを使用して関連広告を配信します。'
        },
        {
          'question': 'リターゲティングとは何ですか？',
          'options': ['以前のウェブサイト訪問者に広告を表示する', '新しいオーディエンスをターゲットにする', '広告コンテンツを変更する', '広告配置を最適化する'],
          'correctAnswerIndex': 0,
          'explanation': 'リターゲティングは、以前にウェブサイトを訪問したユーザーやブランドとインタラクションしたユーザーに広告を表示します。'
        },
        {
          'question': 'DMPの主な機能は何ですか？',
          'options': ['オーディエンスデータの収集、整理、アクティベーション', '広告コンテンツの作成', '広告キャンペーンの管理', 'コンバージョンの追跡'],
          'correctAnswerIndex': 0,
          'explanation': 'データ管理プラットフォーム（DMP）は、広告のためのオーディエンスデータを収集、整理、アクティベーションします。'
        },
        {
          'question': 'ルックアライクターゲティングは何のために使用されますか？',
          'options': ['既存顧客と類似した新しい潜在顧客を見つける', '競合他社をターゲットにする', '新しいオーディエンスを作成する', '市場動向を分析する'],
          'correctAnswerIndex': 0,
          'explanation': 'ルックアライクターゲティングは、既存顧客と類似した特徴を持つ新しい潜在顧客を特定します。'
        }
      ],
      'Media Buying': [
        {
          'question': 'プログラム化メディア購入とは何ですか？',
          'options': ['広告在庫の自動売買', '手動広告購入', '直接パブリッシャー関係', '従来の広告'],
          'correctAnswerIndex': 0,
          'explanation': 'プログラム化メディア購入は、技術を使用して広告在庫の売買を自動化します。'
        },
        {
          'question': 'プライベートマーケットプレイス（PMP）とは何ですか？',
          'options': ['プレミアム在庫の招待制マーケットプレイス', '公開オークションマーケットプレイス', '直接購入プラットフォーム', 'ソーシャルメディア広告'],
          'correctAnswerIndex': 0,
          'explanation': 'プライベートマーケットプレイス（PMP）は、プレミアム広告在庫が選択された広告主に販売される招待制マーケットプレイスです。'
        },
        {
          'question': 'セカンドプライスオークションでは、勝者は何を支払いますか？',
          'options': ['2番目に高い入札額', '自分の入札額', 'すべての入札の平均', '固定価格'],
          'correctAnswerIndex': 0,
          'explanation': 'セカンドプライスオークションでは、勝者は2番目に高い入札額を支払います。'
        },
        {
          'question': 'パブリッシャーにとってヘッダー入札の主な利点は何ですか？',
          'options': ['競争の増加と収益の向上', '広告の読み込み速度向上', 'ユーザーエクスペリエンスの向上', 'コスト削減'],
          'correctAnswerIndex': 0,
          'explanation': 'ヘッダー入札により、パブリッシャーは在庫を複数のアドエクスチェンジに同時に提供でき、競争と収益が増加します。'
        },
        {
          'question': 'プログラム化広告の一部でない方法はどれですか？',
          'options': ['手動交渉', 'リアルタイム入札', 'プライベートマーケットプレイス', 'プログラム化ダイレクト'],
          'correctAnswerIndex': 0,
          'explanation': '手動交渉は自動化されたプログラム化広告の一部ではありません。RTB、PMP、プログラム化ダイレクトはすべてプログラム化方法です。'
        }
      ],
      'User Identification': [
        {
          'question': '広告におけるクッキーの用途は何ですか？',
          'options': ['ウェブサイト間でユーザーを識別・追跡する', 'ユーザー設定を保存する', 'ウェブサイトのパフォーマンスを向上させる', 'ユーザーアカウントを作成する'],
          'correctAnswerIndex': 0,
          'explanation': 'クッキーは、広告目的でウェブサイト間でユーザーを識別・追跡するために使用される小さなテキストファイルです。'
        },
        {
          'question': 'デバイスフィンガープリンティングとは何ですか？',
          'options': ['ユニークな特徴に基づいてデバイスを識別する', 'デバイスプロファイルを作成する', 'デバイスの位置を追跡する', 'デバイス設定を管理する'],
          'correctAnswerIndex': 0,
          'explanation': 'デバイスフィンガープリンティングは、ブラウザ設定、画面解像度、インストールされたフォントなどのユニークな特徴に基づいてデバイスを識別します。'
        },
        {
          'question': '広告IDは何のために使用されますか？',
          'options': ['アプリとウェブサイト間でユーザー行動を追跡する', 'ユーザーアカウントを作成する', 'アプリ権限を管理する', 'ユーザーデータを保存する'],
          'correctAnswerIndex': 0,
          'explanation': '広告IDは、広告と追跡目的でモバイルデバイスに割り当てられるユニークな識別子です。'
        },
        {
          'question': 'ユーザー識別が直面している課題は何ですか？',
          'options': ['プライバシー規制とブラウザ制限', '技術的制限', 'コスト制約', 'ユーザーの抵抗'],
          'correctAnswerIndex': 0,
          'explanation': 'ユーザー識別は、プライバシー規制とサードパーティクッキーに対するブラウザ制限により、より困難になっています。'
        },
        {
          'question': 'クロスデバイス識別は何のために使用されますか？',
          'options': ['複数のデバイス間で同じユーザーを認識する', 'デバイスプロファイルを作成する', '複数のアカウントを管理する', 'デバイスパフォーマンスを追跡する'],
          'correctAnswerIndex': 0,
          'explanation': 'クロスデバイス識別により、広告主は複数のデバイス間で同じユーザーを認識できます。'
        }
      ],
      'Ad Fraud and Privacy': [
        {
          'question': '広告詐欺とは何ですか？',
          'options': ['無効なインプレッションを生成するための意図的な欺瞞', '偶発的な広告配置ミス', '広告パフォーマンスの悪化', '技術的エラー'],
          'correctAnswerIndex': 0,
          'explanation': '広告詐欺は、無効な広告インプレッションやクリックを生成するための意図的な欺瞞を含み、広告主に年間数十億ドルの損失を与えています。'
        },
        {
          'question': '広告の視認性とは何ですか？',
          'options': ['広告が実際にユーザーに見られているかどうか', '広告のクリック率', '広告パフォーマンス指標', '広告配置の質'],
          'correctAnswerIndex': 0,
          'explanation': '広告の視認性は、広告が実際にユーザーに見られているかどうかを測定し、通常は広告の50%が少なくとも1秒間表示される必要があります。'
        },
        {
          'question': 'GDPRなどのプライバシー規制は何を保護しますか？',
          'options': ['ユーザーデータと消費者の管理', '広告主の利益', 'パブリッシャーの収益', '技術プラットフォーム'],
          'correctAnswerIndex': 0,
          'explanation': 'GDPRなどのプライバシー規制は、ユーザーデータを保護し、消費者に情報の収集・使用方法に関する管理権を与えます。'
        },
        {
          'question': 'ブランドセーフティとは何ですか？',
          'options': ['広告が適切なコンテキストで表示されることを確保する', 'ブランドロゴを保護する', 'ブランド評判を管理する', 'ブランドガイドラインを作成する'],
          'correctAnswerIndex': 0,
          'explanation': 'ブランドセーフティ対策により、広告が適切なコンテキストで表示され、ブランドの評判を損なう可能性のあるコンテンツと一緒に表示されることを防ぎます。'
        },
        {
          'question': 'ディスプレイ広告の典型的な視認性基準は何ですか？',
          'options': ['1秒間50%表示', '1秒間100%表示', '2秒間25%表示', '0.5秒間75%表示'],
          'correctAnswerIndex': 0,
          'explanation': '視認性基準では通常、広告の50%が少なくとも1秒間表示される必要があります。'
        }
      ],
      'Attribution': [
        {
          'question': '広告におけるアトリビューションとは何ですか？',
          'options': ['コンバージョンのクレジットをタッチポイントに割り当てる', '広告パフォーマンスを追跡する', 'ROIを測定する', 'ユーザー行動を分析する'],
          'correctAnswerIndex': 0,
          'explanation': 'アトリビューションは、コンバージョンのクレジットをカスタマージャーニーの特定のタッチポイントに割り当てるプロセスです。'
        },
        {
          'question': 'クロスデバイスアトリビューションとは何ですか？',
          'options': ['複数のデバイス間で行動を追跡する', '単一デバイス追跡', 'マルチチャネルマーケティング', 'デバイス固有キャンペーン'],
          'correctAnswerIndex': 0,
          'explanation': 'クロスデバイスアトリビューションは、複数のデバイス間でユーザー行動とコンバージョンを追跡し、カスタマージャーニーの完全なビューを提供します。'
        },
        {
          'question': 'マルチタッチアトリビューションモデルは何を考慮しますか？',
          'options': ['カスタマージャーニーのすべてのタッチポイント', '最初のタッチポイントのみ', '最後のタッチポイントのみ', 'ダイレクトトラフィックのみ'],
          'correctAnswerIndex': 0,
          'explanation': 'マルチタッチアトリビューションモデルは、最初または最後のインタラクションだけでなく、カスタマージャーニーのすべてのタッチポイントを考慮します。'
        },
        {
          'question': 'ラストクリックアトリビューションとは何ですか？',
          'options': ['すべてのクレジットを最終タッチポイントに与える', 'すべてのタッチポイントにクレジットを与える', '最初のタッチポイントにクレジットを与える', '平等にクレジットを与える'],
          'correctAnswerIndex': 0,
          'explanation': 'ラストクリックアトリビューションは、コンバージョン前の最終タッチポイントにすべてのクレジットを与えます。'
        },
        {
          'question': 'ファーストクリックアトリビューションの制限は何ですか？',
          'options': ['各タッチポイントの真の貢献を反映しない可能性がある', '実装が複雑すぎる', 'データが多すぎる', '正確ではない'],
          'correctAnswerIndex': 0,
          'explanation': 'ファーストクリックアトリビューションは、すべてのクレジットを初期タッチポイントに与えますが、各タッチポイントの真の貢献を正確に反映しない可能性があります。'
        }
      ],
      'Personalization & A/B Testing': [
        {
          'question': 'What is the main goal of personalization in marketing?',
          'options': ['To tailor messages to individual users', 'To automate workflows', 'To increase ad spend', 'To reduce content creation'],
          'correctAnswerIndex': 0,
          'explanation': 'Personalization aims to deliver relevant content and experiences to each user based on their preferences and behavior.'
        },
        {
          'question': 'What does A/B testing help marketers determine?',
          'options': ['Which version of content performs better', 'How to automate emails', 'The best CRM vendor', 'The most popular social network'],
          'correctAnswerIndex': 0,
          'explanation': 'A/B testing compares two versions of a webpage or app to see which one achieves better results.'
        },
        {
          'question': 'Which of the following is NOT a use case for A/B testing?',
          'options': ['Choosing a subject line', 'Optimizing landing pages', 'Managing customer data', 'Testing call-to-action buttons'],
          'correctAnswerIndex': 2,
          'explanation': 'Managing customer data is not a direct use case for A/B testing.'
        },
      ],
      'Marketing Automation': [
        {
          'question': 'What is marketing automation primarily used for?',
          'options': ['Automating repetitive marketing tasks', 'Designing websites', 'Managing payroll', 'Creating ad creatives'],
          'correctAnswerIndex': 0,
          'explanation': 'Marketing automation platforms help automate tasks like email campaigns, lead nurturing, and workflow management.'
        },
        {
          'question': 'Which of the following is a feature of marketing automation?',
          'options': ['Lead nurturing', 'Manual data entry', 'Offline advertising', 'Print media management'],
          'correctAnswerIndex': 0,
          'explanation': 'Lead nurturing is a core feature of marketing automation platforms.'
        },
        {
          'question': 'What is a drip campaign?',
          'options': ['A series of automated emails sent over time', 'A type of social media ad', 'A CRM feature', 'A web analytics tool'],
          'correctAnswerIndex': 0,
          'explanation': 'Drip campaigns are automated sets of emails sent based on specific timelines or user actions.'
        },
      ],
      'CRM': [
        {
          'question': 'What does CRM stand for?',
          'options': ['Customer Relationship Management', 'Content Resource Management', 'Campaign Reporting Mechanism', 'Customer Retention Model'],
          'correctAnswerIndex': 0,
          'explanation': 'CRM stands for Customer Relationship Management.'
        },
        {
          'question': 'Which of the following is a primary function of a CRM system?',
          'options': ['Managing customer data', 'Sending mass emails', 'Designing websites', 'Running A/B tests'],
          'correctAnswerIndex': 0,
          'explanation': 'CRM systems are used to manage and analyze customer interactions and data.'
        },
        {
          'question': 'Which company is known for its CRM platform?',
          'options': ['Salesforce', 'Mailchimp', 'Google Analytics', 'WordPress'],
          'correctAnswerIndex': 0,
          'explanation': 'Salesforce is a leading CRM platform.'
        },
      ],
      'Email Marketing': [
        {
          'question': 'What is a common metric to measure email marketing success?',
          'options': ['Open rate', 'Page load time', 'Ad impressions', 'Bounce rate'],
          'correctAnswerIndex': 0,
          'explanation': 'Open rate measures how many recipients open an email.'
        },
        {
          'question': 'Which tool is widely used for email marketing?',
          'options': ['Mailchimp', 'Salesforce', 'Google Ads', 'Figma'],
          'correctAnswerIndex': 0,
          'explanation': 'Mailchimp is a popular email marketing platform.'
        },
        {
          'question': 'What is a subscriber list?',
          'options': ['A list of people who have opted in to receive emails', 'A list of website pages', 'A list of ad campaigns', 'A list of CRM contacts only'],
          'correctAnswerIndex': 0,
          'explanation': 'A subscriber list is a collection of email addresses of people who have opted in to receive communications.'
        },
      ],
      'Content Marketing': [
        {
          'question': 'What is the main goal of content marketing?',
          'options': ['To attract and retain a clearly defined audience', 'To increase ad spend', 'To automate emails', 'To manage payroll'],
          'correctAnswerIndex': 0,
          'explanation': 'Content marketing aims to attract and retain customers by creating valuable content.'
        },
        {
          'question': 'Which of the following is a content marketing format?',
          'options': ['Blog post', 'TV commercial', 'Billboard', 'Direct mail'],
          'correctAnswerIndex': 0,
          'explanation': 'Blog posts are a common format in content marketing.'
        },
        {
          'question': 'What is an editorial calendar used for?',
          'options': ['Planning and scheduling content', 'Tracking ad spend', 'Managing CRM contacts', 'Running A/B tests'],
          'correctAnswerIndex': 0,
          'explanation': 'Editorial calendars help marketers plan and schedule content publication.'
        },
      ],
      'Social Media Marketing': [
        {
          'question': 'Which platform is commonly used for B2B social media marketing?',
          'options': ['LinkedIn', 'Instagram', 'Snapchat', 'Pinterest'],
          'correctAnswerIndex': 0,
          'explanation': 'LinkedIn is widely used for B2B social media marketing.'
        },
        {
          'question': 'What is a social media campaign?',
          'options': ['A coordinated marketing effort on one or more platforms', 'A type of email automation', 'A CRM feature', 'A web analytics tool'],
          'correctAnswerIndex': 0,
          'explanation': 'A social media campaign is a coordinated effort to reinforce or assist with a business goal using one or more social media platforms.'
        },
        {
          'question': 'What does engagement mean in social media marketing?',
          'options': ['Interactions such as likes, comments, and shares', 'Number of emails sent', 'Website bounce rate', 'CRM pipeline stages'],
          'correctAnswerIndex': 0,
          'explanation': 'Engagement refers to how users interact with social media content.'
        },
      ],
      'Web Analytics': [
        {
          'question': 'What is bounce rate in web analytics?',
          'options': ['The percentage of visitors who leave after viewing one page', 'The number of emails opened', 'The number of social media likes', 'The number of CRM contacts'],
          'correctAnswerIndex': 0,
          'explanation': 'Bounce rate measures the percentage of visitors who navigate away after viewing only one page.'
        },
        {
          'question': 'Which tool is commonly used for web analytics?',
          'options': ['Google Analytics', 'Salesforce', 'Mailchimp', 'HubSpot'],
          'correctAnswerIndex': 0,
          'explanation': 'Google Analytics is a leading web analytics tool.'
        },
        {
          'question': 'What does a conversion rate measure?',
          'options': ['The percentage of visitors who complete a desired action', 'The number of emails sent', 'The number of social posts', 'The number of CRM deals'],
          'correctAnswerIndex': 0,
          'explanation': 'Conversion rate measures how many visitors complete a desired goal out of the total number of visitors.'
        },
      ],
      'Customer Data Platforms': [
        {
          'question': 'What is a Customer Data Platform (CDP)?',
          'options': ['A system that unifies customer data from multiple sources', 'A type of CRM', 'An email marketing tool', 'A web analytics platform'],
          'correctAnswerIndex': 0,
          'explanation': 'A CDP collects and unifies customer data from multiple sources to create a single customer profile.'
        },
        {
          'question': 'Which of the following is a benefit of using a CDP?',
          'options': ['Better segmentation and personalization', 'Increased ad spend', 'Automated payroll', 'Manual data entry'],
          'correctAnswerIndex': 0,
          'explanation': 'CDPs enable better segmentation and personalization for marketing.'
        },
        {
          'question': 'What is identity resolution in the context of CDPs?',
          'options': ['Matching data from different sources to the same customer', 'Sending automated emails', 'Running A/B tests', 'Managing social media'],
          'correctAnswerIndex': 0,
          'explanation': 'Identity resolution is the process of matching data from different sources to a single customer profile.'
        },
      ],
    };
  }

  // Test API connection
  static Future<bool> testApiConnection() async {
    if (!isApiKeyValid) {
      print('API key is not valid');
      return false;
    }
    
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not found. Please set OPENAI_API_KEY in your .env file.');
    }

    try {
      final response = await http.post(
        Uri.parse(_openaiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': 'Hello, this is a test message.',
            }
          ],
          'max_tokens': 10,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print('API connection successful');
        return true;
      } else {
        print('API connection failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('API connection error: $e');
      return false;
    }
  }
  
  // Get API status message
  static String getApiStatusMessage() {
    if (!isApiKeyValid) {
      return 'API key not configured. Using local question generation and fallback questions.';
    }
    return 'API key configured. AI-powered questions available with local generation fallback.';
  }
} 