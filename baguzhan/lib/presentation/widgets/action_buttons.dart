import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.primaryKey,
    this.secondaryLabel,
    this.onSecondaryPressed,
    this.secondaryKey,
  });

  final Key? primaryKey;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;

  final Key? secondaryKey;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            key: primaryKey,
            onPressed: onPrimaryPressed,
            child: Text(primaryLabel),
          ),
        ),
        if (secondaryLabel != null && onSecondaryPressed != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              key: secondaryKey,
              onPressed: onSecondaryPressed,
              child: Text(secondaryLabel!),
            ),
          ),
        ],
      ],
    );
  }
}
