import '../../domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  AppSettingsModel({
    required super.appName,
    required super.appVersion,
    required super.appDescription,
    required super.appTagline,
    required super.termsAndConditions,
    required super.contactEmail,
    required super.contactPhone,
    required super.website,
    required super.supportEmail,
    required super.socialMedia,
    required super.lastUpdated,
    required super.createdBy,
    required super.isActive,
    required super.referAndEarnText,
    required super.totalDistance,
    required super.totalGemCoins,
    required super.totalRides,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      appName: json['appName'],
      appVersion: json['appVersion'],
      appDescription: json['appDescription'],
      appTagline: json['appTagline'],
      termsAndConditions: json['termsAndConditions'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      website: json['website'],
      supportEmail: json['supportEmail'],
      socialMedia: SocialMediaModel.fromJson(json['socialMedia']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      createdBy: json['createdBy'],
      isActive: json['isActive'],
      referAndEarnText: json['referAndEarnText'] ?? '',
      totalDistance: json['totalDistance'] ?? '0',
      totalGemCoins: json['totalGemCoins'] ?? '0',
      totalRides: json['totalRides'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'appDescription': appDescription,
      'appTagline': appTagline,
      'termsAndConditions': termsAndConditions,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'website': website,
      'supportEmail': supportEmail,
      'socialMedia': (socialMedia as SocialMediaModel).toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'createdBy': createdBy,
      'isActive': isActive,
      'referAndEarnText': referAndEarnText,
      'totalDistance': totalDistance,
      'totalGemCoins': totalGemCoins,
      'totalRides': totalRides,
    };
  }
}

class SocialMediaModel extends SocialMedia {
  SocialMediaModel({
    required super.facebook,
    required super.twitter,
    required super.instagram,
    required super.linkedin,
    required super.youtube,
    required super.whatsapp,
  });

  factory SocialMediaModel.fromJson(Map<String, dynamic> json) {
    return SocialMediaModel(
      facebook: json['facebook'],
      twitter: json['twitter'],
      instagram: json['instagram'],
      linkedin: json['linkedin'],
      youtube: json['youtube'],
      whatsapp: json['whatsapp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook': facebook,
      'twitter': twitter,
      'instagram': instagram,
      'linkedin': linkedin,
      'youtube': youtube,
      'whatsapp': whatsapp,
    };
  }
} 