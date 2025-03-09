import 'package:flutter/material.dart';

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final Color? color;

  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: color ?? Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: color ?? Theme.of(context).colorScheme.error,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color ?? Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ErrorOverlay extends StatelessWidget {
  final Widget child;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Color? color;

  const ErrorOverlay({
    super.key,
    required this.child,
    required this.hasError,
    this.errorMessage,
    this.onRetry,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (hasError)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: ErrorWidget(
              message: errorMessage ?? 'An error occurred',
              onRetry: onRetry,
              color: color ?? Colors.white,
            ),
          ),
      ],
    );
  }
}
