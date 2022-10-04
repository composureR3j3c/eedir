import 'package:flutter/material.dart';
import 'package:ridee/AllScreens/mainScreen.dart';
import 'package:ridee/AllScreens/mapSample.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      // home: MapSample(),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
