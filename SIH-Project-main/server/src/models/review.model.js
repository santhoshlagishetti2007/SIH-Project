const mongoose = require('mongoose');

const ReviewSchema = new mongoose.Schema(
  {
    targetType: {
      type: String,
      enum: ['place', 'eatery', 'group', 'vendor_product', 'other'],
      required: true,
      index: true,
    },
    targetId: {
      type: String,
      required: true,
      index: true,
    },
    userId: {
      type: String,
      required: true,
      index: true,
    },
    userName: {
      type: String,
      default: 'Traveler',
    },
    userAvatar: {
      type: String,
      default: '',
    },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    text: {
      type: String,
      required: true,
      trim: true,
    },
    photos: {
      type: [String],
      default: [],
    },
    reportCount: {
      type: Number,
      default: 0,
    },
    reportedBy: {
      type: [String],
      default: [],
    },
    isHidden: {
      type: Boolean,
      default: false,
      index: true,
    },
    moderationStatus: {
      type: String,
      enum: ['approved', 'pending_review', 'flagged_hidden', 'dismissed'],
      default: 'approved',
    },
  },
  {
    timestamps: true,
    toJSON: {
      virtuals: true,
      transform: (_doc, ret) => {
        ret.id = ret._id.toString();
        delete ret.__v;
        return ret;
      },
    },
  }
);

/**
 * Curated seed reviews for places, eateries, and community groups
 */
const SEED_REVIEWS = [
  // Rawat Mishthan Bhandar (Eatery)
  {
    targetType: 'eatery',
    targetId: 'eat_rawat_kachori',
    userId: 'user_aarav_21',
    userName: 'Aarav Sharma',
    rating: 5,
    text: 'The best Pyaaz Kachori in all of Rajasthan! Crispy outer crust with aromatic spicy onion filling. Must try with cold sweet lassi.',
    photos: ['https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600&auto=format&fit=crop&q=80'],
    reportCount: 0,
    isHidden: false,
  },
  {
    targetType: 'eatery',
    targetId: 'eat_rawat_kachori',
    userId: 'user_sneha_44',
    userName: 'Sneha Patel',
    rating: 4,
    text: 'Extremely crowded around 9 AM breakfast rush, but the kachoris are served boiling hot and fresh. Great tea as well.',
    photos: [],
    reportCount: 0,
    isHidden: false,
  },
  // Laxmi Mishthan Bhandar (LMB)
  {
    targetType: 'eatery',
    targetId: 'eat_lmb_ghevar',
    userId: 'user_rohit_88',
    userName: 'Rohit Kulkarni',
    rating: 5,
    text: 'Their royal Rajasthani thali and malai ghevar are world class. Heritage ambiance right in the heart of Johari Bazaar.',
    photos: ['https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&auto=format&fit=crop&q=80'],
    reportCount: 0,
    isHidden: false,
  },
  // Jaipur Photowalkers (Group)
  {
    targetType: 'group',
    targetId: 'group_1',
    userId: 'user_tanya_99',
    userName: 'Tanya Roy',
    rating: 5,
    text: 'Amazing community! Vikramaditya is very knowledgeable about old Jaipur havelis and guided us to incredible rooftop photo spots.',
    photos: ['https://images.unsplash.com/photo-1609946850428-118f1ef78f0d?w=600&auto=format&fit=crop&q=80'],
    reportCount: 0,
    isHidden: false,
  },
  {
    targetType: 'group',
    targetId: 'group_1',
    userId: 'user_karan_03',
    userName: 'Karan Mehra',
    rating: 5,
    text: 'Completely free and non-commercial. Wonderful group of photographers welcoming beginners with helpful camera tips.',
    photos: [],
    reportCount: 0,
    isHidden: false,
  },
  // Amer Fort (Place)
  {
    targetType: 'place',
    targetId: 'stop_amer_fort',
    userId: 'user_priya_55',
    userName: 'Priya Sundaram',
    rating: 5,
    text: 'Breathtaking architecture! The Sheesh Mahal mirror work reflects candle light magnificently. Go early morning to beat the heat.',
    photos: ['https://images.unsplash.com/photo-1599661046289-e31897846e41?w=600&auto=format&fit=crop&q=80'],
    reportCount: 0,
    isHidden: false,
  },
];

ReviewSchema.statics.getSeedData = function () {
  return SEED_REVIEWS;
};

const Review = mongoose.model('Review', ReviewSchema);

module.exports = Review;
