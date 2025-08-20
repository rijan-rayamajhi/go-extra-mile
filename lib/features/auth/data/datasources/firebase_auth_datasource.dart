import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    // Initialize GoogleSignIn if needed
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      // Try to initialize if the method exists and is needed
      if (googleSignIn.supportsAuthenticate()) {
        // Initialization is implicit in v7.x
      }
    } catch (e) {
      // Ignore initialization errors - not all platforms require explicit init
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Sign-In flow using authenticate()
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // 2. Get auth tokens - in v7.x we only get idToken from authentication
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 3. For Firebase auth, we can use just the idToken
      // Firebase will handle the credential creation internally
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // Note: accessToken not available in v7.x GoogleSignInAuthentication
        // Use authorization client if you need access tokens for API calls
      );

      // 4. Sign in with Firebase
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        // 6. Store/update user data in Firestore after successful authentication
        final userModel = UserModel.fromFirebaseUser(user);
        await userFirestoreDataSource.createOrUpdateUserProfile(user: userModel);
      }
      
      return user;
    } catch (e) {
      // Handle any authentication errors
      if (e is AccountDeletedException) {
        // Re-throw the account deleted exception
        rethrow;
      }
      throw AuthenticationException('Google Sign-In failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  User? getCurrentUser() => firebaseAuth.currentUser;
}
