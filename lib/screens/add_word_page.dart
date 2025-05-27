import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word.dart';
import '../providers/word_provider.dart';
import '../widgets/translation_item.dart';

class AddWordPage extends StatefulWidget {
  final Word? wordToEdit;
  final int? wordIndex;

  const AddWordPage({super.key, this.wordToEdit, this.wordIndex});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final _formKey = GlobalKey<FormState>();
  final _termController = TextEditingController();
  final _exampleController = TextEditingController();

  // List to hold language and translation controllers
  final List<Map<String, TextEditingController>> _translationControllers = [];

  @override
  void initState() {
    super.initState();

    if (widget.wordToEdit != null) {
      // If editing, populate fields with existing data
      _termController.text = widget.wordToEdit!.term;
      if (widget.wordToEdit!.example != null) {
        _exampleController.text = widget.wordToEdit!.example!;
      }

      // Populate translation fields
      widget.wordToEdit!.translations.forEach((language, translation) {
        final controllers = {
          'language': TextEditingController(text: language),
          'translation': TextEditingController(text: translation),
        };
        _translationControllers.add(controllers);
      });
    }

    // If no translations (new word or empty translations map), add an empty field
    if (_translationControllers.isEmpty) {
      _addTranslationField();
    }
  }

  void _addTranslationField() {
    setState(() {
      _translationControllers.add({
        'language': TextEditingController(),
        'translation': TextEditingController(),
      });
    });
  }

  void _removeTranslationField(int index) {
    setState(() {
      // Dispose controllers to avoid memory leaks
      _translationControllers[index]['language']?.dispose();
      _translationControllers[index]['translation']?.dispose();
      _translationControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _termController.dispose();
    _exampleController.dispose();
    // Dispose all translation controllers
    for (var controllers in _translationControllers) {
      controllers['language']?.dispose();
      controllers['translation']?.dispose();
    }
    super.dispose();
  }

  void _saveWord() async {
    if (_formKey.currentState!.validate()) {
      // Build translations map
      final Map<String, String> translations = {};
      for (var controllers in _translationControllers) {
        final language = controllers['language']!.text.trim();
        final translation = controllers['translation']!.text.trim();
        if (language.isNotEmpty && translation.isNotEmpty) {
          translations[language] = translation;
        }
      }

      if (translations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one translation'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final word = Word(
        term: _termController.text.trim(),
        translations: translations,
        example:
            _exampleController.text.trim().isEmpty
                ? null
                : _exampleController.text.trim(),
        createdAt: widget.wordToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final wordProvider = Provider.of<WordProvider>(context, listen: false);

      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        if (widget.wordToEdit != null && widget.wordIndex != null) {
          // Update existing word
          await wordProvider.updateWord(widget.wordIndex!, word);
        } else {
          // Add new word
          await wordProvider.addWord(word);
        }

        // Close loading dialog
        Navigator.of(context).pop();
        
        // Navigate back to home page
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.wordToEdit != null 
                ? 'Word updated successfully' 
                : 'Word added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wordToEdit != null ? 'Edit Word' : 'Add New Word'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _termController,
                  decoration: const InputDecoration(
                    labelText: 'Word',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a word';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Translations section
                const Text(
                  'Translations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  _translationControllers.length,
                  (index) => TranslationItem(
                    index: index,
                    languageController:
                        _translationControllers[index]['language']!,
                    translationController:
                        _translationControllers[index]['translation']!,
                    onRemove: () => _removeTranslationField(index),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addTranslationField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Translation'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _exampleController,
                  decoration: const InputDecoration(
                    labelText: 'Example (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveWord,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Save Word',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
