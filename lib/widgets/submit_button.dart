import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Primary form button with a spinner while loading, plus a "warming up"
/// hint when the request is slow.
class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.label,
    required this.loadingLabel,
    required this.isLoading,
    required this.onPressed,
    this.isSlow = false,
  });

  final String label;
  final String loadingLabel;
  final bool isLoading;
  final bool isSlow;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(loadingLabel),
                  ],
                )
              : Text(label),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: isSlow
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Warming up the server, this can take up to '
                    '30 seconds on the first try...',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
