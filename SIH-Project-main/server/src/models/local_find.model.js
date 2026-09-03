const mongoose = require('mongoose');

/**
 * Local Finds Marketplace Listing Schema
 */
const LocalFindSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    category: {
      type: String,
      required: true,
      enum: [
        'craft',
        'toy',
        'gift',
        'food_product',
        'textile',
        'art',
        'jewelry',
        'spice',
        'general',
      ],
      default: 'craft',
      index: true,
    },
    price: {
      type: Number,
      required: true,
      min: 0,
    },
    originalPrice: {
      type: Number,
      default: 0,
    },
    vendorName: {
      type: String,
      required: true,
      trim: true,
    },
    vendorPhone: {
      type: String,
      default: '+919829012345',
    },
    vendorWhatsApp: {
      type: String,
      default: '+919829012345',
    },
    vendorLocation: {
      address: { type: String, default: '' },
      city: { type: String, default: 'Jaipur', index: true },
      state: { type: String, default: 'Rajasthan' },
      lat: { type: Number, default: 26.9124 },
      lng: { type: Number, default: 75.7873 },
    },
    photos: {
      type: [String],
      default: [],
    },
    description: {
      type: String,
      default: '',
    },
    story: {
      type: String,
      default: '',
    },
    regionTags: {
      type: [String],
      default: [],
      index: true,
    },
    rating: {
      type: Number,
      default: 4.8,
      min: 1,
      max: 5,
    },
    userRatingsTotal: {
      type: Number,
      default: 85,
    },
    isFeatured: {
      type: Boolean,
      default: false,
      index: true,
    },
    inStock: {
      type: Boolean,
      default: true,
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
 * Curated seed listings for top destinations
 */
const SEED_LOCAL_FINDS = [
  // Jaipur / Rajasthan
  {
    name: 'Hand-Painted Blue Pottery Floral Vase',
    category: 'craft',
    price: 850,
    originalPrice: 1100,
    vendorName: 'Kripal Kumbh Heritage Blue Pottery',
    vendorPhone: '+919829012345',
    vendorWhatsApp: '+919829012345',
    vendorLocation: {
      address: 'B-18, Shiv Marg, Bani Park, Jaipur, Rajasthan 302016',
      city: 'Jaipur',
      state: 'Rajasthan',
      lat: 26.9285,
      lng: 75.7925,
    },
    photos: [
      'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800&auto=format&fit=crop&q=80',
    ],
    description: 'Traditional Jaipur turquoise blue pottery vase crafted with quartz stone powder, Fuller’s earth, and natural plant gum.',
    story: 'Preserved by Padmashree awardee master artisans of Jaipur using a 300-year-old Egyptian-Persian low-fire glazing technique without clay.',
    regionTags: ['Jaipur', 'Rajasthan', 'GI Tagged', 'Handmade', 'Blue Pottery', 'Heritage Craft'],
    rating: 4.9,
    userRatingsTotal: 340,
    isFeatured: true,
    inStock: true,
  },
  {
    name: 'Traditional Rajasthani Kathputli String Puppets (Pair)',
    category: 'toy',
    price: 450,
    originalPrice: 600,
    vendorName: 'Bhatt Puppet Artisan Collective',
    vendorPhone: '+919829054321',
    vendorWhatsApp: '+919829054321',
    vendorLocation: {
      address: 'Kathputli Colony, Jyoti Nagar, Jaipur, Rajasthan 302005',
      city: 'Jaipur',
      state: 'Rajasthan',
      lat: 26.8925,
      lng: 75.7985,
    },
    photos: [
      'https://images.unsplash.com/photo-1569420078422-0a41f6e07663?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
    ],
    description: 'Vibrant handcrafted wooden Raja-Rani string puppets draped in recycled sequined Rajasthani bandhej fabric.',
    story: 'Carved from single pieces of mango wood by traditional Bhat community storytellers who have performed folk ballads for generations.',
    regionTags: ['Jaipur', 'Rajasthan', 'Folk Art', 'Handmade', 'Toys', 'Cultural Souvenir'],
    rating: 4.8,
    userRatingsTotal: 210,
    isFeatured: true,
    inStock: true,
  },
  {
    name: 'Royal Kesari Paneer Ghewar Gift Box (500g)',
    category: 'food_product',
    price: 550,
    originalPrice: 650,
    vendorName: 'Laxmi Misthan Bhandar (LMB 1727)',
    vendorPhone: '+919829098765',
    vendorWhatsApp: '+919829098765',
    vendorLocation: {
      address: 'Johari Bazar, Pink City, Jaipur, Rajasthan 302003',
      city: 'Jaipur',
      state: 'Rajasthan',
      lat: 26.9216,
      lng: 75.8251,
    },
    photos: [
      'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&auto=format&fit=crop&q=80',
    ],
    description: 'Iconic honeycomb disc sweet soaked in saffron sugar syrup, topped with fresh mawa malai, pistachios, and silver leaf.',
    story: 'A signature dessert of Teej and royal celebrations, perfected by LMB master sweet-makers in Johari Bazaar since 1727.',
    regionTags: ['Jaipur', 'Rajasthan', 'Heritage Sweet', 'Authentic Food', 'Gift Box'],
    rating: 4.9,
    userRatingsTotal: 580,
    isFeatured: true,
    inStock: true,
  },
  {
    name: 'Hand-Block Printed Sanganeri Pure Cotton Bedcover',
    category: 'textile',
    price: 1250,
    originalPrice: 1600,
    vendorName: 'Chhipa Artisan Block Printers',
    vendorPhone: '+919829033445',
    vendorWhatsApp: '+919829033445',
    vendorLocation: {
      address: 'Main Bazaar, Sanganer, Jaipur, Rajasthan 303902',
      city: 'Jaipur',
      state: 'Rajasthan',
      lat: 26.8195,
      lng: 75.7865,
    },
    photos: [
      'https://images.unsplash.com/photo-1606744837616-56c9a5c6a6eb?w=800&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop&q=80',
    ],
    description: 'Double-bed 100% breathable organic cotton bedsheet hand-printed using carved teakwood blocks and natural herbal dyes.',
    story: 'Crafted in Sanganer village where families have practiced the intricate Chhipa block-printing art on white backgrounds for over 4 centuries.',
    regionTags: ['Jaipur', 'Sanganer', 'GI Tagged', 'Hand Block Print', 'Organic Cotton', 'Textile'],
    rating: 4.7,
    userRatingsTotal: 195,
    isFeatured: false,
    inStock: true,
  },
  {
    name: 'Artisan Brass Inlay Elephant Trinket Gift Box',
    category: 'gift',
    price: 650,
    originalPrice: 850,
    vendorName: 'Bapu Bazaar Lac & Wood Guild',
    vendorPhone: '+919829066778',
    vendorWhatsApp: '+919829066778',
    vendorLocation: {
      address: 'Shop 42, Bapu Bazaar, Pink City, Jaipur, Rajasthan 302003',
      city: 'Jaipur',
      state: 'Rajasthan',
      lat: 26.9189,
      lng: 75.8242,
    },
    photos: [
      'https://images.unsplash.com/photo-1544717305-2782549b5136?w=800&auto=format&fit=crop&q=80',
    ],
    description: 'Polished sheesham wood keepsake jewelry box adorned with delicate hand-carved floral brass wire inlays.',
    story: 'Crafted by master wood turners using ancient Tarkashi brass wire inlay methods passed down from Mughal court artisans.',
    regionTags: ['Jaipur', 'Bapu Bazaar', 'Handmade', 'Brass Inlay', 'Souvenir Gift'],
    rating: 4.8,
    userRatingsTotal: 140,
    isFeatured: false,
    inStock: true,
  },

  // Delhi / NCR
  {
    name: 'Authentic Royal Chandni Chowk Spices Box',
    category: 'spice',
    price: 490,
    originalPrice: 650,
    vendorName: 'Mehra Spice Merchants (Khari Baoli)',
    vendorPhone: '+919811012345',
    vendorWhatsApp: '+919811012345',
    vendorLocation: {
      address: 'Khari Baoli, Chandni Chowk, Old Delhi, Delhi 110006',
      city: 'Delhi',
      state: 'Delhi',
      lat: 28.6562,
      lng: 77.2215,
    },
    photos: [
      'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800&auto=format&fit=crop&q=80',
    ],
    description: 'Handpicked spice selection featuring Kashmiri saffron strands, Malabar black pepper, green cardamom, and royal garam masala.',
    story: 'Sourced directly from Khari Baoli, Asia’s largest wholesale spice market operating since the 17th century near Fatehpuri Masjid.',
    regionTags: ['Delhi', 'Old Delhi', 'Khari Baoli', 'Authentic Spices', 'Organic'],
    rating: 4.9,
    userRatingsTotal: 420,
    isFeatured: true,
    inStock: true,
  },

  // Goa
  {
    name: 'Handcrafted Coconut Shell Coaster & Bowl Set',
    category: 'craft',
    price: 390,
    originalPrice: 500,
    vendorName: 'Fontainhas Eco-Artisans Guild',
    vendorPhone: '+919822012345',
    vendorWhatsApp: '+919822012345',
    vendorLocation: {
      address: 'Fontainhas Latin Quarter, Panaji, Goa 403001',
      city: 'Goa',
      state: 'Goa',
      lat: 15.4989,
      lng: 73.8278,
    },
    photos: [
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&auto=format&fit=crop&q=80',
    ],
    description: 'Eco-friendly polished reclaimed coconut shell serving bowls and drink coasters with natural beeswax lacquer.',
    story: 'Handmade by coastal Goan craftspeople transforming upcycled discarded coconut shells into zero-waste functional tableware.',
    regionTags: ['Goa', 'Panaji', 'Eco Friendly', 'Handmade', 'Coastal Craft'],
    rating: 4.8,
    userRatingsTotal: 165,
    isFeatured: true,
    inStock: true,
  },
];

LocalFindSchema.statics.getSeedData = function () {
  return SEED_LOCAL_FINDS;
};

const LocalFind = mongoose.model('LocalFind', LocalFindSchema);

module.exports = LocalFind;
