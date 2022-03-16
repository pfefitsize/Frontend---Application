import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/positioned_tap_detector.dart'

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
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
      appBar: AppBar(title: const Text('')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Container(
        height: 70.0,
        width: 70.0,
        margin: const EdgeInsets.only(bottom: 20.0),
        child: FittedBox(
          child: FloatingActionButton(
            highlightElevation: 30,
            child : const Icon(Icons.camera_alt),
            onPressed: () async {
              // Take the Picture in a try / catch block. If anything goes wrong,
              // catch the error.
              try {
                // Ensure that the camera is initialized.
                await _initializeControllerFuture;

                // Attempt to take a picture and get the file `image`
                // where it was saved.
                final image = await _controller.takePicture();

                // If the picture was taken, display it on a new screen.
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                      // Pass the automatically generated path to
                      // the DisplayPictureScreen widget.
                      imagePath: image.path,
                    ),
                  ),
                );
              } catch (e) {
                // If an error occurs, log the error to the console.
                print(e);
              }
            },
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState(imagePath);
}



class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final double maxPointCount = 8;
  double pointCount = 0;
  List<Widget> points = <Widget>[];
  // List<(double, double)> pointsPositions = <(double, double)>[];
  String imagePath = '';

  _DisplayPictureScreenState(String this.imagePath);

  void addNewPoint(detail) {
    {
      if(pointCount <= maxPointCount) {
        pointCount++;
        var appBarHeight = AppBar().preferredSize.height;
        var newPoint = Positioned(
          left: detail.globalPosition.dx - (45 / 2),
          top: detail.globalPosition.dy - 45 - appBarHeight,
          child: Image.asset(
            'graphics/images/position_marker_' + pointCount.toStringAsFixed(0) +
                '.png',
            colorBlendMode: BlendMode.multiply,
            height: 45,
            width: 45,
          ),
        );
        print(pointCount);
        if (pointCount == maxPointCount) {
          print('You can now Validate !');
        }

        setState(() {
          points.add(newPoint);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Placez les points comme sur l\'exemple')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children : [Stack(
            children: <Widget>[
              GestureDetector(
                child: Center(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5.0),
                      topRight: Radius.circular(5.0),
                    ),
                    child: Image.file(File(imagePath)),
                  ),
                ),
                onTapUp: (detail) => addNewPoint(detail),
              )
            ] +
                points,
          )]
        )
    );
  }
}
