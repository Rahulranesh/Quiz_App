import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import '../controllers/enhanced_quiz_controller.dart';
import '../controllers/settings_controller.dart';

class InteractiveQuizView extends StatefulWidget {
  const InteractiveQuizView({super.key});

  @override
  State<InteractiveQuizView> createState() => _InteractiveQuizViewState();
}

class _InteractiveQuizViewState extends State<InteractiveQuizView>
    with TickerProviderStateMixin {
  final EnhancedQuizController controller = Get.find<EnhancedQuizController>();
  
  late AnimationController questionAnimationController;
  late AnimationController answerAnimationController;
  late AnimationController gestureAnimationController;

  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    setupAnimationControllers();
    setupConfetti();
    
    // Listen for quiz completion
    ever(controller.isQuizCompleted, (completed) {
      if (completed == true) {
        // Quiz is completed, redirect to result page immediately
        Get.offAllNamed('/result');
      }
    });
  }

  void setupAnimationControllers() {
    questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    answerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    gestureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    


    controller.setAnimationControllers(
      questionController: questionAnimationController,
      answerController: answerAnimationController,
      gestureController: gestureAnimationController,
    );
  }

  void setupConfetti() {
    confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {

    
    questionAnimationController.dispose();
    answerAnimationController.dispose();
    gestureAnimationController.dispose();

    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.1),
              Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildLoadingView();
                  } else if (controller.errorMessage.value.isNotEmpty) {
                    return _buildErrorView();
                  } else {
                    return _buildQuizContent();
                  }
                }),
              ),
              _buildControlBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Obx(() => Column(
              children: [
                Text(
                  'Interactive Quiz',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: controller.getProgressPercentage(),
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.getAnsweredQuestionsCount()}/${controller.questions.length} questions answered',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            )),
          ),

        ],
      ),
    );
  }



  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/loading.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 24),
          Obx(() => Text(
            controller.loadingMessage.value,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          )),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Obx(() => Text(
              'Unable to Generate Questions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 16),
            Obx(() => Text(
              controller.errorMessage.value,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    controller.errorMessage.value = '';
                    final settingsController = Get.find<SettingsController>();
                    controller.startQuiz(questionCount: settingsController.questionsPerQuiz.value);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    return GestureDetector(
      onPanUpdate: (details) {
        // Handle swipe gestures
        if (details.delta.dx > 10) {
          controller.previousQuestion();
        } else if (details.delta.dx < -10) {
          controller.nextQuestion();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildQuestionCard(),
            const SizedBox(height: 24),
            _buildAnswerOptions(),
            const SizedBox(height: 24),
            _buildInteractiveControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Obx(() {
      final question = controller.getCurrentQuestion();
      if (question == null) return const SizedBox.shrink();

      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Question ${controller.currentQuestionIndex.value + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (controller.streakCount.value > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${controller.streakCount.value}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                question.question,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
                Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  ),
                        child: Text(
                  question.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                        ),
                      ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
    });
  }

  Widget _buildAnswerOptions() {
    return Obx(() {
      final question = controller.getCurrentQuestion();
      if (question == null) return const SizedBox.shrink();

      return Column(
        children: question.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = controller.getUserAnswerForCurrentQuestion() == index;
          final isCorrect = controller.isAnswerRevealed.value && index == question.correctAnswerIndex;
          final isWrong = controller.isAnswerRevealed.value && isSelected && index != question.correctAnswerIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                controller.answerQuestion(index);
                // Only auto-advance if this is not the last question
                if (controller.currentQuestionIndex.value < controller.questions.length - 1) {
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    if (!controller.isQuizCompleted.value) {
                      controller.nextQuestion();
                    }
                  });
                } else {
                  // This is the last question, complete the quiz after a short delay
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    if (!controller.isQuizCompleted.value) {
                      controller.completeQuiz();
                    }
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.2)
                      : isWrong
                          ? Colors.red.withOpacity(0.2)
                          : isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                    color: isCorrect
                        ? Colors.green
                        : isWrong
                            ? Colors.red
                            : isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                      width: 32,
                      height: 32,
                        decoration: BoxDecoration(
                        color: isCorrect
                            ? Colors.green
                            : isWrong
                                ? Colors.red
                                : isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index),
                                style: TextStyle(
                            color: isSelected || isCorrect || isWrong
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                          ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      Icon(Icons.check_circle, color: Colors.green, size: 24)
                    else if (isWrong)
                      Icon(Icons.cancel, color: Colors.red, size: 24),
                    ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 100)).slideX(begin: 0.3, end: 0);
        }).toList(),
      );
    });
  }

  Widget _buildInteractiveControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          Icons.arrow_back,
          'Previous',
          () => controller.previousQuestion(),
          controller.currentQuestionIndex.value > 0,
        ),
        _buildControlButton(
          Icons.help,
          'Help',
          () {
            // Show help dialog
          },
          true,
        ),
        _buildControlButton(
          Icons.arrow_forward,
          'Next',
          () => controller.nextQuestion(),
          controller.currentQuestionIndex.value < controller.questions.length - 1,
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap, bool enabled) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: enabled ? onTap : null,
          color: enabled ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: enabled ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() => Row(
        children: [
          // Score and streak info
          Expanded(
            child: Column(
              children: [
                Text(
                  'Score: ${controller.score.value}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  'Streak: ${controller.streakCount.value}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }


} 