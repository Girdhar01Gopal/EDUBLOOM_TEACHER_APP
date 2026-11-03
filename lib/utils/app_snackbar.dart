import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Place at: lib/utils/app_snackbar.dart
///
/// Single place for every snackbar in the app:
///  - always slides in from the TOP
///  - white card + green (success) / red (error) accent
///  - raw API / exception text is NEVER shown to the user
///    (user sees "Something went wrong"; the real error is printed in console)
class AppSnackbar {
  AppSnackbar._();

  static const Color _green = Color(0xFF16A34A);
  static const Color _red = Color(0xFFDC2626);
  static const Color _text = Color(0xFF1F2937);

  static const String _genericError = 'Something went wrong. Please try again.';
  static const String _noInternet =
      'No internet connection. Please check your network.';
  static const String _timeout = 'The request timed out. Please try again.';

  static const TextStyle _messageStyle =
  TextStyle(color: _text, fontSize: 13, height: 1.3);

  static const EdgeInsets _margin = EdgeInsets.fromLTRB(14, 12, 14, 0);
  static const EdgeInsets _padding =
  EdgeInsets.symmetric(horizontal: 14, vertical: 12);

  // Words / patterns that mean "this is a technical message, don't show it".
  static final RegExp _technical = RegExp(
    r"Exception|Error:|errno|Null check|type '|StackTrace|<html|^\s*[\{\[<]",
    caseSensitive: false,
  );

  // Patterns that mean "device has no network" (works even when the
  // SocketException is wrapped inside http's ClientException).
  static final RegExp _networkDown = RegExp(
    r"SocketException|Failed host lookup|Network is unreachable|Connection (failed|refused|reset)|No address associated",
    caseSensitive: false,
  );

  static void success(String message, {String title = 'Success'}) =>
      _show(title, message, _green, Icons.check_circle_rounded);

  /// Shows an error snackbar. If [message] looks technical (exception text,
  /// html, json, very long, network error ...) the user sees
  /// "Something went wrong" and the real text is printed in the console.
  static void error(String message, {String title = 'Error'}) {
    final safe = _sanitize(message);
    if (safe != message.trim()) {
      _log('error()', message);
    }
    _show(title, safe, _red, Icons.error_rounded);
  }

  /// One-liner for every `catch` / `onError` block:
  /// `AppSnackbar.apiError(e);` or `AppSnackbar.apiError(e, stackTrace: s);`
  ///
  /// User  -> always sees "Something went wrong. Please try again."
  /// Console -> prints the real error (+ status code / stack trace).
  static void apiError(
      Object? error, {
        int? statusCode,
        StackTrace? stackTrace,
        String title = 'Error',
        String fallback = _genericError,
      }) {
    _log('apiError()', error, statusCode: statusCode, stackTrace: stackTrace);
    _show(title, fallback, _red, Icons.error_rounded);
  }

  /// Prints the real error in the debug console so you can see what failed.
  static void _log(
      String source,
      Object? error, {
        int? statusCode,
        StackTrace? stackTrace,
      }) {
    debugPrint('┌── AppSnackbar $source');
    if (statusCode != null) debugPrint('│ statusCode : $statusCode');
    debugPrint('│ error      : $error');
    if (stackTrace != null) debugPrint('│ stackTrace : $stackTrace');
    debugPrint('└──────────────────────');
  }

  /// Converts an exception and/or HTTP status code into a readable line.
  /// (Not used by [apiError] any more; kept in case you want a specific
  /// message for some screen.)
  static String friendlyMessage(
      Object? error, {
        int? statusCode,
        String fallback = _genericError,
      }) {
    final text = error?.toString() ?? '';

    if (error is SocketException || _networkDown.hasMatch(text)) {
      return _noInternet;
    }
    if (error is TimeoutException || text.contains('TimeoutException')) {
      return _timeout;
    }
    if (error is HandshakeException || text.contains('HandshakeException')) {
      return 'Secure connection failed. Please try again.';
    }
    if (error is FormatException) {
      return 'Received an unexpected response from the server.';
    }
    switch (statusCode) {
      case null:
        return fallback;
      case 400:
        return 'Invalid request. Please try again.';
      case 401:
      case 403:
        return 'Your session has expired or you do not have permission. Please login again.';
      case 404:
        return 'The requested data was not found.';
      case 408:
        return _timeout;
      case 429:
        return 'Too many requests. Please wait a moment.';
      default:
        return statusCode >= 500
            ? 'Server is busy right now. Please try again later.'
            : fallback;
    }
  }

  static String _sanitize(String message) {
    final m = message.trim();
    if (m.isEmpty) return _genericError;
    if (_networkDown.hasMatch(m)) return _genericError;
    if (m.length > 140 || _technical.hasMatch(m)) return _genericError;
    return m;
  }

  static void _show(String title, String message, Color accent, IconData icon) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.w800,
          fontSize: 15,
        ),
      ),
      messageText: Text(message, style: _messageStyle),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      borderRadius: 14,
      margin: _margin,
      padding: _padding,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 400),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
      leftBarIndicatorColor: accent,
      isDismissible: true,
      dismissDirection: DismissDirection.up,
      shouldIconPulse: false,
      boxShadows: [
        BoxShadow(
          color: accent.withOpacity(0.22),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withOpacity(0.12),
        ),
        child: Icon(icon, color: accent, size: 22),
      ),
    );
  }
}