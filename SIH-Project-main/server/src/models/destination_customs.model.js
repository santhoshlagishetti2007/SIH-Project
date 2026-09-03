const mongoose = require('mongoose');

const DestinationCustomsSchema = new mongoose.Schema(
  {
    destination: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },
    region: {
      type: String,
      default: 'India',
    },
    dressCode: {
      general: { type: String, default: 'Comfortable, modest casuals. Breathable cottons in summer.' },
      religiousSites: { type: String, default: 'Cover shoulders and knees. Remove footwear before entering sanctums.' },
      nightlife: { type: String, default: 'Smart casuals in upscale lounges and dining clubs.' },
    },
    templeEtiquette: {
      type: [String],
      default: [],
    },
    tippingNorms: {
      restaurants: { type: String, default: '7% - 10% for good service (check if service charge is already added).' },
      autosCabs: { type: String, default: 'Round up the fare or ₹20 - ₹50 for luggage assistance.' },
      guidesDrivers: { type: String, default: '₹300 - ₹600 per day for tour guides; ₹200 - ₹400 for cab drivers.' },
      hotelStaff: { type: String, default: '₹50 - ₹100 for bellhops and housekeeping.' },
    },
    commonScams: [
      {
        name: { type: String, required: true },
        warning: { type: String, required: true },
        preventionTip: { type: String, required: true },
      },
    ],
    dos: {
      type: [String],
      default: [],
    },
    donts: {
      type: [String],
      default: [],
    },
    localCustoms: {
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
 * Curated destination customs seed catalog
 */
const SEED_DESTINATION_CUSTOMS = [
  {
    destination: 'Jaipur',
    region: 'Rajasthan',
    dressCode: {
      general: 'Modest lightweight cottons. Sun hat and sunglasses recommended for exploring open fort courtyards.',
      religiousSites: 'Cover head (dupatta/scarf), remove shoes and leather belts at Govind Dev Ji & Birla Mandir.',
      nightlife: 'Smart casuals at rooftop cafes and C-Scheme lounges.',
    },
    templeEtiquette: [
      'Remove footwear at designated shoe stands before entering temple premises.',
      'Do not photograph deity idols or sanctum sanctorum without explicit permission.',
      'Accept prasad (blessed offering) with your right hand.',
      'Walk around temple shrines in a clockwise direction (Pradakshina).',
    ],
    tippingNorms: {
      restaurants: '7% - 10% if service charge is not included in the bill.',
      autosCabs: 'Round up the meter or app fare by ₹20 - ₹50.',
      guidesDrivers: '₹400 - ₹600 per full-day heritage tour guide; ₹300 for personal drivers.',
      hotelStaff: '₹50 - ₹100 per luggage bag for bellhops.',
    },
    commonScams: [
      {
        name: 'The "Cheap Gemstone / Blue Pottery Export" Scam',
        warning: 'Friendly strangers in Johari Bazaar offering to mail gems back home to evade duty or make quick profit.',
        preventionTip: 'Never purchase gemstones or carpets on behalf of strangers. Only buy certified gemstones from Rajasthan Govt Emporiums (Rajasthali).',
      },
      {
        name: 'Unlicensed Tourist Fort Guides',
        warning: 'Touts outside Amber Fort offering "special shortcut entries" or quoting inflated prices.',
        preventionTip: 'Hire only Rajasthan Tourism Department certified guides with blue ID badges from the official ticket counter.',
      },
      {
        name: 'Unmetered Auto "Commission Stops"',
        warning: 'Auto drivers offering cheap rides in exchange for visiting "government-run" silk or handicraft shops.',
        preventionTip: 'Politely decline unscheduled stops and insist on app-based navigation (Uber/Ola/Google Maps).',
      },
    ],
    dos: [
      'Greet locals with "Namaste" or "Khamma Ghani" (traditional Rajasthani greeting) with folded hands.',
      'Bargain politely in Bapu Bazaar and Johari Bazaar (starting around 30% - 40% below initial ask).',
      'Try authentic Pyaaz Kachori and Dal Baati Churma using clean right hand.',
      'Carry cash (₹100/₹200 notes) for small street vendors and rickshaws.',
    ],
    donts: [
      'Don’t point the soles of your shoes or feet toward people, elders, or sacred shrines.',
      'Don’t engage with persistent snake charmers or peacock feather sellers at fort gates without agreeing on price first.',
      'Don’t drink unboiled tap water — opt for sealed mineral water or RO filtered water.',
    ],
    localCustoms: [
      'Markets in the walled Old City observe a brief afternoon lull between 2 PM and 4 PM.',
      'Govind Dev Ji temple has 7 Aarti timings daily; 5 AM Mangala Aarti is highly revered.',
    ],
  },
  {
    destination: 'Delhi',
    region: 'National Capital Region',
    dressCode: {
      general: 'Modern casuals. Comfortable walking shoes for large monument complexes.',
      religiousSites: 'Full head covering at Gurudwara Bangla Sahib and Jama Masjid (scarves/robes available at entry).',
      nightlife: 'Chic / dressy at Connaught Place and Aerocity lounges.',
    },
    templeEtiquette: [
      'Wash hands and feet at water basins before entering Gurudwaras (Bangla Sahib / Sis Ganj).',
      'Cover your head with a cloth or handkerchief at all times inside Sikh shrines.',
      'Dress conservatively when visiting Old Delhi mosques and monuments.',
    ],
    tippingNorms: {
      restaurants: '10% in sit-down restaurants (check if 10% service charge is already applied).',
      autosCabs: 'Round up the fare; ₹30 - ₹50 for polite cab drivers.',
      guidesDrivers: '₹500 - ₹800 per day for certified city tour guides.',
      hotelStaff: '₹100 for luggage assistance.',
    },
    commonScams: [
      {
        name: 'The "Train Station / Monument Closed" Scam',
        warning: 'Touts around New Delhi Railway Station claiming your train is cancelled or the tourist office has moved to Connaught Place.',
        preventionTip: 'Ignore touts completely. Proceed straight to official IRCTC / Northern Railway counters or your booked platform.',
      },
      {
        name: 'Broken Taxi Meter Scam',
        warning: 'Airport cab drivers claiming the digital meter is faulty and demanding fixed inflated cash fares.',
        preventionTip: 'Book through official Prepaid Taxi Booths inside airport terminal or use BluSmart/Uber/Ola.',
      },
    ],
    dos: [
      'Take the Delhi Metro — clean, air-conditioned, with female-only first coach on every train.',
      'Experience the communal kitchen (Langar) at Gurudwara Bangla Sahib.',
      'Keep your bags zipped in crowded markets like Chandni Chowk and Sarojini Nagar.',
    ],
    donts: [
      'Don’t purchase Metro tokens from strangers outside stations.',
      'Don’t wander into isolated dark alleys of outer ring road sectors after 10 PM.',
    ],
    localCustoms: [
      'Most monuments and museums in Delhi are closed on Mondays (e.g. Red Fort, National Museum).',
    ],
  },
  {
    destination: 'Goa',
    region: 'Konkan Coast',
    dressCode: {
      general: 'Beachwear and shorts are fine on beaches and coastal shacks.',
      religiousSites: 'Strict modesty at Old Goa churches (Basilica of Bom Jesus) and Mangueshi Temple — no swimwear, cover shoulders and knees.',
      nightlife: 'Casual chic for beach clubs and night markets.',
    },
    templeEtiquette: [
      'Maintain quiet reverence inside historic Portuguese churches.',
      'Remove footwear before entering temple courtyards in Ponda.',
    ],
    tippingNorms: {
      restaurants: '10% at beach shacks and coastal dining spots.',
      autosCabs: 'Round up or ₹50 for drivers.',
      guidesDrivers: '₹300 - ₹500 for full-day coastal drivers.',
      hotelStaff: '₹50 - ₹100 for service staff.',
    },
    commonScams: [
      {
        name: 'Overpriced Rental Scooter Damage Scam',
        warning: 'Rental operators blaming existing scratches on you upon return.',
        preventionTip: 'Always take a 360-degree video and high-res photos of the scooter and odometer before driving away.',
      },
    ],
    dos: [
      'Wear helmets when riding rental two-wheelers (strictly enforced with digital fines).',
      'Carry valid driving license and digital copies of scooter RC.',
    ],
    donts: [
      'Don’t swim past red safety flags or during monsoon high-tide warnings.',
      'Don’t wear beachwear inside ancient churches or villages.',
    ],
    localCustoms: [
      'The "Susegad" tradition — relaxed, peaceful pace of life, with quiet hours in villages between 1 PM and 4 PM.',
    ],
  },
];

DestinationCustomsSchema.statics.getSeedData = function () {
  return SEED_DESTINATION_CUSTOMS;
};

const DestinationCustoms = mongoose.model('DestinationCustoms', DestinationCustomsSchema);

module.exports = DestinationCustoms;
