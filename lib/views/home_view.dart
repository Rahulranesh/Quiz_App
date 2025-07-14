import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../l10n/app_localizations.dart';
import '../controllers/enhanced_quiz_controller.dart';
import '../controllers/progress_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/language_controller.dart';
import '../controllers/auth_controller.dart';
import 'debug_data_view.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    
    // Listen for settings changes to refresh the view
    final settingsController = Get.find<SettingsController>();
    ever(settingsController.questionsPerQuiz, (count) {
      setState(() {
        // Refresh the view when question count changes
      });
    });
    
    // Listen for language changes to refresh the view
    final languageController = Get.find<LanguageController>();
    ever(languageController.currentLanguage, (language) {
      setState(() {
        // Refresh the view when language changes
      });
    });

    // Listen for authentication changes to refresh user data
    final authController = Get.find<AuthController>();
    ever(authController.authState, (authState) {
      if (authState.isAuthenticated) {
        // Refresh progress data when user logs in
        final progressController = Get.find<ProgressController>();
        progressController.loadProgress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizController = Get.find<EnhancedQuizController>();
    final progressController = Get.find<ProgressController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshQuestions(quizController),
            tooltip: AppLocalizations.of(context)!.refreshQuestions,
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => Get.toNamed('/progress'),
            tooltip: AppLocalizations.of(context)!.progress,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/settings'),
            tooltip: AppLocalizations.of(context)!.settings,
          ),
          // Debug button - only show in debug mode
          if (const bool.fromEnvironment('dart.vm.product') == false)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () => Get.to(() => const DebugDataView()),
              tooltip: 'Debug: View Stored Data',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context, authController);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(authController.currentUser?.name ?? 'Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(width: 8),
                    const Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (progressController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Welcome Section
              _buildUserWelcomeSection(context, authController, progressController)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 24),

              // Quick Stats
              _buildQuickStats(context, progressController)
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 24),

              // Quiz Categories
              _buildCategoriesSection(context, quizController, progressController)
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(context, quizController)
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUserWelcomeSection(BuildContext context, AuthController authController, ProgressController progressController) {
    final stats = progressController.getProgressStats();
    final user = authController.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user?.name ?? 'User'}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.welcomeSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                context,
                '${stats['totalQuizzes']}',
                AppLocalizations.of(context)!.quizzes,
                Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                context,
                '${stats['accuracy'].toStringAsFixed(1)}%',
                AppLocalizations.of(context)!.accuracy,
                Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                context,
                '${stats['completedCategories']}/${stats['totalCategories']}',
                AppLocalizations.of(context)!.categories,
                Theme.of(context).colorScheme.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, ProgressController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProgressCard(
                  context,
                  'Average Score',
                  '${controller.userProgress.value.averageScore.toStringAsFixed(1)}/10',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressCard(
                  context,
                  'Questions Answered',
                  '${controller.userProgress.value.totalQuestionsAnswered}',
                  Icons.question_answer,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, EnhancedQuizController quizController, ProgressController progressController) {
    final categories = quizController.getCategories();
    final settingsController = Get.find<SettingsController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz Categories',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            double aspectRatio = constraints.maxWidth > 600 ? 1.4 : 1.2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: aspectRatio,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isCompleted = progressController.isCategoryCompleted(category);
                final questionCount = settingsController.questionsPerQuiz.value;
                
                return _buildCategoryCard(
                  context,
                  category,
                  questionCount,
                  isCompleted,
                  () => _startCategoryQuiz(quizController, category),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category, int questionCount, bool isCompleted, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isCompleted
                ? LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.1),
                      Colors.green.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 32,
                color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                category,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '$questionCount questions',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isCompleted) ...[
                const SizedBox(height: 4),
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Advertising Basics':
        return Icons.info;
      case 'AdTech Platforms':
        return Icons.computer;
      case 'Targeting and Data':
        return Icons.track_changes;
      case 'Media Buying':
        return Icons.shopping_cart;
      case 'User Identification':
        return Icons.person;
      case 'Ad Fraud and Privacy':
        return Icons.security;
      case 'Attribution':
        return Icons.analytics;
      default:
        return Icons.quiz;
    }
  }

  Widget _buildQuickActions(BuildContext context, EnhancedQuizController quizController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _startRandomQuiz(quizController),
                icon: const Icon(Icons.shuffle),
                label: const Text('Random Quiz'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Get.toNamed('/progress'),
                icon: const Icon(Icons.analytics),
                label: const Text('View Progress'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),

      ],
    );
  }

  void _startCategoryQuiz(EnhancedQuizController controller, String category) async {
    final settingsController = Get.find<SettingsController>();
    await controller.startQuiz(
      category: category, 
      questionCount: settingsController.questionsPerQuiz.value
    );
    if (controller.questions.isNotEmpty) {
      Get.toNamed('/quiz');
    }
  }

  void _startRandomQuiz(EnhancedQuizController controller) async {
    final settingsController = Get.find<SettingsController>();
    await controller.startQuiz(questionCount: settingsController.questionsPerQuiz.value);
    if (controller.questions.isNotEmpty) {
      Get.toNamed('/quiz');
    }
  }

  void _refreshQuestions(EnhancedQuizController controller) async {
    Get.snackbar(
      'Refreshing',
      'Generating new questions from AdTech book...',
      snackPosition: SnackPosition.BOTTOM,
    );
    await controller.refreshQuestions();
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authController.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
} 