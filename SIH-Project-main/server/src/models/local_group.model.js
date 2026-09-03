const mongoose = require('mongoose');

const LocalGroupSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },
    city: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    description: {
      type: String,
      required: true,
      trim: true,
    },
    category: {
      type: String,
      enum: ['heritage_walk', 'photography', 'food_trails', 'hiking_nature', 'art_craft', 'volunteering', 'other'],
      default: 'heritage_walk',
      index: true,
    },
    leadName: {
      type: String,
      required: true,
      trim: true,
    },
    leadContact: {
      phone: { type: String, default: '+919876543210' },
      email: { type: String, default: 'organizer@sanchari.local' },
      whatsapp: { type: String, default: '+919876543210' },
    },
    membersCount: {
      type: Number,
      default: 24,
      min: 1,
    },
    maxMembers: {
      type: Number,
      default: 100,
    },
    meetingPoint: {
      type: String,
      default: 'City Main Square',
    },
    schedule: {
      type: String,
      default: 'Every Saturday 7:30 AM',
    },
    coverPhoto: {
      type: String,
      default: 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800&auto=format&fit=crop&q=80',
    },
    tags: {
      type: [String],
      default: [],
    },
    verificationStatus: {
      type: String,
      enum: ['pending', 'verified', 'rejected'],
      default: 'pending',
      index: true,
    },
    verificationDetails: {
      documentType: { type: String, default: 'Govt ID & Charter Pledge' },
      documentId: { type: String, default: 'DOC-SANCHARI-VERIFIED' },
      reviewerNotes: { type: String, default: 'Verified community organizer identity and non-commercial charter.' },
      verifiedAt: { type: Date, default: Date.now },
      verifiedBy: { type: String, default: 'admin_security_team' },
    },
    joinRequests: [
      {
        userId: { type: String, required: true },
        userName: { type: String, required: true },
        userPhone: { type: String, default: '' },
        message: { type: String, default: 'Hi! I would love to join your upcoming community walk.' },
        requestedAt: { type: Date, default: Date.now },
        status: { type: String, enum: ['pending', 'accepted', 'declined'], default: 'pending' },
      },
    ],
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
 * Curated seed catalog of verified non-commercial community groups
 */
const SEED_LOCAL_GROUPS = [
  {
    name: 'Jaipur Heritage & Haveli Photowalkers',
    city: 'Jaipur',
    description: 'A weekend community of photography enthusiasts and heritage lovers exploring hidden royal havelis, street portraiture in old bazaars, and sunrise shots at Nahargarh.',
    category: 'photography',
    leadName: 'Vikramaditya Rathore',
    leadContact: {
      phone: '+919829011442',
      email: 'vikram.photo@jaipurwalks.org',
      whatsapp: '+919829011442',
    },
    membersCount: 168,
    maxMembers: 250,
    meetingPoint: 'Hawa Mahal Front Plaza, Badi Chaupar',
    schedule: 'Every Saturday at 6:45 AM (Sunrise Walk)',
    coverPhoto: 'https://images.unsplash.com/photo-1609946850428-118f1ef78f0d?w=800&auto=format&fit=crop&q=80',
    tags: ['Architecture', 'Sunrise', 'Heritage', 'Street Photography', 'Non-Commercial'],
    verificationStatus: 'verified',
    verificationDetails: {
      documentType: 'Aadhaar & Rajasthan Photo Society Charter',
      documentId: 'RAJ-PH-2024-8891',
      reviewerNotes: 'Verified 4-year active community track record and free community photowalks.',
      verifiedAt: new Date('2026-01-10'),
      verifiedBy: 'admin_curator_1',
    },
  },
  {
    name: 'Pink City Food & Kachori Explorers',
    city: 'Jaipur',
    description: 'Non-commercial foodie collective dedicated to mapping 100-year-old traditional sweet shops, hing kachoris, rabdi ghevar stalls, and evening masala chai hubs.',
    category: 'food_trails',
    leadName: 'Meenakshi Joshi',
    leadContact: {
      phone: '+919829055881',
      email: 'meenakshi@foodiesjaipur.in',
      whatsapp: '+919829055881',
    },
    membersCount: 215,
    maxMembers: 300,
    meetingPoint: 'Rawat Mishthan Bhandar, Station Road',
    schedule: 'Bi-weekly Sunday 8:30 AM',
    coverPhoto: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
    tags: ['Street Food', 'Kachori', 'Heritage Chai', 'Vegetarian', 'Zero Commission'],
    verificationStatus: 'verified',
    verificationDetails: {
      documentType: 'Passport & Culinary Guild ID',
      documentId: 'CUL-IND-77312',
      reviewerNotes: 'Verified community food trail organizer with transparent dutch-pay meals.',
      verifiedAt: new Date('2026-02-15'),
      verifiedBy: 'admin_curator_1',
    },
  },
  {
    name: 'Delhi Shahjahanabad Heritage Guild',
    city: 'Delhi',
    description: 'Community historians and passionate walkers discovering the medieval gates, sufi shrines, Urdu poetry corners, and forgotten dharamsalas of Old Delhi.',
    category: 'heritage_walk',
    leadName: 'Faizan Qureshi',
    leadContact: {
      phone: '+919811099221',
      email: 'faizan@delhiheritageguild.org',
      whatsapp: '+919811099221',
    },
    membersCount: 310,
    maxMembers: 400,
    meetingPoint: 'Jama Masjid Gate No. 3 (Opposite Urdu Bazaar)',
    schedule: 'Every Sunday 7:00 AM',
    coverPhoto: 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=800&auto=format&fit=crop&q=80',
    tags: ['Mughal History', 'Sufi Shrines', 'Urdu Poetry', 'Architecture Walk'],
    verificationStatus: 'verified',
    verificationDetails: {
      documentType: 'Govt Heritage Fellow Credential',
      documentId: 'DEL-HER-99014',
      reviewerNotes: 'Verified non-profit community walk organizer with academic citations.',
      verifiedAt: new Date('2026-01-20'),
      verifiedBy: 'admin_curator_1',
    },
  },
  {
    name: 'Goa Coastal Mangrove & Kayak Volunteers',
    city: 'Goa',
    description: 'Volunteer conservationists hosting morning backwater paddling, bird watching trails along Chapora river, and beach cleanup community drives.',
    category: 'hiking_nature',
    leadName: 'Natasha D’Souza',
    leadContact: {
      phone: '+919822019944',
      email: 'natasha@goanaturetrails.org',
      whatsapp: '+919822019944',
    },
    membersCount: 145,
    maxMembers: 200,
    meetingPoint: 'Nerul Backwaters Jetty, North Goa',
    schedule: 'Saturday & Wednesday 6:30 AM',
    coverPhoto: 'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800&auto=format&fit=crop&q=80',
    tags: ['Eco Trails', 'Kayaking', 'Birding', 'Beach Cleanup', 'Community Conservation'],
    verificationStatus: 'verified',
    verificationDetails: {
      documentType: 'Goa Eco-Tourism Guild Card',
      documentId: 'GOA-ECO-44120',
      reviewerNotes: 'Verified environmental NGO volunteer lead.',
      verifiedAt: new Date('2026-02-01'),
      verifiedBy: 'admin_curator_1',
    },
  },
  {
    name: 'Udaipur Lakeside Sketchers & Artists',
    city: 'Udaipur',
    description: 'Open community for watercolorists, urban sketchers, and art enthusiasts meeting by Lake Pichola to capture the royal ghats and reflection ripples.',
    category: 'art_craft',
    leadName: 'Ritu Chittora',
    leadContact: {
      phone: '+919829044332',
      email: 'ritu@udaipursketch.org',
      whatsapp: '+919829044332',
    },
    membersCount: 92,
    maxMembers: 150,
    meetingPoint: 'Ambrai Ghat (Hanuman Ghat), Udaipur',
    schedule: 'Every Sunday 5:00 PM (Sunset Sketch)',
    coverPhoto: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=800&auto=format&fit=crop&q=80',
    tags: ['Urban Sketching', 'Pichola Lake', 'Watercolor', 'Art Walk', 'Free Group'],
    verificationStatus: 'verified',
    verificationDetails: {
      documentType: 'Artist Association ID & Passport',
      documentId: 'UDP-ART-33219',
      reviewerNotes: 'Verified open artistic community organizer.',
      verifiedAt: new Date('2026-02-18'),
      verifiedBy: 'admin_curator_1',
    },
  },
];

LocalGroupSchema.statics.getSeedData = function () {
  return SEED_LOCAL_GROUPS;
};

const LocalGroup = mongoose.model('LocalGroup', LocalGroupSchema);

module.exports = LocalGroup;
