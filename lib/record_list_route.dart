import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:se_project/record_detail_route.dart';
import 'package:se_project/record_utils.dart';

import 'camera_route.dart';
import 'home_page_route.dart';
import 'config.dart';
import 'jwt.dart';

class RecordListRoute extends StatelessWidget {
  RecordListRoute({Key? key}) : super(key: key);
  final _ListRecord _listRecord = _ListRecord();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("檢測紀錄"),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          // Add video
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RecordingScreen()),
              );
            },
          ),

          // Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await JWT().logout();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePageRoute(
                    title: '',
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Center(child: RecordList()),
    );
  }
}

class RecordList extends StatefulWidget {
  RecordList({Key? key}) : super(key: key);

  @override
  State<RecordList> createState() => _ListRecord();
}

class _ListRecord extends State<RecordList> {
  bool lock = false;
  String? nextUrl = "${Config.baseUrl}/updrs/record";

  final ScrollController _controller = ScrollController();
  bool showToTopBtn = false; //是否显示“返回到顶部”按钮

  //列表集合資料
  final List records = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    records.clear();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Scrollbar(
          child: Center(
        child: FutureBuilder(
            future: fetchRecords(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return Text(snapshot.error.toString());
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: records.length,
                  controller: _controller,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RecordDetailRoute(
                                    recordId: records[index]["video_id"])));
                      },
                      title: Text(
                          "${DateFormat("yyyy-MM-dd hh:mm").format(DateTime.parse(records[index]["created_at"]).toLocal()).toString()} "),
                      subtitle:
                          Text('狀態：${recordStatus[records[index]["state"]]}'),
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            }),
      )),
      floatingActionButton: !showToTopBtn
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.arrow_upward),
              onPressed: () {
                //返回到顶部时执行动画
                _controller.animateTo(
                  .0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,
                );
              }),
    );
  }

  _scrollListener() {
    if (_controller.position.maxScrollExtent - _controller.offset < 200) {
      // print("bottom!");
      fetchRecords();
    }
  }

  Future<bool> fetchRecords() async {
    if (nextUrl == null) return false;
    if (lock) {
      // print("locked");
      return false;
    }
    lock = true;
    Uri uri = Uri.parse(nextUrl!);
    String token = JWT().token;
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode > 299) {
      lock = false;
      print("something went wrong");
      // something went wrong here
      return false;
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    nextUrl = body["next"];
    lock = false;
    final newRecords = body["data"];
    if (newRecords != null) {
      setState(() {
        records.addAll(newRecords);
      });
    }

    if (nextUrl == null) {
      return true;
    }
    // print(nextUrl);
    return true;
  }
}
