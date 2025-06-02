import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_ebook/views/providers/books_provider.dart';
import 'package:smart_ebook/views/providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReviewsTab extends ConsumerStatefulWidget {
  final String bookId;

  const ReviewsTab({super.key, required this.bookId});

  @override
  ConsumerState createState() => _ReviewsTabState();
}

class _ReviewsTabState extends ConsumerState<ReviewsTab> {
  double _rating = 0.0;
  String _comment = '';

  void _submitReview() async {
    final localizations = AppLocalizations.of(context)!;
    final profileState = ref.read(profileProvider);
    if (profileState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in to add a review")), //
      );
      return;
    }
    if (_rating == 0.0 || _comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and comment')),
      );
      return;
    }
    final userId = profileState.user!.id;
    final bookServices = ref.read(bookServicesProvider);
    try {
      await bookServices.addReview(userId, widget.bookId, _rating, _comment);
      setState(() {
        _rating = 0.0;
        _comment = '';
      });
      ref.invalidate(reviewsProvider(widget.bookId));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Review added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add review: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(reviewsProvider(widget.bookId));
    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return Column(
            children: [
              const Expanded(child: Center(child: Text("No reviews yet."))),
              _buildReviewForm(),
            ],
          );
        }
        return FutureBuilder<Map<String, Map<String, String>>>(
          future: ref
              .read(bookServicesProvider)
              .getUserProfiles(
                reviews.map((review) => review.userId).toSet().toList(),
              ),
          builder: (context, snapshot) {
            final userProfiles = snapshot.data ?? {};
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      final userProfile =
                          userProfiles[review.userId] ??
                          {'name': 'Unknown User', 'profileImageUrl': ''};
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 15,
                          backgroundImage:
                              userProfile['profileImageUrl']!.isNotEmpty
                                  ? NetworkImage(
                                    userProfile['profileImageUrl']!,
                                  )
                                  : null,
                          child:
                              userProfile['profileImageUrl']!.isEmpty
                                  ? const Icon(Icons.person, size: 15)
                                  : null,
                        ),
                        title: Text(
                          userProfile['name']!,
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          review.comment,
                          style: GoogleFonts.lato(fontStyle: FontStyle.italic),
                        ),
                        trailing: Text("${review.rating} ★"),
                      );
                    },
                  ),
                ),
                _buildReviewForm(),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildReviewForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "Add a Review",
            style: GoogleFonts.lato(fontSize: 20, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 3),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemBuilder:
                (context, _) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: "Comment"),
            onChanged: (value) {
              setState(() {
                _comment = value;
              });
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _submitReview, child: const Text("Submit")),
        ],
      ),
    );
  }
}
