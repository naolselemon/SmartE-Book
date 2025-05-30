import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String? apiKey = dotenv.env['GEMINI_API_KEY'];
  final String baseUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';

  Future<List<Map<String, dynamic>>> getBookRecommendations({
    required List<Map<String, dynamic>> searchHistory,
    required List<Map<String, dynamic>> favorites,
    required List<Map<String, dynamic>> reviews,
    required List<Map<String, dynamic>> books,
  }) async {
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY is not set in .env file');
    }

    print('Books dataset sent to Gemini: $books'); // Log books dataset

    final prompt = _buildPrompt(searchHistory, favorites, reviews, books);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2000, // Increased to prevent truncation
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API response: $data'); // Log raw API response

        // Safely access nested fields
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception('No candidates found in API response');
        }

        final content = candidates[0]['content'] as Map<String, dynamic>?;
        if (content == null) {
          throw Exception('No content found in API response');
        }

        final parts = content['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) {
          throw Exception('No parts found in API response');
        }

        final recommendationsText = parts[0]['text'] as String?;
        if (recommendationsText == null) {
          throw Exception('No text found in API response parts');
        }

        print('Raw recommendations text: $recommendationsText'); // Log raw text

        // Clean Markdown code fences and whitespace
        String cleanedText = recommendationsText.trim().replaceAll(
          RegExp(r'^```json\s*|\s*```$'),
          '',
        );

        print('Cleaned recommendations text: $cleanedText'); // Log cleaned text

        // Validate and parse JSON
        try {
          final recommendations = jsonDecode(cleanedText) as List<dynamic>?;
          if (recommendations == null || recommendations.isEmpty) {
            throw Exception(
              'Failed to parse recommendations as JSON list or empty list',
            );
          }

          return recommendations.map((rec) {
            final map = rec as Map<String, dynamic>;
            // Ensure all required fields with defaults
            return {
              'bookId': map['bookId']?.toString() ?? '',
              'title': map['title']?.toString() ?? 'Unknown',
              'author': map['author']?.toString() ?? 'Unknown',
              'rating': map['rating'] is num ? map['rating'].toDouble() : 0.0,
              'reviews': map['reviews'] is num ? map['reviews'] as int : 0,
              'imageUrl':
                  map['imageUrl']?.toString() ??
                  'assets/images/placeholder.png',
              'reason': map['reason']?.toString() ?? '',
              'audioId': map['audioId']?.toString() ?? '',
              'audioUrl': map['audioUrl']?.toString() ?? '', // Ensure non-null
              'fileId': map['fileId']?.toString() ?? '',
              'price': map['price'] is num ? map['price'].toDouble() : 0.0,
            };
          }).toList();
        } catch (e) {
          // Fallback: Attempt to parse up to the last valid object
          try {
            final lastValidBracket = cleanedText.lastIndexOf('}');
            if (lastValidBracket > 0) {
              final partialText =
                  cleanedText.substring(0, lastValidBracket + 1) + ']';
              final recommendations = jsonDecode(partialText) as List<dynamic>?;
              if (recommendations != null && recommendations.isNotEmpty) {
                print('Parsed partial recommendations: $recommendations');
                return recommendations.map((rec) {
                  final map = rec as Map<String, dynamic>;
                  return {
                    'bookId': map['bookId']?.toString() ?? '',
                    'title': map['title']?.toString() ?? 'Unknown',
                    'author': map['author']?.toString() ?? 'Unknown',
                    'rating':
                        map['rating'] is num ? map['rating'].toDouble() : 0.0,
                    'reviews':
                        map['reviews'] is num ? map['reviews'] as int : 0,
                    'imageUrl':
                        map['imageUrl']?.toString() ??
                        'assets/images/placeholder.png',
                    'reason': map['reason']?.toString() ?? '',
                    'audioId': map['audioId']?.toString() ?? '',
                    'audioUrl': map['audioUrl']?.toString() ?? '',
                    'fileId': map['fileId']?.toString() ?? '',
                    'price':
                        map['price'] is num ? map['price'].toDouble() : 0.0,
                  };
                }).toList();
              }
            }
          } catch (fallbackError) {
            print('Fallback parsing error: $fallbackError');
          }
          print('JSON parsing error: $e, cleaned text: $cleanedText');
          throw Exception('Invalid JSON format in recommendations: $e');
        }
      } else {
        print('API error response: ${response.body}'); // Log error response
        throw Exception('Failed to fetch recommendations: ${response.body}');
      }
    } catch (e) {
      print('Error in getBookRecommendations: $e'); // Log error
      rethrow; // Propagate to recommendationsProvider
    }
  }

  String _buildPrompt(
    List<Map<String, dynamic>> searchHistory,
    List<Map<String, dynamic>> favorites,
    List<Map<String, dynamic>> reviews,
    List<Map<String, dynamic>> books,
  ) {
    final limitedBooks = books.take(50).toList(); // Limit to 50 books
    final searchQueries = searchHistory
        .map((entry) => entry['query']?.toString() ?? '')
        .join(', ');
    final favoriteBookIds = favorites
        .map((fav) => fav['bookId']?.toString() ?? '')
        .join(', ');
    final reviewSummary = reviews
        .map(
          (r) =>
              'Book ${r['bookId']?.toString() ?? 'unknown'} rated ${r['rating']?.toString() ?? 'N/A'}',
        )
        .join(', ');

    return '''
Based on this user data:
- Searched: $searchQueries
- Favorites: $favoriteBookIds
- Reviews: $reviewSummary

And the following book dataset:
${jsonEncode(limitedBooks)}

Recommend books as a JSON list with structure:
[
  {
    "bookId": "...",
    "title": "...",
    "author": "...",
    "rating": 4.5,
    "reviews": 123,
    "imageUrl": "https://...",
    "reason": "Why this is recommended",
    "audioId": "...",
    "audioUrl": "https://...",
    "fileId": "...",
    "price": 0.0
  },
  ...
]
''';
  }
}
