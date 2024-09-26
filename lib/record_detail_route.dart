import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:se_project/record_utils.dart';

import 'config.dart';
import 'jwt.dart';

class RecordDetailRoute extends StatelessWidget {
  final int recordId;

  const RecordDetailRoute({Key? key, required this.recordId}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("檢測詳細紀錄 #$recordId"),
        ),
        body: Center(
          child: FutureBuilder(
            future: getRecord(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!["results"] == null) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("還沒檢測出來喔！"),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: snapshot.data!["results"].length,
                    itemBuilder: (var context, index) {
                      // return Text("${snapshot.data!["results"][index]}");
                      return Container(
                        height: 100,
                        // color: Colors.blue,
                        // child: Text(
                        //   "item: ${snapshot.data!["results"][index]["item"]}\n" +
                        //       "right: ${snapshot.data!["results"][index]["values"]["right"]}\n" +
                        //       "Left: ${snapshot.data!["results"][index]["values"]["left"]}\n",
                        //   style: TextStyle(fontSize: 20.0),
                        // ),

                        child: ListView(
                          children: [
                            ListTile(
                              title: Text(
                                  "item: ${snapshot.data!["results"][index]["item"]}",
                                  style: TextStyle(fontSize: 20.0)),
                              subtitle: Text(
                                "right: ${snapshot.data!["results"][index]["values"]["right"]}\n" +
                                    "Left: ${snapshot.data!["results"][index]["values"]["left"]}\n",
                                style: TextStyle(fontSize: 20.0),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text("發生錯誤了！ ${snapshot.error.toString()}");
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ));
  }

  Future<Map> getRecord() async {
    Uri uri = Uri.parse("${Config.baseUrl}/updrs/record/$recordId");
    String token = JWT().token;
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode > 299) {
      throw Exception("something went wrong");
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map;
  }
}
