import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ml_object_detection/utils/extension.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final String objectName;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.objectName,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(imagePath),
                  fit: context.isLandscape ? BoxFit.fitHeight : BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Object Type: ${objectName.toUpperCase()}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${DateFormat.yMMMd().add_Hms().format(timestamp)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
