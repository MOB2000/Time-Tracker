import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './email_sign_in_change_model.dart';
import '../../common_widgets/form_submit_button.dart';
import '../../common_widgets/show_alert_dialog.dart';
import '../../services/auth.dart';

class EmailSignInFormChangeNotifier extends StatefulWidget {
  final EmailSignInChangeModel model;

  EmailSignInFormChangeNotifier({Key key, this.model}) : super(key: key);

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);

    return ChangeNotifierProvider<EmailSignInChangeModel>(
      create: (_) => EmailSignInChangeModel(
        auth: auth,
      ),
      child: Consumer<EmailSignInChangeModel>(
        builder: (_, model, __) => EmailSignInFormChangeNotifier(
          model: model,
        ),
      ),
    );
  }

  @override
  _EmailSignInFormChangeNotifierState createState() =>
      _EmailSignInFormChangeNotifierState();
}

class _EmailSignInFormChangeNotifierState
    extends State<EmailSignInFormChangeNotifier> {
  EmailSignInChangeModel get model => widget.model;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  void _toggleFormType() {
    model.toggleFormType();
    _emailController.clear();
    _passwordController.clear();
  }

  Future<void> _submit() async {
    try {
      await model.submit();
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      showAlertDialog(
        context,
        title: 'Sign in failed',
        content: e.message,
        defaultActionText: 'OK',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  onChanged: model.updateEmail,
                  onEditingComplete: () {
                    final newFocus = model.emailValidator.isValid(model.email)
                        ? _passwordFocusNode
                        : _emailFocusNode;
                    FocusScope.of(context).requestFocus(newFocus);
                  },
                  decoration: InputDecoration(
                    enabled: !model.isLoading,
                    labelText: 'Email',
                    hintText: 'test@test.com',
                    errorText: model.emailErrorText,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  onChanged: model.updatePassword,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _submit,
                  decoration: InputDecoration(
                    enabled: !model.isLoading,
                    labelText: 'Password',
                    errorText: model.passwordErrorText,
                  ),
                ),
                SizedBox(height: 60),
                FormSubmitButton(
                  text: model.primaryText,
                  onPressed: model.submitEnabled ? _submit : null,
                ),
                SizedBox(height: 20),
                TextButton(
                  child: Text(model.secondaryText),
                  onPressed: model.isLoading ? null : _toggleFormType,
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
