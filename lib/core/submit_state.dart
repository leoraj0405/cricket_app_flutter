import 'dart:async';

import 'package:flutter/widgets.dart';

import 'network/api_exception.dart';

/// Loading / error state for a form that submits to the API.
///
/// Wrap the request in [runSubmit]: it blocks double taps, flips
/// [isSlow] after a few seconds (the server may be cold-starting) and turns
/// any failure into [errorMessage].
mixin SubmitState<T extends StatefulWidget> on State<T> {
  bool isSubmitting = false;
  bool isSlow = false;
  String? errorMessage;
  Timer? _slowTimer;

  Future<void> runSubmit(Future<void> Function() action) async {
    if (isSubmitting) return;
    setState(() {
      isSubmitting = true;
      isSlow = false;
      errorMessage = null;
    });
    _slowTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => isSlow = true);
    });

    try {
      await action();
    } on ApiException catch (e) {
      showError(e.message);
    } catch (_) {
      showError('Something went wrong. Please try again.');
    } finally {
      _slowTimer?.cancel();
      if (mounted) {
        setState(() {
          isSubmitting = false;
          isSlow = false;
        });
      }
    }
  }

  void showError(String message) {
    if (mounted) setState(() => errorMessage = message);
  }

  void clearError() {
    if (errorMessage != null) setState(() => errorMessage = null);
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    super.dispose();
  }
}
