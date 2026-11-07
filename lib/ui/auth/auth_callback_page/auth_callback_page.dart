import 'package:flutter/material.dart';
import 'package:gw_community/routing/auth_deep_link_handler.dart';

/// Shown while a reset-password or magic-link URL is exchanged for a session.
class AuthCallbackPage extends StatefulWidget {
  const AuthCallbackPage({super.key, required this.uri});

  final Uri uri;

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  @override
  void initState() {
    super.initState();
    AuthDeepLinkHandler.instance.handle(widget.uri);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
