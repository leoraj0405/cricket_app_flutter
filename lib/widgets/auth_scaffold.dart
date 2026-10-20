import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'ground_background.dart';

/// Layout shared by the auth screens: the stadium backdrop with [header] on
/// top and a white sheet holding [title], [subtitle] and [child] below.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.header,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final Widget header;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Caps the form at 420px wide while the white sheet spans the screen.
    final horizontalPadding = math.max(
      24.0,
      (MediaQuery.sizeOf(context).width - 420) / 2,
    );

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: GroundBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: header),
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    28,
                    horizontalPadding,
                    24 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      child,
                    ],
                  ),
                ),
              ),
              // Extends the white sheet to the bottom edge on tall screens.
              const SliverFillRemaining(
                hasScrollBody: false,
                child: ColoredBox(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small header for the secondary auth screens: a back button and an icon
/// badge.
class CompactAuthHeader extends StatelessWidget {
  const CompactAuthHeader({
    super.key,
    required this.icon,
    this.canGoBack = true,
  });

  final IconData icon;

  /// Disable while a request is in flight.
  final bool canGoBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: 'Back',
              color: Colors.white,
              disabledColor: Colors.white38,
              onPressed: canGoBack
                  ? () => Navigator.of(context).maybePop()
                  : null,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.amber.withValues(alpha: 0.2),
                  blurRadius: 28,
                ),
              ],
            ),
            child: Icon(icon, size: 36, color: AppColors.amber),
          ),
        ],
      ),
    );
  }
}
