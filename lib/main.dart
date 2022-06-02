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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Color Code Finder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class ColorModel{
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
        colorCode : json['ColorCode'],
        hue : json['AssignedHue'],
        saturation: json['AssignedSaturation'],
        value: json['AssignedValue'],
    );
  }
}
class _MyHomePageState extends State<MyHomePage> {
  String code = "";
  ColorModel currentColorModel = const ColorModel(colorCode: "", hue: 0, saturation: 0, value: 0);
  Color color = Colors.transparent;

  TextEditingController colorToSearch = TextEditingController();

  Color getAssignedFlutterColor(int hue, int sat, int val) {
    return HSVColor.fromAHSV(1, hue.roundToDouble(), sat / 100, val / 100)
        .toColor();
  }

  Future<void> _getCode() async {
    print(colorToSearch.text);
    final response = await http
        .get(Uri.parse('https://us-central1-beauty-by-me-4fc72.cloudfunctions.net/bbmExpress/api/colors/appSearch/shopifyData/${colorToSearch.text}'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        currentColorModel = ColorModel.fromJson(jsonDecode(response.body));
        color = getAssignedFlutterColor(currentColorModel.hue, currentColorModel.saturation, currentColorModel.value);
        code = currentColorModel.colorCode;
      });
      print("SUCCESS");
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load color');
    }
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Column(
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

             Container(
               height: 150,
               width: 150,
              color: color,
            ) ,
            const Text(
              'Color code:',
            ),
            Text(
              code,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: colorToSearch,
                  ),
                )
              ],),
           const SizedBox(height: 15),
            SizedBox(child: ElevatedButton(child: const Text('Search'),  onPressed: _getCode,),)
          ],
        ),
      ),
    );
  }
}
