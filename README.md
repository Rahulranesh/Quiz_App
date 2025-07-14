# AdTech Quiz App

A modern, interactive quiz application focused on Digital Advertising Technology (AdTech), featuring dynamic question generation using OpenAI, robust local fallback, and detailed progress tracking.

## Features

### 🎯 Core Quiz Functionality
- **Dynamic Question Generation**: Uses OpenAI GPT-3.5-turbo to generate questions from AdTech book content (PDF)
- **Multiple Categories**: 7 AdTech categories (Advertising Basics, AdTech Platforms, Targeting and Data, Media Buying, User Identification, Ad Fraud and Privacy, Attribution)
- **Fallback Logic**: If AI or PDF fails, uses local and hardcoded fallback questions
- **Interactive UI**: Built with Flutter, Material 3, and GetX for smooth, reactive experience
- **Progress Tracking**: Tracks quiz history, scores, category completion, and more
- **Settings**: Dark/light mode, sound, questions per quiz, language
- **Debug Tools**: In-app debug view to inspect all stored data and export as JSON

### 📊 Analytics & Progress
- **Detailed Statistics**: Track accuracy, average scores, and category performance
- **Quiz History**: View past quiz sessions and results
- **Category Progress**: Monitor completion status for each AdTech category
- **Performance Metrics**: Visual charts and progress indicators

### ⚙️ Settings & Customization
- **Dark/Light Theme**: Toggle between themes
- **Sound Effects**: Enable/disable audio feedback
- **Questions per Quiz**: Adjustable (5-25)
- **Language**: English and Japanese support (with AI prompt adaptation)

### 🛠️ Developer & Debug Tools
- **Debug Data View**: Inspect all SharedPreferences data in-app
- **Export Data**: Export all stored data as JSON to your desktop for VS Code inspection
- **Clear All Data**: Wipe all local data from the app

## Categories Covered

1. **Advertising Basics**
2. **AdTech Platforms**
3. **Targeting and Data**
4. **Media Buying**
5. **User Identification**
6. **Ad Fraud and Privacy**
7. **Attribution**

## Technical Architecture

### Frontend
- **Framework**: Flutter 3.7.0+
- **State Management**: GetX
- **UI**: Material Design 3, custom animations, Lottie, Confetti

### Backend/Services
- **Question Generation**: OpenAI GPT-3.5-turbo API (with robust prompt engineering)
- **Content Extraction**: PDF parsing (via `pdftotext` or fallback content)
- **Local Fallback**: Local generator and hardcoded questions for offline/AI-failure scenarios
- **Data Storage**: SharedPreferences (with user-specific and global keys)
- **Analytics**: Custom progress and statistics

### Key Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  get: ^4.6.6
  shared_preferences: ^2.2.2
  http: ^1.1.0
  flutter_animate: ^4.5.0
  lottie: ^3.0.0
  confetti: ^0.7.0
  path_provider: ^2.1.1
  permission_handler: ^11.0.1
  cupertino_icons: ^1.0.2
  crypto: ^3.0.3
```

## Installation & Setup

### Prerequisites
- Flutter SDK 3.7.0 or higher
- Dart SDK 3.7.0 or higher
- OpenAI API key (for dynamic question generation)
- `pdftotext` installed (for PDF extraction)

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
   - Replace the API key with your actual OpenAI key
4. **Add AdTech book PDF**
   - Place `adtech_book.pdf` in the `quiz_app/` directory
5. **Run the application**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── controllers/           # Quiz, progress, settings, language, auth
├── models/                # Data models (Question, QuizSession, UserProgress)
├── services/              # AI, PDF, local fallback, storage, analytics
├── utils/                 # Debug export utilities
├── views/                 # Home, quiz, progress, settings, debug, results
└── main.dart              # App entry point
```

## Usage Guide

### Starting a Quiz
1. Open the app
2. Choose a category or start a random quiz
3. Answer questions (options are shuffled, correct answer is randomized)

### Debugging & Data Inspection
- **Settings → Data Management → View Stored Data**: See all SharedPreferences data
- **Export to Desktop**: Download all data as JSON for VS Code
- **Clear All Data**: Wipe all app data

### Progress Tracking
- **Progress tab**: View stats, history, and category completion

## Troubleshooting
- **Question Generation Problems**: Check OpenAI API key, internet, and PDF presence
- **PDF Extraction Issues**: Ensure `pdftotext` is installed and PDF is present
- **Performance**: Clear app cache, restart, check device storage

## Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License
MIT License - see the LICENSE file for details.

## Support
- Create an issue in the repository
- Check the troubleshooting section
- Review the documentation

## Future Enhancements
- [ ] Multi-language UI
- [ ] Offline mode with cached questions
- [ ] Social features and leaderboards
- [ ] Advanced analytics and insights
- [ ] Custom quiz creation tools
- [ ] Integration with learning management systems

