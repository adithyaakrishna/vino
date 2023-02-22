import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'history_screen.dart';

class DetailScreen extends StatefulWidget {
  final String imagePath;

  const DetailScreen({required this.imagePath});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final String _imagePath;
  late final TextDetector _textDetector;
  Size? _imageSize;
  List<TextElement> _elements = [];

  List<String>? _listRecogTexts;

  // Fetching the image size from the image file
  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  // To detect the email addresses present in an image
  void _recognizeEmails() async {
    _getImageSize(File(_imagePath));

    // Creating an InputImage object using the image path
    final inputImage = InputImage.fromFilePath(_imagePath);
    // Retrieving the RecognisedText from the InputImage
    final text = await _textDetector.processImage(inputImage);

    // Pattern of RegExp for matching a general VIN Number
    String vinPattern = r"\b[(A-H|J-N|P|R-Z|0-9)]{17}\b";
    String vinPattern2 = r"[A-HJ-NPR-Z0-9]{17}";
    String vinPattern3 = r"[a-zA-Z0-9]{9}[a-zA-Z0-9-]{2}[0-9]{6}";
    String vinPattern4 = r"\b[(A-H|J-N|P|R-Z|0-9)]{17}\b";
    String vinPattern5 = r"^(?=.*[0-9])(?=.*[A-z])[0-9A-z-]{17}$";
    // String odoPattern = r"/\b\d{6}\b/g";
    // String odoPattern2 = r"^[0-9]$|^[1-9][0-9]$|^(999999)$";

    RegExp regEx = RegExp(vinPattern);
    RegExp regEx2 = RegExp(vinPattern2);
    RegExp regEx3 = RegExp(vinPattern3);
    RegExp regEx4 = RegExp(vinPattern4);
    RegExp regEx5 = RegExp(vinPattern5);

    List<String> textStrings = [];


    // Finding and storing the text String(s) and the TextElement(s)
    for (TextBlock block in text.textBlocks) {
      for (TextLine line in block.textLines) {
          if (regEx5.hasMatch(line.lineText) || regEx3.hasMatch(line.lineText) || regEx2.hasMatch(line.lineText) || regEx.hasMatch(line.lineText) || regEx4.hasMatch(line.lineText)) {
            textStrings.add(line.lineText);
          for (TextElement element in line.textElements) {
            _elements.add(element);
          }
        }
      }
    }

    setState(() {
      _listRecogTexts = textStrings;
    });
  }

  @override
  void initState() {
    _imagePath = widget.imagePath;
    // Initializing the text detector
    _textDetector = GoogleMlKit.vision.textDetector();
    _recognizeEmails();
    super.initState();
  }

  void saveReading(String reading) async {
  var dateTime = DateTime.now();
  var date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  var time = "${dateTime.hour}:${dateTime.minute}:${dateTime.second}";

  var prefs = await SharedPreferences.getInstance();
  List<String> readingList = prefs.getStringList('readingList') ?? [];
  readingList.add("$date $time: $reading");
  prefs.setStringList('readingList', readingList);
}

  @override
  void dispose() {
    // Disposing the text detector when not used anymore
    _textDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, // <-- SEE HERE
        ),
        backgroundColor: Colors.white,
        elevation: 2.0,
        title:      
      Text('Image Details', textAlign: TextAlign.center, style: TextStyle(
        color: Color.fromRGBO(42, 47, 45, 1),
        fontFamily: 'Poppins',
        fontSize: 16,
        letterSpacing: 1,
        fontWeight: FontWeight.bold,
        height: 1
      ),),
              centerTitle: true,
      ),
      body: _imageSize != null
          ? Container(
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
   height: 467,
                      width: 365,                    
                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50.0),
                        child: Container(
                          decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                          child: CustomPaint(
                            foregroundPainter: TextDetectorPainter(
                              _imageSize!,
                              _elements,
                            ),
                            child: AspectRatio(
                              aspectRatio: _imageSize!.aspectRatio,
                              child: Image.file(
                                File(_imagePath),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Identified text",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Container(
                          height: 80,
                          width: 340,
                           decoration: BoxDecoration(
    color: Color(0xFFDCE5F9),
    borderRadius: BorderRadius.all(Radius.circular(10))
  ),
                           child:
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Expanded(
              child: SizedBox(
                height: 100.0,
                child: SingleChildScrollView(
                  child: _listRecogTexts != null?ListView.builder(
                    shrinkWrap: true,
                    itemCount: _listRecogTexts!.length,
                    itemBuilder: (context, index) {
                      return Text(_listRecogTexts![index]);
                    },
                  ):Container(),
                ),
              ),
          ),
        ),

                         ),
                       ),
                        // Save the reading button
                                                Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all<Size>(
                                Size(300, 48)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF6C63FF)),
                          ),
                          onPressed: () async {
                                saveReading(_listRecogTexts!.join("\n"));
                                Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReadingHistoryPage()
                              ),
                            );
                          },
                          child: Text(
                            'Save',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: const Color.fromRGBO(255, 255, 255, 1),
                              fontFamily: 'Product Sans',
                              fontSize: 20,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
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

// Helps in painting the bounding boxes around the recognized
// email addresses in the picture
class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.elements);

  final Size absoluteImageSize;
  final List<TextElement> elements;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextElement container) {
      return Rect.fromLTRB(
        container.rect.left * scaleX,
        container.rect.top * scaleY,
        container.rect.right * scaleX,
        container.rect.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 2.0;

    for (TextElement element in elements) {
      canvas.drawRect(scaleRect(element), paint);
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return true;
  }
}
