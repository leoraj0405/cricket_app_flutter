import 'package:flutter/material.dart';

import '../core/validators.dart';
import '../theme/app_theme.dart';

/// Password + confirm password fields with a live checklist of
/// [passwordRules], used when choosing a new password.
class NewPasswordFields extends StatefulWidget {
  const NewPasswordFields({
    super.key,
    required this.passwordController,
    required this.confirmController,
    required this.enabled,
    required this.onChanged,
    required this.onSubmitted,
    this.passwordLabel = 'Password',
  });

  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool enabled;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;
  final String passwordLabel;

  @override
  State<NewPasswordFields> createState() => _NewPasswordFieldsState();
}

class _NewPasswordFieldsState extends State<NewPasswordFields> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Widget _visibilityToggle(bool obscured, VoidCallback onPressed) {
    return IconButton(
      tooltip: obscured ? 'Show password' : 'Hide password',
      onPressed: onPressed,
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.passwordController,
          enabled: widget.enabled,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (_) => widget.onChanged(),
          decoration: InputDecoration(
            labelText: widget.passwordLabel,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: _visibilityToggle(
              _obscurePassword,
              () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: Validators.newPassword,
        ),
        const SizedBox(height: 12),
        _PasswordChecklist(controller: widget.passwordController),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.confirmController,
          enabled: widget.enabled,
          obscureText: _obscureConfirm,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (_) => widget.onChanged(),
          onFieldSubmitted: (_) => widget.onSubmitted(),
          decoration: InputDecoration(
            labelText: 'Confirm password',
            prefixIcon: const Icon(Icons.lock_reset_rounded),
            suffixIcon: _visibilityToggle(
              _obscureConfirm,
              () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          validator: (value) =>
              Validators.confirmPassword(value, widget.passwordController.text),
        ),
      ],
    );
  }
}

class _PasswordChecklist extends StatelessWidget {
  const _PasswordChecklist({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final password = controller.text;
        return Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            for (final rule in passwordRules)
              _RuleItem(label: rule.label, met: rule.isMetBy(password)),
          ],
        );
      },
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.pitchGreen : AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label[0].toUpperCase() + label.substring(1),
          style: TextStyle(
            fontSize: 12.5,
            color: color,
            fontWeight: met ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
