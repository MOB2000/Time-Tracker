import 'dart:async';

import 'package:flutter/foundation.dart' show required;
import 'package:rxdart/rxdart.dart';

import './email_sign_in_model.dart';
import '../../services/auth.dart';

class EmailSignInBloc {
  final AuthBase auth;

  EmailSignInBloc({
    @required this.auth,
  });

  final _modelSubject =
      BehaviorSubject<EmailSignInModel>.seeded(EmailSignInModel());

  Stream<EmailSignInModel> get modelStream => _modelSubject.stream;

  EmailSignInModel get _model => _modelSubject.value;

  Future<void> submit() async {
    updateWith(isLoading: true, isSubmitted: true);
    try {
      _model.formType == EmailSignInFormType.signIn
          ? await auth.signInWithEmailAndPassword(_model.email, _model.password)
          : await auth.createUserWithEmailAndPassword(
              _model.email, _model.password);
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void toggleFormType() {
    final newFormType = _model.formType == EmailSignInFormType.signIn
        ? EmailSignInFormType.register
        : EmailSignInFormType.signIn;
    updateWith(
      email: '',
      password: '',
      formType: newFormType,
      isLoading: false,
      isSubmitted: false,
    );
  }

  void updateEmail(String newEmail) => updateWith(email: newEmail);

  void updatePassword(String newPassword) => updateWith(password: newPassword);

  void updateWith({
    String email,
    String password,
    EmailSignInFormType formType,
    bool isLoading,
    bool isSubmitted,
  }) {
    _modelSubject.value = _model.copyWith(
      email: email,
      password: password,
      formType: formType,
      isLoading: isLoading,
      isSubmitted: isSubmitted,
    );
  }

  void dispose() {
    _modelSubject.close();
  }
}
