import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final String? userName;
  final String? gender;
  final double? totalGemCoins;
  final DateTime? dateOfBirth;
  final bool? privateProfile;
  final double? totalDistance;
  final int? totalRide;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? bio;
  final List<String>? interests;
  final String? address;
  final String? instagramLink;
  final String? youtubeLink;
  final String? whatsappLink;
  final bool? showInstagram;
  final bool? showYoutube;
  final bool? showWhatsapp;
  final String? referralCode;
   
  const ProfileEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    this.userName,
    this.gender,
    this.totalGemCoins,
    this.dateOfBirth,
    this.privateProfile,
    this.totalDistance,
    this.totalRide,
    this.createdAt,
    this.updatedAt,
    this.bio,
    this.interests,
    this.address,
    this.instagramLink,
    this.youtubeLink,
    this.whatsappLink,
    this.showInstagram,
    this.showYoutube,
    this.showWhatsapp,
    this.referralCode,
  });

  @override
  List<Object?> get props => [uid, displayName, email, photoUrl, userName, gender, totalGemCoins, dateOfBirth, privateProfile, totalDistance, totalRide, createdAt, updatedAt, bio, interests, address, instagramLink, youtubeLink, whatsappLink, showInstagram, showYoutube, showWhatsapp, referralCode];
}








