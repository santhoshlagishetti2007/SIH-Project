const mongoose = require('mongoose');

/**
 * Women's Safety Destination Guide Schema
 */
const WomensSafetyGuideSchema = new mongoose.Schema(
  {
    city: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },
    safeAreas: {
      type: [String],
      default: [],
    },
    cautionAreas: {
      type: [String],
      default: [],
    },
    transportAdvice: {
      general: { type: String, default: '' },
      nightTransit: { type: String, default: '' },
      recommendedApps: { type: [String], default: ['Uber', 'Ola', 'Namma Yatri'] },
      verifiedCabs: { type: String, default: '' },
    },
    emergencyNumbers: {
      nationalHelpline: { type: String, default: '112' },
      womenHelpline: { type: String, default: '1091' },
      womenHelplineAlt: { type: String, default: '181' },
      policeHelpline: { type: String, default: '100' },
      ambulance: { type: String, default: '108' },
      touristHelpline: { type: String, default: '1363' },
    },
    localTips: {
      type: [String],
      default: [],
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
 * Curated destination safety guide seed catalog
 */
const SEED_SAFETY_GUIDES = [
  {
    city: 'Jaipur',
    safeAreas: [
      'C-Scheme (Well-lit cafes, restaurants, residential security)',
      'Malviya Nagar & Gaurav Tower Area (High footfall, modern shopping)',
      'Bani Park (Hotels hub, tourist police presence)',
      'Mansarovar Main Boulevard',
      'Tonk Road Commercial Belt',
    ],
    cautionAreas: [
      'Isolated outskirts of Nahargarh Fort Road after 8:30 PM',
      'Unlit interior bylanes of Purani Basti late at night',
      'Underpass stretches near Ajmer Road bypass after 10 PM',
    ],
    transportAdvice: {
      general: 'Jaipur Metro operates till 10:00 PM with dedicated female security. App-based cabs (Uber/Ola) are active 24/7 across city centers.',
      nightTransit: 'Avoid hailing unmetered roadside auto-rickshaws alone after 10 PM in secluded sectors. Use app cabs with live location sharing.',
      recommendedApps: ['Uber', 'Ola', 'Jaipur Metro App'],
      verifiedCabs: 'Pink City Cabs & Pre-paid booths at Jaipur Junction Railway Station and Airport.',
    },
    emergencyNumbers: {
      nationalHelpline: '112',
      womenHelpline: '1091',
      womenHelplineAlt: '181',
      policeHelpline: '100',
      ambulance: '108',
      touristHelpline: '1363',
    },
    localTips: [
      'Jaipur Tourist Police are stationed at major heritage sites (Hawa Mahal, Amber Fort, City Palace).',
      'Keep Sanchari live location sharing enabled when traveling across desert forts.',
      'Use the Fake Call simulator if negotiating with aggressive shop touts in crowded bazaars.',
      'Rajasthan State Transport Corporation operates pink reserved seating in city buses.',
    ],
  },
  {
    city: 'Delhi',
    safeAreas: [
      'Connaught Place Inner & Middle Circles (heavy police patrols)',
      'Hauz Khas Village & Enclave (active dining zone)',
      'Chanakyapuri & Diplomatic Enclave (high security)',
      'Saket District Centre & Malls',
      'Khan Market Area',
    ],
    cautionAreas: [
      'Secluded stretches of Yamuna Khadar and isolated ridge roads after 9 PM',
      'Dark underpasses near Kashmere Gate late at night',
      'Empty industrial zones in outer border areas',
    ],
    transportAdvice: {
      general: 'Delhi Metro has a dedicated first coach exclusively for women on every train, monitored by CISF armed security.',
      nightTransit: 'Always use app-based cabs or GPS-enabled Meru/BluSmart electric cabs. Verify driver details before onboarding.',
      recommendedApps: ['BluSmart', 'Uber', 'Ola', 'Delhi Metro Sarathi'],
      verifiedCabs: 'BluSmart EV cabs (100% verified drivers, 0 driver cancellations).',
    },
    emergencyNumbers: {
      nationalHelpline: '112',
      womenHelpline: '1091',
      womenHelplineAlt: '181',
      policeHelpline: '100',
      ambulance: '108',
      touristHelpline: '1363',
    },
    localTips: [
      'Delhi Metro stations feature emergency panic buttons on every platform.',
      'Himmat Plus app is integrated with Delhi Police Emergency Command.',
      'Always enter the Pink Women Coach (first coach toward train movement).',
    ],
  },
  {
    city: 'Goa',
    safeAreas: [
      'Panaji Fontainhas Latin Quarter & Waterfront Promenade',
      'Candolim & Calangute Main Coastal Belt (active tourists)',
      'Anjuna Beach Road Market Sector',
      'Colva Beach Commercial Hub',
    ],
    cautionAreas: [
      'Secluded cliffs of Cabo de Rama and dark jungle paths after sunset',
      'Deserted unlit stretches between Chapora and Morjim late night',
    ],
    transportAdvice: {
      general: 'GoaMiles app is the government-regulated cab booking service. Self-drive rental scooters require valid helmets and digital license.',
      nightTransit: 'Avoid hitchhiking or riding pillion with strangers along coastal roads.',
      recommendedApps: ['GoaMiles', 'Uber (Airport Only)'],
      verifiedCabs: 'GoaMiles Certified Tourist Drivers with GPS tracking.',
    },
    emergencyNumbers: {
      nationalHelpline: '112',
      womenHelpline: '1091',
      womenHelplineAlt: '181',
      policeHelpline: '100',
      ambulance: '108',
      touristHelpline: '1363',
    },
    localTips: [
      'Goa Pink Force police patrol coastal beaches until midnight.',
      'Lifeguards (Drishti Marine) are active across tourist beaches from 7 AM to 6 PM.',
    ],
  },
];

WomensSafetyGuideSchema.statics.getSeedData = function () {
  return SEED_SAFETY_GUIDES;
};

const WomensSafetyGuide = mongoose.model('WomensSafetyGuide', WomensSafetyGuideSchema);

module.exports = WomensSafetyGuide;
