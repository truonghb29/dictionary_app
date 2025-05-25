import '../models/word.dart';

class SampleData {
  static List<Word> getSampleWords() {
    return [
      Word(
        term: 'Hello',
        translations: {
          'English': 'A greeting used when meeting someone',
          'Vietnamese': 'Xin chào',
          'French': 'Bonjour',
          'Spanish': 'Hola',
        },
        example: 'Hello, how are you today?',
      ),
      Word(
        term: 'Goodbye',
        translations: {
          'English': 'A farewell used when parting',
          'Vietnamese': 'Tạm biệt',
          'French': 'Au revoir',
          'Spanish': 'Adiós',
        },
        example: 'Goodbye, see you tomorrow!',
      ),
      Word(
        term: 'Thank you',
        translations: {
          'English': 'An expression of gratitude',
          'Vietnamese': 'Cảm ơn',
          'French': 'Merci',
          'Spanish': 'Gracias',
        },
        example: 'Thank you for your help!',
      ),
      Word(
        term: 'Please',
        translations: {
          'English': 'Used as a polite addition to requests',
          'Vietnamese': 'Làm ơn',
          'French': 'S\'il vous plaît',
          'Spanish': 'Por favor',
        },
        example: 'Please pass the salt.',
      ),
      Word(
        term: 'Sorry',
        translations: {
          'English': 'Used as an expression of regret',
          'Vietnamese': 'Xin lỗi',
          'French': 'Désolé',
          'Spanish': 'Lo siento',
        },
        example: 'I\'m sorry for being late.',
      ),
    ];
  }
}
