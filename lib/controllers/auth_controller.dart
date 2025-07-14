import 'package:get/get.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final Rx<AuthState> authState = AuthState().obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    authState.value = authState.value.copyWith(isLoading: true);
    
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        authState.value = AuthState(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      } else {
        authState.value = AuthState(isLoading: false);
      }
    } catch (e) {
      authState.value = AuthState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    authState.value = authState.value.copyWith(isLoading: true, error: null);
    
    try {
      final user = await AuthService.register(
        email: email,
        password: password,
        name: name,
      );
      
      if (user != null) {
        authState.value = AuthState(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      authState.value = authState.value.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    authState.value = authState.value.copyWith(isLoading: true, error: null);
    
    try {
      final user = await AuthService.login(
        email: email,
        password: password,
      );
      
      if (user != null) {
        authState.value = AuthState(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
        return true;
      }
      return false;
    } catch (e) {
      authState.value = authState.value.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    authState.value = authState.value.copyWith(isLoading: true);
    
    try {
      await AuthService.logout();
      authState.value = AuthState(isLoading: false);
      Get.offAllNamed('/auth');
    } catch (e) {
      authState.value = authState.value.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await AuthService.updateUserPreferences(preferences);
      
      // Update local state
      final currentUser = authState.value.user;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(preferences: preferences);
        authState.value = authState.value.copyWith(user: updatedUser);
      }
    } catch (e) {
      authState.value = authState.value.copyWith(error: e.toString());
    }
  }

  void clearError() {
    authState.value = authState.value.copyWith(error: null);
  }

  bool get isAuthenticated => authState.value.isAuthenticated;
  User? get currentUser => authState.value.user;
  bool get isLoading => authState.value.isLoading;
  String? get error => authState.value.error;
} 