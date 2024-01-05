import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection_app/main.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isWorking = false;
  String result = "";
  late CameraController cameraController;
  CameraImage? imgCamera;

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/mobilenet_v1_1.0_224.txt"
    );
  }

  initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        cameraController.startImageStream((image) {
          if (!isWorking) {
            isWorking = true;
            imgCamera = image;
            runModelOnStreamFrames();
          }
        });
      });
    });
  }

  runModelOnStreamFrames() async {
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: imgCamera!.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: imgCamera!.height,
          imageWidth: imgCamera!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.1,
          asynch: true
      );

      result = "";
      recognitions?.forEach((response) {
        result += response["label"] + "  " + (response["confidence"] as double).toStringAsFixed(2) + "\n\n";
      });

      setState(() {
        result;
      });

      isWorking = false;
    }
  }


  final ButtonStyle flatButtonStyle = TextButton.styleFrom(
    minimumSize: const Size(360, 270),
    backgroundColor: Colors.blueAccent,
    padding: const EdgeInsets.only(top: 35),
  );

  @override
  void initState() {
    super.initState();

    loadModel();
  }

  @override
  void dispose() async {
    super.dispose();
    await Tflite.close();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.black,
            child: Column(
              children: [
                Stack(children: [
                  Center(
                    child: Container(
                      height: 320,
                      width: 400,
                    ),
                  ),
                  Center(
                    child: TextButton(
                      style: flatButtonStyle,
                      onPressed: () {
                        initCamera();
                      },
                      child: imgCamera == null
                          ? const SizedBox(
                        height: 270,
                        width: 400,
                        child: Icon(
                          Icons.photo_camera_front,
                          color: Colors.white,
                          size: 100,
                        ),
                      )
                          : AspectRatio(
                        aspectRatio: cameraController.value.aspectRatio,
                        child: CameraPreview(cameraController),
                      ),
                    ),
                  )
                ]),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 55.0),
                    child: SingleChildScrollView(
                      child: Text(
                        result,
                        style: const TextStyle(
                          backgroundColor: Colors.black54,
                          fontSize: 30.0,
                          color: Colors.white
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
