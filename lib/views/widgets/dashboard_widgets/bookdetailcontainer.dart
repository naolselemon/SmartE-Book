import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/dashboard_pages/bookdetailpage.dart';

class BookDetailContainer extends ConsumerStatefulWidget {
  final String bookId;
  final String imagePath;
  final String title;
  final String author;
  final double rating;
  final int reviews;
  final String summary;
  final String audioId;
  final String audioUrl;
  final String fileId;

  const BookDetailContainer({
    super.key,
    required this.bookId,
    required this.imagePath,
    this.title = '',
    this.author = '',
    this.rating = 0.0,
    this.reviews = 0,
    this.summary = '',
    this.audioId = '',
    this.audioUrl = '',
    this.fileId = '',
  });

  @override
  ConsumerState createState() => _BookDetailContainerState();
}

class _BookDetailContainerState extends ConsumerState<BookDetailContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isAmharic = Localizations.localeOf(context).languageCode == 'am';

    return MouseRegion(
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BookDetailPage(
                    bookId: widget.bookId,
                    title: widget.title,
                    author: widget.author,
                    imagePath: widget.imagePath,
                    rating: widget.rating,
                    reviewCount: widget.reviews,
                    summary: widget.summary,
                    audioId: widget.audioId,
                    audioUrl: widget.audioUrl,
                    pdfId: widget.fileId,
                  ),
            ),
          );
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Card(
                elevation: _isHovered ? 6 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Container(
                  width: 160,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surface,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(5, 5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.black.withOpacity(0.3),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title.isNotEmpty
                                    ? widget.title
                                    : 'Unknown Title',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontFamily:
                                      isAmharic
                                          ? 'NotoSansEthiopic'
                                          : 'poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                semanticsLabel: widget.title,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.author.isNotEmpty
                                    ? widget.author
                                    : 'Unknown Author',
                                style: textTheme.bodySmall?.copyWith(
                                  fontFamily:
                                      isAmharic
                                          ? 'NotoSansEthiopic'
                                          : 'poppins',
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                semanticsLabel: widget.author,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: colorScheme.secondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.rating.toStringAsFixed(1),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${widget.reviews})',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
