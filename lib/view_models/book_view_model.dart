// import 'package:appwrite/models.dart' as appwrite;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:smart_ebook/models/book.dart';
// import 'package:smart_ebook/models/review.dart';
// import 'package:smart_ebook/controllers/book_services.dart';
// import 'package:smart_ebook/controllers/user_services.dart';

// import 'package:smart_ebook/views/providers/books_provider.dart';

// class BookState {
//   final Map<String, List<Book>> booksByCategory;
//   final List<Book> favorites;
//   final bool isLoading;
//   final String? errorMessage;

//   BookState({
//     Map<String, List<Book>>? booksByCategory,
//     this.favorites = const [],
//     this.isLoading = false,
//     this.errorMessage,
//   }) : booksByCategory = booksByCategory ?? {};

//   BookState copyWith({
//     Map<String, List<Book>>? booksByCategory,
//     List<Book>? favorites,
//     bool? isLoading,
//     String? errorMessage,
//   }) {
//     return BookState(
//       booksByCategory: booksByCategory ?? this.booksByCategory,
//       favorites: favorites ?? this.favorites,
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }
// }

// class BookViewModel extends StateNotifier<BookState> {
//   final BookServices _bookServices;
//   final String userId;

//   BookViewModel(this._bookServices, this.userId)
//     : super(BookState(isLoading: false));

//   Future<void> fetchBooks(String category) async {
//     state = state.copyWith(isLoading: true, errorMessage: null);
//     try {
//       List<Book> books = [];
//       if (category == 'top_rated') {
//         books = await _bookServices.getTopRatedBooks();
//       } else {
//         List<String>? queries;
//         if (category == 'new') {
//           queries = ['ORDER_DESC(createdAt)', 'LIMIT(10)'];
//         } else if (category == 'free') {
//           queries = ['EQUAL(price,0.0)', 'LIMIT(10)'];
//         } else if (category == 'trending') {
//           queries = ['ORDER_DESC(createdAt)', 'LIMIT(10)'];
//         }
//         final documentList = await _bookServices.getBooks(
//           'books',
//           queries: queries,
//         );
//         books =
//             documentList.documents
//                 .map((doc) => Book.fromDocument(doc.data))
//                 .toList();
//       }
//       final updatedBooks = Map<String, List<Book>>.from(state.booksByCategory)
//         ..[category] = books;
//       state = state.copyWith(booksByCategory: updatedBooks, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         errorMessage: 'Failed to fetch $category books: $e',
//       );
//     }
//   }

//   Future<void> fetchFavorites() async {
//     state = state.copyWith(isLoading: true, errorMessage: null);
//     try {
//       final documentList = await _bookServices.getFavorites(userId);
//       final bookIds =
//           documentList.documents
//               .map((doc) => doc.data['bookId'] as String)
//               .toList();
//       List<Book> favorites = [];
//       if (bookIds.isNotEmpty) {
//         final books = await _bookServices.getBooks(
//           'books',
//           queries: ['EQUAL(\$id,[$bookIds])'],
//         );
//         favorites =
//             books.documents.map((doc) => Book.fromDocument(doc.data)).toList();
//       }
//       state = state.copyWith(favorites: favorites, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(
//         favorites: [],
//         isLoading: false,
//         errorMessage: 'Failed to fetch favorites: $e',
//       );
//     }
//   }

//   Future<Map<String, dynamic>> fetchBookRatingAndReviewCount(
//     String bookId,
//   ) async {
//     try {
//       return await _bookServices.getBookRatingAndReviewCount(bookId);
//     } catch (e) {
//       return {'rating': 0.0, 'reviewCount': 0};
//     }
//   }

//   Future<List<Review>> fetchReviews(String bookId) async {
//     try {
//       final documentList = await _bookServices.getReviews(bookId);
//       return documentList.documents
//           .map((doc) => Review.fromDocument(doc.data))
//           .toList();
//     } catch (e) {
//       return [];
//     }
//   }

//   Future<bool> isFavorite(String bookId) async {
//     try {
//       final favorites = await _bookServices.getFavorites(userId);
//       return favorites.documents.any((doc) => doc.data['bookId'] == bookId);
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<String?> getFavoriteId(String bookId) async {
//     try {
//       final favorites = await _bookServices.getFavorites(userId);
//       final favorite = favorites.documents.firstWhere(
//         (doc) => doc.data['bookId'] == bookId,
//         orElse:
//             () => appwrite.Document(
//               $id: '',
//               $collectionId: '',
//               $databaseId: '',
//               $createdAt: '',
//               $updatedAt: '',
//               $permissions: [],
//               data: {},
//             ),
//       );
//       return favorite.$id.isNotEmpty ? favorite.$id : null;
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<void> toggleFavorite(
//     String bookId,
//     bool isFavorite,
//     String? favoriteId,
//   ) async {
//     try {
//       if (isFavorite && favoriteId != null) {
//         await _bookServices.removeFavorite(favoriteId);
//       } else {
//         await _bookServices.addFavorite(userId, bookId);
//       }
//       await fetchFavorites(); // Refresh favorites
//     } catch (e) {
//       state = state.copyWith(errorMessage: 'Failed to update favorite: $e');
//     }
//   }

//   Future<void> submitReview(
//     String bookId,
//     double rating,
//     String comment,
//   ) async {
//     try {
//       await _bookServices.addReview(userId, bookId, rating, comment);
//     } catch (e) {
//       state = state.copyWith(errorMessage: 'Failed to submit review: $e');
//     }
//   }
// }

// final bookViewModelProvider =
//     StateNotifierProvider.family<BookViewModel, BookState, String>(
//       (ref, userId) => BookViewModel(ref.watch(bookServicesProvider), userId),
//     );

// final userIdProvider = FutureProvider<String>((ref) async {
//   final user = await UserServices().getCurrentUser();
//   return user?.id ?? '';
// });
