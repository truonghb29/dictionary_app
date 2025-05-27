import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../models/word.dart';
import '../services/auth_service.dart';
import '../widgets/translations_viewer.dart';
import '../widgets/animated_list_item.dart';
import 'add_word_page.dart';
import 'admin_dashboard_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Show confirmation dialog before deleting a word
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Confirm Delete'),
                content: const Text(
                  'Are you sure you want to delete this word?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  // Navigate to edit page
  void _editWord(BuildContext context, Word word, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddWordPage(wordToEdit: word, wordIndex: index),
      ),
    );
  }

  // Navigate to profile page
  void _navigateToProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dictionary App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Debug indicator for authentication status
          Consumer<WordProvider>(
            builder: (context, wordProvider, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: wordProvider.isUserLoggedIn ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  wordProvider.isUserLoggedIn ? 'ONLINE' : 'OFFLINE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _navigateToProfile,
          ),
        ],
      ),
      body: Column(
        children: [
          if (searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search words...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: Consumer<WordProvider>(
              builder: (ctx, wordProvider, _) {
                // Show loading indicator
                if (wordProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Show error message if any
                if (wordProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${wordProvider.errorMessage}',
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            wordProvider.clearError();
                            wordProvider.loadWords();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final words =
                    searchQuery.isEmpty
                        ? wordProvider.words
                        : wordProvider.searchWord(searchQuery);

                if (words.isEmpty) {
                  return const Center(child: Text('No words found. Add some!'));
                }

                // Build the word card widget
                Widget buildWordCard(Word word, int providerIndex) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  word.term,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Edit button
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed:
                                    () =>
                                        _editWord(context, word, providerIndex),
                                color: Theme.of(ctx).primaryColor,
                              ),
                              // Delete button
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () async {
                                  if (await _confirmDelete(context)) {
                                    try {
                                      // Show loading
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );

                                      await wordProvider.deleteWord(providerIndex);
                                      
                                      // Close loading dialog
                                      Navigator.of(context).pop();
                                      
                                      // Show success message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Word deleted successfully'),
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
                                },
                                color: Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Display translations using the TranslationsViewer widget
                          TranslationsViewer(translations: word.translations),
                          if (word.example != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Example: ${word.example}',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                // If searching, display a flat list
                if (searchQuery.isNotEmpty) {
                  return ListView.builder(
                    itemCount: words.length,
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (ctx, index) {
                      final word = words[index];
                      final providerIndex = wordProvider.findWordIndex(
                        word.term,
                      );
                      return AnimatedListItem(
                        index: index,
                        child: buildWordCard(word, providerIndex),
                      );
                    },
                  );
                }

                // Otherwise, group by first letter
                final letters = wordProvider.uniqueFirstLetters;
                return ListView.builder(
                  itemCount: letters.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (ctx, letterIndex) {
                    final letter = letters[letterIndex];
                    final letterWords = wordProvider.getWordsStartingWith(
                      letter,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            color: Theme.of(ctx).primaryColor.withOpacity(0.1),
                            width: double.infinity,
                            child: Text(
                              letter,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(ctx).primaryColor,
                              ),
                            ),
                          ),
                        ),
                        ...letterWords.asMap().entries.map((entry) {
                          final int localIndex = entry.key;
                          final Word word = entry.value;
                          final providerIndex = wordProvider.findWordIndex(
                            word.term,
                          );
                          return AnimatedListItem(
                            index: localIndex,
                            child: buildWordCard(word, providerIndex),
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const AddWordPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void showSearch(BuildContext context) {
    setState(() {
      searchQuery = ' '; // Set to non-empty to show search field
      _searchController.clear();
    });
  }
}
