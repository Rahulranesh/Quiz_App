import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/quiz_controller.dart';
import '../controllers/settings_controller.dart';


class QuizView extends StatelessWidget {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final quizController = Get.find<QuizController>();
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final category = quizController.selectedCategory.value;
          return Text(
            category.isNotEmpty ? category : 'Quiz',
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context, quizController),
        ),
        actions: [
          Obx(() => TextButton(
            onPressed: null,
            child: Text(
              '${quizController.score.value}/${quizController.questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )),
        ],
      ),
      body: Obx(() {
        if (quizController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  quizController.loadingMessage.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (quizController.questions.isEmpty) {
          return const Center(
            child: Text('No questions available'),
          );
        }

        return Column(
          children: [
            // Progress Bar
            _buildProgressBar(context, quizController)
                .animate()
                .fadeIn(duration: 400.ms),

            // Question Content
            Expanded(
              child: _buildQuestionContent(context, quizController, settingsController)
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideX(begin: 0.1, end: 0),
            ),

            // Navigation Buttons
            _buildNavigationButtons(context, quizController)
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms),
          ],
        );
      }),
    );
  }

  Widget _buildProgressBar(BuildContext context, QuizController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${controller.currentQuestionIndex.value + 1} of ${controller.questions.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(controller.getProgressPercentage() * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: controller.getProgressPercentage(),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(BuildContext context, QuizController controller, SettingsController settingsController) {
    final currentQuestion = controller.getCurrentQuestion();
    if (currentQuestion == null) return const SizedBox.shrink();

    final userAnswer = controller.getUserAnswerForCurrentQuestion();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                      Icons.quiz,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Question ${controller.currentQuestionIndex.value + 1}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentQuestion.question,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Options
          Text(
            'Select your answer:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...currentQuestion.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isSelected = userAnswer == index;
            final isAnswered = userAnswer != null;

            return _buildOptionCard(
              context,
              option,
              index,
              isSelected,
              isAnswered,
              currentQuestion.correctAnswerIndex,
              () => _selectAnswer(controller, index),
            ).animate().fadeIn(
              duration: 400.ms,
              delay: (index * 100).ms,
            ).slideX(begin: 0.2, end: 0);
          }).toList(),

          const SizedBox(height: 24),

          // Explanation (if answered and enabled)
          if (userAnswer != null && settingsController.showExplanations.value)
            _buildExplanationCard(context, currentQuestion, userAnswer)
                .animate()
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String option,
    int index,
    bool isSelected,
    bool isAnswered,
    int correctAnswerIndex,
    VoidCallback onTap,
  ) {
    Color? backgroundColor;
    Color? borderColor;
    IconData? icon;
    Color? iconColor;

    if (isAnswered) {
      if (index == correctAnswerIndex) {
        // Correct answer
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        icon = Icons.check_circle;
        iconColor = Colors.green;
      } else if (isSelected && index != correctAnswerIndex) {
        // Wrong answer selected
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        icon = Icons.cancel;
        iconColor = Colors.red;
      }
    } else if (isSelected) {
      // Selected but not answered yet
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
      borderColor = Theme.of(context).colorScheme.primary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: isAnswered ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor,
            border: borderColor != null
                ? Border.all(color: borderColor, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: iconColor, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard(BuildContext context, dynamic question, int userAnswer) {
    final isCorrect = userAnswer == question.correctAnswerIndex;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.info,
                color: isCorrect ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct!' : 'Explanation',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, QuizController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          // Navigation buttons
          Row(
        children: [
          // Previous Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.currentQuestionIndex.value > 0
                  ? () => controller.previousQuestion()
                  : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Next/Finish Button
          Expanded(
            child: Obx(() {
              final isLastQuestion = controller.currentQuestionIndex.value == controller.questions.length - 1;
              final isAnswered = controller.isCurrentQuestionAnswered();
              
              return ElevatedButton.icon(
                onPressed: isAnswered
                    ? () async {
                        if (isLastQuestion) {
                          await controller.completeQuiz();
                          // Navigate to progress view after quiz completion
                          Get.offAllNamed('/progress');
                        } else {
                          controller.nextQuestion();
                        }
                      }
                    : null,
                icon: Icon(isLastQuestion ? Icons.check : Icons.arrow_forward),
                label: Text(isLastQuestion ? 'Finish' : 'Next'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              );
            }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectAnswer(QuizController controller, int answerIndex) {
    controller.answerQuestion(answerIndex);
  }

  void _showExitDialog(BuildContext context, QuizController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.resetQuiz();
              Get.back();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
} 