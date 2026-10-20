import 'package:flutter/material.dart';

import '../core/submit_state.dart';
import '../core/validators.dart';
import '../services/auth_service.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/error_banner.dart';
import '../widgets/submit_button.dart';
import 'verify_otp_screen.dart';

/// Step 1 of the reset flow: ask for the email and send a one-time code.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.authService,
    this.initialEmail = '',
  });

  final AuthService authService;
  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SubmitState {
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
    text: widget.initialEmail,
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    clearError();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    await runSubmit(() async {
      await widget.authService.forgotPassword(email: email);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              VerifyOtpScreen(authService: widget.authService, email: email),
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
          icon: Icons.lock_reset_rounded,
          canGoBack: !isSubmitting,
        ),
        title: 'Forgot password?',
        subtitle:
            "Enter your account email and we'll send you a "
            '${Validators.otpLength}-digit code to reset your password.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedErrorBanner(message: errorMessage, onDismiss: clearError),
              TextFormField(
                controller: _emailController,
                enabled: !isSubmitting,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                onChanged: (_) => clearError(),
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: Validators.email,
              ),
              const SizedBox(height: 24),
              SubmitButton(
                label: 'Send code',
                loadingLabel: 'Sending code...',
                isLoading: isSubmitting,
                isSlow: isSlow,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(context).maybePop(),
                child: const Text('Back to sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
