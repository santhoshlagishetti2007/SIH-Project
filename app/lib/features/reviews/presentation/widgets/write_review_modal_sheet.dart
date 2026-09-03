import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/reviews_controller.dart';

/// Interactive modal sheet to rate (1-5 stars) and write a review
class WriteReviewModalSheet extends ConsumerStatefulWidget {
  final String targetId;
  final String targetType;
  final String targetName;

  const WriteReviewModalSheet({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
  });

  static void show(BuildContext context, {
    required String targetId,
    required String targetType,
    required String targetName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WriteReviewModalSheet(
        targetId: targetId,
        targetType: targetType,
        targetName: targetName,
      ),
    );
  }

  @override
  ConsumerState<WriteReviewModalSheet> createState() => _WriteReviewModalSheetState();
}

class _WriteReviewModalSheetState extends ConsumerState<WriteReviewModalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _photoUrlController = TextEditingController();
  double _selectedRating = 5.0;
  bool _isSubmitting = false;

  final Map<int, String> _ratingLabels = {
    5: '⭐ Outstanding! (5.0)',
    4: '⭐ Very Good (4.0)',
    3: '⭐ Good Experience (3.0)',
    2: '⭐ Needs Improvement (2.0)',
    1: '⭐ Poor Experience (1.0)',
  };

  @override
  void dispose() {
    _textController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final authState = ref.read(authControllerProvider);
    final user = authState is Authenticated ? authState.user : null;
    final userName = user?.displayName ?? 'Traveler';

    final notifier = ref.read(reviewsControllerProvider(widget.targetId).notifier);
    final success = await notifier.submitReview(
      targetType: widget.targetType,
      userName: userName,
      rating: _selectedRating,
      text: _textController.text.trim(),
      photos: _photoUrlController.text.trim().isNotEmpty ? [_photoUrlController.text.trim()] : [],
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF38A169),
            content: Text('🎉 Review submitted successfully! Thank you for sharing.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Rate & Review: ${widget.targetName}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Help fellow travelers with authentic local insights.',
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.grey.shade600),
              ),
              const SizedBox(height: 18),

              // Interactive Star Rating Selector
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1.0;
                        final isFilled = starValue <= _selectedRating;
                        return IconButton(
                          iconSize: 36,
                          icon: Icon(
                            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                            color: Colors.amber,
                          ),
                          onPressed: () => setState(() => _selectedRating = starValue),
                        );
                      }),
                    ),
                    Text(
                      _ratingLabels[_selectedRating.toInt()] ?? 'Rating: $_selectedRating',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Review Feedback Text Input
              TextFormField(
                controller: _textController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Your Experience & Tips *',
                  hintText: 'What did you like? Any dish or spot to recommend? Best time to visit?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please write your review feedback';
                  if (v.trim().length < 5) return 'Review must be at least 5 characters long';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Optional Photo URL
              TextFormField(
                controller: _photoUrlController,
                decoration: InputDecoration(
                  labelText: 'Photo Link (Optional)',
                  prefixIcon: const Icon(Icons.add_photo_alternate_outlined),
                  hintText: 'https://...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                ),
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final url = v.trim().toLowerCase();
                    if (!url.startsWith('http://') && !url.startsWith('https://')) {
                      return 'Must be a valid web link starting with https://';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('SUBMIT REVIEW', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
