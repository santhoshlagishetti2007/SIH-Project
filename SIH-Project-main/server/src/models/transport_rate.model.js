const mongoose = require('mongoose');

/**
 * Single Transport Mode Rate Configuration
 */
const ModeRateSchema = new mongoose.Schema(
  {
    baseFare: { type: Number, required: true, default: 0 },
    perKmRate: { type: Number, required: true, default: 0 },
    minFare: { type: Number, default: 0 },
    speedKmh: { type: Number, required: true, default: 20 },
    isAvailable: { type: Boolean, default: true },
    notes: { type: String, default: '' },
  },
  { _id: false }
);

/**
 * City Transport Rate Configuration Schema
 */
const TransportRateConfigSchema = new mongoose.Schema(
  {
    city: {
      type: String,
      required: [true, 'City name is required'],
      unique: true,
      trim: true,
      index: true,
    },
    currency: {
      type: String,
      default: 'INR',
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    modes: {
      walking: {
        type: ModeRateSchema,
        default: () => ({ baseFare: 0, perKmRate: 0, minFare: 0, speedKmh: 4.5, isAvailable: true }),
      },
      auto: {
        type: ModeRateSchema,
        default: () => ({ baseFare: 30, perKmRate: 15.0, minFare: 30, speedKmh: 22, isAvailable: true }),
      },
      bus: {
        type: ModeRateSchema,
        default: () => ({ baseFare: 10, perKmRate: 3.5, minFare: 10, speedKmh: 18, isAvailable: true }),
      },
      metro: {
        type: ModeRateSchema,
        default: () => ({ baseFare: 15, perKmRate: 4.0, minFare: 15, speedKmh: 32, isAvailable: false }),
      },
      cab: {
        type: ModeRateSchema,
        default: () => ({ baseFare: 60, perKmRate: 20.0, minFare: 60, speedKmh: 25, isAvailable: true }),
      },
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
 * Default Seed Rates for Major Destinations in India
 */
const DEFAULT_CITY_RATES = [
  {
    city: 'Jaipur',
    currency: 'INR',
    modes: {
      walking: { baseFare: 0, perKmRate: 0, minFare: 0, speedKmh: 4.5, isAvailable: true },
      auto: { baseFare: 30, perKmRate: 14.0, minFare: 30, speedKmh: 22, isAvailable: true, notes: 'Prepaid auto booths at Railway Station & Sindhi Camp' },
      bus: { baseFare: 10, perKmRate: 3.0, minFare: 10, speedKmh: 18, isAvailable: true, notes: 'JCTSL city low floor AC & Non-AC buses' },
      metro: { baseFare: 12, perKmRate: 3.5, minFare: 12, speedKmh: 34, isAvailable: true, notes: 'Jaipur Pink Line (Mansarovar - Badi Choupad)' },
      cab: { baseFare: 60, perKmRate: 18.0, minFare: 60, speedKmh: 26, isAvailable: true },
    },
  },
  {
    city: 'Delhi',
    currency: 'INR',
    modes: {
      walking: { baseFare: 0, perKmRate: 0, minFare: 0, speedKmh: 4.5, isAvailable: true },
      auto: { baseFare: 30, perKmRate: 11.5, minFare: 30, speedKmh: 24, isAvailable: true, notes: 'Metered auto rates per Delhi Govt norms' },
      bus: { baseFare: 5, perKmRate: 2.5, minFare: 5, speedKmh: 16, isAvailable: true, notes: 'DTC electric and CNG low floor fleet' },
      metro: { baseFare: 10, perKmRate: 3.0, minFare: 10, speedKmh: 38, isAvailable: true, notes: 'Delhi Metro Rail network (DMRC)' },
      cab: { baseFare: 50, perKmRate: 16.0, minFare: 50, speedKmh: 25, isAvailable: true },
    },
  },
  {
    city: 'Mumbai',
    currency: 'INR',
    modes: {
      walking: { baseFare: 0, perKmRate: 0, minFare: 0, speedKmh: 4.5, isAvailable: true },
      auto: { baseFare: 23, perKmRate: 15.3, minFare: 23, speedKmh: 20, isAvailable: true, notes: 'Strictly metered across Mumbai suburbs' },
      bus: { baseFare: 6, perKmRate: 2.5, minFare: 6, speedKmh: 15, isAvailable: true, notes: 'BEST AC and Non-AC city buses' },
      metro: { baseFare: 10, perKmRate: 3.5, minFare: 10, speedKmh: 35, isAvailable: true, notes: 'Mumbai Metro Lines 1, 2A, 7' },
      cab: { baseFare: 28, perKmRate: 18.5, minFare: 28, speedKmh: 22, isAvailable: true, notes: 'Kaali Peeli and ride-hail cabs' },
    },
  },
  {
    city: 'Goa',
    currency: 'INR',
    modes: {
      walking: { baseFare: 0, perKmRate: 0, minFare: 0, speedKmh: 4.5, isAvailable: true },
      auto: { baseFare: 50, perKmRate: 22.0, minFare: 50, speedKmh: 25, isAvailable: true, notes: 'Local auto rickshaws & motorcycle pilots' },
      bus: { baseFare: 15, perKmRate: 3.0, minFare: 15, speedKmh: 22, isAvailable: true, notes: 'Kadamba Transport Corporation (KTCL)' },
      metro: { baseFare: 0, perKmRate: 0, minFare: 0, speedKmh: 0, isAvailable: false, notes: 'No metro system in Goa' },
      cab: { baseFare: 120, perKmRate: 28.0, minFare: 120, speedKmh: 30, isAvailable: true, notes: 'GoaMiles and tourist taxi network' },
    },
  },
  {
    city: 'Bengaluru',
    currency: 'INR',
    modes: {
      walking: { baseFare: 0, perKmRate: 0, minFare: 0, speedKmh: 4.5, isAvailable: true },
      auto: { baseFare: 30, perKmRate: 15.0, minFare: 30, speedKmh: 20, isAvailable: true, notes: 'Bengaluru metered auto fares' },
      bus: { baseFare: 8, perKmRate: 3.0, minFare: 8, speedKmh: 15, isAvailable: true, notes: 'BMTC Vajra AC & Non-AC services' },
      metro: { baseFare: 10, perKmRate: 3.5, minFare: 10, speedKmh: 36, isAvailable: true, notes: 'Namma Metro Purple & Green lines' },
      cab: { baseFare: 75, perKmRate: 20.0, minFare: 75, speedKmh: 22, isAvailable: true },
    },
  },
  {
    city: 'Default',
    currency: 'INR',
    modes: {
      walking: { baseFare: 0, perKmRate: 0, minFare: 0, speedKmh: 4.5, isAvailable: true },
      auto: { baseFare: 30, perKmRate: 15.0, minFare: 30, speedKmh: 22, isAvailable: true },
      bus: { baseFare: 10, perKmRate: 3.5, minFare: 10, speedKmh: 18, isAvailable: true },
      metro: { baseFare: 15, perKmRate: 4.0, minFare: 15, speedKmh: 32, isAvailable: false },
      cab: { baseFare: 60, perKmRate: 20.0, minFare: 60, speedKmh: 25, isAvailable: true },
    },
  },
];

TransportRateConfigSchema.statics.getDefaultCityRates = function () {
  return DEFAULT_CITY_RATES;
};

const TransportRateConfig = mongoose.model('TransportRateConfig', TransportRateConfigSchema);

module.exports = {
  TransportRateConfig,
  DEFAULT_CITY_RATES,
};
