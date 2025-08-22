import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'user_firestore_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final UserFirestoreDataSource userFirestoreDataSource;

  FirebaseAuthDataSource({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.userFirestoreDataSource,
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
      log(' signInWithGoogle ');
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      log(googleUser.toString());
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userModel = UserModel.fromFirebaseUser(user);
        await userFirestoreDataSource.createOrUpdateUserProfile(user: userModel);
      }

      return user;
    } catch (e) {
      log(' ❌ signInWithGoogle error: $e ');
      if (e is AccountDeletedException) rethrow;
      throw AuthenticationException('Google Sign-In failed: ${e.toString()}');
    }
  }

  // APPLE SIGN-IN
  Future<User?> signInWithApple() async {
    log(' ✅ signInWithApple datasource called ');
    try {
      // Check if Apple Sign-In is available
      if (!await SignInWithApple.isAvailable()) {
        log(' ❌ Apple Sign-In is not available on this device');
        throw AuthenticationException('Apple Sign-In is not available on this device');
      }
      log(' ✅ Apple Sign-In is available ');
      
      // Request Apple credential
      log(' 🔄 Requesting Apple credential...');
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      log(' ✅ Apple credential received: ${appleCredential.identityToken != null ? 'Has ID token' : 'No ID token'}');
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

      if (user != null) {
        // Build user model with proper fallbacks
        String email = user.email ?? appleCredential.email ?? '';
        String displayName = user.displayName ?? '';
        
        // If no display name from Firebase, try to construct from Apple credential
        if (displayName.isEmpty && (appleCredential.givenName != null || appleCredential.familyName != null)) {
          final givenName = appleCredential.givenName ?? '';
          final familyName = appleCredential.familyName ?? '';
          displayName = '${givenName} ${familyName}'.trim();
        }

        final userModel = UserModel(
          uid: user.uid,
          email: email,
          displayName: displayName.isNotEmpty ? displayName : 'Apple User',
          photoUrl: user.photoURL,
        );

        await userFirestoreDataSource.createOrUpdateUserProfile(user: userModel);
      }

      return user;
    } catch (e) {
      log(' ✅ error: $e ');
      
      // Handle specific Apple Sign-In errors
      if (e is SignInWithAppleAuthorizationException) {
        // Log the specific error code for debugging
        log('Apple Sign-In error code: ${e.code}');
        
        if (e.code == 1) { // canceled
          throw AuthenticationException('Apple Sign-In was cancelled');
        } else if (e.code == 1000) { // unknown
          throw AuthenticationException('Apple Sign-In failed: Please try again or check your Apple ID settings');
        }
      }
      
      // Re-throw other exceptions
      throw AuthenticationException('Apple Sign-In failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  User? getCurrentUser() => firebaseAuth.currentUser;
}
