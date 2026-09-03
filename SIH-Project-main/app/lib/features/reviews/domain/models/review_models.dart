class RatingBreakdown {
  final int star5;
  final int star4;
  final int star3;
  final int star2;
  final int star1;

  const RatingBreakdown({
    this.star5 = 0,
    this.star4 = 0,
    this.star3 = 0,
    this.star2 = 0,
    this.star1 = 0,
  });

  factory RatingBreakdown.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RatingBreakdown();
    return RatingBreakdown(
      star5: (json['5'] as num?)?.toInt() ?? 0,
      star4: (json['4'] as num?)?.toInt() ?? 0,
      star3: (json['3'] as num?)?.toInt() ?? 0,
      star2: (json['2'] as num?)?.toInt() ?? 0,
      star1: (json['1'] as num?)?.toInt() ?? 0,
    );
  }
}

class ReviewModel {
  final String id;
  final String targetType;
  final String targetId;
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String text;
  final List<String> photos;
  final int reportCount;
  final bool isHidden;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.userId,
    this.userName = 'Traveler',
    this.userAvatar = '',
    required this.rating,
    required this.text,
    this.photos = const [],
    this.reportCount = 0,
    this.isHidden = false,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      targetType: json['targetType'] as String? ?? 'place',
      targetId: json['targetId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Traveler',
      userAvatar: json['userAvatar'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      text: json['text'] as String? ?? '',
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      reportCount: (json['reportCount'] as num?)?.toInt() ?? 0,
      isHidden: json['isHidden'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class ReviewSummary {
  final String targetId;
  final String targetType;
  final double averageRating;
  final int totalReviews;
  final RatingBreakdown ratingBreakdown;
  final List<ReviewModel> reviews;

  const ReviewSummary({
    required this.targetId,
    this.targetType = 'place',
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.ratingBreakdown = const RatingBreakdown(),
    this.reviews = const [],
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    final list = json['reviews'] as List<dynamic>? ?? [];
    return ReviewSummary(
      targetId: json['targetId'] as String? ?? '',
      targetType: json['targetType'] as String? ?? 'place',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      ratingBreakdown: RatingBreakdown.fromJson(json['ratingBreakdown'] as Map<String, dynamic>?),
      reviews: list.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
