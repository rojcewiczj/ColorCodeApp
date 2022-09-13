import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Color Code Finder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class ColorModel {
  final String colorCode;
  final int hue;
  final int saturation;
  final int value;
  const ColorModel({
    required this.colorCode,
    required this.hue,
    required this.saturation,
    required this.value,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) {
    return ColorModel(
      colorCode: json['ColorCode'],
      hue: json['AssignedHue'],
      saturation: json['AssignedSaturation'],
      value: json['AssignedValue'],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String code = "";
  ColorModel currentColorModel =
      const ColorModel(colorCode: "", hue: 0, saturation: 0, value: 0);
  Color color = Colors.transparent;

  TextEditingController colorController = TextEditingController();

  Color getAssignedFlutterColor(int hue, int sat, int val) {
    return HSVColor.fromAHSV(1, hue.roundToDouble(), sat / 100, val / 100)
        .toColor();
  }

  Future<void> _getCode() async {
    final response = await http.get(Uri.parse(
        'https://us-central1-beauty-by-me-4fc72.cloudfunctions.net/bbmExpress/api/webColors/webSearch/shopifyData/${colorController.text}'));
    final colorResponse = jsonDecode(response.body) as Map<String, dynamic>;
    print("response: $colorResponse");
    if (response.statusCode == 200) {
      currentColorModel = ColorModel.fromJson(colorResponse);
      setState(() {
        color = getAssignedFlutterColor(currentColorModel.hue,
            currentColorModel.saturation, currentColorModel.value);
        code = currentColorModel.colorCode;
      });
    } else {
      setState(() {
        code = colorResponse['message'];
        color = Colors.transparent;
      });
      throw Exception('Failed to load color');
    }
  }

  @override
  void dispose() {
    colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 30, right: 30),
        child: Container(
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Container(
                height: 250,
                width: 150,
                color: color,
              ),
              SizedBox(
                height: 25,
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                code,
                style: TextStyle( fontSize: 55, color: color)
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 200,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: colorController,
                    style: TextStyle(
                        fontSize: 25.0,
                        height: 2.0,
                        color: Colors.black87
                    ),
                  decoration: const InputDecoration(hintText: 'COLOR ID',
                  focusColor: Colors.black87, focusedBorder: UnderlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4)), borderSide: BorderSide(width: 8,color: Colors.black12),
              ),
                    enabledBorder:UnderlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4)), borderSide: BorderSide(width: 8,color: Colors.black12),
                    ),),
                ),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black87),
                  ),
                    child: const Text('Search', style: TextStyle( fontSize: 20),),
                    onPressed: () {
                      if (colorController.text.isEmpty) {
                        print("Empty");
                      } else {
                        _getCode();
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
