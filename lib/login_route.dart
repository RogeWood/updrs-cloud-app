import 'package:flutter/material.dart';
import 'package:se_project/record_list_route.dart';

import 'jwt.dart';
import 'register_route.dart';

class LoginRoute extends StatelessWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("登入"),
          automaticallyImplyLeading: false,
        ),
        body: const Padding(
            padding: EdgeInsets.all(8.0), child: LoginForm(title: "登入")));
  }
}

class LoginForm extends StatefulWidget {
  final String title;

  const LoginForm({Key? key, required this.title}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginForm();
}

class _LoginForm extends State<LoginForm> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool loginBtnDisable = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // username
        TextFormField(
          controller: usernameController,
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            hintText: '請輸入你的帳號',
            labelText: 'Username',
          ),
          onSaved: (String? value) {
            // This optional block of code can be used to run
            // code when the user saves the form.
          },
          validator: (String? value) {
            return (value != null && value != "") ? '必填' : null;
          },
        ),
        // password
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            icon: Icon(Icons.lock),
            hintText: '請輸入你的密碼',
            labelText: 'Password',
          ),
          onSaved: (String? value) {
            // This optional block of code can be used to run
            // code when the user saves the form.
          },
          validator: (String? value) {
            return (value != null && value != "") ? '必填' : null;
          },
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 35),
            ),
            onPressed: loginBtnDisable
                ? null
                : () {
                    setState(() {
                      loginBtnDisable = true;
                    });
                    JWT()
                        .login(usernameController.text, passwordController.text)
                        .then((value) {
                      setState(() {
                        loginBtnDisable = false;
                      });
                      if (value) {
                        //go to home page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RecordListRoute()),
                        );
                      } else {
                        setState(() {
                          loginBtnDisable = false;
                        });
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              // Retrieve the text the that user has entered by using the
                              // TextEditingController.
                              content: const Text("登入失敗！"),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("好"))
                              ],
                            );
                          },
                        );
                      }
                    }).onError((error, stackTrace) {
                      setState(() {
                        loginBtnDisable = false;
                      });
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            // Retrieve the text the that user has entered by using the
                            // TextEditingController.
                            content: Text("登入失敗！ " + error.toString()),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("好"))
                            ],
                          );
                        },
                      );
                    });
                  },
            child: Text(loginBtnDisable ? "登入中，請稍後..." : "登入"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 35),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterRoute()),
              );
            },
            child: const Text("註冊"),
          ),
        ),
      ],
    );
  }
}
