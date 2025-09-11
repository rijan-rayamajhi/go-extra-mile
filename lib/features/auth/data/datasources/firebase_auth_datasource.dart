import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/error/exceptions.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  FirebaseAuthDataSource({
    required this.firebaseAuth,
    required this.googleSignIn,
  }) {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      if (googleSignIn.supportsAuthenticate()) { 
        // Initialize Google Sign-In with serverClientId for Android
        // This is required for proper authentication flow on Android
        await googleSignIn.initialize(
          serverClientId: '780810782870-06q24ca9q0vukqm4fe1bo7igbal9pmh0.apps.googleusercontent.com',
        );
      }
    } catch (e) {
      //ignore error
    }
  }

  // GOOGLE SIGN-IN
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      return user;
    } catch (e) {
      throw AuthenticationException('Google Sign-In failed: ${e.toString()}');
    }
  }

  // APPLE SIGN-IN
  Future<User?> signInWithApple() async {
    try {
      // Check if Apple Sign-In is available
      if (!await SignInWithApple.isAvailable()) {
        throw AuthenticationException('Apple Sign-In is not available on this device');
      }
      
      // Request Apple credential
      log(' 🔄 Requesting Apple credential...');
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      // Validate that we got the required tokens
      if (appleCredential.identityToken == null) {
        throw AuthenticationException('Apple Sign-In failed: No identity token received');
      }

      // Create Firebase credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in with Firebase
      final userCredential = await firebaseAuth.signInWithCredential(oauthCredential);
      final user = userCredential.user;
      return user;
    } catch (e) {
        throw AuthenticationException('Apple Sign-In failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }
}
