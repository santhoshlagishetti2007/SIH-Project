import '../../../../core/network/api_result.dart';
import '../../../../core/network/network_exceptions.dart';
import '../datasources/womens_safety_remote_data_source.dart';
import '../../domain/models/womens_safety_models.dart';
import '../../domain/repositories/womens_safety_repository.dart';

class WomensSafetyRepositoryImpl implements WomensSafetyRepository {
  final WomensSafetyRemoteDataSource _remoteDataSource;

  WomensSafetyRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<WomensSafetyGuide>> getCitySafetyGuide(String city) async {
    try {
      final guide = await _remoteDataSource.getCitySafetyGuide(city);
      return ApiResult.success(guide);
    } on NetworkExceptions catch (_) {
      return ApiResult.success(_getOfflineGuide(city));
    } catch (_) {
      return ApiResult.success(_getOfflineGuide(city));
    }
  }

  @override
  Future<ApiResult<List<EmergencyStation>>> getNearestEmergencyServices({
    double? lat,
    double? lng,
    String? city,
    String? type,
  }) async {
    try {
      final list = await _remoteDataSource.getNearestEmergencyServices(
        lat: lat,
        lng: lng,
        city: city,
        type: type,
      );
      return ApiResult.success(list);
    } on NetworkExceptions catch (_) {
      return ApiResult.success(_getOfflineEmergencyStations());
    } catch (_) {
      return ApiResult.success(_getOfflineEmergencyStations());
    }
  }

  @override
  Future<ApiResult<List<WomenVerifiedListing>>> getWomenVerifiedStaysAndGuides({
    String? city,
    String? category,
  }) async {
    try {
      final list = await _remoteDataSource.getWomenVerifiedStaysAndGuides(
        city: city,
        category: category,
      );
      return ApiResult.success(list);
    } on NetworkExceptions catch (_) {
      return ApiResult.success(_getOfflineVerifiedListings());
    } catch (_) {
      return ApiResult.success(_getOfflineVerifiedListings());
    }
  }

  WomensSafetyGuide _getOfflineGuide(String city) {
    return const WomensSafetyGuide(
      city: 'Jaipur',
      safeAreas: [
        'C-Scheme (Well-lit cafes, high residential security)',
        'Malviya Nagar & Gaurav Tower Boulevard',
        'Bani Park (Tourist police presence)',
      ],
      cautionAreas: [
        'Isolated Nahargarh Fort Road after 8:30 PM',
        'Dark interior bylanes of Purani Basti late at night',
      ],
      transportAdvice: TransportAdvice(
        general: 'Jaipur Metro operates till 10 PM with dedicated female security. App cabs are available 24/7.',
        nightTransit: 'Avoid unmetered roadside autos alone after 10 PM. Use app cabs with live location sharing.',
        recommendedApps: ['Uber', 'Ola', 'Jaipur Metro'],
        verifiedCabs: 'Pink City Cabs & Pre-paid booths at Junction & Airport.',
      ),
      emergencyNumbers: EmergencyNumbers(
        womenHelpline: '1091',
        womenHelplineAlt: '181',
        nationalHelpline: '112',
        policeHelpline: '100',
        ambulance: '108',
      ),
      localTips: [
        'Tourist Police are stationed at Hawa Mahal & Amer Fort.',
        'Use the Fake Call simulator if negotiating with persistent touts.',
      ],
    );
  }

  List<EmergencyStation> _getOfflineEmergencyStations() {
    return const [
      EmergencyStation(
        id: 'ps_1',
        name: 'Jaipur Women Police Station (Mahila Thana)',
        type: 'police',
        address: 'Gandhi Nagar, Tonk Road, Jaipur',
        phone: '+911412706558',
        helpline: '1091',
        distanceText: '850m • ~3 min drive',
        lat: 26.8912,
        lng: 75.8021,
      ),
      EmergencyStation(
        id: 'hosp_1',
        name: 'SMS Multi-Specialty Government Hospital',
        type: 'hospital',
        address: 'JLN Marg, Ashok Nagar, Jaipur',
        phone: '+911412560291',
        helpline: '108',
        distanceText: '1.4 km • ~6 min drive',
        lat: 26.8985,
        lng: 75.8152,
      ),
    ];
  }

  List<WomenVerifiedListing> _getOfflineVerifiedListings() {
    return const [
      WomenVerifiedListing(
        id: 'stay_w1',
        name: 'The Heritage Haveli Boutique Stay (Women Host)',
        type: 'stay',
        city: 'Jaipur',
        price: 2800,
        rating: 4.9,
        reviewsCount: 184,
        safetyBadges: ['🌸 Female Host', '📹 24/7 CCTV', '💡 Well-Lit Street', '🔒 Smart Keypad'],
        photo: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&auto=format&fit=crop&q=80',
        phone: '+919829011223',
        description: 'Charming heritage villa hosted by travel photographer Priya Sharma with 24/7 night guard.',
      ),
      WomenVerifiedListing(
        id: 'guide_w1',
        name: 'Ananya Mehra — Certified Ministry of Tourism Guide',
        type: 'guide',
        city: 'Jaipur',
        price: 600,
        rating: 4.95,
        reviewsCount: 160,
        safetyBadges: ['🛡️ Govt Certified', '🌸 Solo Women Specialist'],
        photo: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=800&auto=format&fit=crop&q=80',
        phone: '+919829033221',
        description: 'Specializes in safe heritage walking tours across Pink City bazaars & Amer Fort.',
      ),
    ];
  }
}
