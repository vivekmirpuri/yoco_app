import 'package:flutter/material.dart';

class UploadProgressDialog extends StatelessWidget {
  final double progress;
  final String fileName;
  final VoidCallback? onCancel;

  const UploadProgressDialog({
    Key? key,
    required this.progress,
    required this.fileName,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Uploading...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            fileName,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.2),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        if (onCancel != null)
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
      ],
    );
  }
} 