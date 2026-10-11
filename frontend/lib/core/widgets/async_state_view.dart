import 'package:flutter/material.dart';

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    required this.isLoading,
    required this.child,
    this.errorMessage,
    this.onRetry,
    super.key,
  });

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Loading'),
      );
    }

    final message = errorMessage;
    if (message != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFB5473C),
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return child;
  }
}
