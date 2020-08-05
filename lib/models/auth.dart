import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import '../utils.dart';
import '../constants.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _currentUser;

  Future<void> init() async {
    _currentUser = await _auth.currentUser();
    if (_currentUser == null && await isInternetConnected()) {
      await _signInAnonymously();
    }
  }

  String getUid() => _currentUser != null ? _currentUser.uid : null;
  bool isAnonymous() => _currentUser == null || _currentUser.isAnonymous;
  String getAvatarUrl() => _currentUser.isAnonymous
      ? kNoAvatarUrl
      : _currentUser.providerData[0].photoUrl;
  String getDisplayName() => _currentUser.providerData[0].displayName;
  String getEmail() => _currentUser.providerData[0].email;

  Future<void> _signInAnonymously() async {
    final FirebaseUser user = (await _auth.signInAnonymously()).user;
    _currentUser = user;
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    _currentUser = user;
  }

  Future<void> signInWithFacebook() async {
    final FacebookLogin facebookLogin = FacebookLogin();
    final FacebookLoginResult result = await facebookLogin.logIn(['email']);

    if (result.status == FacebookLoginStatus.loggedIn) {
      final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: result.accessToken.token,
      );
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      _currentUser = user;
    } else if (result.status == FacebookLoginStatus.error) {
      print(result.errorMessage);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
  }

  void printUser() {
    print('isAnonymous: ${_currentUser.isAnonymous}');
    if (!_currentUser.isAnonymous) {
      print('providerId: ${_currentUser.providerData[0].providerId}');
      print('displayName: ${_currentUser.providerData[0].displayName}');
      print('email: ${_currentUser.providerData[0].email}');
      print('photoUrl: ${_currentUser.providerData[0].photoUrl}');
    }
  }
}
