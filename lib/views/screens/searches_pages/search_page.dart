// import "package:flutter/material.dart";


// import "package:smart_ebook/views/widgets/searches_widgets/authors_images.dart";
// import "package:smart_ebook/views/widgets/searches_widgets/book_coverpage.dart";
// import "package:smart_ebook/views/widgets/searches_widgets/categories_card.dart";


// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => LandingPageScreensState();
// }

// class LandingPageScreensState extends State<SearchScreen> {
//   final _searchController = TextEditingController();
//   List<Book> filteredBooks = [];

//   @override
//   void initState() {
//     _searchController.addListener(_filteredBooks);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_filteredBooks);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _filteredCategory(String category) {
//     setState(() {
//       filteredBooks = books.where((book) => book.category == category).toList();
//     });
//   }

//   //searching books
//   void _filteredBooks() {
//     String query = _searchController.text.toLowerCase();
//     setState(() {
//       if (query.isEmpty) {
//         filteredBooks.clear();
//         return;
//       }
//       filteredBooks =
//           books.where((book) {
//             return book.title.toLowerCase().contains(query) ||
//                 book.author.toLowerCase().contains(query) ||
//                 book.category.toLowerCase().contains(query);
//           }).toList();
//     });
//   }

//   //fetching most sold books
//   List<Book> getTrendingBooks(List<Book> books) {
//     List<Book> sortedBooks = List.from(books);
//     sortedBooks.sort((a, b) => b.sold.compareTo(a.sold));
//     return sortedBooks.take(5).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
//         child: SafeArea(
//           child: Stack(
//             children: [
//               SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       icon: Icon(Icons.arrow_back_ios_new),
//                     ),
//                     const SizedBox(height: 10),
//                     SearchBar(
//                       controller: _searchController,
//                       hintText: 'Search books...',
//                       leading: Icon(Icons.search),
//                       shape: WidgetStateProperty.all(
//                         RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(7),
//                         ),
//                       ),
//                       backgroundColor: WidgetStateProperty.all(
//                         Theme.of(context).colorScheme.inversePrimary,
//                       ),
//                       surfaceTintColor: WidgetStateProperty.all(
//                         Colors.transparent,
//                       ),
//                       elevation: WidgetStateProperty.all(0),
//                     ),

//                     const SizedBox(height: 10),

//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Categories",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Wrap(
//                           spacing: 10,
//                           runSpacing: 10,
//                           children:
//                               books.map((book) {
//                                 return CategoriesCard(
//                                   text: book.category,
//                                   onCategoryClicked:
//                                       (category) => _filteredCategory(category),
//                                 );
//                               }).toList(),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),

//                     const Text(
//                       "Famous Authors",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Wrap(
//                         spacing: 5,
//                         runSpacing: 5,
//                         children:
//                             books.map((book) {
//                               return AuthorsImages(
//                                 image: book.authorImage,
//                                 name: book.author,
//                               );
//                             }).toList(),
//                       ),
//                     ),

//                     const SizedBox(height: 10),
//                     const Text(
//                       "Trending Books",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                       ),
//                     ),
//                     const SizedBox(height: 5),

//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children:
//                             getTrendingBooks(books).map((book) {
//                               return BookCoverpage(image: book.coverImage);
//                             }).toList(),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (_searchController.text.isNotEmpty ||
//                   filteredBooks.isNotEmpty) ...[
//                 Positioned(
//                   top: 120,
//                   right: 0,
//                   left: 0,
//                   bottom: 0,
//                   child: Material(
//                     elevation: 10,
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       padding: EdgeInsets.only(top: 16),
//                       color: Theme.of(context).colorScheme.surfaceBright,
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: filteredBooks.length,
//                         itemBuilder: (context, index) {
//                           Book book = filteredBooks[index];
//                           return Container(
//                             margin: EdgeInsets.symmetric(
//                               vertical: 5,
//                             ), // space between tiles
//                             decoration: BoxDecoration(
//                               color:
//                                   Theme.of(context).colorScheme.primaryFixedDim,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: ListTile(
//                               contentPadding: EdgeInsets.symmetric(
//                                 vertical: 10,
//                                 horizontal: 16,
//                               ), // padding inside the tile
//                               leading: ClipRRect(
//                                 borderRadius: BorderRadius.circular(
//                                   8,
//                                 ), // rounded image
//                                 child: Image.asset(
//                                   book.coverImage,
//                                   width: 50,
//                                   height: 50,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                               title: Text(
//                                 book.title,
//                                 style: TextStyle(
//                                   color:
//                                       Theme.of(
//                                         context,
//                                       ).colorScheme.onPrimaryContainer,
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 book.category,
//                                 style: TextStyle(
//                                   color:
//                                       Theme.of(
//                                         context,
//                                       ).colorScheme.onPrimaryContainer,
//                                 ),
//                               ),
//                               trailing: Text(
//                                 book.author,
//                                 style: TextStyle(
//                                   color:
//                                       Theme.of(
//                                         context,
//                                       ).colorScheme.onPrimaryContainer,
//                                 ),
//                               ),
//                               onTap: () {},
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
