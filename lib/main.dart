//import 'dart:convert';
import 'dart:io';

import 'package:ecolyze/analysis_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aws_rekognition_api/rekognition-2016-06-27.dart' as aws;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Ecolyzer'),
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
  bool firstBuild = true;
  bool isLoading = false;
  XFile? image;
  Future<aws.DetectCustomLabelsResponse>? _rekResponse;
  final double? _minConfidence = 5;

  void _sendImage(XFile? image) async {
    bool useMockCustomLabel = false;

    setState(() {
      firstBuild = false;
      isLoading = true;
    });

    // Initialize
    http.Client httpClient = http.Client();

    if (useMockCustomLabel) {
      _rekResponse =
          Future((() => aws.DetectCustomLabelsResponse(customLabels: [
                aws.CustomLabel(
                  confidence: 0.89,
                  geometry: aws.Geometry(
                      boundingBox: aws.BoundingBox(
                          top: 0.5, left: 0.5, height: 0.15, width: 0.2)),
                  name: "bad_insulation",
                ),
                aws.CustomLabel(
                  confidence: 0.64,
                  geometry: aws.Geometry(
                      boundingBox: aws.BoundingBox(
                          top: 0.2, left: 0.7, height: 0.1, width: 0.2)),
                  name: "bad_insulation",
                ),
              ])));
    } else {
      // To-do: To use this programm change the following attributes to
      // your credentials of the AWS Rekognition Service
      aws.Rekognition rekognition = aws.Rekognition(
          region: 'us-east-1',
          credentials:
              aws.AwsClientCredentials(accessKey: 'XXXXX', secretKey: 'XXXXX'),
          client: httpClient,
          endpointUrl: "https://rekognition.us-east-1.amazonaws.com");

      // Convert Image to Byte-List
      File imageFile = File(image!.path);
      Uint8List imageBytes = await imageFile.readAsBytes();
      //String base64Image = base64Encode(imageBytes);

      // Send request
      _rekResponse = rekognition.detectCustomLabels(
          image: aws.Image(bytes: imageBytes),
          projectVersionArn:
              'arn:aws:rekognition:us-east-1:430635303718:project/Ecolyze_1/version/Ecolyze_1.2023-01-19T16.29.51/1674142191173',
          maxResults: 3,
          minConfidence: _minConfidence);
    }

    setState(() {
      isLoading = true;
    });

    // Close http-Client
    _rekResponse?.then((clr) {
      print(clr.customLabels.toString());

      httpClient.close();
      setState(() {
        isLoading = false;
      });
    });
  }

  void _pickAndSendImage() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _sendImage(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: const Text('Search Scans'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(Icons.search),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            firstBuild
                ? const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('No analysis yet'),
                  )
                : FutureBuilder<aws.DetectCustomLabelsResponse>(
                    future: _rekResponse,
                    builder: (BuildContext context,
                        AsyncSnapshot<aws.DetectCustomLabelsResponse>
                            snapshot) {
                      List<Widget> children;
                      if (snapshot.hasError) {
                        // Error Screen
                        children = <Widget>[
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                                'The AI-Model needs to be activated first! Please refer to the Github Repository or the Technical Project Description for more information!\n\nError: ${snapshot.error}. '),
                          ),
                        ];
                      } else {
                        // Display-Response or Loading Screen
                        if (isLoading) {
                          // Loading Screen
                          children = <Widget>[
                            const SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text('Awaiting result...'),
                            ),
                          ];
                        } else if (snapshot.data?.customLabels != null &&
                            (snapshot.data?.customLabels?.isNotEmpty ??
                                false)) {
                          // Response Screen with labels
                          children = <Widget>[
                            const Icon(
                              Icons.check_circle_outline,
                              color: Color.fromARGB(255, 18, 97, 20),
                              size: 60,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text(
                                'Analysis Result',
                                textScaleFactor: 1.5,
                              ),
                            ),
                            CustomPaint(
                              foregroundPainter:
                                  AnalysisPainter(snapshot.data?.customLabels),
                              child: Image.file(File(image!.path)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                  'Problem-Label: ${snapshot.data?.customLabels?[0].name ?? "Bad insulation"}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                  'Confidence of Prediction: ${snapshot.data?.customLabels?[0].confidence ?? "Minimum " + _minConfidence.toString()}'),
                            ),
                          ];
                        } else {
                          // Response Screen when no custom labels available
                          children = const <Widget>[
                            Icon(
                              Icons.check_circle_outline,
                              color: Color.fromARGB(255, 18, 97, 20),
                              size: 60,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text('No relevant results'),
                            ),
                          ];
                        }
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: children,
                        ),
                      );
                    }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndSendImage,
        tooltip: 'Pick Image',
        label: const Text(
          'New Scan',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.add_photo_alternate,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
