import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthResult {
  final String idToken;
  final String email;
  final String? displayName;
  final String? photoUrl;

  GoogleAuthResult({
    required this.idToken,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await _googleSignIn.initialize(
      serverClientId:
          '738539470201-7kabsdci5eklo42agtc773gc7k6ssguv.apps.googleusercontent.com',
    );

    _initialized = true;
  }

  Future<GoogleAuthResult?> signIn() async {
    try {
      await initialize();

      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication authentication = account.authentication;

      final String? idToken = authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google did not return an ID token.');
      }

      return GoogleAuthResult(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } catch (e) {
      print('GOOGLE SIGN-IN ERROR: $e');
      rethrow;
    }
  }

  // Future<void> signOut() async {
  //   try {
  //     await _googleSignIn.signOut();
  //   } catch (e) {
  //     print('GOOGLE SIGN-OUT ERROR: $e');
  //   }
  // }
}
