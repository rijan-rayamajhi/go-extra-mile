import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_event.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_state.dart';
import 'package:go_extra_mile_new/features/profile/presentation/screens/my_profile_screen.dart';

class HomeProfileImage extends StatefulWidget {
  const HomeProfileImage({super.key});

  @override
  State<HomeProfileImage> createState() => _HomeProfileImageState();
}

class _HomeProfileImageState extends State<HomeProfileImage> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<ProfileBloc>().add(GetProfileEvent(user.uid));
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            );
          } else if (state is ProfileLoaded) {
            return CircularImage(
              imageUrl: state.profile.photoUrl ,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyProfileScreen()),
                );
              },
              height: 50,
              width: 50,
            );
          } else if (state is ProfileError) {
            // Fallback to default image on error
            return CircularImage(
              imageUrl: 'https://img.freepik.com/free-vector/happy-raksha-bandhan-indian-festival-banner-design_1017-20014.jpg?semt=ais_hybrid&w=740&q=80',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyProfileScreen()),
                );
              },
              height: 50,
              width: 50,
            );
          } else {
            // Initial state or other states - show default image
            return CircularImage(
              imageUrl: 'https://img.freepik.com/free-vector/happy-raksha-bandhan-indian-festival-banner-design_1017-20014.jpg?semt=ais_hybrid&w=740&q=80',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyProfileScreen()),
                );
              },
              height: 50,
              width: 50,
            );
          }
        },
      ),
    );
  }
}
