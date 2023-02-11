import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:nsmvision_odovinrecog/main.dart';
import 'package:image_picker/image_picker.dart';

import 'detail_screen.dart';
import 'history_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late final CameraController _controller;

  // Initializes camera controller to preview on screen
  void _initializeCamera() async {
    final CameraController cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );
    _controller = cameraController;

    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  // Takes picture with the selected device camera, and
  // returns the image path
  Future<String?> _takePicture() async {
    if (!_controller.value.isInitialized) {
      print("Controller is not initialized");
      return null;
    }

    String? imagePath;

    if (_controller.value.isTakingPicture) {
      print("Processing is progress ...");
      return null;
    }

    try {
      // Turning off the camera flash
      _controller.setFlashMode(FlashMode.off);
      // Returns the image in cross-platform file abstraction
      final XFile file = await _controller.takePicture();
      // Retrieving the path
      imagePath = file.path;
    } on CameraException catch (e) {
      print("Camera Exception: $e");
      return null;
    }

    return imagePath;
  }

  @override
  void initState() {
    _initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    // dispose the camera controller when navigated
    // to a different page
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 2.0,
        title:      
      Text('NSMV OdoRecog', textAlign: TextAlign.center, style: TextStyle(
        color: Color.fromRGBO(42, 47, 45, 1),
        fontFamily: 'Poppins',
        fontSize: 16,
        letterSpacing: 1,
        fontWeight: FontWeight.bold,
        height: 1
      ),),
              centerTitle: true,
      ),
      body: _controller.value.isInitialized
          ? Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 500,
                    width: 360,
        child: _controller != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF6C63FF),
                  ),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  ),
                ),
              )
            : Container(),
      ),
                ),
                Padding(padding: EdgeInsets.all(20),
                child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: <Widget>[
    RawMaterialButton(
      onPressed: () async{
          // Handle gallery button press
          // Handle gallery button press
              final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
              // Do something with the picked file
              if (pickedFile != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                  imagePath: pickedFile.path,
                                ),
                              ),
                            );
                          } else {
                            print('Image path not found!');
                          }

      },
      child: Icon(Icons.photo_library, color: Colors.white),
      shape: CircleBorder(),
      fillColor: Color(0xFF6C63FF),
      elevation: 6.0,
      padding: EdgeInsets.all(15.0),
    ),
    RawMaterialButton(
      onPressed: () async{
          // Handle camera button press
          await _takePicture().then((String? path) {
                          if (path != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                  imagePath: path,
                                ),
                              ),
                            );
                          } else {
                            print('Image path not found!');
                          }
                        });
      },
      child: Icon(Icons.camera_alt, color: Colors.white),
      shape: CircleBorder(),
      fillColor: Color(0xFF6C63FF),
      elevation: 6.0,
      padding: EdgeInsets.all(15.0),
    ),
     RawMaterialButton(
      onPressed: () async{
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReadingHistoryPage()
                              ),
                            );

      },
      child: Icon(Icons.history, color: Colors.white),
      shape: CircleBorder(),
      fillColor: Color(0xFF6C63FF),
      elevation: 6.0,
      padding: EdgeInsets.all(15.0),
    ),
  ],
)
                ),
              ],
            )
          : Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }


}
