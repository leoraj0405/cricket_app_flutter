import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/network/api_exception.dart';
import '../core/submit_state.dart';
import '../core/validators.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/error_banner.dart';
import '../widgets/submit_button.dart';
import 'reset_password_screen.dart';

/// Step 2 of the reset flow: check the code that was emailed to [email].
class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.authService,
    required this.email,
  });

  final AuthService authService;
  final String email;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> with SubmitState {
  static const _resendCooldown = 30;

  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  bool _isResending = false;
  int _resendSecondsLeft = _resendCooldown;
  Timer? _resendTimer;

  bool get _isBusy => isSubmitting || _isResending;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsLeft = _resendCooldown);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _resendSecondsLeft--);
      if (_resendSecondsLeft <= 0) timer.cancel();
    });
  }

  Future<void> _submit() async {
    if (_isBusy) return;
    FocusScope.of(context).unfocus();
    clearError();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final otp = _otpController.text.trim();
    await runSubmit(() async {
      await widget.authService.verifyOtp(email: widget.email, otp: otp);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResetPasswordScreen(
            authService: widget.authService,
            email: widget.email,
            otp: otp,
          ),
        ),
      );
    });
  }

  Future<void> _resend() async {
    if (_isBusy || _resendSecondsLeft > 0) return;
    clearError();
    setState(() => _isResending = true);
    try {
      final message = await widget.authService.forgotPassword(
        email: widget.email,
      );
      if (!mounted) return;
      _otpController.clear();
      _startResendCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isNotEmpty ? message : 'A new code is on its way.',
          ),
        ),
      );
    } on ApiException catch (e) {
      showError(e.message);
    } catch (_) {
      showError('Could not resend the code. Please try again.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_isBusy,
      child: AuthScaffold(
        header: CompactAuthHeader(
          icon: Icons.mark_email_read_outlined,
          canGoBack: !_isBusy,
        ),
        title: 'Check your email',
        subtitle:
            'Enter the ${Validators.otpLength}-digit code we sent to '
            '${widget.email}',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedErrorBanner(message: errorMessage, onDismiss: clearError),
              TextFormField(
                controller: _otpController,
                enabled: !_isBusy,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                maxLength: Validators.otpLength,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 12,
                  color: AppColors.textPrimary,
                ),
                onChanged: (value) {
                  clearError();
                  if (value.length == Validators.otpLength) _submit();
                },
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  hintText: '------',
                  counterText: '',
                ),
                validator: Validators.otp,
              ),
              const SizedBox(height: 24),
              SubmitButton(
                label: 'Verify code',
                loadingLabel: 'Verifying...',
                isLoading: isSubmitting,
                isSlow: isSlow,
                onPressed: _isResending ? null : _submit,
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Didn't get the code?",
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: _isBusy || _resendSecondsLeft > 0
                        ? null
                        : _resend,
                    child: _isResending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _resendSecondsLeft > 0
                                ? 'Resend in ${_resendSecondsLeft}s'
                                : 'Resend code',
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
