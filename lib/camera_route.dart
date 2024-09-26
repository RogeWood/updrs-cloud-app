import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'video_upload_route.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({
    Key? key,
  }) : super(key: key);

  @override
  RecordingScreenState createState() => RecordingScreenState();
}

class RecordingScreenState extends State<RecordingScreen> {
  bool hasStartedRecord = false;
  late final CameraController _controller;
  late final Future<CameraController> _initializeControllerFuture;
  int lastPressRecord = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = () async {
      var cameras = await availableCameras();
      var camera = cameras.first;
      _controller = CameraController(
          camera,
          // Define the resolution to use.
          ResolutionPreset.high,
          enableAudio: false);
      await _controller.initialize();
      await _controller.prepareForVideoRecording();
      return _controller;
    }();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('錄影')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<CameraController>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // If the Future is complete, display the preview.
            var camera = _controller.value;
            // fetch screen size
            final size = MediaQuery.of(context).size;

            // calculate scale depending on screen and camera ratios
            // this is actually size.aspectRatio / (1 / camera.aspectRatio)
            // because camera preview size is received as landscape
            // but we're calculating for portrait orientation
            var scale = size.aspectRatio * camera.aspectRatio;
            // to prevent scaling down, invert the value
            scale = 1 / scale;
            return Center(child: CameraPreview(snapshot.data!));
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Text(snapshot.error.toString());
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          if (DateTime.now().millisecondsSinceEpoch - lastPressRecord < 3000) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("不要按這麼快！"),
              duration: Duration(seconds: 1),
            ));
            return;
          }
          lastPressRecord = DateTime.now().millisecondsSinceEpoch;
          try {
            // Ensure that the camera is initialized.
            if (!hasStartedRecord) {
              await _initializeControllerFuture;
              await _controller.startVideoRecording();
              setState(() {
                hasStartedRecord = true;
              });
              return;
            }
          } catch (e) {
            print(e);
          }

          // Attempt to take a picture and get the file `video`
          // where it was saved.
          // final video = await _controller.takePicture();

          try {
            final video = await _controller.stopVideoRecording();
            // If the picture was taken, display it on a new screen.

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => VideoUploadRoute(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  videoPath: video.path,
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("錄影失敗！"),
            ));
            print(e);
          }
          setState(() {
            hasStartedRecord = false;
          });
        },
        child: Icon(hasStartedRecord ? Icons.stop : Icons.video_call),
      ),
    );
  }
}
