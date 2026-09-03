import 'package:flutter/material.dart';

enum LocalFindCategory {
  all('all', 'All Finds', Icons.grid_view_rounded),
  craft('craft', 'Craft & Pottery', Icons.palette_outlined),
  toy('toy', 'Toys & Puppets', Icons.smart_toy_outlined),
  gift('gift', 'Souvenirs & Gifts', Icons.card_giftcard_outlined),
  foodProduct('food_product', 'Local Food & Sweets', Icons.bakery_dining_outlined),
  textile('textile', 'Handloom & Textiles', Icons.texture_rounded),
  spice('spice', 'Spices', Icons.spa_outlined),
  jewelry('jewelry', 'Jewelry', Icons.diamond_outlined),
  art('art', 'Folk Art', Icons.brush_outlined);

  final String code;
  final String label;
  final IconData icon;

  const LocalFindCategory(this.code, this.label, this.icon);

  static LocalFindCategory fromCode(String code) {
    return LocalFindCategory.values.firstWhere(
      (c) => c.code == code,
      orElse: () => LocalFindCategory.all,
    );
  }
}

class VendorLocation {
  final String address;
  final String city;
  final String state;
  final double lat;
  final double lng;

  const VendorLocation({
    this.address = '',
    this.city = 'Jaipur',
    this.state = 'Rajasthan',
    this.lat = 26.9124,
    this.lng = 75.7873,
  });

  factory VendorLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VendorLocation();
    return VendorLocation(
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? 'Jaipur',
      state: json['state'] as String? ?? 'Rajasthan',
      lat: (json['lat'] as num?)?.toDouble() ?? 26.9124,
      lng: (json['lng'] as num?)?.toDouble() ?? 75.7873,
    );
  }

  Map<String, dynamic> toJson() => {
    'address': address,
    'city': city,
    'state': state,
    'lat': lat,
    'lng': lng,
  };
}

class LocalFindItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final double originalPrice;
  final String vendorName;
  final String vendorPhone;
  final String vendorWhatsApp;
  final VendorLocation vendorLocation;
  final List<String> photos;
  final String description;
  final String story;
  final List<String> regionTags;
  final double rating;
  final int userRatingsTotal;
  final bool isFeatured;
  final bool inStock;

  const LocalFindItem({
    required this.id,
    required this.name,
    this.category = 'craft',
    required this.price,
    this.originalPrice = 0,
    required this.vendorName,
    this.vendorPhone = '+919829012345',
    this.vendorWhatsApp = '+919829012345',
    this.vendorLocation = const VendorLocation(),
    this.photos = const [],
    this.description = '',
    this.story = '',
    this.regionTags = const [],
    this.rating = 4.8,
    this.userRatingsTotal = 85,
    this.isFeatured = false,
    this.inStock = true,
  });

  factory LocalFindItem.fromJson(Map<String, dynamic> json) {
    return LocalFindItem(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Local Artisan Find',
      category: json['category'] as String? ?? 'craft',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      vendorName: json['vendorName'] as String? ?? 'Local Artisan',
      vendorPhone: json['vendorPhone'] as String? ?? '+919829012345',
      vendorWhatsApp: json['vendorWhatsApp'] as String? ?? '+919829012345',
      vendorLocation: VendorLocation.fromJson(json['vendorLocation'] as Map<String, dynamic>?),
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      description: json['description'] as String? ?? '',
      story: json['story'] as String? ?? '',
      regionTags: (json['regionTags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      userRatingsTotal: (json['userRatingsTotal'] as num?)?.toInt() ?? 85,
      isFeatured: json['isFeatured'] as bool? ?? false,
      inStock: json['inStock'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'originalPrice': originalPrice,
    'vendorName': vendorName,
    'vendorPhone': vendorPhone,
    'vendorWhatsApp': vendorWhatsApp,
    'vendorLocation': vendorLocation.toJson(),
    'photos': photos,
    'description': description,
    'story': story,
    'regionTags': regionTags,
    'rating': rating,
    'userRatingsTotal': userRatingsTotal,
    'isFeatured': isFeatured,
    'inStock': inStock,
  };

  /// Fallback curated seed list for offline travelers
  static List<LocalFindItem> get offlineCuratedCatalog => [
    const LocalFindItem(
      id: 'offline_find_1',
      name: 'Hand-Painted Blue Pottery Floral Vase',
      category: 'craft',
      price: 850,
      originalPrice: 1100,
      vendorName: 'Kripal Kumbh Heritage Blue Pottery',
      vendorPhone: '+919829012345',
      vendorWhatsApp: '+919829012345',
      vendorLocation: VendorLocation(
        address: 'B-18, Shiv Marg, Bani Park, Jaipur',
        city: 'Jaipur',
        state: 'Rajasthan',
      ),
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
    ),
    const LocalFindItem(
      id: 'offline_find_2',
      name: 'Traditional Rajasthani Kathputli String Puppets (Pair)',
      category: 'toy',
      price: 450,
      originalPrice: 600,
      vendorName: 'Bhatt Puppet Artisan Collective',
      vendorPhone: '+919829054321',
      vendorWhatsApp: '+919829054321',
      vendorLocation: VendorLocation(
        address: 'Kathputli Colony, Jyoti Nagar, Jaipur',
        city: 'Jaipur',
        state: 'Rajasthan',
      ),
      photos: [
        'https://images.unsplash.com/photo-1569420078422-0a41f6e07663?w=800&auto=format&fit=crop&q=80',
      ],
      description: 'Vibrant handcrafted wooden Raja-Rani string puppets draped in recycled sequined Rajasthani bandhej fabric.',
      story: 'Carved from single pieces of mango wood by traditional Bhat community storytellers who have performed folk ballads for generations.',
      regionTags: ['Jaipur', 'Rajasthan', 'Folk Art', 'Handmade', 'Toys'],
      rating: 4.8,
      userRatingsTotal: 210,
      isFeatured: true,
      inStock: true,
    ),
    const LocalFindItem(
      id: 'offline_find_3',
      name: 'Royal Kesari Paneer Ghewar Gift Box (500g)',
      category: 'food_product',
      price: 550,
      originalPrice: 650,
      vendorName: 'Laxmi Misthan Bhandar (LMB 1727)',
      vendorPhone: '+919829098765',
      vendorWhatsApp: '+919829098765',
      vendorLocation: VendorLocation(
        address: 'Johari Bazar, Pink City, Jaipur',
        city: 'Jaipur',
        state: 'Rajasthan',
      ),
      photos: [
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
      ],
      description: 'Iconic honeycomb disc sweet soaked in saffron sugar syrup, topped with fresh mawa malai, pistachios, and silver leaf.',
      story: 'A signature dessert of Teej and royal celebrations, perfected by LMB master sweet-makers in Johari Bazaar since 1727.',
      regionTags: ['Jaipur', 'Rajasthan', 'Heritage Sweet', 'Authentic Food', 'Gift Box'],
      rating: 4.9,
      userRatingsTotal: 580,
      isFeatured: true,
      inStock: true,
    ),
    const LocalFindItem(
      id: 'offline_find_4',
      name: 'Hand-Block Printed Sanganeri Pure Cotton Bedcover',
      category: 'textile',
      price: 1250,
      originalPrice: 1600,
      vendorName: 'Chhipa Artisan Block Printers',
      vendorPhone: '+919829033445',
      vendorWhatsApp: '+919829033445',
      vendorLocation: VendorLocation(
        address: 'Main Bazaar, Sanganer, Jaipur',
        city: 'Jaipur',
        state: 'Rajasthan',
      ),
      photos: [
        'https://images.unsplash.com/photo-1606744837616-56c9a5c6a6eb?w=800&auto=format&fit=crop&q=80',
      ],
      description: 'Double-bed 100% breathable organic cotton bedsheet hand-printed using carved teakwood blocks and natural herbal dyes.',
      story: 'Crafted in Sanganer village where families have practiced the intricate Chhipa block-printing art on white backgrounds for over 4 centuries.',
      regionTags: ['Jaipur', 'Sanganer', 'GI Tagged', 'Hand Block Print', 'Textile'],
      rating: 4.7,
      userRatingsTotal: 195,
      isFeatured: false,
      inStock: true,
    ),
    const LocalFindItem(
      id: 'offline_find_5',
      name: 'Artisan Brass Inlay Elephant Trinket Gift Box',
      category: 'gift',
      price: 650,
      originalPrice: 850,
      vendorName: 'Bapu Bazaar Lac & Wood Guild',
      vendorPhone: '+919829066778',
      vendorWhatsApp: '+919829066778',
      vendorLocation: VendorLocation(
        address: 'Shop 42, Bapu Bazaar, Pink City, Jaipur',
        city: 'Jaipur',
        state: 'Rajasthan',
      ),
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
    ),
  ];
}
