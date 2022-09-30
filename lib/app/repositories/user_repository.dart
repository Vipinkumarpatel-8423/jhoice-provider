import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../models/user_model.dart';
import '../providers/laravel_provider.dart';
import '../services/auth_service.dart';

class UserRepository {
  LaravelApiClient _laravelApiClient;
  fba.FirebaseAuth _auth = fba.FirebaseAuth.instance;

  UserRepository() {}

  Future<User> login(User user) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.login(user);
  }

  Future<User> loginSocial(Map<String, dynamic> user) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.loginSocial(user);
  }

  Future<User> get(User user) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.getUser(user);
  }

  Future<User> update(User user) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.updateUser(user);
  }

  Future<User> getCurrentUser() {
    return this.get(Get.find<AuthService>().user.value);
  }

  Future<User> register(User user) async {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return await _laravelApiClient.register(user).then((response) {
      return response;
    }).catchError((error) {
      throw Exception(error.message != null ? error.message : error);
    });
  }

  Future<bool> sendResetLinkEmail(User user) {
    _laravelApiClient = Get.find<LaravelApiClient>();
    return _laravelApiClient.sendResetLinkEmail(user);
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      fba.UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return await signUpWithEmailAndPassword(email, password);
    }
  }

  Future<Map<String, dynamic>> signInGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = fba.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      fba.UserCredential result =
          await fba.FirebaseAuth.instance.signInWithCredential(credential);

      Map<String, dynamic> user = {
        "name": result.user.displayName,
        "email": result.user.email,
        "token": await result.user.getIdToken(),
        "avatar_original": result.user.photoURL,
      };

      return user;
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>> signInFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      print(loginResult.message);

      // Create a credential from the access token
      final fba.OAuthCredential facebookAuthCredential =
          fba.FacebookAuthProvider.credential(loginResult.accessToken.token);

      // Once signed in, return the UserCredential
      fba.UserCredential result = await fba.FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      print(result.user);

      Map<String, dynamic> user = {
        // "name": result.user.displayName,
        // "email": result.user.email,
        // "token": await result.user.getIdToken(),
        // "avatar_original": result.user.photoURL,
      };

      return user;
    } catch (e) {
      print(e);
    }
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    fba.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (result.user != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> verifyPhone(String smsCode) async {
    try {
      final fba.AuthCredential credential = fba.PhoneAuthProvider.credential(
          verificationId: Get.find<AuthService>().user.value.verificationId,
          smsCode: smsCode);
      await fba.FirebaseAuth.instance.signInWithCredential(credential);
      Get.find<AuthService>().user.value.verifiedPhone = true;
    } catch (e) {
      Get.find<AuthService>().user.value.verifiedPhone = false;
      throw Exception(e.toString());
    }
  }

  Future<void> sendCodeToPhone() async {
    Get.find<AuthService>().user.value.verificationId = '';
    final fba.PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {};
    final fba.PhoneCodeSent smsCodeSent =
        (String verId, [int forceCodeResent]) {
      Get.find<AuthService>().user.value.verificationId = verId;
    };
    final fba.PhoneVerificationCompleted _verifiedSuccess =
        (fba.AuthCredential auth) async {};
    final fba.PhoneVerificationFailed _verifyFailed =
        (fba.FirebaseAuthException e) {};
    await _auth.verifyPhoneNumber(
      phoneNumber: Get.find<AuthService>().user.value.phoneNumber,
      timeout: const Duration(seconds: 5),
      verificationCompleted: _verifiedSuccess,
      verificationFailed: _verifyFailed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve,
    );
  }

  Future signOut() async {
    return await _auth.signOut();
  }
}
