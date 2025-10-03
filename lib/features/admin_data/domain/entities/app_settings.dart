import 'package:equatable/equatable.dart';
import 'faq.dart';

class AppSettings extends Equatable {
  final String appName;
  final String appTagline;
  final String appVersion;
  final DateTime createdAt;
  final String email;
  final List<Faq> faqs;
  final String phoneNumber;
  final String termsAndConditionLink;
  final DateTime updatedAt;
  final String whatsappNumber;

  const AppSettings({
    required this.appName,
    required this.appTagline,
    required this.appVersion,
    required this.createdAt,
    required this.email,
    required this.faqs,
    required this.phoneNumber,
    required this.termsAndConditionLink,
    required this.updatedAt,
    required this.whatsappNumber,
  });

  @override
  List<Object?> get props => [
        appName,
        appTagline,
        appVersion,
        createdAt,
        email,
        faqs,
        phoneNumber,
        termsAndConditionLink,
        updatedAt,
        whatsappNumber,
      ];
}
