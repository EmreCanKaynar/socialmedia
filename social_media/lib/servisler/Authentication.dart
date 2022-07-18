import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<FirebaseUser> signInEmailAndPassword(
      String email, String password) async {
    var result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<FirebaseUser> onStateChanged() {
    return _auth.onAuthStateChanged;
  }

  Future<FirebaseUser> signUpWithEmailAndPassword(
      String email, String password) async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  Future<FirebaseUser> SignInWithGoogle() async {
    GoogleSignInAccount googleHesabi = await GoogleSignIn().signIn();
    GoogleSignInAuthentication yetkiKarti = await googleHesabi.authentication;
    AuthCredential kimlikBilgileri = GoogleAuthProvider.getCredential(
        idToken: yetkiKarti.idToken, accessToken: yetkiKarti.accessToken);
    AuthResult user = await _auth.signInWithCredential(kimlikBilgileri);
    return user.user;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
