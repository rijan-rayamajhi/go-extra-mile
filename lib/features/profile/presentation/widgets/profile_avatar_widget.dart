import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/profile/home_profile_image.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_event.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_state.dart';

class ProfileAvatarWidget extends StatelessWidget {
  const ProfileAvatarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileInitial) {
          context.read<ProfileBloc>().add(const GetProfileEvent());
        } else if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProfileLoaded) {
          return HomeProfileImage(profileImageUrl: state.profile.photoUrl);
        } else if (state is ProfileError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink(); // fallback
      },
    );
  }
}
