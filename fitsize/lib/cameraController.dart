import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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

class Coordonates<String, Int> {
  final Int x;
  final Int y;

  Coordonates(this.x, this.y);
}


class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final double maxPointCount = 8;
  double pointCount = 0;
  double referenceObjectLength = 0;
  double valueInputDialog = 0;
  List<Widget> points = <Widget>[];
  List<Coordonates> pointsPositions = <Coordonates>[];
  String imagePath = '';
  bool _isButtonDisabled = true;
  final TextEditingController _textFieldController = TextEditingController();

  _DisplayPictureScreenState(String this.imagePath);

  void addNewPoint(detail) {
    {
      if(pointCount <= maxPointCount-1) {
        pointCount++;
        var appBarHeight = AppBar().preferredSize.height;
        var x = detail.globalPosition.dx;
        var y = detail.globalPosition.dy - appBarHeight;
        var newPoint = Positioned(
          left: x - (45 / 2),
          top: y - 45,
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
          _isButtonDisabled = false;
          print('You can now Validate !');
        }

        setState(() {
          pointsPositions.add(Coordonates(x, y-2));
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
          ),
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  side: BorderSide(color: Colors.blue)),
              color: _isButtonDisabled ? Colors.grey : Colors.blue,
              textColor: Colors.white,
              padding: EdgeInsets.all(8.0),
              onPressed: () async {
                if (!_isButtonDisabled) {
                  _displayTextInputDialog(context);
                }
              },
              child: const Text("Suivant", style: TextStyle(fontSize: 12.0,),
              ),
            ),
          ]
        )
    );
  }



  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                'Entez la taille de votre objet de référence (centimètres)'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueInputDialog = value as double;
                });
              },
              keyboardType: TextInputType.number,
              // inputFormatters: <TextInputFormatter>[
              //   FilteringTextInputFormatter.digitsOnly
              // ],
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "4.3"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () async {
                  setState(() {
                    referenceObjectLength = valueInputDialog;
                    Navigator.pop(context);
                  });

                  //This is the call to the backend to send the points
                  var url = Uri.parse('https://example.com/whatsit/create');
                  var response = await http.post(
                      url, body: {'name': 'doodle', 'color': 'blue'});

                  // if (response.isOk) {
                    Navigator.pushNamed(
                      context,
                      '/home',
                      //arguments: ScreenArguments('arg-title', 'arg-message'),
                      arguments: <String, String>{
                        'title': "Deuxième page",
                      },
                    );
                  // }
                },
              ),
            ],
          );
        });
  }
}
