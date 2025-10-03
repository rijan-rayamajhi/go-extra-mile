import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_settings.dart';
import 'faq_model.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.appName,
    required super.appTagline,
    required super.appVersion,
    required super.createdAt,
    required super.email,
    required super.faqs,
    required super.phoneNumber,
    required super.termsAndConditionLink,
    required super.updatedAt,
    required super.whatsappNumber,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      appName: json['appName'] ?? '',
      appTagline: json['appTagline'] ?? '',
      appVersion: json['appVersion'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      email: json['email'] ?? '',
      faqs:
          (json['faqs'] as List<dynamic>?)
              ?.map((faq) => FaqModel.fromJson(faq as Map<String, dynamic>))
              .toList() ??
          [],
      phoneNumber: json['phoneNumber'] ?? '',
      termsAndConditionLink: json['termsAndConditionLink'] ?? '',
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      whatsappNumber: json['whatsappNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appTagline': appTagline,
      'appVersion': appVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'email': email,
      'faqs': faqs
          .map(
            (faq) => FaqModel(
              id: faq.id,
              question: faq.question,
              answer: faq.answer,
            ).toJson(),
          )
          .toList(),
      'phoneNumber': phoneNumber,
      'termsAndConditionLink': termsAndConditionLink,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'whatsappNumber': whatsappNumber,
    };
  }
}
