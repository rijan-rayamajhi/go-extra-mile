import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.uid,
    required super.displayName,
    required super.email,
    required super.photoUrl,
    super.userName,
    super.gender,
    super.totalGemCoins,
    super.dateOfBirth,
    super.privateProfile,
    super.totalDistance,
    super.totalRide,
    super.createdAt,
    super.updatedAt,
    super.bio,
    super.interests,
    super.address,
    super.instagramLink,
    super.youtubeLink,
    super.whatsappLink,
    super.referralCode,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      userName: map['userName'],
      gender: map['gender'],
      totalGemCoins: (map['totalGemCoins'] as num?)?.toDouble(),
      dateOfBirth: (map['dateOfBirth'] as Timestamp?)?.toDate(),
      privateProfile: map['privateProfile'],
      totalDistance: (map['totalDistance'] as num?)?.toDouble(),
      totalRide: map['totalRide'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      bio: map['bio'],
      interests: (map['interests'] as List?)?.map((e) => e.toString()).toList(),
      address: map['address'],
      instagramLink: map['instagramLink'],
      youtubeLink: map['youtubeLink'],
      whatsappLink: map['whatsappLink'], // Backward compatibility
      referralCode: map['referralCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'userName': userName,
      'gender': gender,
      'totalGemCoins': totalGemCoins,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'privateProfile': privateProfile,
      'totalDistance': totalDistance,
      'totalRide': totalRide,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'bio': bio,
      'interests': interests,
      'address': address,
      'instagramLink': instagramLink,
      'youtubeLink': youtubeLink,
      'whatsappLink': whatsappLink,
      'whatsappNumber': whatsappLink, // Backward compatibility during transition
      'referralCode': referralCode,
    };
  }

  ProfileModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    String? userName,
    String? gender,
    double? totalGemCoins,
    DateTime? dateOfBirth,
    bool? privateProfile,
    double? totalDistance,
    int? totalRide,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bio,
    List<String>? interests,
    String? address,
    String? instagramLink,
    String? youtubeLink,
    String? whatsappLink,
    String? referralCode,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      userName: userName ?? this.userName,
      gender: gender ?? this.gender,
      totalGemCoins: totalGemCoins ?? this.totalGemCoins,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      privateProfile: privateProfile ?? this.privateProfile,
      totalDistance: totalDistance ?? this.totalDistance,
      totalRide: totalRide ?? this.totalRide,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      address: address ?? this.address,
      instagramLink: instagramLink ?? this.instagramLink,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      whatsappLink: whatsappLink ?? this.whatsappLink,
      referralCode: referralCode ?? this.referralCode,
    );
  }
}
