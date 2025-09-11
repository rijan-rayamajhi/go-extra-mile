import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/features/profile/presentation/screens/my_profile_screen.dart';

class HomeProfileImage extends StatelessWidget {
  final String? profileImageUrl;
  
  const HomeProfileImage({
    super.key,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CircularImage(
        key: ValueKey(profileImageUrl), // Add unique key based on image URL
        imageUrl: profileImageUrl,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyProfileScreen()),
          );
        },
        height: 50,
        width: 50,
      ),
    );
  }
}
