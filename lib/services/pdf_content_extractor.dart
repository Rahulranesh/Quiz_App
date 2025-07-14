import 'dart:io';

class PDFContentExtractor {
  static Map<String, String> _chapterContent = {};
  static bool _isInitialized = false;
  
  // Enhanced chapter mappings based on the book structure with more keywords
  static const Map<String, List<String>> _chapterKeywords = {
    'Advertising Basics': [
      'advertiser', 'publisher', 'relationship', 'brand', 'company',
      'advertising technology', 'adtech', 'target audience', 'digital advertising',
      'advertising ecosystem', 'advertising industry', 'advertising fundamentals',
      'advertising principles', 'advertising concepts', 'advertising basics'
    ],
    'AdTech Platforms': [
      'ad server', 'platform', 'technology', 'system', 'infrastructure',
      'first-party', 'third-party', 'DSP', 'SSP', 'DMP', 'ad exchange',
      'demand-side platform', 'supply-side platform', 'data management platform',
      'advertising platform', 'technology platform', 'adtech platform'
    ],
    'Targeting and Data': [
      'targeting', 'data', 'contextual', 'behavioral', 'demographic',
      'retargeting', 'audience', 'segmentation', 'profile', 'audience targeting',
      'data targeting', 'behavioral targeting', 'contextual targeting',
      'demographic targeting', 'audience data', 'targeting data'
    ],
    'Media Buying': [
      'media buying', 'programmatic', 'RTB', 'real-time bidding',
      'header bidding', 'PMP', 'private marketplace', 'auction', 'media purchase',
      'programmatic buying', 'automated buying', 'media trading', 'ad buying',
      'media procurement', 'buying process'
    ],
    'User Identification': [
      'user identification', 'cookie', 'device fingerprinting',
      'mobile ID', 'tracking', 'privacy', 'GDPR', 'user tracking',
      'identity resolution', 'cross-device', 'user recognition',
      'identification technology', 'user data', 'identity management'
    ],
    'Ad Fraud and Privacy': [
      'ad fraud', 'viewability', 'privacy', 'GDPR', 'CCPA',
      'transparency', 'blocking', 'opt-out', 'fraud prevention',
      'privacy protection', 'data protection', 'fraud detection',
      'privacy regulations', 'ad verification', 'brand safety'
    ],
    'Attribution': [
      'attribution', 'conversion', 'tracking', 'cross-device',
      'multi-touch', 'customer journey', 'conversion tracking',
      'attribution model', 'touchpoint', 'customer attribution',
      'conversion attribution', 'journey tracking', 'attribution data'
    ],
  };
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _extractContentFromPDF();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing PDF content: $e');
      // Use enhanced fallback content
      _useEnhancedFallbackContent();
    }
  }
  
  static Future<void> _extractContentFromPDF() async {
    try {
      // Use pdftotext command to extract text
      final result = await Process.run('pdftotext', ['adtech_book.pdf', '-']);
      
      if (result.exitCode == 0) {
        final content = result.stdout.toString();
        _parseContentByChapters(content);
      } else {
        throw Exception('Failed to extract PDF content');
      }
    } catch (e) {
      print('Error extracting PDF: $e');
      throw e;
    }
  }
  
  static void _parseContentByChapters(String content) {
    final lines = content.split('\n');
    String currentChapter = '';
    String currentContent = '';
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // Detect chapter headers
      if (_isChapterHeader(trimmedLine)) {
        // Save previous chapter content
        if (currentChapter.isNotEmpty && currentContent.isNotEmpty) {
          _chapterContent[currentChapter] = currentContent.trim();
        }
        
        // Start new chapter
        currentChapter = _extractChapterName(trimmedLine);
        currentContent = '';
      } else if (currentChapter.isNotEmpty) {
        // Add content to current chapter
        currentContent += ' $trimmedLine';
      }
    }
    
    // Save last chapter
    if (currentChapter.isNotEmpty && currentContent.isNotEmpty) {
      _chapterContent[currentChapter] = currentContent.trim();
    }
  }
  
  static bool _isChapterHeader(String line) {
    // Check if line looks like a chapter header
    final chapterPatterns = [
      RegExp(r'^\d+\.\s+[A-Z]'),
      RegExp(r'^Chapter\s+\d+'),
      RegExp(r'^[A-Z][A-Z\s]+$'),
    ];
    
    return chapterPatterns.any((pattern) => pattern.hasMatch(line));
  }
  
  static String _extractChapterName(String header) {
    // Extract chapter name from header
    final patterns = [
      RegExp(r'^\d+\.\s+(.+)'),
      RegExp(r'^Chapter\s+\d+:\s*(.+)'),
      RegExp(r'^(.+)$'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(header);
      if (match != null) {
        return match.group(1)?.trim() ?? header;
      }
    }
    
    return header;
  }
  
  static void _useEnhancedFallbackContent() {
    // Enhanced fallback content with more comprehensive AdTech information
    _chapterContent = {
      'Advertising Basics': '''
        Digital advertising is a global multibillion-dollar industry comprising thousands of companies, but at the heart of it all are two key players: the advertiser and the publisher. The advertiser-publisher relationship dates back well before the invention of the internet. Publishers, such as newspapers and magazines, would sell ad space to advertisers as a way to generate additional revenue on top of their regular subscriptions and individual sales.
        
        An advertiser is a brand or company that wants to get its product or service in front of its target audience to build brand awareness, develop brand loyalty, and increase sales. A publisher can be defined as any company that produces content that attracts an audience. Examples of publishers include newspapers and magazines in the offline world, and websites and mobile apps in the online world.
        
        Advertising technology refers to the software and tools used to create, run, manage, measure, and optimize digital advertising campaigns. All parties involved in digital advertising—from brands and advertisers to ad agencies, technology vendors, and publishers—use one or more pieces of advertising technology.
        
        The digital advertising ecosystem consists of advertisers, agencies, publishers, ad networks, ad exchanges, data providers, and technology platforms. Each participant plays a specific role in the delivery of digital advertisements to consumers. The ecosystem has evolved significantly with the introduction of programmatic advertising, which automates the buying and selling of ad inventory.
      ''',
      'AdTech Platforms': '''
        Ad servers are technology platforms that deliver ads to users based on various targeting criteria and campaign parameters. There are two main types of ad servers: first-party and third-party ad servers. First-party ad servers are owned and operated by publishers, while third-party ad servers are independent technology platforms.
        
        Real-Time Bidding (RTB) is an automated auction process for buying and selling ad impressions in real-time. Header bidding allows multiple ad exchanges to bid on ad inventory simultaneously, increasing competition and publisher revenue.
        
        Demand-Side Platforms (DSPs) allow advertisers to buy ad inventory from multiple sources through a single interface. Supply-Side Platforms (SSPs) help publishers sell their ad inventory to multiple buyers. Data Management Platforms (DMPs) collect, organize, and activate audience data for advertising.
        
        Ad exchanges are digital marketplaces that enable advertisers and publishers to buy and sell ad space in real-time. They facilitate the automated buying and selling of digital advertising inventory through real-time bidding auctions.
      ''',
      'Targeting and Data': '''
        Contextual targeting displays ads based on the content of the webpage where the ad appears. Behavioral targeting uses data about user actions and browsing history to serve relevant ads. Retargeting shows ads to users who have previously visited a website or interacted with a brand.
        
        Data Management Platforms (DMPs) collect, organize, and activate audience data for advertising. They help advertisers and publishers create audience segments and target specific groups of users.
        
        Demographic targeting uses information such as age, gender, income, and location to target ads to specific groups of people. Geographic targeting focuses on users in specific locations or regions.
        
        Lookalike targeting identifies new potential customers who share similar characteristics with existing customers. This approach uses machine learning algorithms to find users who are likely to be interested in a product or service based on the behavior of current customers.
      ''',
      'Media Buying': '''
        Programmatic media buying uses technology to automate the buying and selling of ad inventory. It includes several methods such as Real-Time Bidding (RTB), Private Marketplaces (PMP), and Programmatic Direct.
        
        Private Marketplaces (PMP) are invitation-only marketplaces where premium ad inventory is sold to select advertisers. They offer more control and transparency than open auctions.
        
        In first-price auctions, the winner pays their bid amount. In second-price auctions, the winner pays the second-highest bid amount. Most programmatic auctions use second-price auction models.
        
        Header bidding allows publishers to offer their inventory to multiple ad exchanges simultaneously before making calls to their ad servers. This increases competition and can lead to higher revenue for publishers.
      ''',
      'User Identification': '''
        Cookies are small text files used to identify and track users across websites for advertising purposes. Device fingerprinting identifies devices based on unique characteristics like browser settings, screen resolution, and installed fonts.
        
        Advertising IDs are unique identifiers assigned to mobile devices for advertising and tracking purposes. They allow advertisers to track user behavior across different apps and websites.
        
        User identification is becoming more challenging due to privacy regulations and browser restrictions on third-party cookies. New technologies like Unified ID 2.0 and Google's Privacy Sandbox are emerging to address these challenges.
        
        Cross-device identification allows advertisers to recognize the same user across multiple devices, providing a more complete view of the customer journey and enabling more effective targeting and attribution.
      ''',
      'Ad Fraud and Privacy': '''
        Ad fraud involves deliberate deception to generate invalid ad impressions or clicks, costing advertisers billions annually. Common types of ad fraud include bot traffic, click farms, and domain spoofing.
        
        Ad viewability measures whether ads are actually seen by users, typically requiring 50% of the ad to be visible for at least 1 second. Viewability standards are set by organizations like the Media Rating Council (MRC).
        
        Privacy regulations like GDPR and CCPA protect user data and give consumers control over how their information is collected and used. These regulations require transparency about data collection and provide users with opt-out mechanisms.
        
        Brand safety measures ensure that ads appear in appropriate contexts and don't appear alongside content that could damage a brand's reputation. This includes avoiding placement on sites with inappropriate content.
      ''',
      'Attribution': '''
        Attribution is the process of assigning credit for conversions to specific touchpoints in the customer journey. It helps advertisers understand which channels and campaigns are driving results.
        
        Cross-device attribution tracks user behavior and conversions across multiple devices to provide a complete view of the customer journey. This is essential for understanding the full path to conversion.
        
        Multi-touch attribution models consider all touchpoints in the customer journey, not just the first or last interaction. Common models include linear attribution, time decay attribution, and data-driven attribution.
        
        Last-click attribution gives all credit to the final touchpoint before conversion, while first-click attribution gives all credit to the initial touchpoint. Both models have limitations and may not accurately reflect the true contribution of each touchpoint.
      ''',
    };
  }
  
  static Future<String> getContentForCategory(String category) async {
    await initialize();
    
    print('Getting content for category: $category');
    print('Available chapters: ${_chapterContent.keys.toList()}');
    
    // Find the best matching chapter for the category
    String bestMatch = '';
    int bestScore = 0;
    
    for (final chapter in _chapterContent.keys) {
      final score = _calculateCategoryMatch(category, chapter);
      print('Chapter: $chapter, Score: $score');
      if (score > bestScore) {
        bestScore = score;
        bestMatch = chapter;
      }
    }
    
    print('Best match for $category: $bestMatch (score: $bestScore)');
    final content = _chapterContent[bestMatch] ?? '';
    print('Content length: ${content.length} characters');
    
    return content;
  }
  
  static int _calculateCategoryMatch(String category, String chapter) {
    final categoryKeywords = _chapterKeywords[category] ?? [];
    final chapterLower = chapter.toLowerCase();
    
    int score = 0;
    for (final keyword in categoryKeywords) {
      if (chapterLower.contains(keyword.toLowerCase())) {
        score++;
      }
    }
    
    return score;
  }
  
  static Future<List<String>> getAvailableChapters() async {
    await initialize();
    return _chapterContent.keys.toList();
  }
  
  static Future<String> getRandomContent(int maxLength) async {
    await initialize();
    
    final allContent = _chapterContent.values.join(' ');
    if (allContent.length <= maxLength) {
      return allContent;
    }
    
    // Get a random segment of content
    final startIndex = (DateTime.now().millisecondsSinceEpoch % (allContent.length - maxLength)).toInt();
    return allContent.substring(startIndex, startIndex + maxLength);
  }
  
  static Future<Map<String, String>> getAllChapterContent() async {
    await initialize();
    return Map.from(_chapterContent);
  }
} 