const mongoose = require('mongoose');

/**
 * Single Transit Mode Option for a leg
 */
const TransitModeOptionSchema = new mongoose.Schema(
  {
    mode: { type: String, required: true }, // 'walk', 'auto', 'bus', 'metro', 'cab'
    label: { type: String, default: '' },
    icon: { type: String, default: '' },
    cost: { type: Number, default: 0 },
    durationMinutes: { type: Number, default: 15 },
    isAvailable: { type: Boolean, default: true },
    isRecommended: { type: Boolean, default: false },
    description: { type: String, default: '' },
  },
  { _id: false }
);

/**
 * Transit Leg Subdocument Schema connecting two consecutive stops
 */
const TransitLegSchema = new mongoose.Schema(
  {
    fromStopId: { type: String, required: true },
    toStopId: { type: String, required: true },
    fromStopName: { type: String, default: '' },
    toStopName: { type: String, default: '' },
    distanceKm: { type: Number, default: 0 },
    durationMinutes: { type: Number, default: 15 },
    selectedMode: {
      type: String,
      enum: ['walk', 'auto', 'bus', 'metro', 'cab'],
      default: 'auto',
    },
    estimatedCost: { type: Number, default: 0 },
    modes: { type: [TransitModeOptionSchema], default: [] },
  },
  { _id: false }
);

/**
 * Itinerary Stop Subdocument Schema
 */
const ItineraryStopSchema = new mongoose.Schema(
  {
    id: {
      type: String,
      required: true,
      default: () => new mongoose.Types.ObjectId().toString(),
    },
    placeId: {
      type: String,
      default: '',
    },
    name: {
      type: String,
      required: [true, 'Stop name is required'],
      trim: true,
    },
    category: {
      type: String,
      enum: [
        'monument',
        'attraction',
        'food',
        'restaurant',
        'cafe',
        'nature',
        'culture',
        'activity',
        'shopping',
        'hotel',
        'transport',
        'other',
      ],
      default: 'attraction',
    },
    description: {
      type: String,
      default: '',
      trim: true,
    },
    location: {
      lat: { type: Number, default: 0 },
      lng: { type: Number, default: 0 },
      address: { type: String, default: '' },
      city: { type: String, default: '' },
    },
    timeSlot: {
      type: String,
      default: 'Morning',
    },
    startTime: {
      type: String,
      default: '09:00',
    },
    endTime: {
      type: String,
      default: '11:00',
    },
    durationMinutes: {
      type: Number,
      default: 120,
    },
    cost: {
      type: Number,
      default: 0,
      min: 0,
    },
    costCategory: {
      type: String,
      enum: ['activities', 'food', 'stay', 'transport', 'other'],
      default: 'activities',
    },
    rating: {
      type: Number,
      default: 4.5,
      min: 0,
      max: 5,
    },
    userRatingsTotal: {
      type: Number,
      default: 100,
    },
    imageUrl: {
      type: String,
      default: '',
    },
    order: {
      type: Number,
      default: 0,
    },
    notes: {
      type: String,
      default: '',
    },
    isCustom: {
      type: Boolean,
      default: false,
    },
  },
  { _id: false }
);

/**
 * Itinerary Day Subdocument Schema
 */
const ItineraryDaySchema = new mongoose.Schema(
  {
    dayNumber: {
      type: Number,
      required: true,
    },
    date: {
      type: String,
      default: '',
    },
    title: {
      type: String,
      required: true,
      default: function () {
        return `Day ${this.dayNumber}`;
      },
    },
    theme: {
      type: String,
      default: 'Exploration & Sights',
    },
    dayCost: {
      type: Number,
      default: 0,
      min: 0,
    },
    dayTransportCost: {
      type: Number,
      default: 0,
      min: 0,
    },
    stops: {
      type: [ItineraryStopSchema],
      default: [],
    },
    transitLegs: {
      type: [TransitLegSchema],
      default: [],
    },
  },
  { _id: false }
);

/**
 * Cost Breakdown Subdocument Schema
 */
const CostBreakdownSchema = new mongoose.Schema(
  {
    activities: { type: Number, default: 0 },
    food: { type: Number, default: 0 },
    stay: { type: Number, default: 0 },
    transport: { type: Number, default: 0 },
    other: { type: Number, default: 0 },
    total: { type: Number, default: 0 },
  },
  { _id: false }
);

/**
 * Main Trip Schema
 */
const TripSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: [true, 'User ID is required'],
      index: true,
      trim: true,
    },
    title: {
      type: String,
      required: [true, 'Trip title is required'],
      trim: true,
    },
    destination: {
      type: String,
      required: [true, 'Destination is required'],
      trim: true,
    },
    startDate: {
      type: Date,
      default: Date.now,
    },
    endDate: {
      type: Date,
      default: () => new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
    },
    travelerType: {
      type: String,
      enum: ['solo', 'backpacker', 'family', 'woman_traveler', 'luxury', 'group', 'other'],
      default: 'solo',
    },
    budget: {
      type: Number,
      default: 15000,
      min: 0,
    },
    estimatedTotalCost: {
      type: Number,
      default: 0,
      min: 0,
    },
    currency: {
      type: String,
      default: 'INR',
    },
    companions: {
      type: [String],
      default: [],
    },
    status: {
      type: String,
      enum: ['draft', 'planned', 'ongoing', 'completed'],
      default: 'planned',
    },
    itinerary: {
      type: [ItineraryDaySchema],
      default: [],
    },
    costBreakdown: {
      type: CostBreakdownSchema,
      default: () => ({ activities: 0, food: 0, stay: 0, transport: 0, other: 0, total: 0 }),
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
 * Helper to calculate all costs for a trip's itinerary, including transit leg costs
 */
TripSchema.methods.recalculateTotalCosts = function () {
  const breakdown = {
    activities: 0,
    food: 0,
    stay: 0,
    transport: 0,
    other: 0,
    total: 0,
  };

  let totalTripCost = 0;

  if (Array.isArray(this.itinerary)) {
    this.itinerary.forEach((day) => {
      let daySum = 0;
      let dayTransportSum = 0;

      // 1. Sum up all stops
      if (Array.isArray(day.stops)) {
        day.stops.forEach((stop, index) => {
          stop.order = index;
          const stopCost = Number(stop.cost) || 0;
          daySum += stopCost;

          const categoryKey = stop.costCategory || 'activities';
          if (breakdown[categoryKey] !== undefined) {
            breakdown[categoryKey] += stopCost;
          } else {
            breakdown.other += stopCost;
          }
        });
      }

      // 2. Sum up transit leg costs
      if (Array.isArray(day.transitLegs)) {
        day.transitLegs.forEach((leg) => {
          const legCost = Number(leg.estimatedCost) || 0;
          daySum += legCost;
          dayTransportSum += legCost;
          breakdown.transport += legCost;
        });
      }

      day.dayTransportCost = dayTransportSum;
      day.dayCost = daySum;
      totalTripCost += daySum;
    });
  }

  breakdown.total = totalTripCost;
  this.costBreakdown = breakdown;
  this.estimatedTotalCost = totalTripCost;
  return totalTripCost;
};

/**
 * Pre-save middleware to automatically recalculate costs whenever the trip or itinerary is modified
 */
TripSchema.pre('save', function (next) {
  if (this.isModified('itinerary') || this.isNew) {
    this.recalculateTotalCosts();
  }
  next();
});

TripSchema.index({ userId: 1, createdAt: -1 });

const Trip = mongoose.model('Trip', TripSchema);

module.exports = Trip;
