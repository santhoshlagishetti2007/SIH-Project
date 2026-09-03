import '../../../../core/network/api_result.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../datasources/destination_customs_remote_data_source.dart';
import '../../domain/models/destination_customs_models.dart';
import '../../domain/repositories/destination_customs_repository.dart';

class DestinationCustomsRepositoryImpl implements DestinationCustomsRepository {
  final DestinationCustomsRemoteDataSource _remoteDataSource;
  final LocalCacheService _cacheService;

  DestinationCustomsRepositoryImpl(
    this._remoteDataSource, [
    LocalCacheService? cacheService,
  ]) : _cacheService = cacheService ?? LocalCacheService();

  @override
  Future<ApiResult<DestinationCustoms>> getDestinationCustoms(String destination) async {
    try {
      final customs = await _remoteDataSource.getDestinationCustoms(destination);
      return ApiResult.success(customs);
    } on NetworkExceptions catch (_) {
      final cached = _cacheService.getCachedDestinationCustoms(destination);
      if (cached != null) {
        return ApiResult.success(DestinationCustoms.fromJson(cached));
      }
      return ApiResult.success(_getOfflineCustoms(destination));
    } catch (_) {
      final cached = _cacheService.getCachedDestinationCustoms(destination);
      if (cached != null) {
        return ApiResult.success(DestinationCustoms.fromJson(cached));
      }
      return ApiResult.success(_getOfflineCustoms(destination));
    }
  }

  DestinationCustoms _getOfflineCustoms(String destination) {
    final d = destination.toLowerCase();
    if (d == 'delhi') {
      return const DestinationCustoms(
        destination: 'Delhi',
        region: 'National Capital Region',
        dressCode: DressCode(
          general: 'Modern casuals with comfortable walking shoes for large historical sites.',
          religiousSites: 'Full head covering at Gurudwara Bangla Sahib and Jama Masjid (scarves available at entry).',
          nightlife: 'Chic / smart casuals in CP, Khan Market, and Aerocity lounges.',
        ),
        templeEtiquette: [
          'Wash hands and feet at water basins before entering Gurudwaras.',
          'Cover your head at all times inside Sikh and Sufi shrines.',
          'Dress conservatively when visiting Old Delhi mosques and monuments.',
        ],
        tippingNorms: TippingNorms(
          restaurants: '10% in sit-down dining spots (check if service charge is already added).',
          autosCabs: 'Round up fare; ₹30 - ₹50 for polite cab drivers.',
          guidesDrivers: '₹500 - ₹800 per day for certified city tour guides.',
          hotelStaff: '₹100 for luggage assistance.',
        ),
        commonScams: [
          CommonScam(
            name: 'The "Train / Monument Closed" Scam',
            warning: 'Touts around NDLS Station claiming your train is cancelled or tourist office moved to Connaught Place.',
            preventionTip: 'Ignore touts completely. Proceed straight to official IRCTC / Northern Railway counters or your booked platform.',
          ),
          CommonScam(
            name: 'Broken Taxi Meter Scam',
            warning: 'Airport cab drivers claiming the meter is faulty and asking high cash fares.',
            preventionTip: 'Book through official Prepaid Taxi Booths inside airport terminal or use BluSmart/Uber/Ola.',
          ),
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
      );
    }

    // Default: Jaipur
    return const DestinationCustoms(
      destination: 'Jaipur',
      region: 'Rajasthan',
      dressCode: DressCode(
        general: 'Modest lightweight cottons. Sun hat and sunglasses recommended for open fort courtyards.',
        religiousSites: 'Cover head (dupatta/scarf), remove shoes and leather belts at Govind Dev Ji & Birla Mandir.',
        nightlife: 'Smart casuals at rooftop cafes and C-Scheme lounges.',
      ),
      templeEtiquette: [
        'Remove footwear at designated shoe stands before entering temple premises.',
        'Do not photograph deity idols or sanctum sanctorum without explicit permission.',
        'Accept prasad (blessed offering) with your right hand.',
        'Walk around temple shrines in a clockwise direction (Pradakshina).',
      ],
      tippingNorms: TippingNorms(
        restaurants: '7% - 10% if service charge is not included in the bill.',
        autosCabs: 'Round up the meter or app fare by ₹20 - ₹50.',
        guidesDrivers: '₹400 - ₹600 per full-day heritage tour guide; ₹300 for personal drivers.',
        hotelStaff: '₹50 - ₹100 per luggage bag for bellhops.',
      ),
      commonScams: [
        CommonScam(
          name: 'The "Cheap Gemstone / Blue Pottery Export" Scam',
          warning: 'Friendly strangers in Johari Bazaar offering to mail gems back home to make quick profit.',
          preventionTip: 'Never purchase gemstones on behalf of strangers. Only buy certified gemstones from Rajasthan Govt Emporiums (Rajasthali).',
        ),
        CommonScam(
          name: 'Unlicensed Tourist Fort Guides',
          warning: 'Touts outside Amber Fort offering "special shortcut entries" or quoting inflated prices.',
          preventionTip: 'Hire only Rajasthan Tourism Department certified guides with blue ID badges from the official ticket counter.',
        ),
        CommonScam(
          name: 'Unmetered Auto "Commission Stops"',
          warning: 'Auto drivers offering cheap rides in exchange for visiting "government-run" silk or handicraft shops.',
          preventionTip: 'Politely decline unscheduled stops and insist on app-based navigation (Uber/Ola/Google Maps).',
        ),
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
    );
  }
}
