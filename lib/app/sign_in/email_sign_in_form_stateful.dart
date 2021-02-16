import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './email_sign_in_model.dart' show EmailSignInFormType;
import './validators.dart';
import '../../common_widgets/form_submit_button.dart';
import '../../common_widgets/show_alert_dialog.dart';
import '../../services/auth.dart';

class EmailSignInFormStateful extends StatefulWidget {
  final void Function() onSignedIn;

  const EmailSignInFormStateful({@required this.onSignedIn});

  @override
  _EmailSignInFormStatefulState createState() =>
      _EmailSignInFormStatefulState();
}

class _EmailSignInFormStatefulState extends State<EmailSignInFormStateful>
    with EmailAndPasswordValidators {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();

  final _passwordFocusNode = FocusNode();

  String get _email => _emailController.text;

  String get _password => _passwordController.text;

  EmailSignInFormType _formType = EmailSignInFormType.signIn;

  bool _submitted = false;

  bool _isLoading = false;

  void _toggleFormType() {
    setState(() {
      _submitted = false;
      _formType = _formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.register
          : EmailSignInFormType.signIn;
    });
    _emailController.clear();
    _passwordController.clear();
  }

  Future<void> _submit(AuthBase auth) async {
    setState(() {
      _submitted = true;
      _isLoading = true;
    });
    try {
      _formType == EmailSignInFormType.signIn
          ? await auth.signInWithEmailAndPassword(_email, _password)
          : await auth.createUserWithEmailAndPassword(_email, _password);
      widget.onSignedIn();
    } on FirebaseAuthException catch (e) {
      showAlertDialog(
        context,
        title: 'Sign in failed',
        content: e.message,
        defaultActionText: 'OK',
      );
    } finally {
      _isLoading = false;
    }
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);

    final primaryText = _formType == EmailSignInFormType.signIn
        ? 'Sign in'
        : 'Create an account';
    final secondaryText = _formType == EmailSignInFormType.signIn
        ? 'Need an account? Register'
        : 'Have an account? Sign in';
    bool submitEnabled = !_isLoading &&
        emailValidator.isValid(_email) &&
        passwordValidator.isValid(_password);
    void _updateEnable() {
      setState(() {});
    }

    bool emailError = _submitted && !emailValidator.isValid(_email);
    bool passwordError = _submitted && !passwordValidator.isValid(_password);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  key: Key('email'),
                  controller: _emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  focusNode: _emailFocusNode,
                  onChanged: (newValue) => _updateEnable(),
                  onEditingComplete: () {
                    final newFocus = emailValidator.isValid(_email)
                        ? _passwordFocusNode
                        : _emailFocusNode;
                    FocusScope.of(context).requestFocus(newFocus);
                  },
                  decoration: InputDecoration(
                    enabled: !_isLoading,
                    labelText: 'Email',
                    hintText: 'test@test.com',
                    errorText: emailError ? invalidEmailErrorText : null,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  key: Key('password'),
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  onChanged: (newValue) => _updateEnable(),
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () => _submit(auth),
                  decoration: InputDecoration(
                    enabled: !_isLoading,
                    labelText: 'Password',
                    errorText: passwordError ? invalidPasswordErrorText : null,
                  ),
                ),
                SizedBox(height: 40),
                FormSubmitButton(
                  text: primaryText,
                  onPressed: submitEnabled ? () => _submit(auth) : null,
                ),
                SizedBox(height: 20),
                TextButton(
                  child: Text(secondaryText),
                  onPressed: _isLoading ? null : _toggleFormType,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
