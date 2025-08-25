class TextValidators {

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (!RegExp(pattern).hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    if (trimmedValue.length > 20) {
      return 'Username must be less than 20 characters';
    }
    
    // Allow letters, numbers, dots, and underscores (similar to Gmail)
    // Must start with a letter or number
    // Cannot start or end with dots or underscores
    const pattern = r'^[a-zA-Z0-9][a-zA-Z0-9._]*[a-zA-Z0-9]$';
    if (!RegExp(pattern).hasMatch(trimmedValue)) {
      return 'Username can only contain letters, numbers, dots, and underscores. Must start and end with a letter or number.';
    }
    
    // Check for consecutive dots or underscores
    if (trimmedValue.contains('..') || trimmedValue.contains('__') || trimmedValue.contains('._') || trimmedValue.contains('._')) {
      return 'Username cannot contain consecutive dots or underscores';
    }
    
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required';
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 2) {
      return 'Display name must be at least 2 characters long';
    }
    
    if (trimmedValue.length > 50) {
      return 'Display name must be less than 50 characters';
    }
    
    // Check if it starts and ends with alphanumeric
    if (!RegExp(r'^[a-zA-Z0-9]').hasMatch(trimmedValue) || 
        !RegExp(r'[a-zA-Z0-9]$').hasMatch(trimmedValue)) {
      return 'Display name must start and end with a letter or number';
    }
    
    // Check for consecutive spaces
    if (trimmedValue.contains('  ')) {
      return 'Display name cannot contain consecutive spaces';
    }
    
    // Check for invalid characters
    if (RegExp(r'[^a-zA-Z0-9\s\''-.]').hasMatch(trimmedValue)) {
      return 'Display name can only contain letters, numbers, spaces, apostrophes, hyphens, and periods';
    }
    
    return null;
  }


  static String? bio(String? value) {
    // Bio is optional; validate only when provided
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final trimmedValue = value.trim();
    const int maxLength = 160;

    if (trimmedValue.length > maxLength) {
      return 'Bio must be $maxLength characters or less';
    }

    return null;
  }

  static String? gender(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Gender is required';
    }
    return null;
  }

  static String? instagram(String? value) {
    // Instagram is optional; validate only when provided
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final trimmedValue = value.trim();
    
    // Instagram URL format: https://www.instagram.com/username/
    // or just username (for backward compatibility)
    if (trimmedValue.startsWith('http')) {
      // Full URL validation
      final urlPattern = r'^https?://(?:www\.)?instagram\.com/[a-zA-Z0-9._]+\/?$';
      if (!RegExp(urlPattern).hasMatch(trimmedValue)) {
        return 'Please enter a valid Instagram profile URL';
      }
    } else {
      // Username validation (for backward compatibility)
      const pattern = r'^[a-zA-Z0-9._]+$';
      if (!RegExp(pattern).hasMatch(trimmedValue)) {
        return 'Instagram username can only contain letters, numbers, periods, and underscores';
      }
      
      if (trimmedValue.isEmpty) {
        return 'Instagram username must be at least 1 character';
      }
      
      if (trimmedValue.length > 30) {
        return 'Instagram username must be 30 characters or less';
      }
      
      if (trimmedValue.startsWith('.') || trimmedValue.endsWith('.')) {
        return 'Instagram username cannot start or end with a period';
      }
      
      if (trimmedValue.contains('..')) {
        return 'Instagram username cannot contain consecutive periods';
      }
    }
    
    return null;
  }

  static String? youtube(String? value) {
    // YouTube is optional; validate only when provided
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final trimmedValue = value.trim();
    
    // YouTube URL format: https://www.youtube.com/@username or https://www.youtube.com/c/username
    // or just username (for backward compatibility)
    if (trimmedValue.startsWith('http')) {
      // Full URL validation
      final urlPattern = r'^https?://(?:www\.)?youtube\.com/(?:@|c/|channel/)[a-zA-Z0-9\-\_]+/?$';
      if (!RegExp(urlPattern).hasMatch(trimmedValue)) {
        return 'Please enter a valid YouTube channel URL';
      }
    } else {
      // Username validation (for backward compatibility)
      const pattern = r'^[a-zA-Z0-9\s\-_]+$';
      if (!RegExp(pattern).hasMatch(trimmedValue)) {
        return 'YouTube channel name can only contain letters, numbers, spaces, hyphens, and underscores';
      }
      
      if (trimmedValue.length < 3) {
        return 'YouTube channel name must be at least 3 characters';
      }
      
      if (trimmedValue.length > 50) {
        return 'YouTube channel name must be 50 characters or less';
      }
      
      if (trimmedValue.startsWith(' ') || trimmedValue.endsWith(' ')) {
        return 'YouTube channel name cannot start or end with a space';
      }
      
      if (trimmedValue.contains('  ')) {
        return 'YouTube channel name cannot contain consecutive spaces';
      }
    }
    
    return null;
  }

  static String? whatsapp(String? value) {
    // WhatsApp is optional; validate only when provided
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final trimmedValue = value.trim();
    
    // Phone number validation - exactly 10 digits without country code
    const pattern = r'^[0-9]{10}$';
    if (!RegExp(pattern).hasMatch(trimmedValue)) {
      return 'WhatsApp number must be exactly 10 digits without country code';
    }
    
    return null;
  }

  static String? rideTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ride title is required';
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 3) {
      return 'Ride title must be at least 3 characters long';
    }
    
    if (trimmedValue.length > 100) {
      return 'Ride title must be less than 100 characters';
    }
    
    // Check if it starts and ends with alphanumeric
    if (!RegExp(r'^[a-zA-Z0-9]').hasMatch(trimmedValue) || 
        !RegExp(r'[a-zA-Z0-9]$').hasMatch(trimmedValue)) {
      return 'Ride title must start and end with a letter or number';
    }
    
    // Check for consecutive spaces
    if (trimmedValue.contains('  ')) {
      return 'Ride title cannot contain consecutive spaces';
    }
    
    // Check for invalid characters
    if (RegExp(r'[^a-zA-Z0-9\s\''-.]').hasMatch(trimmedValue)) {
      return 'Ride title can only contain letters, numbers, spaces, apostrophes, hyphens, and periods';
    }
    
    return null;
  }

  static String? rideDescription(String? value) {
    // Description is optional; validate only when provided
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final trimmedValue = value.trim();
    const int maxLength = 500;

    if (trimmedValue.length > maxLength) {
      return 'Description must be $maxLength characters or less';
    }
    
    // Check for consecutive spaces
    if (trimmedValue.contains('  ')) {
      return 'Description cannot contain consecutive spaces';
    }
    
    // Check for invalid characters
    if (RegExp(r'[^a-zA-Z0-9\s\''-.,!?]').hasMatch(trimmedValue)) {
      return 'Description can only contain letters, numbers, spaces, apostrophes, hyphens, periods, commas, exclamation marks, and question marks';
    }
    
    return null;
  }

  static String? vehicleRegistrationNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vehicle registration number is required';
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 4) {
      return 'Vehicle registration number must be at least 4 characters long';
    }
    
    if (trimmedValue.length > 15) {
      return 'Vehicle registration number must be less than 15 characters';
    }
    
    // Allow only numbers
    const pattern = r'^[0-9]+$';
    if (!RegExp(pattern).hasMatch(trimmedValue)) {
      return 'Vehicle registration number can only contain numbers';
    }
    
    return null;
  }
} 