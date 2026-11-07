import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/routing/auth_callback_link.dart';
import 'package:gw_community/routing/portal_app_links.dart';
import 'package:gw_community/routing/router.dart';
import 'package:gw_community/ui/auth/change_password_page/change_password_page.dart';
import 'package:gw_community/ui/auth/login_page/login_page.dart';
import 'package:gw_community/ui/home/home_page/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Turns a password-reset or magic-link URL into a session and opens the
/// right screen. Password recovery must land on [ChangePasswordPage].
class AuthDeepLinkHandler {
  AuthDeepLinkHandler._();

  static final AuthDeepLinkHandler instance = AuthDeepLinkHandler._();

  static const _consumedAuthTokensKey = 'consumed_auth_token_hashes';

  final Set<String> _consumed = {};
  final Map<String, Future<void>> _inflight = {};
  Future<void>? _loadFuture;

  bool get _hasSession => SupaFlow.client.auth.currentSession != null;

  Future<void> handle(Uri uri) {
    final link = AuthCallbackLink.tryParse(uri);
    if (link == null) return Future.value();
    return _inflight.putIfAbsent(link.dedupeKey, () {
      return _complete(uri, link).whenComplete(() {
        _inflight.remove(link.dedupeKey);
      });
    });
  }

  Future<void> _complete(Uri uri, AuthCallbackLink link) async {
    await _ensureLoaded();

    final tokenKey = link.persistKey;
    if (tokenKey != null && _consumed.contains(tokenKey)) {
      debugPrint('🔗 Skipping auth callback: token already consumed');
      if (!_hasSession) {
        _showError('otp_already_used', recovery: link.isRecovery);
      } else if (AppStateNotifier.instance.pendingPasswordRecovery) {
        _go(ChangePasswordPage.routePath);
      }
      return;
    }

    if (link.errorCode != null) {
      if (!_hasSession) _showError(link.errorCode!, recovery: link.isRecovery);
      return;
    }

    if (!link.hasPayload) {
      // A shell URL (no code, no token) is what iOS delivers when the
      // browser confirmation dialog strips the query. Wait in case the
      // real link is still being exchanged on the other listener.
      for (var attempt = 0; attempt < 15; attempt++) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (AppStateNotifier.instance.pendingPasswordRecovery && _hasSession) {
          _go(ChangePasswordPage.routePath);
          return;
        }
        if (_hasSession) return;
        final anotherLinkInFlight = _inflight.length > 1;
        if (!anotherLinkInFlight && attempt >= 3) break;
      }
      if (!_hasSession) _showError('auth_failed', recovery: link.isRecovery);
      return;
    }

    if (link.isAccessLink) {
      await _completeAccessLink(link);
      return;
    }
    await _completeLoginCallback(uri, link);
  }

  Future<void> _completeAccessLink(AuthCallbackLink link) async {
    final tokenHash = link.tokenHash;
    if (tokenHash == null) {
      if (!_hasSession) _showError('otp_expired', recovery: link.isRecovery);
      return;
    }

    if (_hasSession && !link.isRecovery) {
      debugPrint('🔗 Skipping access-link: already signed in');
      await _markConsumed(tokenHash);
      return;
    }

    if (link.isRecovery) _markRecovery();

    try {
      debugPrint('🔗 Verifying access-link token');
      await SupaFlow.client.auth.verifyOTP(
        type: _otpType(link.params['type']),
        tokenHash: tokenHash,
      );
      await _markConsumed(tokenHash);
      if (link.isRecovery) {
        _markRecovery();
        _go(ChangePasswordPage.routePath);
      } else {
        _goAfterSignIn();
      }
    } on AuthException catch (e) {
      debugPrint('🔗 access-link verifyOTP failed: ${e.message}');
      await _markConsumed(tokenHash);
      if (link.isRecovery && !_hasSession) _clearRecovery();
      if (_hasSession && link.isRecovery) {
        _go(ChangePasswordPage.routePath);
        return;
      }
      if (_hasSession) return;
      _showError(
        e.message.toLowerCase().contains('expired')
            ? 'otp_expired'
            : 'auth_failed',
        recovery: link.isRecovery,
      );
    } catch (e, stackTrace) {
      debugPrint('🔗 access-link unexpected error: $e\n$stackTrace');
      if (link.isRecovery && !_hasSession) _clearRecovery();
      if (!_hasSession) _showError('auth_failed', recovery: link.isRecovery);
    }
  }

  Future<void> _completeLoginCallback(Uri uri, AuthCallbackLink link) async {
    if (link.isRecovery) _markRecovery();

    try {
      debugPrint('🔗 Exchanging login-callback for a session');
      final response = await SupaFlow.client.auth.getSessionFromUrl(uri);
      final recovery =
          link.isRecovery || _isRecoveryRedirect(response.redirectType);
      if (recovery) _markRecovery();
      final tokenKey = link.persistKey;
      if (tokenKey != null) await _markConsumed(tokenKey);
      if (recovery || AppStateNotifier.instance.pendingPasswordRecovery) {
        _go(ChangePasswordPage.routePath);
      } else {
        _goAfterSignIn();
      }
    } on AuthException catch (e) {
      debugPrint('🔗 login-callback exchange failed: ${e.message}');
      await _waitForSession();
      if (_hasSession &&
          (link.isRecovery ||
              AppStateNotifier.instance.pendingPasswordRecovery)) {
        _markRecovery();
        _go(ChangePasswordPage.routePath);
        return;
      }
      if (_hasSession) {
        _goAfterSignIn();
        return;
      }
      if (link.isRecovery) _clearRecovery();
      _showError(
        e.message.toLowerCase().contains('expired')
            ? 'otp_expired'
            : 'auth_failed',
        recovery: true,
      );
    } catch (e, stackTrace) {
      debugPrint('🔗 login-callback unexpected error: $e\n$stackTrace');
      await _waitForSession();
      if (_hasSession && AppStateNotifier.instance.pendingPasswordRecovery) {
        _go(ChangePasswordPage.routePath);
        return;
      }
      if (!_hasSession) _showError('auth_failed', recovery: link.isRecovery);
    }
  }

  Future<void> _waitForSession() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      if (_hasSession || AppStateNotifier.instance.pendingPasswordRecovery) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void _goAfterSignIn() {
    if (AppStateNotifier.instance.pendingPasswordRecovery) {
      _go(ChangePasswordPage.routePath);
      return;
    }
    if (AppStateNotifier.instance.hasRedirect()) {
      final location = AppStateNotifier.instance.getRedirectLocation();
      AppStateNotifier.instance.clearRedirectLocation();
      unawaited(_clearPendingPortalLink());
      _go(location);
      return;
    }
    _go(HomePage.routePath);
  }

  bool _isRecoveryRedirect(String? redirectType) {
    return redirectType == 'recovery' || redirectType == 'passwordRecovery';
  }

  void _markRecovery() {
    AppStateNotifier.instance.beginPasswordRecovery();
  }

  void _clearRecovery() {
    AppStateNotifier.instance.finishPasswordRecovery();
  }

  OtpType _otpType(String? type) {
    switch (type) {
      case 'recovery':
        return OtpType.recovery;
      case 'signup':
        return OtpType.signup;
      case 'invite':
        return OtpType.invite;
      case 'email_change':
        return OtpType.emailChange;
      case 'email':
        return OtpType.email;
      default:
        return OtpType.magiclink;
    }
  }

  Future<void> _ensureLoaded() {
    return _loadFuture ??= _loadConsumed();
  }

  Future<void> _loadConsumed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _consumed
        ..clear()
        ..addAll(prefs.getStringList(_consumedAuthTokensKey) ?? const []);
    } catch (e) {
      debugPrint('🔗 Failed to load consumed auth tokens: $e');
    }
  }

  Future<void> _markConsumed(String tokenKey) async {
    if (tokenKey.isEmpty || _consumed.contains(tokenKey)) return;
    _consumed.add(tokenKey);
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokens = _consumed.toList();
      if (tokens.length > 20) {
        tokens.removeRange(0, tokens.length - 20);
      }
      await prefs.setStringList(_consumedAuthTokensKey, tokens);
    } catch (e) {
      debugPrint('🔗 Failed to persist consumed auth token: $e');
    }
  }

  Future<void> _clearPendingPortalLink() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(PortalAppLinks.pendingLinkPrefsKey);
    } catch (e) {
      debugPrint('🔗 Failed to clear pending portal link: $e');
    }
  }

  void _go(String location, [int attempt = 0]) {
    final ctx = appNavigatorKey.currentContext;
    final routerNotReady =
        ctx == null || !ctx.mounted || AppStateNotifier.instance.loading;
    if (routerNotReady) {
      if (attempt < 30) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _go(location, attempt + 1);
        });
      }
      return;
    }
    debugPrint('🔗 Opening $location');
    ctx.go(location);
  }

  void _showError(String errorCode, {bool recovery = false}) {
    final message = switch (errorCode) {
      'otp_already_used' =>
        'This access link was already used. Open the app and request a new one.',
      'otp_expired' => 'The access link has expired. Please request a new one.',
      _ => recovery
          ? 'Could not open the password reset. Request a new link from the app.'
          : 'Authentication failed. Please try again.',
    };
    _showErrorWithRetry(message);
  }

  void _showErrorWithRetry(String message, [int attempt = 0]) {
    if (_hasSession && !AppStateNotifier.instance.pendingPasswordRecovery) {
      return;
    }

    final ctx = appNavigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) {
      if (attempt < 10) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _showErrorWithRetry(message, attempt + 1);
        });
      }
      return;
    }

    try {
      if (!AppStateNotifier.instance.pendingPasswordRecovery) {
        ctx.go(LoginPage.routePath);
      }
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
      ));
    } catch (_) {
      if (attempt < 10) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _showErrorWithRetry(message, attempt + 1);
        });
      }
    }
  }
}
