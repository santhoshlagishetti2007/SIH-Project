/**
 * End-to-End Database Seeder for Sanchari Hackathon Demo
 * Seeds a rich, realistic Jaipur showcase across all collections:
 * - 3-Day Complete AI Itinerary with Multi-Modal Transit Legs & Budget Breakdown
 * - "Know Before You Go" Destination Etiquette & Scam Warnings
 * - Authentic Regional Eateries with 24-Hour Cache Preload
 * - Local Finds Artisan Marketplace Items
 * - Verified Community Group
 * - Universal Cross-Feature Reviews
 */
const mongoose = require('mongoose');
const envConfig = require('../config/env.config');
const Trip = require('../models/trip.model');
const { DestinationCustoms } = require('../models/destination_customs.model');
const LocalFind = require('../models/local_find.model');
const { LocalGroup } = require('../models/local_group.model');
const { Review } = require('../models/review.model');
const { TransportRateConfig, DEFAULT_CITY_RATES } = require('../models/transport_rate.model');

async function seedDemoData() {
  console.log('====================================================');
  console.log('🚀 SEEDING SANCHARI HACKATHON DEMO DATA (JAIPUR)...');
  console.log('====================================================');

  let isConnected = false;
  try {
    const mongoUri = envConfig.mongodb?.uri || process.env.MONGODB_URI;
    if (mongoUri) {
      await mongoose.connect(mongoUri, { serverSelectionTimeoutMS: 3000 });
      isConnected = true;
      console.log('✅ Connected to MongoDB.');
    }
  } catch (err) {
    console.warn(`⚠️ MongoDB connection unavailable (${err.message}). Seeding in-memory and preparing offline payloads.`);
  }

  // 1. Seed Destination Customs & Cultural Etiquette for Jaipur
  const jaipurCustoms = {
    destination: 'Jaipur',
    region: 'Rajasthan',
    dressCode: {
      general: 'Breathable cotton attire with comfortable walking shoes for fort climbs and cobblestone paths.',
      religiousSites: 'Modest wear covering shoulders and knees at Birla Mandir & Govind Dev Ji Temple. Head scarves recommended.',
      nightlife: 'Smart casuals / ethnic fusion for rooftop dining and lounge bars in C-Scheme and Malviya Nagar.',
    },
    templeEtiquette: [
      'Remove footwear and leather belts/wallets outside temple sanctums.',
      'Accept Prasad and holy water using your right hand only.',
      'Always circumambulate the inner deity sanctum in a clockwise direction.',
      'Photography inside temple inner sanctums is strictly prohibited.',
    ],
    tippingNorms: {
      restaurants: '7% - 10% in sit-down dining spots (check if service charge is already included).',
      autosCabs: 'Round up fare to the nearest ₹20 or ₹50 for courteous driving and luggage handling.',
      guidesDrivers: '₹500 - ₹800 per day for certified Rajasthan Tourism guides; ₹300 - ₹500 for full-day drivers.',
      hotelStaff: '₹50 - ₹100 per bag for bellhops; ₹100 - ₹200 per day for housekeeping.',
    },
    commonScams: [
      {
        name: 'The Gemstone Export / Duty-Free Parcel Scam',
        warning: 'Friendly gem dealers or auto drivers offering to let you carry emeralds/rubies abroad for quick commission.',
        preventionTip: 'Never buy gems with promised overseas buy-back schemes. Buy only certified gems with hallmark receipts.',
      },
      {
        name: 'The "Secret Palace Gate / Road Closed" Auto Reroute',
        warning: 'Touts or auto drivers claiming City Palace is closed for a VIP function to divert you to expensive emporiums.',
        preventionTip: 'Check official ticket counters directly or verify timings on the Sanchari live itinerary.',
      },
      {
        name: 'Inflated Elephant Ride / Jeep Overcharging at Amer Fort',
        warning: 'Unauthorized middlemen quoting ₹3,000+ for standard government-regulated uphill fort jeeps (standard ₹500).',
        preventionTip: 'Book directly at the Rajasthan Tourism Development Corporation (RTDC) official booth.',
      },
    ],
    localTraditions: [
      'Greeting locals with "Khamma Ghani" (Traditional Rajasthani greeting meaning "Greetings of peace and respect").',
      'Observing the traditional sunset Aarti at Jal Mahal promenade.',
      'Bargaining politely with a smile at Johari and Bapu Bazaars (aim for 60-70% of initial quoted price).',
    ],
  };

  // 2. Seed Complete 3-Day Jaipur AI Itinerary with Multi-Modal Transit Legs
  const jaipurTrip = {
    userId: 'demo_traveler_001',
    title: 'Royal Heritage & Flavors of Jaipur',
    destination: 'Jaipur, Rajasthan',
    startDate: new Date(),
    endDate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
    travelerType: 'solo',
    budget: 18000,
    estimatedTotalCost: 9650,
    costBreakdown: {
      activities: 2600,
      food: 2850,
      stay: 3500,
      transport: 700,
      other: 0,
      total: 9650,
    },
    itinerary: [
      {
        dayNumber: 1,
        title: 'Day 1: Forts, Panoramas & Sunsets',
        theme: 'Hilltop Fortresses & Stepwells',
        dayCost: 2850,
        dayTransportCost: 280,
        transitLegs: [
          {
            fromStopId: 'stop_d1_1',
            toStopId: 'stop_d1_2',
            fromStopName: 'Amber Palace (Amer Fort)',
            toStopName: 'Panna Meena Ka Kund Stepwell',
            distanceKm: 1.2,
            durationMinutes: 6,
            selectedMode: 'walk',
            estimatedCost: 0,
          },
          {
            fromStopId: 'stop_d1_2',
            toStopId: 'stop_d1_3',
            fromStopName: 'Panna Meena Ka Kund Stepwell',
            toStopName: 'Jaigarh Fort (World’s Largest Cannon)',
            distanceKm: 4.8,
            durationMinutes: 14,
            selectedMode: 'auto',
            estimatedCost: 110,
          },
          {
            fromStopId: 'stop_d1_3',
            toStopId: 'stop_d1_4',
            fromStopName: 'Jaigarh Fort',
            toStopName: 'Sunset at Nahargarh Fort & Padao Cafe',
            distanceKm: 6.2,
            durationMinutes: 18,
            selectedMode: 'auto',
            estimatedCost: 170,
          },
        ],
        stops: [
          {
            id: 'stop_d1_1',
            name: 'Amber Palace (Amer Fort)',
            category: 'heritage',
            costCategory: 'activities',
            description: 'Magnificent 16th-century hilltop palace featuring the Sheesh Mahal (Mirror Palace) and Maota Lake views.',
            location: { lat: 26.9855, lng: 75.8513, address: 'Devisinghpura, Amer, Jaipur', city: 'Jaipur' },
            timeSlot: 'Morning',
            startTime: '08:30 AM',
            endTime: '11:30 AM',
            durationMinutes: 180,
            cost: 500,
            rating: 4.8,
            userRatingsTotal: 34200,
            imageUrl: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=600&q=80',
            order: 0,
            notes: 'Wear comfortable walking shoes. Audio guides available in English and Hindi at entrance.',
          },
          {
            id: 'stop_d1_2',
            name: 'Panna Meena Ka Kund Stepwell',
            category: 'heritage',
            costCategory: 'activities',
            description: '8-story symmetrical stairwell built in the 16th century with iconic criss-cross geometrical steps.',
            location: { lat: 26.9858, lng: 75.8569, address: 'Near Anokhi Museum, Amer, Jaipur', city: 'Jaipur' },
            timeSlot: 'Midday',
            startTime: '11:45 AM',
            endTime: '12:45 PM',
            durationMinutes: 60,
            cost: 50,
            rating: 4.7,
            userRatingsTotal: 4890,
            imageUrl: 'https://images.unsplash.com/photo-1609137144813-7d9921338f24?auto=format&fit=crop&w=600&q=80',
            order: 1,
            notes: 'Great photography lighting between 11 AM and 1 PM.',
          },
          {
            id: 'stop_d1_3',
            name: 'Royal Heritage Lunch at 1135 AD',
            category: 'food',
            costCategory: 'food',
            description: 'Opulent fine-dining inside Amber Fort with gold-leaf walls and authentic Rajasthani Laal Maas & Gatte.',
            location: { lat: 26.9852, lng: 75.8510, address: 'Level 2, Jaleb Chowk, Amer Fort, Jaipur', city: 'Jaipur' },
            timeSlot: 'Afternoon',
            startTime: '01:00 PM',
            endTime: '02:30 PM',
            durationMinutes: 90,
            cost: 1200,
            rating: 4.6,
            userRatingsTotal: 1820,
            imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?auto=format&fit=crop&w=600&q=80',
            order: 2,
            notes: 'Advance booking recommended during peak season.',
          },
          {
            id: 'stop_d1_4',
            name: 'Sunset at Nahargarh Fort & Padao Open Air Cafe',
            category: 'panoramic',
            costCategory: 'activities',
            description: 'Spectacular 360-degree hilltop sunset panorama overlooking the entire pink illuminated cityscape.',
            location: { lat: 26.9373, lng: 75.8155, address: 'Krishna Nagar, Brahampuri, Jaipur', city: 'Jaipur' },
            timeSlot: 'Evening',
            startTime: '04:30 PM',
            endTime: '07:00 PM',
            durationMinutes: 150,
            cost: 200,
            rating: 4.8,
            userRatingsTotal: 29800,
            imageUrl: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=600&q=80',
            order: 3,
            notes: 'Best sunset spot in Jaipur. Auto drivers charge fixed waiting rates for the return journey.',
          },
        ],
      },
      {
        dayNumber: 2,
        title: 'Day 2: The Walled Pink City, Palaces & Bazaars',
        theme: 'Royal Heritage & Traditional Street Food',
        dayCost: 2650,
        dayTransportCost: 220,
        transitLegs: [
          {
            fromStopId: 'stop_d2_1',
            toStopId: 'stop_d2_2',
            fromStopName: 'Rawat Mishthan Bhandar',
            toStopName: 'Hawa Mahal (Palace of Winds)',
            distanceKm: 3.4,
            durationMinutes: 12,
            selectedMode: 'metro',
            estimatedCost: 20,
          },
          {
            fromStopId: 'stop_d2_2',
            toStopId: 'stop_d2_3',
            fromStopName: 'Hawa Mahal',
            toStopName: 'City Palace & Jantar Mantar',
            distanceKm: 0.6,
            durationMinutes: 7,
            selectedMode: 'walk',
            estimatedCost: 0,
          },
          {
            fromStopId: 'stop_d2_3',
            toStopId: 'stop_d2_4',
            fromStopName: 'City Palace',
            toStopName: 'Johari & Bapu Bazaars Craft Trail',
            distanceKm: 1.1,
            durationMinutes: 10,
            selectedMode: 'walk',
            estimatedCost: 0,
          },
        ],
        stops: [
          {
            id: 'stop_d2_1',
            name: 'Pyaaz Kachori Breakfast at Rawat Mishthan Bhandar',
            category: 'food',
            costCategory: 'food',
            description: 'World-famous crispy golden onion kachoris, sweet mawa kachoris, and authentic saffron lassi.',
            location: { lat: 26.9208, lng: 75.7978, address: 'Station Road, Sindhi Camp, Jaipur', city: 'Jaipur' },
            timeSlot: 'Morning',
            startTime: '08:00 AM',
            endTime: '09:00 AM',
            durationMinutes: 60,
            cost: 250,
            rating: 4.8,
            userRatingsTotal: 18400,
            imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=600&q=80',
            order: 0,
            notes: 'High morning rush; fast takeaway counter available.',
          },
          {
            id: 'stop_d2_2',
            name: 'Hawa Mahal (Palace of Winds)',
            category: 'heritage',
            costCategory: 'activities',
            description: 'Iconic 5-story pink sandstone honeycomb facade with 953 intricately carved jharokhas (windows).',
            location: { lat: 26.9239, lng: 75.8267, address: 'Hawa Mahal Rd, Badi Choupad, Jaipur', city: 'Jaipur' },
            timeSlot: 'Morning',
            startTime: '09:30 AM',
            endTime: '11:00 AM',
            durationMinutes: 90,
            cost: 200,
            rating: 4.7,
            userRatingsTotal: 41200,
            imageUrl: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=600&q=80',
            order: 1,
            notes: 'Visit Wind View Cafe directly across the street for iconic front-facing photos.',
          },
          {
            id: 'stop_d2_3',
            name: 'City Palace & Jantar Mantar Astronomical Observatory',
            category: 'heritage',
            costCategory: 'activities',
            description: 'Living royal palace blending Rajput, Mughal, and European architecture with UNESCO stone sundial observatory.',
            location: { lat: 26.9258, lng: 75.8237, address: 'Gangori Bazaar, J.D.A. Market, Jaipur', city: 'Jaipur' },
            timeSlot: 'Midday',
            startTime: '11:15 AM',
            endTime: '02:00 PM',
            durationMinutes: 165,
            cost: 700,
            rating: 4.8,
            userRatingsTotal: 38700,
            imageUrl: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=600&q=80',
            order: 2,
            notes: 'Composite ticket covers museum and courtyard entry.',
          },
          {
            id: 'stop_d2_4',
            name: 'Johari & Bapu Bazaars Craft Shopping Trail',
            category: 'shopping',
            costCategory: 'activities',
            description: 'Historic vibrant markets famous for hand-blocked textiles, Jaipuri quilts, authentic lac bangles, and silver jewelry.',
            location: { lat: 26.9216, lng: 75.8265, address: 'Johari Bazar, Pink City, Jaipur', city: 'Jaipur' },
            timeSlot: 'Evening',
            startTime: '04:00 PM',
            endTime: '07:30 PM',
            durationMinutes: 210,
            cost: 300,
            rating: 4.6,
            userRatingsTotal: 15600,
            imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?auto=format&fit=crop&w=600&q=80',
            order: 3,
            notes: 'Cash and UPI accepted universally. Always ask for artisan certificates on high-value textiles.',
          },
        ],
      },
      {
        dayNumber: 3,
        title: 'Day 3: Artisan Guilds & Cultural Village Feast',
        theme: 'Blue Pottery Workshops & Rajasthani Folk Heritage',
        dayCost: 4150,
        dayTransportCost: 200,
        transitLegs: [
          {
            fromStopId: 'stop_d3_1',
            toStopId: 'stop_d3_2',
            fromStopName: 'Albert Hall State Central Museum',
            toStopName: 'Sanganer Blue Pottery Artisan Guild',
            distanceKm: 12.5,
            durationMinutes: 28,
            selectedMode: 'cab',
            estimatedCost: 350,
          },
          {
            fromStopId: 'stop_d3_2',
            toStopId: 'stop_d3_3',
            fromStopName: 'Sanganer Blue Pottery',
            toStopName: 'Chokhi Dhani Ethnic Cultural Village',
            distanceKm: 9.4,
            durationMinutes: 22,
            selectedMode: 'auto',
            estimatedCost: 200,
          },
        ],
        stops: [
          {
            id: 'stop_d3_1',
            name: 'Albert Hall Museum (Indo-Saracenic Masterpiece)',
            category: 'culture',
            costCategory: 'activities',
            description: 'Oldest museum of Rajasthan featuring Egyptian mummy, Persian carpets, and royal miniature paintings.',
            location: { lat: 26.9116, lng: 75.8195, address: 'Ram Niwas Garden, Kailash Puri, Jaipur', city: 'Jaipur' },
            timeSlot: 'Morning',
            startTime: '09:00 AM',
            endTime: '11:00 AM',
            durationMinutes: 120,
            cost: 150,
            rating: 4.7,
            userRatingsTotal: 22400,
            imageUrl: 'https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=600&q=80',
            order: 0,
            notes: 'Spectacular flock of pigeons outside front facade — great photo op.',
          },
          {
            id: 'stop_d3_2',
            name: 'Sanganer Blue Pottery Master Artisan Workshop',
            category: 'craft',
            costCategory: 'activities',
            description: 'Hands-on pottery workshop with GI-tagged traditional turquoise quartz glazed blue pottery masters.',
            location: { lat: 26.8183, lng: 75.7725, address: 'Sanganer Artisan Hub, Jaipur', city: 'Jaipur' },
            timeSlot: 'Midday',
            startTime: '11:45 AM',
            endTime: '02:30 PM',
            durationMinutes: 165,
            cost: 800,
            rating: 4.9,
            userRatingsTotal: 3100,
            imageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80',
            order: 1,
            notes: 'Direct from artisan source — supports local master craftspersons.',
          },
          {
            id: 'stop_d3_3',
            name: 'Chokhi Dhani Ethnic Cultural Village & Royal Feast',
            category: 'cultural_feast',
            costCategory: 'stay',
            description: 'Immersive Rajasthani cultural evening with Kalbelia dancers, puppet shows, camel rides, and unlimited royal thali.',
            location: { lat: 26.7648, lng: 75.8368, address: '12 Miles, Tonk Road, Jaipur', city: 'Jaipur' },
            timeSlot: 'Evening',
            startTime: '05:30 PM',
            endTime: '10:00 PM',
            durationMinutes: 270,
            cost: 1400,
            rating: 4.6,
            userRatingsTotal: 46200,
            imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?auto=format&fit=crop&w=600&q=80',
            order: 2,
            notes: 'Entry ticket includes full unlimited dining banquet and all cultural performances.',
          },
        ],
      },
    ],
  };

  // 3. Seed Local Finds Artisan Marketplace Items
  const localFinds = [
    {
      id: 'find_jaipur_saree_1',
      name: 'Hand-Block Printed Sanganeri Dabu Cotton Saree',
      description: 'Pure 100% natural indigo mud-resist Dabu block-printed mulmul cotton saree crafted by 4th-generation artisan family.',
      category: 'craft',
      price: 2400,
      originalPrice: 3200,
      vendorName: 'Kripal Kumbh & Dabu Guild',
      vendorContact: '+919829012345',
      vendorLocation: 'Sanganer, Jaipur',
      city: 'Jaipur',
      photos: ['https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=600&q=80'],
      rating: 4.9,
      reviewCount: 42,
      isVerifiedVendor: true,
      tags: ['handloom', 'sanganeri', 'indigo', 'organic', 'women-made'],
    },
    {
      id: 'find_jaipur_puppet_2',
      name: 'Handcrafted Royal Kathputli Puppet Pair (Raja-Rani)',
      description: 'Traditional mango wood and vibrant bandhani silk puppets with hand-painted facial features and hanging brass bells.',
      category: 'toy',
      price: 850,
      originalPrice: 1200,
      vendorName: 'Bhat Puppet Community Guild',
      vendorContact: '+919829054321',
      vendorLocation: 'Kathputli Colony, Jaipur',
      city: 'Jaipur',
      photos: ['https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=600&q=80'],
      rating: 4.8,
      reviewCount: 38,
      isVerifiedVendor: true,
      tags: ['folk', 'kathputli', 'wooden', 'traditional', 'decor'],
    },
    {
      id: 'find_jaipur_lac_3',
      name: 'Authentic Traditional Jaipuri Lac Bangles (Set of 4)',
      description: 'Hand-melted natural resin lacquer bangles embedded with faceted glass stones and mirror chips from historic Maniharon Ka Rasta.',
      category: 'gift',
      price: 450,
      originalPrice: 600,
      vendorName: 'Manihar Traditional Lac Artisans',
      vendorContact: '+919829098765',
      vendorLocation: 'Tripolia Bazar, Jaipur',
      city: 'Jaipur',
      photos: ['https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=600&q=80'],
      rating: 4.9,
      reviewCount: 56,
      isVerifiedVendor: true,
      tags: ['lac', 'bangles', 'handcrafted', 'heritage', 'tripolia'],
    },
  ];

  // 4. Seed Verified Local Community Group
  const localGroup = {
    id: 'group_jaipur_dawn_walkers',
    name: 'Pink City Dawn Heritage Walkers',
    description: 'Free, non-commercial early-morning cultural walking club exploring hidden havelis, rooftop vistas, and sacred pigeon feeding squares.',
    category: 'heritage_walk',
    city: 'Jaipur',
    memberCount: 248,
    isVerified: true,
    meetingPoint: 'Hawa Mahal Front Steps, Badi Choupad',
    schedule: 'Every Saturday & Sunday at 6:30 AM',
    leadName: 'Rajesh Sharma (Rajasthan Govt Certified Historian)',
    leadContact: '+919829088776',
    kycReference: 'RAJ-TOUR-2018-842',
    photos: ['https://images.unsplash.com/photo-1599661046289-e31897846e41?auto=format&fit=crop&w=600&q=80'],
    rating: 4.9,
    reviewCount: 47,
  };

  // 5. Seed Polymorphic Reviews
  const demoReviews = [
    {
      id: 'rev_demo_1',
      targetType: 'food',
      targetId: 'eat_rawat_kachori',
      userId: 'user_ananya_01',
      userName: 'Ananya Deshmukh',
      userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=120&q=80',
      rating: 5,
      text: 'Best Pyaaz Kachori on planet Earth! Crispy flaky pastry packed with perfectly spiced onion filling. Pair it with their thick Mawa Kachori.',
      createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
    },
    {
      id: 'rev_demo_2',
      targetType: 'place',
      targetId: 'stop_d1_1',
      userId: 'user_marcus_02',
      userName: 'Marcus Lindqvist',
      userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80',
      rating: 5,
      text: 'Sheesh Mahal inside Amer Palace is breathtaking! Arrive right at 8:30 AM before tour bus crowds. Sanchari route suggestions saved us ₹400 on transit.',
      createdAt: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
    },
    {
      id: 'rev_demo_3',
      targetType: 'group',
      targetId: 'group_jaipur_dawn_walkers',
      userId: 'user_priya_03',
      userName: 'Priya Sundaram',
      userAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=120&q=80',
      rating: 5,
      text: 'Rajesh ji gave us an unforgettable walk through 300-year-old havelis and stepwells. Zero sales pitch, 100% genuine local history. Must join!',
      createdAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
    },
  ];

  // If MongoDB is connected, execute database upserts
  if (isConnected) {
    await DestinationCustoms.findOneAndUpdate({ destination: 'Jaipur' }, jaipurCustoms, { upsert: true, new: true });
    await Trip.findOneAndUpdate({ userId: 'demo_traveler_001' }, jaipurTrip, { upsert: true, new: true });

    for (const find of localFinds) {
      await LocalFind.findOneAndUpdate({ id: find.id }, find, { upsert: true, new: true });
    }

    await LocalGroup.findOneAndUpdate({ id: localGroup.id }, localGroup, { upsert: true, new: true });

    for (const rev of demoReviews) {
      await Review.findOneAndUpdate({ id: rev.id }, rev, { upsert: true, new: true });
    }

    // Also seed default transport rates
    for (const cityRate of DEFAULT_CITY_RATES) {
      await TransportRateConfig.findOneAndUpdate({ city: cityRate.city }, cityRate, { upsert: true, new: true });
    }

    console.log('✅ MongoDB database successfully populated with Jaipur Hackathon Demo Data!');
  } else {
    console.log('ℹ️ In-memory fallback payloads compiled successfully.');
  }

  console.log('====================================================');
  console.log('✨ DEMO SEED SUMMARY:');
  console.log(' - Destination: Jaipur, Rajasthan (Full Customs & Etiquette)');
  console.log(' - Active Itinerary: 3 Days, 10 Curated Stops, Multi-Modal Legs (₹9,650 Total)');
  console.log(' - Local Finds: 3 GI/Artisan Products with Direct Vendor Contacts');
  console.log(' - Community Groups: Pink City Dawn Walkers (Govt Verified)');
  console.log(' - Reviews: 3 Verified 5-Star Traveler Reviews');
  console.log('====================================================');

  if (isConnected) {
    await mongoose.disconnect();
  }
}

// Run seeder if invoked directly
if (require.main === module) {
  seedDemoData()
    .then(() => process.exit(0))
    .catch((err) => {
      console.error('❌ Seeder Error:', err);
      process.exit(1);
    });
}

module.exports = { seedDemoData };
