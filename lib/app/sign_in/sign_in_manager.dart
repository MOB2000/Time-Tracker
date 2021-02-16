import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show ValueNotifier, required;
import 'package:time_tracker/services/auth.dart';

class SignInManager {
  final AuthBase auth;
  final ValueNotifier<bool> isLoading;

  SignInManager({@required this.auth, @required this.isLoading});

  Future<User> signIn(Future<User> Function() signInMethod) async {
    try {
      isLoading.value = true;
      return await signInMethod();
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  Future<User> signInWithGoogle() async => signIn(auth.signInWithGoogle);

  Future<User> signInWithFacebook() async => signIn(auth.signInWithFacebook);

  Future<User> signInAnonymously() async => signIn(auth.signInAnonymously);
}
