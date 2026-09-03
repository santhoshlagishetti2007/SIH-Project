import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for generating and launching deep links to Uber, Ola, and Google Maps
class CabDeepLinkService {
  /// Build Uber Native App Deep Link
  static Uri buildUberAppUri({
    required double pickupLat,
    required double pickupLng,
    required String pickupName,
    String pickupAddress = '',
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffName,
    String dropoffAddress = '',
  }) {
    final queryParams = <String, String>{
      'action': 'setPickup',
      'client_id': 'sanchari_travel_companion',
      'pickup[latitude]': pickupLat != 0.0 ? pickupLat.toString() : '26.9124',
      'pickup[longitude]': pickupLng != 0.0 ? pickupLng.toString() : '75.7873',
      'pickup[nickname]': pickupName.isNotEmpty ? pickupName : 'Current Stop',
      'dropoff[latitude]': dropoffLat != 0.0 ? dropoffLat.toString() : '26.9258',
      'dropoff[longitude]': dropoffLng != 0.0 ? dropoffLng.toString() : '75.8236',
      'dropoff[nickname]': dropoffName.isNotEmpty ? dropoffName : 'Next Stop',
    };

    if (pickupAddress.isNotEmpty) {
      queryParams['pickup[formatted_address]'] = pickupAddress;
    }
    if (dropoffAddress.isNotEmpty) {
      queryParams['dropoff[formatted_address]'] = dropoffAddress;
    }

    return Uri(
      scheme: 'uber',
      queryParameters: queryParams,
    );
  }

  /// Build Uber Mobile Web Universal Fallback URL
  static Uri buildUberWebUri({
    required double pickupLat,
    required double pickupLng,
    required String pickupName,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffName,
  }) {
    return Uri.https('m.uber.com', '/ul/', {
      'action': 'setPickup',
      'client_id': 'sanchari_travel_companion',
      'pickup[latitude]': pickupLat != 0.0 ? pickupLat.toString() : '26.9124',
      'pickup[longitude]': pickupLng != 0.0 ? pickupLng.toString() : '75.7873',
      'pickup[nickname]': pickupName.isNotEmpty ? pickupName : 'Current Stop',
      'dropoff[latitude]': dropoffLat != 0.0 ? dropoffLat.toString() : '26.9258',
      'dropoff[longitude]': dropoffLng != 0.0 ? dropoffLng.toString() : '75.8236',
      'dropoff[nickname]': dropoffName.isNotEmpty ? dropoffName : 'Next Stop',
    });
  }

  /// Build Ola Cabs Native App Deep Link
  static Uri buildOlaAppUri({
    required double pickupLat,
    required double pickupLng,
    required String pickupName,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffName,
  }) {
    return Uri(
      scheme: 'olacabs',
      host: 'app',
      path: '/launch',
      queryParameters: {
        'lat': pickupLat != 0.0 ? pickupLat.toString() : '26.9124',
        'lng': pickupLng != 0.0 ? pickupLng.toString() : '75.7873',
        'category_id': '1', // Micro/Mini/Prime auto selection
        'drop_lat': dropoffLat != 0.0 ? dropoffLat.toString() : '26.9258',
        'drop_lng': dropoffLng != 0.0 ? dropoffLng.toString() : '75.8236',
        'drop_name': dropoffName.isNotEmpty ? dropoffName : 'Next Stop',
      },
    );
  }

  /// Build Ola Cabs Web Universal Fallback URL
  static Uri buildOlaWebUri({
    required double pickupLat,
    required double pickupLng,
    required String pickupName,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffName,
  }) {
    return Uri.https('book.olacabs.com', '/', {
      'pickup_name': pickupName.isNotEmpty ? pickupName : 'Current Stop',
      'pickup_lat': pickupLat != 0.0 ? pickupLat.toString() : '26.9124',
      'pickup_lng': pickupLng != 0.0 ? pickupLng.toString() : '75.7873',
      'drop_name': dropoffName.isNotEmpty ? dropoffName : 'Next Stop',
      'drop_lat': dropoffLat != 0.0 ? dropoffLat.toString() : '26.9258',
      'drop_lng': dropoffLng != 0.0 ? dropoffLng.toString() : '75.8236',
    });
  }

  /// Build Google Maps Driving Directions URL
  static Uri buildGoogleMapsDirectionsUri({
    required double pickupLat,
    required double pickupLng,
    required String pickupName,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffName,
  }) {
    final originParam = pickupLat != 0.0 && pickupLng != 0.0
        ? '$pickupLat,$pickupLng'
        : pickupName;
    final destParam = dropoffLat != 0.0 && dropoffLng != 0.0
        ? '$dropoffLat,$dropoffLng'
        : dropoffName;

    return Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': originParam,
      'destination': destParam,
      'travelmode': 'driving',
    });
  }

  /// Launch Uber ride request: Try native app first, fallback to mobile web
  static Future<bool> launchUberRide({
    required double pickupLat,
    required double pickupLng,
    required String pickupName,
    String pickupAddress = '',
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffName,
    String dropoffAddress = '',
  }) async {
    final appUri = buildUberAppUri(
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupName: pickupName,
      pickupAddress: pickupAddress,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      dropoffName: dropoffName,
      dropoffAddress: dropoffAddress,
    );

    final webUri = buildUberWebUri(
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupName: pickupName,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      dropoffName: dropoffName,
    );

    try {
      if (await canLaunchUrl(appUri)) {
        final launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
        if (launched) return true;
      }
    } catch (e) {
      debugPrint('[CabDeepLinkService] Uber app launch error: $e');
    }

    // Web fallback
    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[CabDeepLinkService] Uber web launch error: $e');
      return false;
    }
  }

  /// Launch Ola ride request: Try native app first, fallback to mobile web
  static Future<bool> launchOlaRide({
    required double pickupLat,
    required double pickupLng,
    required String pickupName,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffName,
  }) async {
    final appUri = buildOlaAppUri(
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupName: pickupName,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      dropoffName: dropoffName,
    );

    final webUri = buildOlaWebUri(
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupName: pickupName,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      dropoffName: dropoffName,
    );

    try {
      if (await canLaunchUrl(appUri)) {
        final launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
        if (launched) return true;
      }
    } catch (e) {
      debugPrint('[CabDeepLinkService] Ola app launch error: $e');
    }

    // Web fallback
    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[CabDeepLinkService] Ola web launch error: $e');
      return false;
    }
  }

  /// Launch Google Maps navigation / route
  static Future<bool> launchGoogleMaps({
    required double pickupLat,
    required double pickupLng,
    required String pickupName,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffName,
  }) async {
    final mapsUri = buildGoogleMapsDirectionsUri(
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupName: pickupName,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,
      dropoffName: dropoffName,
    );

    try {
      return await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[CabDeepLinkService] Maps launch error: $e');
      return false;
    }
  }
}
