import 'package:flutter/material.dart';
import 'home_page_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '帕金森氏症雲端檢測服務',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePageRoute(title: '帕金森氏症雲端檢測服務'),
    );
  }
}
