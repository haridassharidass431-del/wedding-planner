import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/luxury_button.dart';
import '../../../core/widgets/rating_badge.dart';
import '../../../data/models/review.dart';
import '../../../data/models/vendor.dart';
import '../../../data/repositories/mock_wedding_repository.dart';

class ReviewsScreen extends StatefulWidget {
  final Vendor? vendor;

  const ReviewsScreen({super.key, this.vendor});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final MockWeddingRepository _repository = MockWeddingRepository();
  int _selectedFilterIndex = 0; // 0: All, 1: 5 Stars, 2: 4 Stars, 3: Verified

  void _openWriteReviewSheet() {
    double selectedRating = 5.0;
    final nameController = TextEditingController(text: 'Ananya & Vignesh');
    final commentController = TextEditingController();
    final serviceController = TextEditingController(text: widget.vendor?.category ?? 'Wedding Service');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Write a Royal Review',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryPlum,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Rate your experience:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        iconSize: 36,
                        icon: Icon(
                          star <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppColors.royalGold,
                        ),
                        onPressed: () {
                          setSheetState(() => selectedRating = star.toDouble());
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Names / Couple Name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: serviceController,
                    decoration: const InputDecoration(
                      labelText: 'Service Utilized',
                      prefixIcon: Icon(Icons.celebration_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Share your wedding experience & feedback...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LuxuryButton(
                    text: 'Submit Verified Review',
                    isGold: true,
                    onPressed: () {
                      if (commentController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your review comments')),
                        );
                        return;
                      }

                      final newReview = Review(
                        id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
                        vendorId: widget.vendor?.id ?? 'v1',
                        userName: nameController.text.trim(),
                        userAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                        rating: selectedRating,
                        date: 'Just now',
                        comment: commentController.text.trim(),
                        serviceUsed: serviceController.text.trim(),
                        weddingDate: 'September 2026',
                        helpfulCount: 0,
                        isVerifiedCustomer: true,
                      );

                      _repository.addReview(newReview);
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thank you! Your verified review has been published.'),
                          backgroundColor: AppColors.primaryPlum,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repository,
      builder: (context, _) {
        final allReviews = widget.vendor != null
            ? _repository.getReviewsForVendor(widget.vendor!.id)
            : _repository.reviews;

        final filteredReviews = allReviews.where((r) {
          if (_selectedFilterIndex == 1) return r.rating >= 5.0;
          if (_selectedFilterIndex == 2) return r.rating >= 4.0 && r.rating < 5.0;
          if (_selectedFilterIndex == 3) return r.isVerifiedCustomer;
          return true;
        }).toList();

        final avgRating = widget.vendor?.rating ?? 4.9;
        final totalCount = allReviews.length;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.vendor != null ? '${widget.vendor!.name} Reviews' : 'Client Reviews'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primaryPlum,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.rate_review_rounded, color: AppColors.royalGold),
            label: const Text('Write Review', style: TextStyle(fontWeight: FontWeight.w700)),
            onPressed: _openWriteReviewSheet,
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
            children: [
              // Rating Overview Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.goldBorder.withValues(alpha: 0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Big numeric score
                    Column(
                      children: [
                        Text(
                          avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryPlum,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(5, (i) {
                            return const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.ratingStar,
                            );
                          }),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$totalCount Ratings',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),

                    // Distribution bars
                    Expanded(
                      child: Column(
                        children: [
                          _ratingBar('5', 0.88),
                          _ratingBar('4', 0.09),
                          _ratingBar('3', 0.02),
                          _ratingBar('2', 0.01),
                          _ratingBar('1', 0.00),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Filter Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(0, 'All ($totalCount)'),
                    const SizedBox(width: 8),
                    _filterChip(1, '5 Stars'),
                    const SizedBox(width: 8),
                    _filterChip(2, '4 Stars'),
                    const SizedBox(width: 8),
                    _filterChip(3, 'Verified Couples'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Review items
              if (filteredReviews.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(Icons.rate_review_outlined, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text(
                        'No reviews in this filter yet.',
                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              else
                ...filteredReviews.map((review) => _reviewCard(review)),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(int index, String label) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedFilterIndex = index);
      },
      selectedColor: AppColors.primaryPlum,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryPlum : AppColors.borderLight,
      ),
    );
  }

  Widget _ratingBar(String stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            stars,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, size: 12, color: AppColors.ratingStar),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.warmCream,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.royalGold),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review.userAvatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.userName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (review.isVerifiedCustomer) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                        ],
                      ],
                    ),
                    Text(
                      '${review.serviceUsed} • ${review.weddingDate}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              RatingBadge(rating: review.rating, isCompact: true),
            ],
          ),
          const SizedBox(height: 12),

          // Comment
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Footer with date & helpful button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.date,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              Row(
                children: [
                  const Icon(Icons.thumb_up_outlined, size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Helpful (${review.helpfulCount})',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
