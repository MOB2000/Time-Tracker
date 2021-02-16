import 'package:flutter/foundation.dart' show ChangeNotifier, required;
import 'package:time_tracker/services/auth.dart';

import './validators.dart';

enum EmailSignInFormType { signIn, register }

class EmailSignInChangeModel with ChangeNotifier, EmailAndPasswordValidators {
  String email;
  String password;
  EmailSignInFormType formType;
  bool isLoading;
  bool isSubmitted;
  final AuthBase auth;

  EmailSignInChangeModel({
    @required this.auth,
    this.email = '',
    this.password = '',
    this.formType = EmailSignInFormType.signIn,
    this.isLoading = false,
    this.isSubmitted = false,
  });

  String get primaryText =>
      formType == EmailSignInFormType.signIn ? 'Sign in' : 'Create an account';

  String get secondaryText => formType == EmailSignInFormType.signIn
      ? 'Need an account? Register'
      : 'Have an account? Sign in';

  bool get emailError => isSubmitted && !emailValidator.isValid(email);

  bool get passwordError => isSubmitted && !passwordValidator.isValid(password);

  String get passwordErrorText =>
      passwordError ? invalidPasswordErrorText : null;

  String get emailErrorText => emailError ? invalidEmailErrorText : null;

  bool get submitEnabled =>
      !isLoading &&
      emailValidator.isValid(email) &&
      passwordValidator.isValid(password);

  void updateWith({
    String email,
    String password,
    EmailSignInFormType formType,
    bool isLoading,
    bool isSubmitted,
  }) {
    this.email = email ?? this.email;
    this.password = password ?? this.password;
    this.formType = formType ?? this.formType;
    this.isLoading = isLoading ?? this.isLoading;
    this.isSubmitted = isSubmitted ?? this.isSubmitted;
    notifyListeners();
  }

  void toggleFormType() {
    final newFormType = this.formType == EmailSignInFormType.signIn
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

  Future<void> submit() async {
    updateWith(isLoading: true, isSubmitted: true);
    try {
      this.formType == EmailSignInFormType.signIn
          ? await auth.signInWithEmailAndPassword(this.email, this.password)
          : await auth.createUserWithEmailAndPassword(
              this.email, this.password);
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }
}
