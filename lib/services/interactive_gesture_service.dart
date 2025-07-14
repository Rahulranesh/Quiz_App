import 'dart:async';
import 'package:flutter/services.dart';

class InteractiveAction {
  final String type;
  final Map<String, dynamic> data;

  InteractiveAction({required this.type, this.data = const {}});
}

class InteractiveGestureService {
  final StreamController<InteractiveAction> _gestureController = StreamController<InteractiveAction>.broadcast();
  Stream<InteractiveAction> get gestureStream => _gestureController.stream;

  // Simplified haptic feedback using Flutter's built-in haptic feedback
  void provideHapticFeedback(String intensity) {
    switch (intensity) {
      case 'light':
        HapticFeedback.lightImpact();
        break;
      case 'medium':
        HapticFeedback.mediumImpact();
        break;
      case 'heavy':
        HapticFeedback.heavyImpact();
        break;
      case 'selection':
        HapticFeedback.selectionClick();
        break;
      default:
        HapticFeedback.lightImpact();
    }
  }

  void triggerGesture(String gestureType, {Map<String, dynamic> data = const {}}) {
    _gestureController.add(InteractiveAction(type: gestureType, data: data));
  }

  void dispose() {
    _gestureController.close();
  }
} 