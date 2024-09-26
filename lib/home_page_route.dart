import 'package:flutter/material.dart';
import 'jwt.dart';
import 'login_route.dart';
import 'record_list_route.dart';

class HomePageRoute extends StatefulWidget {
  const HomePageRoute({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePageRoute> createState() => _HomePageRouteState();
}

class _HomePageRouteState extends State<HomePageRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<bool>(
          future: testLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              WidgetsBinding.instance!.addPostFrameCallback(
                (_) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RecordListRoute()),
                ),
              );
            } else {
              WidgetsBinding.instance!.addPostFrameCallback(
                (_) => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginRoute()),
                ),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: CircularProgressIndicator());
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Future<bool> testLoggedIn() async {
    try {
      await JWT().refreshToken();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
