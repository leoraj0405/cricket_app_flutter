import 'package:flutter/material.dart';

import '../core/submit_state.dart';
import '../core/validators.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/error_banner.dart';
import '../widgets/password_fields.dart';
import '../widgets/submit_button.dart';

/// Sign-up form. Pops with the new account's email on success so the
/// sign-in screen can prefill it.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SubmitState {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    clearError();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    await runSubmit(() async {
      final message = await widget.authService.register(
        userName: _nameController.text.trim(),
        email: email,
        phone: _phoneController.text.replaceAll(RegExp(r'[\s-]'), ''),
        password: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.isNotEmpty
                ? message
                : 'Account created. Sign in to continue.',
          ),
        ),
      );
      Navigator.of(context).pop(email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isSubmitting,
      child: AuthScaffold(
        header: CompactAuthHeader(
          icon: Icons.sports_cricket_rounded,
          canGoBack: !isSubmitting,
        ),
        title: 'Create your account',
        subtitle: 'Join CCCHub to score matches and track your stats',
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
                TextFormField(
                  controller: _nameController,
                  enabled: !isSubmitting,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  onChanged: (_) => clearError(),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: Validators.userName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  enabled: !isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onChanged: (_) => clearError(),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  enabled: !isSubmitting,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  onChanged: (_) => clearError(),
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),
                NewPasswordFields(
                  passwordController: _passwordController,
                  confirmController: _confirmController,
                  enabled: !isSubmitting,
                  onChanged: clearError,
                  onSubmitted: _submit,
                ),
                const SizedBox(height: 24),
                SubmitButton(
                  label: 'Create account',
                  loadingLabel: 'Creating account...',
                  isLoading: isSubmitting,
                  isSlow: isSlow,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: isSubmitting
                          ? null
                          : () => Navigator.of(context).maybePop(),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
