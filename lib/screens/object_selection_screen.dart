import 'package:flutter/material.dart';
import 'package:ml_object_detection/utils/extension.dart';

import 'camera_screen.dart';

class ObjectSelectionScreen extends StatefulWidget {
  const ObjectSelectionScreen({super.key});

  final List<String> objects = const [
    'laptop',
    'monitor',
    'ipod',
    'bottle',
  ];

  @override
  State<ObjectSelectionScreen> createState() => _ObjectSelectionScreenState();
}

class _ObjectSelectionScreenState extends State<ObjectSelectionScreen> {
  String? selectedObjectName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Object'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.isLandscape ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: widget.objects.length,
              itemBuilder: (context, index) {
                return ObjectCard(
                  objectName: widget.objects[index],
                  onTap: () {
                    setState(() {
                      selectedObjectName = widget.objects[index];
                    });
                  },
                  isSelected: selectedObjectName == widget.objects[index],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: selectedObjectName == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CameraScreen(objectName: selectedObjectName!),
                          ),
                        ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18), // Increased font size
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ObjectCard extends StatelessWidget {
  final String objectName;
  final VoidCallback onTap;
  final bool isSelected;

  const ObjectCard({
    super.key,
    required this.objectName,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForObjectName(objectName),
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              objectName.toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForObjectName(String name) {
    switch (name.toLowerCase()) {
      case 'laptop':
        return Icons.laptop;
      case 'monitor':
        return Icons.desktop_windows;
      case 'ipod':
        return Icons.tablet;
      case 'bottle':
        return Icons.local_drink;
      default:
        return Icons.device_unknown;
    }
  }
}
