import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/carousel_ad_model.dart';
import '../../../../core/error/exceptions.dart';
import 'carousel_ad_datasource.dart';

class CarouselAdFirestoreDataSource implements CarouselAdDataSource {
  final FirebaseFirestore firestore;

  CarouselAdFirestoreDataSource({required this.firestore});

  @override
  Future<List<CarouselAdModel>> getCarouselAdsByLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Get all active ads first
      final QuerySnapshot snapshot = await firestore
          .collection('carouselAds')
          .where('isActive', isEqualTo: true)
          .get();

      final List<CarouselAdModel> allAds = snapshot.docs
          .map(
            (doc) =>
                CarouselAdModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Filter ads based on scheduling and location targeting
      final List<CarouselAdModel> filteredAds = allAds.where((ad) {
        // Check scheduling if enabled
        if (ad.scheduling.enabled) {
          final now = DateTime.now();
          if (ad.scheduling.startDate != null &&
              now.isBefore(ad.scheduling.startDate!)) {
            return false; // Ad hasn't started yet
          }
          if (ad.scheduling.endDate != null &&
              now.isAfter(ad.scheduling.endDate!)) {
            return false; // Ad has ended
          }
        }

        // Check location targeting if enabled
        if (ad.locationTargeting.enabled) {
          if (ad.locationTargeting.location == null ||
              ad.locationTargeting.radius == null) {
            return false; // Location targeting enabled but no location/radius set
          }

          final distance = _calculateDistance(
            latitude,
            longitude,
            ad.locationTargeting.location!.latitude,
            ad.locationTargeting.location!.longitude,
          );

          return distance <= ad.locationTargeting.radius!;
        }

        return true; // No location targeting, include the ad
      }).toList();

      return filteredAds;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
