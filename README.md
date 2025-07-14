# AdTech Quiz App

A cross-platform quiz application built with Flutter, designed to help users learn and test their knowledge of AdTech and MarTech concepts. The app features dynamic question generation from a PDF book, category-based quizzes, progress tracking, and interactive learning features.

## Features
- Multiple quiz categories (AdTech & MarTech)
- Dynamic question generation from book content
- Progress tracking and statistics
- Category completion tracking
- Interactive quiz mode with gestures
- Multi-platform support: Android, iOS, Web, Windows, MacOS, Linux
- Localization (English, Japanese)
- User authentication and personalized settings

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart (comes with Flutter)
- A device or emulator for your target platform

### Installation
1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd quiz_app
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the app:**
   ```bash
   flutter run
   ```
   Or specify a platform:
   ```bash
   flutter run -d chrome    # For web
   flutter run -d android  # For Android
   flutter run -d ios      # For iOS
   ```

## Usage
- Select a quiz category from the home screen.
- Answer questions and track your progress.
- View detailed stats and category breakdowns in the Progress section.
- Adjust settings (dark mode, questions per quiz, etc.) in the Settings section.

## Troubleshooting
### UI Overflow Issues
- If you see UI overflow (yellow/black stripes or clipped widgets), try reducing your device's font size or using a device with a larger screen.
- The categories grid is responsive, but on very small screens, long category names may be truncated with ellipsis.
- If you add more categories, the grid will adapt, but ensure your device has enough vertical space.

### Categories Not Updating
- Categories are static by default. If you want to make them dynamic, update the controller to use an `RxList<String>` and trigger UI updates when the list changes.
- If you change the categories in code, hot restart the app to see updates.

### General
- If you encounter issues with question loading, ensure the `adtech_book.pdf` is present in the assets folder.
- For authentication or settings issues, try logging out and back in.

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Create a new Pull Request

## License
This project is licensed under the MIT License.

