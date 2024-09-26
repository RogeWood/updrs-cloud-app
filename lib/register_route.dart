import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:se_project/config.dart';
import 'jwt.dart';

class RegisterRoute extends StatelessWidget {
  const RegisterRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("註冊"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RegisterForm(title: '註冊')));
  }
}

class RegisterForm extends StatefulWidget {
  final String title;

  // ignore: prefer_const_constructors_in_immutables
  RegisterForm({Key? key, required this.title}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterForm();
}

class _RegisterForm extends State<RegisterForm> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final repasswordController = TextEditingController();
  bool registerBtnDisable = false;

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
        TextFormField(
          controller: repasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            icon: Icon(Icons.lock),
            hintText: '確認密碼',
            labelText: 'Confirm password',
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
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
          child: InkWell(
            child: Text(
              '使用者條款',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
            onTap: () {
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('使用者條款'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: const <Widget>[
                          Text(
                              '這個功能還沒實做，但是我相信你才不會看啦。簡單來說，你同意我們以任何方式處理你的資料，並且沒有任何保障。'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('我同意'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 35),
            ),

            // 註冊成功失敗判別
            onPressed: registerBtnDisable
                ? null
                : () async {
                    setState(() {
                      registerBtnDisable = true;
                    });
                    if (passwordController.text == '') {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            // Retrieve the text the that user has entered by using the
                            // TextEditingController.
                            title: const Text('密碼不可為空!'),

                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("好"))
                            ],
                          );
                        },
                      );
                    } else if (repasswordController.text !=
                        passwordController.text) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('密碼確認錯誤!'),
                            content: const Text("請確你輸入了兩次一樣的密碼！"),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("好"))
                            ],
                          );
                        },
                      );
                    } else if (usernameController.text == '') {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            // Retrieve the text the that user has entered by using the
                            // TextEditingController.
                            content: const Text("請輸入帳號!"),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("好"))
                            ],
                          );
                        },
                      );
                    } else {
                      //註冊資料存到SQL
                      setState(() {
                        registerBtnDisable = true;
                      });
                      var response = await http
                          .post(Uri.parse("${Config.baseUrl}/user"), body: {
                        "username": usernameController.text,
                        "password": passwordController.text
                      });
                      if (response.statusCode == 201) {
                        // created
                        showDialog(
                            context: context,
                            builder: (var context) => AlertDialog(
                                  title: const Text("註冊成功！"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.popUntil(context,
                                              (route) => route.isFirst);
                                        },
                                        child: const Text("太好了！"))
                                  ],
                                ));
                      } else if (response.statusCode == 409) {
                        showDialog(
                            context: context,
                            builder: (var context) => AlertDialog(
                                  title: const Text("帳號被人用過啦！"),
                                  content: const Text("換個帳號名稱"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("好"))
                                  ],
                                ));
                        setState(() {
                          registerBtnDisable = false;
                        });
                      } else {
                        showDialog(
                            context: context,
                            builder: (var context) => AlertDialog(
                                  title: const Text("不知道哪裡出錯啦！"),
                                  content: const Text("換個帳號名稱，或是密碼試試看"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("好"))
                                  ],
                                ));
                        setState(() {
                          registerBtnDisable = false;
                        });
                      }
                    }
                    setState(() {
                      registerBtnDisable = false;
                    });
                  },
            child: Text(registerBtnDisable ? "註冊中，請稍後..." : "註冊"),
          ),
        ),
      ],
    );
  }
}
