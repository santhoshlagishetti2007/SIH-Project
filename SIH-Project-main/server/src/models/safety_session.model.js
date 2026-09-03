const mongoose = require('mongoose');

/**
 * Safety & Live Location Sharing Session Schema
 */
const SafetySessionSchema = new mongoose.Schema(
  {
    sessionId: {
      type: String,
      required: true,
      unique: true,
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
      trim: true,
    },
    userPhone: {
      type: String,
      default: '',
    },
    sessionType: {
      type: String,
      enum: ['trip_share', 'sos_alert'],
      default: 'trip_share',
      index: true,
    },
    isActive: {
      type: Boolean,
      default: true,
      index: true,
    },
    currentLocation: {
      lat: { type: Number, required: true, default: 26.9124 },
      lng: { type: Number, required: true, default: 75.7873 },
      accuracy: { type: Number, default: 10 },
      speed: { type: Number, default: 0 },
      battery: { type: Number, default: 85 },
      address: { type: String, default: 'Jaipur, Rajasthan' },
    },
    locationHistory: [
      {
        lat: { type: Number, required: true },
        lng: { type: Number, required: true },
        speed: { type: Number, default: 0 },
        timestamp: { type: Date, default: Date.now },
      },
    ],
    emergencyContacts: [
      {
        name: { type: String, default: '' },
        phone: { type: String, default: '' },
        relation: { type: String, default: 'Emergency Contact' },
      },
    ],
    sosTriggeredAt: {
      type: Date,
      default: null,
    },
    lastPingAt: {
      type: Date,
      default: Date.now,
    },
    expiresAt: {
      type: Date,
      default: () => new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 hours TTL
      index: { expires: 0 },
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

const SafetySession = mongoose.model('SafetySession', SafetySessionSchema);

module.exports = SafetySession;
