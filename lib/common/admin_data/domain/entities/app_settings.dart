class AppSettings {
  final String appName;
  final String appVersion;
  final String appDescription;
  final String appTagline;
  final String termsAndConditions;
  final String contactEmail;
  final String contactPhone;
  final String website;
  final String supportEmail;
  final SocialMedia socialMedia;
  final DateTime lastUpdated;
  final String createdBy;
  final bool isActive;
  final String referAndEarnText;
  final String totalDistance;
  final String totalGemCoins;
  final String totalRides;

  AppSettings({
    required this.appName,
    required this.appVersion,
    required this.appDescription,
    required this.appTagline,
    required this.termsAndConditions,
    required this.contactEmail,
    required this.contactPhone,
    required this.website,
    required this.supportEmail,
    required this.socialMedia,
    required this.lastUpdated,
    required this.createdBy,
    required this.isActive,
    required this.referAndEarnText,
    required this.totalDistance,
    required this.totalGemCoins,
    required this.totalRides,
  });
}

class SocialMedia {
  final String facebook;
  final String twitter;
  final String instagram;
  final String linkedin;
  final String youtube;
  final String whatsapp;

  SocialMedia({
    required this.facebook,
    required this.twitter,
    required this.instagram,
    required this.linkedin,
    required this.youtube,
    required this.whatsapp,
  });
} 