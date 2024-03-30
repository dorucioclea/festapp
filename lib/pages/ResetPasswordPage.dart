import 'package:easy_localization/easy_localization.dart';
import 'package:festapp/RouterService.dart';
import 'package:festapp/appConfig.dart';
import 'package:festapp/data/DataService.dart';
import 'package:festapp/services/ToastHelper.dart';
import 'package:festapp/styles/Styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class ResetPasswordPage extends StatefulWidget {
  static const ROUTE = "resetPassword";

  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    var currentUri = RouterService.getCurrentUri();
    var regExp = RegExp("refresh_token=(?<refresh_token>[^&]+)");
    var regExpMatch = regExp.firstMatch(currentUri.toString());

    if (regExpMatch != null) {
      try {
        var groupName = regExpMatch.namedGroup("refresh_token")!;
        await Supabase.instance.client.auth.setSession(groupName);
      } on Exception catch (e) {
        ToastHelper.Show(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Reset password").tr(),
        leading: BackButton(
          onPressed: () => RouterService.goBackOrInitial(context),
        ),
      ),
      body: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: appMaxWidth),
          child: SingleChildScrollView(
              child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                children: <Widget>[
                  Text("Welcome in {name}!".tr(namedArgs: {"name":AppConfig.appName}), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  const SizedBox(
                    height: 16,
                  ),
                  Text("Create a new password to continue.".tr(), style: const TextStyle(fontSize: 18),),
                  const SizedBox(
                    height: 64,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextFormField(
                        controller: _passwordController,
                        autofillHints: const [AutofillHints.password],
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: "New Password".tr()),
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return "Fill the password!".tr();
                          }
                        },
                      )),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                        color: AppConfig.color1,
                        borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          TextInput.finishAutofillContext();
                          await DataService.changeMyPassword(
                                  _passwordController.text)
                              .then((value) {
                            ToastHelper.Show("Password has been changed.".tr());
                            RouterService.goBackOrInitial(context);
                          }).onError((error, stackTrace) {
                            ToastHelper.Show(error.toString());
                          });
                        }
                      },
                      child: const Text(
                        "Change Password",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ).tr(),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}