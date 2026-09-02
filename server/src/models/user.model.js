const mongoose = require('mongoose');

/**
 * Emergency Contact Subdocument Schema
 */
const EmergencyContactSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Contact name is required'],
      trim: true,
    },
    phone: {
      type: String,
      required: [true, 'Contact phone number is required'],
      trim: true,
    },
    relation: {
      type: String,
      enum: ['parent', 'spouse', 'sibling', 'friend', 'relative', 'other'],
      default: 'friend',
      trim: true,
    },
    isPrimary: {
      type: Boolean,
      default: false,
    },
  },
  { _id: true }
);

/**
 * User Schema linked by Firebase UID
 */
const UserSchema = new mongoose.Schema(
  {
    uid: {
      type: String,
      required: [true, 'Firebase UID is required'],
      unique: true,
      index: true,
      trim: true,
    },
    email: {
      type: String,
      lowercase: true,
      trim: true,
      index: true,
    },
    phone: {
      type: String,
      trim: true,
    },
    displayName: {
      type: String,
      required: [true, 'Display name is required'],
      trim: true,
      default: 'Traveler',
    },
    photoUrl: {
      type: String,
      trim: true,
      default: null,
    },
    homeCity: {
      type: String,
      trim: true,
      default: '',
    },
    preferredLanguage: {
      type: String,
      trim: true,
      default: 'en',
    },
    travelerType: {
      type: String,
      enum: ['solo', 'backpacker', 'family', 'woman_traveler', 'luxury', 'group', 'other'],
      default: 'solo',
    },
    emergencyContacts: {
      type: [EmergencyContactSchema],
      default: [],
    },
    isOnboarded: {
      type: Boolean,
      default: false,
    },
    authProvider: {
      type: String,
      enum: ['password', 'google.com', 'phone', 'dev_mock', 'other'],
      default: 'password',
    },
    fcmToken: {
      type: String,
      trim: true,
      default: null,
    },
    travelPreferences: {
      type: [String],
      default: [],
    },
  },
  {
    timestamps: true,
    toJSON: {
      virtuals: true,
      transform: (_doc, ret) => {
        delete ret.__v;
        return ret;
      },
    },
  }
);

// Helpful index for search & personalization
UserSchema.index({ travelerType: 1, homeCity: 1 });

const User = mongoose.model('User', UserSchema);

module.exports = User;
