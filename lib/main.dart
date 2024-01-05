import 'package:flutter/material.dart';
import 'package:object_detection_app/HomePage.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Object Detection App',
      home: HomePage(),
    );
  }
}
