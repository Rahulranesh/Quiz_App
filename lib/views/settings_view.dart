import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/settings_controller.dart';
import '../controllers/language_controller.dart';
import '../services/dynamic_question_generator.dart';
import 'debug_data_view.dart';


class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (settingsController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Settings
              _buildSectionHeader(context, 'App Settings', Icons.settings)
                  .animate()
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 16),

              _buildThemeSetting(context, settingsController)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideX(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              _buildLanguageSetting(context)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 150.ms)
                  .slideX(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              _buildSoundSetting(context, settingsController)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideX(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Quiz Settings
              _buildSectionHeader(context, 'Quiz Settings', Icons.quiz)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),

              const SizedBox(height: 16),

              _buildQuestionsPerQuizSetting(context, settingsController)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideX(begin: 0.2, end: 0),

              const SizedBox(height: 12),

              _buildExplanationsSetting(context, settingsController)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms)
                  .slideX(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Data Management
              _buildSectionHeader(context, 'Data Management', Icons.storage)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 600.ms),

              const SizedBox(height: 16),

              _buildDataManagementSection(context, settingsController)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 700.ms)
                  .slideX(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // API Status
              _buildSectionHeader(context, 'API Status', Icons.api)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 650.ms),

              const SizedBox(height: 16),

              _buildApiStatusSection(context)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 750.ms)
                  .slideX(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // About
              _buildSectionHeader(context, 'About', Icons.info)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 800.ms),

              const SizedBox(height: 16),

              _buildAboutSection(context)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 900.ms)
                  .slideX(begin: 0.2, end: 0),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSetting(BuildContext context, SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.dark_mode,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Switch between light and dark themes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: controller.isDarkMode.value,
            onChanged: (value) => controller.toggleDarkMode(),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSoundSetting(BuildContext context, SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.volume_up,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sound Effects',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Enable or disable sound effects',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: controller.soundEnabled.value,
            onChanged: (value) => controller.toggleSound(),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsPerQuizSetting(BuildContext context, SettingsController settingsController) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_list_numbered,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Questions per Quiz',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Number of questions in random quizzes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  settingsController.getQuestionsPerQuizText(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DropdownButton<int>(
                value: settingsController.questionsPerQuiz.value,
                onChanged: (value) {
                  if (value != null) {
                    settingsController.updateQuestionsPerQuiz(value);
                  }
                },
                items: settingsController.getQuestionsPerQuizOptions().map((count) {
                  return DropdownMenuItem<int>(
                    value: count,
                    child: Text('$count'),
                  );
                }).toList(),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildExplanationsSetting(BuildContext context, SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Show Explanations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Display explanations after answering questions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: controller.showExplanations.value,
            onChanged: (value) => controller.toggleShowExplanations(),
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSection(BuildContext context, SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDataManagementItem(
            context,
            'View Stored Data',
            'Debug view of all stored SharedPreferences data',
            Icons.storage,
            () => Get.to(() => const DebugDataView()),
          ),
          const Divider(),
          _buildDataManagementItem(
            context,
            'Export Data',
            'Export your quiz data and progress',
            Icons.download,
            () => _showExportDialog(context),
          ),
          const Divider(),
          _buildDataManagementItem(
            context,
            'Clear All Data',
            'Permanently delete all quiz history and progress',
            Icons.delete_forever,
            () => _showClearDataDialog(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildAboutItem(
            context,
            'App Version',
            '1.0.0',
            Icons.info,
          ),
          const Divider(),
          _buildAboutItem(
            context,
            'Questions Source',
            'The AdTech Book',
            Icons.book,
          ),
          const Divider(),
          _buildAboutItem(
            context,
            'Total Questions',
            '24 questions across 7 categories',
            Icons.quiz,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(BuildContext context, String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    Get.snackbar(
      'Coming Soon',
      'Data export feature will be available in the next update',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _buildLanguageSetting(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.language,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Language',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Select your preferred language',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: languageController.currentLanguage.value,
            onChanged: (value) {
              if (value != null) {
                languageController.changeLanguage(value);
              }
            },
            items: languageController.availableLanguages.asMap().entries.map((entry) {
              final index = entry.key;
              final languageCode = entry.value;
              final languageName = languageController.availableLanguageNames[index];
              return DropdownMenuItem<String>(
                value: languageCode,
                child: Text(languageName),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your quiz history, progress, and settings. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Clear data logic would go here
              Get.snackbar(
                'Data Cleared',
                'All data has been cleared successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildApiStatusSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.api,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OpenAI API Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      DynamicQuestionGenerator.getApiStatusMessage(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                Get.snackbar(
                  'Testing API',
                  'Testing OpenAI API connection...',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 1),
                );
                
                final isConnected = await DynamicQuestionGenerator.testApiConnection();
                
                Get.snackbar(
                  isConnected ? 'API Connected' : 'API Failed',
                  isConnected 
                    ? 'OpenAI API is working correctly!' 
                    : 'API connection failed. Check your API key.',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3),
                  backgroundColor: isConnected ? Colors.green : Colors.red,
                  colorText: Colors.white,
                );
              },
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('Test API Connection'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 