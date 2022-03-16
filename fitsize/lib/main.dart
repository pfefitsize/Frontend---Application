//import 'dart:html';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import "home.dart";
import 'camera_old.dart';
import 'cameraController.dart';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class ScreenArguments {
  final String title;
  final String message;

  ScreenArguments(this.title, this.message);
}

void main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  // runApp(MyApp(firstCamera));
  runApp(
    MyApp(firstCamera)
  );
}

class MyApp extends StatelessWidget {
  var firstCamera;

  MyApp(CameraDescription this.firstCamera, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'FitSize'),
      debugShowCheckedModeBanner: false,
      initialRoute: '/connect',
      routes: {
        '/connect': (context) => const MyHomePage(title: 'FitSize'),
        '/home': (context) => MyModels(),
        '/camera': (context) => MaterialApp(
          theme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          home: TakePictureScreen(
            // Pass the appropriate camera to the TakePictureScreen widget.
            camera: firstCamera,
          ),
        ),
      },
      onGenerateRoute: (settings) {
          if (settings.name == '/connect') {
              return MaterialPageRoute(builder: (context) => const MyHomePage(title: 'FitSize'));
          } else if (settings.name == '/home') {
              return MaterialPageRoute(
                  builder: (context) {
                      return MyModels();
                  },
              );
          }
          return MaterialPageRoute(builder: (context) => UnknownScreen());
      },
    );
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        //child: Text('404!'),
        child : Text('Arg title is ${args}'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String email = '';
  String password ='';

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              onSubmitted: (String enteredemail){
                setState(() {
                  email=enteredemail;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              onSubmitted: (String enteredpassword){
                setState(() {
                  password=enteredpassword;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(color: Colors.blue)),
              color: Colors.blue,
              textColor: Colors.white,
              padding: EdgeInsets.all(8.0),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/home',
                  //arguments: ScreenArguments('arg-title', 'arg-message'),
                  arguments: <String, String>{
                    'title':"Deuxième page",
                  },
                );
              },
              child: const Text("Se connecter", style: TextStyle(fontSize: 12.0,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}