
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:gramapict/result.dart';
class CaptureView extends StatefulWidget {
  final List<CameraDescription> cameras;
  CaptureView({super.key,required this.cameras});
  @override
  _CaptureView createState() => _CaptureView();
}
class  _CaptureView extends State<CaptureView> {
  late CameraController _cameraController;
  bool isLoading = true;
  Future initCamera(CameraDescription cameraDescription) async {
// create a CameraController
    _cameraController = CameraController(
        cameraDescription, ResolutionPreset.high);
// Next, initialize the controller. This returns a Future.
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }
  @override
  void initState() {
    super.initState();
    // initialize the rear camera
    initCamera(widget.cameras![0]);

  }
  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();
    super.dispose();
  }
  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      setState(() {
        isLoading = true;
      });
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      setState(() {
        isLoading = false;
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResultView(
                image: picture,
              )));

    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      setState(() {
        isLoading = false;
      });
      return null;

    }

  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return
      Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Capture Image'),
        ), //AppBar
        body:
            Column(
              children: [
                Expanded(child: Container(
                width: MediaQuery.of(context).size.width - 20,
                child: !isLoading
                    ? CameraPreview(_cameraController)
                    : Center(child:CircularProgressIndicator())

                )),
                SizedBox(height: 10),
                Center(child: Container(
                  width: MediaQuery.of(context).size.width - 20, // Set the desired width here
                  height : 50,
                  margin: EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Color.fromRGBO(214, 19, 95, 1), // Set the desired background color
                      foregroundColor: Colors.white, // Set the desired font color
                    ),
                    onPressed: takePicture,
                    child: Text('Capture',style: TextStyle(fontSize: 16)),
                  ),
                ))
              ],
            ) //Text
      );
  }
}
