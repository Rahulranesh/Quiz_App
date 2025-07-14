# AdTech Quiz App

A comprehensive, interactive quiz application focused on Digital Advertising Technology (AdTech) with advanced voice interaction capabilities and dynamic question generation using AI.

## Features

### 🎯 Core Quiz Functionality
- **Dynamic Question Generation**: Questions are generated dynamically from AdTech book content using OpenAI API
- **Multiple Categories**: 7 comprehensive AdTech categories covering all aspects of digital advertising
- **Interactive UI**: Modern, responsive design with smooth animations and transitions
- **Progress Tracking**: Detailed analytics and progress monitoring



### 📊 Analytics & Progress
- **Detailed Statistics**: Track accuracy, average scores, and category performance
- **Quiz History**: View past quiz sessions and results
- **Category Progress**: Monitor completion status for each AdTech category
- **Performance Metrics**: Visual charts and progress indicators

### ⚙️ Settings & Customization
- **Dark/Light Theme**: Toggle between themes
- **Sound Effects**: Customize audio feedback
- **Questions per Quiz**: Adjust quiz length (5-25 questions)

## Categories Covered

1. **Advertising Basics** - Fundamentals of digital advertising
2. **AdTech Platforms** - DSP, SSP, DMP, and other platforms
3. **Targeting and Data** - Audience targeting and data management
4. **Media Buying** - Programmatic buying and RTB
5. **User Identification** - Cookies, device fingerprinting, and privacy
6. **Ad Fraud and Privacy** - Fraud prevention and privacy regulations
7. **Attribution** - Conversion tracking and attribution models



## Technical Architecture

### Frontend
- **Framework**: Flutter 3.7.0+
- **State Management**: GetX for reactive state management
- **UI Components**: Material Design 3 with custom animations

### Backend Services
- **Question Generation**: OpenAI GPT-3.5-turbo API
- **Content Extraction**: PDF content parsing from AdTech book
- **Data Storage**: SharedPreferences for local storage
- **Analytics**: Custom progress tracking and statistics

### Key Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  get: ^4.6.6                    # State management
  shared_preferences: ^2.2.2     # Local storage
  http: ^1.1.2                   # API calls
  flutter_animate: ^4.5.0        # Animations
  audioplayers: ^6.5.0           # Audio playback
  vibration: ^3.1.3              # Haptic feedback
  lottie: ^3.3.1                 # Lottie animations
  confetti: ^0.8.0               # Celebration effects
```

## Installation & Setup

### Prerequisites
- Flutter SDK 3.7.0 or higher
- Dart SDK 3.7.0 or higher
- OpenAI API key

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd quiz_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure OpenAI API**
   - Open `lib/services/dynamic_question_generator.dart`
   - Replace `YOUR_OPENAI_API_KEY` with your actual API key

4. **Add AdTech book PDF**
   - Place `adtech_book.pdf` in the root directory
   - Ensure the PDF contains AdTech content for question generation

5. **Run the application**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── controllers/
│   ├── enhanced_quiz_controller.dart    # Main quiz logic
│   ├── progress_controller.dart         # Progress tracking
│   └── settings_controller.dart         # Settings management
├── models/
│   └── quiz_models.dart                 # Data models
├── services/
│   ├── dynamic_question_generator.dart  # AI question generation
│   ├── pdf_content_extractor.dart       # PDF content parsing
│   ├── interactive_gesture_service.dart # Gesture handling
│   ├── quiz_data_service.dart          # Quiz data management
│   └── storage_service.dart            # Local storage
├── views/
│   ├── home_view.dart                   # Main dashboard
│   ├── interactive_quiz_view.dart       # Quiz interface
│   ├── progress_view.dart               # Progress analytics
│   ├── settings_view.dart               # Settings page
│   └── quiz_result_view.dart            # Results display

└── main.dart                           # App entry point
```

## Usage Guide

### Starting a Quiz
1. Open the app and navigate to the home screen
2. Choose a category or start a random quiz
3. Tap to interact with questions and options

### Progress Tracking
1. Navigate to Progress tab to view statistics
2. Check category completion status
3. Review quiz history and performance trends

## Troubleshooting

### Question Generation Problems
- Verify OpenAI API key is valid
- Check internet connectivity
- Ensure AdTech book PDF is present

### Performance Issues
- Clear app cache if needed
- Restart the application
- Check device storage space

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review the documentation

## Future Enhancements

- [ ] Multi-language support
- [ ] Offline mode with cached questions
- [ ] Social features and leaderboards
- [ ] Advanced analytics and insights
- [ ] Integration with learning management systems
- [ ] Custom quiz creation tools
