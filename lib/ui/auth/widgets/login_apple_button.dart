import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Apple Sign-In button using the official widget from sign_in_with_apple,
/// which renders ASAuthorizationAppleIDButton and complies with Apple's guidelines.
class LoginAppleButton extends StatelessWidget {
  const LoginAppleButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: SignInWithAppleButton(
        onPressed: isLoading ? () {} : onPressed,
        style: SignInWithAppleButtonStyle.whiteOutlined,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        text: isLoading ? 'Signing in...' : 'Sign in with Apple',
      ),
    );
  }
}
