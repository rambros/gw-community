// lib/ui/auth/invite_accept_page/view_model/invite_accept_view_model.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gw_community/data/services/auth/providers/apple_auth_provider.dart';
import 'package:gw_community/data/services/auth/providers/google_auth_provider.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class InviteAcceptViewModel extends ChangeNotifier {
  InviteAcceptViewModel({required this.token});

  final String token;

  // ========== CONTROLLERS ==========

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();

  final TextEditingController confirmPasswordController = TextEditingController();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  // ========== STATE ==========

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isValidatingToken = true;
  bool get isValidatingToken => _isValidatingToken;

  bool _tokenValid = false;
  bool get tokenValid => _tokenValid;

  bool _passwordVisibility = false;
  bool get passwordVisibility => _passwordVisibility;

  bool _confirmPasswordVisibility = false;
  bool get confirmPasswordVisibility => _confirmPasswordVisibility;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _tokenError;
  String? get tokenError => _tokenError;

  // ========== INITIALIZATION ==========

  Future<void> init() async {
    // Validate token existence and basic format immediately
    if (token.isEmpty) {
      _tokenValid = false;
      _tokenError = 'Invalid invitation link.';
      _isValidatingToken = false;
      notifyListeners();
      return;
    }

    debugPrint('🔍 Validating token: $token');

    // Validate token with backend via Edge Function with timeout
    try {
      final response = await SupaFlow.client.functions
          .invoke('validate-invite', body: {'token': token})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('⏱️ Timeout validating token');
              throw TimeoutException('Request timed out');
            },
          );

      debugPrint('📡 Response status: ${response.status}');
      debugPrint('📡 Response data: ${response.data}');

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('✅ Parsed data: $data');

        if (data['valid'] == true) {
          _tokenValid = true;
          debugPrint('✅ Token is valid!');
        } else {
          _tokenValid = false;
          _tokenError = data['message'] as String? ?? 'This invitation link is invalid or has expired.';
          debugPrint('❌ Token invalid: $_tokenError');
        }
      } else {
        _tokenValid = false;
        _tokenError = 'Error validating invitation. Please try again.';
        debugPrint('❌ Bad response status: ${response.status}');
      }
    } on TimeoutException catch (e) {
      debugPrint('❌ Timeout error: $e');
      _tokenValid = false;
      _tokenError = 'Request timed out. Please check your internet connection and try again.';
    } catch (e) {
      debugPrint('❌ Error validating token: $e');
      _tokenValid = false;
      _tokenError = 'Error validating invitation. Please try again.';
    }

    _isValidatingToken = false;
    notifyListeners();
  }

  // ========== COMMANDS ==========

  void togglePasswordVisibility() {
    _passwordVisibility = !_passwordVisibility;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _confirmPasswordVisibility = !_confirmPasswordVisibility;
    notifyListeners();
  }

  Future<bool> submitPassword() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call Edge Function to accept invite
      final response = await SupaFlow.client.functions.invoke(
        'accept-invite',
        body: {'token': token, 'password': passwordController.text.trim()},
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = data['error'] as String? ?? 'Failed to accept invitation. Please try again.';
        }
      } else {
        final data = response.data as Map<String, dynamic>?;
        _errorMessage = data?['error'] as String? ?? 'Failed to accept invitation. Please try again.';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ========== OAUTH ==========

  Future<bool> signInWithOAuth({required bool isApple}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = isApple ? await appleSignInFunc() : await googleSignInFunc();

      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Link the authenticated OAuth user to the invite record
      final response = await SupaFlow.client.functions
          .invoke('accept-invite-oauth', body: {'token': token})
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException('Request timed out'),
          );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true) {
          _isLoading = false;
          notifyListeners();
          return true;
        }
        _errorMessage = data['error'] as String? ?? 'Failed to accept invitation.';
      } else {
        final data = response.data as Map<String, dynamic>?;
        _errorMessage = data?['error'] as String? ?? 'Failed to accept invitation.';
      }

      // Link failed — sign out to avoid a partially-linked session
      await SupaFlow.client.auth.signOut();
    } on TimeoutException {
      _errorMessage = 'Request timed out. Please check your connection and try again.';
      await SupaFlow.client.auth.signOut();
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      await SupaFlow.client.auth.signOut();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ========== VALIDATORS ==========

  String? validatePassword(String? val) {
    if (val == null || val.isEmpty) {
      return 'Password is required';
    }
    if (val.length < 6) {
      return 'Minimum 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? val) {
    if (val == null || val.isEmpty) {
      return 'Confirm password is required';
    }
    if (val != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  void dispose() {
    passwordController.dispose();
    passwordFocusNode.dispose();
    confirmPasswordController.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
