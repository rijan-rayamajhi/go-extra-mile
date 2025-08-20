import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/common/screens/google_maps_current_location_picker.dart';
import 'package:go_extra_mile_new/common/widgets/app_bar_widget.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/core/utils/image_picker_utils.dart';
import 'package:go_extra_mile_new/core/utils/text_validators.dart';
import 'package:go_extra_mile_new/core/utils/date_picker_utils.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/profile/domain/entities/profile_entity.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_event.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_state.dart';
import 'package:go_extra_mile_new/features/profile/presentation/widgets/edit_profile_address.dart';
import 'package:go_extra_mile_new/features/profile/presentation/widgets/edit_profile_bio_field.dart';
import 'package:go_extra_mile_new/features/profile/presentation/widgets/edit_profile_dob.dart';
import 'package:go_extra_mile_new/features/profile/presentation/widgets/edit_profile_gender.dart';
import 'package:go_extra_mile_new/features/profile/presentation/widgets/edit_profile_instagram_field.dart';
import 'package:go_extra_mile_new/features/profile/presentation/widgets/edit_profile_photo.dart';
import 'package:go_extra_mile_new/features/profile/presentation/widgets/edit_profile_username_field.dart';
import 'package:go_extra_mile_new/features/profile/presentation/widgets/edit_profile_email_field.dart';
import 'package:go_extra_mile_new/features/profile/presentation/widgets/edit_profile_display_name_field.dart';
import 'package:go_extra_mile_new/features/profile/presentation/widgets/edit_profile_whatsapp_field.dart';
import 'package:go_extra_mile_new/features/profile/presentation/widgets/edit_profile_youtube_field.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'dart:async';

class EditProfileScreen extends StatefulWidget {
  //profile entity
  final ProfileEntity profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _selectedImageFile;
  bool _isLoading = false;
  late TextEditingController _usernameController;
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _instagramController;
  late TextEditingController _youtubeController;
  late TextEditingController _whatsappController;
  Timer? _usernameDebounceTimer;
  bool _isUsernameAvailable = true;
  bool _isCheckingUsername = false;
  String? _usernameValidationError;
  String? _displayNameValidationError;
  String? _bioValidationError;
  String? _instagramValidationError;
  String? _youtubeValidationError;
  String? _whatsappValidationError;
  static const Duration _debounceDelay = Duration(milliseconds: 800);
  DateTime? _selectedDob;
  String? _selectedGender;
  String? _selectedAddress;
  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.userName);
    _displayNameController = TextEditingController(
      text: widget.profile.displayName,
    );
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _instagramController = TextEditingController(
      text: widget.profile.instagramLink ?? '',
    );
    _youtubeController = TextEditingController(
      text: widget.profile.youtubeLink ?? '',
    );
    _whatsappController = TextEditingController(
      text: widget.profile.whatsappLink ?? '',
    );
    _selectedDob = widget.profile.dateOfBirth;
    _selectedGender = widget.profile.gender;
    _selectedAddress = widget.profile.address;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _whatsappController.dispose();
    _usernameDebounceTimer?.cancel();
    super.dispose();
  }

  void _debounceUsernameCheck(String username) {
    // Cancel previous timer
    _usernameDebounceTimer?.cancel();

    // Clear previous availability state
    if (username.isEmpty || username == widget.profile.userName) {
      setState(() {
        _isUsernameAvailable = true;
        _isCheckingUsername = false;
        _usernameValidationError = null;
      });
      return;
    }

    // Set a new timer to debounce the API call
    _usernameDebounceTimer = Timer(_debounceDelay, () {
      if (mounted &&
          username.isNotEmpty &&
          username != widget.profile.userName) {
        _performUsernameCheck(username);
      }
    });
  }

  void _performUsernameCheck(String username) {
    if (!mounted) return;

    setState(() {
      _isCheckingUsername = true;
    });

    context.read<ProfileBloc>().add(CheckUsernameAvailabilityEvent(username));
  }

  void _onUsernameChanged(String username) {
    // Validate username format
    final validationError = TextValidators.username(username);
    setState(() {
      _usernameValidationError = validationError;
    });

    // Immediate UI feedback
    if (username.isEmpty || username == widget.profile.userName) {
      setState(() {
        _isUsernameAvailable = true;
        _isCheckingUsername = false;
      });
    }

    // Only check availability if validation passes
    if (validationError == null) {
      // Debounced API call
      _debounceUsernameCheck(username);
    }
  }

  void _onDisplayNameChanged(String displayName) {
    // Validate display name format
    final validationError = TextValidators.displayName(displayName);
    setState(() {
      _displayNameValidationError = validationError;
    });
  }

  void _onBioChanged(String bio) {
    final String? error = TextValidators.bio(bio);
    setState(() {
      _bioValidationError = error;
    });
  }

  void _onInstagramChanged(String instagram) {
    final String? error = TextValidators.instagram(instagram);
    setState(() {
      _instagramValidationError = error;
    });
  }

  void _onYoutubeChanged(String youtube) {
    final String? error = TextValidators.youtube(youtube);
    setState(() {
      _youtubeValidationError = error;
    });
  }

  void _onWhatsappChanged(String whatsapp) {
    final String? error = TextValidators.whatsapp(whatsapp);
    setState(() {
      _whatsappValidationError = error;
    });
  }

  bool _validateForm() {
    final String? usernameError = TextValidators.username(
      _usernameController.text,
    );
    final String? displayNameError = TextValidators.displayName(
      _displayNameController.text,
    );
    final String? bioError = TextValidators.bio(_bioController.text);
    final String? instagramError = TextValidators.instagram(
      _instagramController.text,
    );
    final String? youtubeError = TextValidators.youtube(
      _youtubeController.text,
    );
    final String? whatsappError = TextValidators.whatsapp(
      _whatsappController.text,
    );

    // DOB must be 18+
    final DateTime now = DateTime.now();
    final DateTime eighteenYearsAgo = DateTime(
      now.year - 18,
      now.month,
      now.day,
    );
    final bool dobValid =
        _selectedDob != null && !_selectedDob!.isAfter(eighteenYearsAgo);

    setState(() {
      _usernameValidationError = usernameError;
      _displayNameValidationError = displayNameError;
      _bioValidationError = bioError;
      _instagramValidationError = instagramError;
      _youtubeValidationError = youtubeError;
      _whatsappValidationError = whatsappError;
    });

    // Show specific field errors first for clarity
    if (usernameError != null) {
      AppSnackBar.error(context, usernameError);
      return false;
    }
    if (displayNameError != null) {
      AppSnackBar.error(context, displayNameError);
      return false;
    }
    if (bioError != null) {
      AppSnackBar.error(context, bioError);
      return false;
    }
    if (instagramError != null) {
      AppSnackBar.error(context, instagramError);
      return false;
    }
    if (youtubeError != null) {
      AppSnackBar.error(context, youtubeError);
      return false;
    }
    if (whatsappError != null) {
      AppSnackBar.error(context, whatsappError);
      return false;
    }
    if (!dobValid) {
      AppSnackBar.error(context, 'Please select a valid date of birth (18+).');
      return false;
    }

    // Add gender validation
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      AppSnackBar.error(context, 'Please select your gender.');
      return false;
    }

    // If username changed, ensure availability check passed
    if (_usernameController.text.trim().isNotEmpty &&
        _usernameController.text.trim() !=
            (widget.profile.userName ?? '').trim() &&
        usernameError == null) {
      if (_isCheckingUsername) {
        AppSnackBar.error(
          context,
          'Please wait while we check username availability',
        );
        return false;
      }
      if (!_isUsernameAvailable) {
        AppSnackBar.error(context, 'Username is already taken');
        return false;
      }
    }

    // Username availability checks

    return true;
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final File? imageFile = await ImagePickerUtils.pickAndCropImage(
        context: context,
        maxSizeInMB: 5,
        forceCropAspectRatio: true,
        ratioX: 1,
        ratioY: 1,
        cropStyle: CropStyle.circle,
        imageQuality: 80,
      );

      if (imageFile != null) {
        setState(() {
          _selectedImageFile = imageFile;
        });
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        AppSnackBar.error(context, 'Error picking image: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateProfile() {
    if (!_validateForm()) return;

    // Create updated profile entity with only the fields being edited
    final updatedProfile = ProfileEntity(
      uid: widget.profile.uid,
      displayName: _displayNameController.text.trim(),
      email: widget.profile.email,
      photoUrl: widget.profile.photoUrl, // Keep the original photoUrl, it will be updated by the repository
      userName: _usernameController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _selectedDob,
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      address: _selectedAddress,
      instagramLink: _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
      youtubeLink: _youtubeController.text.trim().isEmpty ? null : _youtubeController.text.trim(),
      whatsappLink: _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
      // Note: Other fields like totalGemCoins, totalRide, interests, referralCode, etc.
      // are not included as they are not being edited in this screen
      // The repository will handle partial updates by only updating non-null fields
    );

    // Dispatch update event to bloc with the selected image file
    context.read<ProfileBloc>().add(UpdateProfileEvent(updatedProfile, profilePhotoImageFile: _selectedImageFile));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          AppSnackBar.success(context, 'Profile updated successfully!');
          Navigator.pop(context, state.profile);
        } else if (state is ProfileError) {
          AppSnackBar.error(context, state.message);
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final bool isUpdating = state is ProfileUpdating;
          
          return Stack(
            children: [
              Scaffold(
                appBar: AppBarWidget(title: 'Edit Profile'),
                body: GestureDetector(
                  onTap: () {
                    // Close keyboard when tapping outside
                    FocusScope.of(context).unfocus();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(screenPadding),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildProfileSection(),
                          const SizedBox(height: 24),
                          _buildUsernameSection(),
                          const SizedBox(height: 24),
                          _buildEmailSection(),
                          const SizedBox(height: 24),
                          _buildDisplayNameSection(),
                          const SizedBox(height: 24),
                          _buildBioSection(),
                          const SizedBox(height: 24),
                          _buildDobSection(),
                          const SizedBox(height: 24),
                          _buildGenderSection(),
                          const SizedBox(height: 24),
                          _buildAddressSection(),
                          const SizedBox(height: 24),
                          _buildInstagramSection(),
                          const SizedBox(height: 24),
                          _buildYoutubeSection(),
                          const SizedBox(height: 24),
                          _buildWhatsappSection(),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            text: isUpdating ? 'Updating...' : 'Update Profile',
                            onPressed: isUpdating ? () {} : _updateProfile,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isUpdating)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileSection() {
    return EditProfilePhotoSection(
      imageUrl: _selectedImageFile != null
          ? _selectedImageFile!.path
          : widget.profile.photoUrl,
      isLoading: _isLoading,
      heroTag: 'edit_profile_image',
      onTap: _pickImage,
    );
  }

  Widget _buildUsernameSection() {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is UsernameAvailabilityResult) {
          setState(() {
            _isUsernameAvailable = state.isAvailable;
            _isCheckingUsername = false;
          });
        } else if (state is ProfileError) {
          setState(() {
            _isCheckingUsername = false;
          });
          AppSnackBar.error(context, state.message);
        }
      },
      child: EditProfileUsernameField(
        controller: _usernameController,
        isChecking: _isCheckingUsername,
        isAvailable: _isUsernameAvailable,
        validationError: _usernameValidationError,
        originalUsername: widget.profile.userName,
        onChanged: _onUsernameChanged,
      ),
    );
  }

  Widget _buildEmailSection() {
    return EditProfileEmailField(email: widget.profile.email);
  }

  Widget _buildDisplayNameSection() {
    return EditProfileDisplayNameField(
      controller: _displayNameController,
      validationError: _displayNameValidationError,
      onChanged: _onDisplayNameChanged,
    );
  }

  Widget _buildBioSection() {
    return EditProfileBioField(
      controller: _bioController,
      validationError: _bioValidationError,
      onChanged: _onBioChanged,
    );
  }

  Widget _buildAddressSection() {
    return EditProfileAddress(
      selectedAddress: _selectedAddress,
      onTap: () async {
        // Navigate to current location picker
        final String? selectedAddress = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => GoogleMapsCurrentLocationPicker(
              onLocationSelected: (String address) {
                // This callback will be called when location is confirmed
                setState(() {
                  _selectedAddress = address;
                });
              },
            ),
          ),
        );

        // Handle the returned address from the picker
        if (selectedAddress != null) {
          setState(() {
            _selectedAddress = selectedAddress;
          });
        }
      },
    );
  }

  Widget _buildGenderSection() {
    return EditProfileGender(
      selectedGender: _selectedGender,
      onTap: () async {
        final String? gender = await _openGenderBottomSheet();
        if (gender != null) {
          setState(() {
            _selectedGender = gender;
          });
        }
      },
    );
  }

  Future<String?> _openGenderBottomSheet() async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Text(
                    'Select Gender',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildGenderOptionTile(
                        context,
                        icon: Icons.male_rounded,
                        title: 'Male',
                        subtitle: 'Identify as male',
                        onTap: () => Navigator.pop(ctx, 'Male'),
                      ),
                      const SizedBox(height: 12),
                      _buildGenderOptionTile(
                        context,
                        icon: Icons.female_rounded,
                        title: 'Female',
                        subtitle: 'Identify as female',
                        onTap: () => Navigator.pop(ctx, 'Female'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Cancel button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenderOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDobSection() {
    return EditProfileDob(
      selectedDate: _selectedDob,
      onTap: () async {
        final DateTime now = DateTime.now();
        final DateTime eighteenYearsAgo = DateTime(
          now.year - 18,
          now.month,
          now.day,
        );
        final DateTime? picked = await DatePickerUtils.pickDate(
          context,
          initialDate: _selectedDob ?? eighteenYearsAgo,
          firstDate: DatePickerUtils.kDefaultFirstDate,
          lastDate: eighteenYearsAgo,
          helpText: 'Select your date of birth',
          confirmText: 'Select',
        );
        if (picked != null) {
          setState(() {
            _selectedDob = DateTime(picked.year, picked.month, picked.day);
          });
        }
      },
    );
  }

  Widget _buildInstagramSection() {
    return EditProfileInstagramField(
      controller: _instagramController,
      validationError: _instagramValidationError,
      onChanged: _onInstagramChanged,
    );
  }

  Widget _buildYoutubeSection() {
    return EditProfileYoutubeField(
      controller: _youtubeController,
      validationError: _youtubeValidationError,
      onChanged: _onYoutubeChanged,
    );
  }

  Widget _buildWhatsappSection() {
    return EditProfileWhatsappField(
      controller: _whatsappController,
      validationError: _whatsappValidationError,
      onChanged: _onWhatsappChanged,
    );
  }
}
