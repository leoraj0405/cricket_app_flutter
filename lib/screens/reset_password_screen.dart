import 'package:flutter/material.dart';

import '../core/submit_state.dart';
import '../services/auth_service.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/error_banner.dart';
import '../widgets/password_fields.dart';
import '../widgets/submit_button.dart';

/// Step 3 of the reset flow: choose a new password using the verified code.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.authService,
    required this.email,
    required this.otp,
  });

  final AuthService authService;
  final String email;
  final String otp;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SubmitState {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    clearError();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await runSubmit(() async {
      final message = await widget.authService.resetPassword(
        email: widget.email,
        otp: widget.otp,
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      // Back to the sign-in screen at the bottom of the stack.
      Navigator.of(context).popUntil((route) => route.isFirst);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message.isNotEmpty
                ? message
                : 'Password updated. Sign in with your new password.',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isSubmitting,
      child: AuthScaffold(
        header: CompactAuthHeader(
          icon: Icons.password_rounded,
          canGoBack: !isSubmitting,
        ),
        title: 'Set a new password',
        subtitle: 'Choose a new password for ${widget.email}',
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedErrorBanner(
                  message: errorMessage,
                  onDismiss: clearError,
                ),
                NewPasswordFields(
                  passwordController: _passwordController,
                  confirmController: _confirmController,
                  passwordLabel: 'New password',
                  enabled: !isSubmitting,
                  onChanged: clearError,
                  onSubmitted: _submit,
                ),
                const SizedBox(height: 24),
                SubmitButton(
                  label: 'Reset password',
                  loadingLabel: 'Updating...',
                  isLoading: isSubmitting,
                  isSlow: isSlow,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
