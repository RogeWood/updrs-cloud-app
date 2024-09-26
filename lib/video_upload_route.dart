import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'jwt.dart';
import 'record_list_route.dart';

class VideoUploadRoute extends StatefulWidget {
  final String videoPath;

  const VideoUploadRoute({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<VideoUploadRoute> createState() => _VideoUploadRoute();
}

class _VideoUploadRoute extends State<VideoUploadRoute> {
  bool uploading = false;

  void setUploading(bool v) {
    setState(() {
      uploading = v;
    });
  }

  bool getUploading() {
    return uploading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('確認錄影')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body: WillPopScope(
          onWillPop: () async {
            if (uploading) return false;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RecordListRoute()),
            );
            return false;
          },
          child: FormWithVideo(
            videoPath: widget.videoPath,
            setUploading: setUploading,
            getUploading: getUploading,
          ),
        ));
  }
}

class FormWithVideo extends StatefulWidget {
  final String videoPath;
  final void Function(bool) setUploading;
  final bool Function() getUploading;

  const FormWithVideo(
      {Key? key,
      required this.videoPath,
      required this.setUploading,
      required this.getUploading})
      : super(key: key);

  @override
  createState() => _FormWithVideo();
}

class _FormWithVideo extends State<FormWithVideo> {
  late VideoPlayerController videoController;
  late Future<void> _initializeVideoPlayerFuture;
  final locationController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    videoController = VideoPlayerController.file(File(widget.videoPath));

    _initializeVideoPlayerFuture = videoController.initialize();

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    videoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SingleChildScrollView(
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 20),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          VideoProgressIndicator(
                            videoController,
                            allowScrubbing: true,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    videoController
                                        .seekTo(const Duration(seconds: 0));
                                  },
                                  child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: const Icon(Icons.fast_forward))),
                              const Padding(padding: EdgeInsets.all(3)),
                              ElevatedButton(
                                  onPressed: () {
                                    if (!videoController.value.isPlaying) {
                                      videoController.play();
                                    } else {
                                      videoController.pause();
                                    }
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(Icons.play_arrow),
                                      Text("/"),
                                      Icon(Icons.pause)
                                    ],
                                  )),
                            ],
                          ),
                        ],
                      ),
                      TextField(
                          controller: locationController,
                          decoration: const InputDecoration(labelText: "地點")),
                      TextField(
                          controller: noteController,
                          decoration: const InputDecoration(labelText: "備註")),
                      // 上傳
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 35),
                          ),
                          onPressed: widget.getUploading()
                              ? null
                              : () async {
                                  widget.setUploading(true);
                                  var request = http.MultipartRequest(
                                      "POST",
                                      Uri.parse(
                                          "${Config.baseUrl}/updrs/record"));
                                  request.fields["location"] =
                                      locationController.value.text;
                                  request.fields["note"] =
                                      noteController.value.text;
                                  request.files.add(
                                      await http.MultipartFile.fromPath(
                                          "file", widget.videoPath));
                                  request.headers["Authorization"] =
                                      "Bearer ${JWT().token}";
                                  var response = await request.send();
                                  if (response.statusCode > 299) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text('出錯了！請稍後再試'),
                                    ));
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text('上傳成功'),
                                    ));
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RecordListRoute()),
                                    );
                                  }
                                },
                          child: widget.getUploading()
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                      SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.grey,
                                          )),
                                      Text("   上傳中，這不會花費太多時間..."),
                                    ])
                              : const Text("上傳"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
