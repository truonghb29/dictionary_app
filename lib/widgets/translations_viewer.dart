import 'package:flutter/material.dart';

class TranslationsViewer extends StatefulWidget {
  final Map<String, String> translations;

  const TranslationsViewer({super.key, required this.translations});

  @override
  State<TranslationsViewer> createState() => _TranslationsViewerState();
}

class _TranslationsViewerState extends State<TranslationsViewer> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    // If there are no translations or only one, just show it directly
    if (widget.translations.isEmpty) {
      return const Text('No translations available');
    }

    if (widget.translations.length == 1) {
      final entry = widget.translations.entries.first;
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "${entry.key}: ",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            TextSpan(
              text: entry.value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      );
    }

    // If there are multiple translations, use an expandable view
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Always show the first translation
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "${widget.translations.entries.first.key}: ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              TextSpan(
                text: widget.translations.entries.first.value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),

        // Show the rest of translations if expanded
        if (_expanded)
          ...widget.translations.entries.skip(1).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${entry.key}: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: entry.value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

        // Toggle button
        if (widget.translations.length > 1)
          TextButton(
            onPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _expanded
                      ? 'Show less'
                      : 'Show ${widget.translations.length - 1} more translations',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
