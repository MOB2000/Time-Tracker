import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './email_sign_in_bloc.dart';
import './email_sign_in_model.dart';
import '../../common_widgets/form_submit_button.dart';
import '../../common_widgets/show_alert_dialog.dart';
import '../../services/auth.dart';

class EmailSignInFormBlocBased extends StatefulWidget {
  final EmailSignInBloc bloc;

  EmailSignInFormBlocBased({Key key, this.bloc}) : super(key: key);

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Provider<EmailSignInBloc>(
      create: (_) => EmailSignInBloc(auth: auth),
      dispose: (_, bloc) => bloc.dispose(),
      child: Consumer<EmailSignInBloc>(
        builder: (_, bloc, __) {
          return EmailSignInFormBlocBased(bloc: bloc);
        },
      ),
    );
  }

  @override
  _EmailSignInFormBlocBasedState createState() =>
      _EmailSignInFormBlocBasedState();
}

class _EmailSignInFormBlocBasedState extends State<EmailSignInFormBlocBased> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  void _toggleFormType() {
    widget.bloc.toggleFormType();
    _emailController.clear();
    _passwordController.clear();
  }

  Future<void> _submit() async {
    try {
      await widget.bloc.submit();
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
    return StreamBuilder<EmailSignInModel>(
      stream: widget.bloc.modelStream,
      initialData: EmailSignInModel(),
      builder: (context, snapshot) {
        final model = snapshot.data;
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
                      onChanged: widget.bloc.updateEmail,
                      onEditingComplete: () {
                        final newFocus =
                            model.emailValidator.isValid(model.email)
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
                      onChanged: widget.bloc.updatePassword,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _submit,
                      decoration: InputDecoration(
                        enabled: !model.isLoading,
                        labelText: 'Password',
                        errorText: model.passwordErrorText,
                      ),
                    ),
                    SizedBox(height: 40),
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
      },
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
