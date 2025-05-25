import 'package:flutter/material.dart';

class TranslationItem extends StatelessWidget {
  final TextEditingController languageController;
  final TextEditingController translationController;
  final VoidCallback onRemove;
  final int index;

  const TranslationItem({
    super.key,
    required this.languageController,
    required this.translationController,
    required this.onRemove,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Translation ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: languageController,
              decoration: const InputDecoration(
                labelText: 'Language',
                border: OutlineInputBorder(),
                hintText: 'e.g., English, Vietnamese, French',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a language';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: translationController,
              decoration: const InputDecoration(
                labelText: 'Translation',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a translation';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
