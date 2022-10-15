import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridee/AllScreens/SplashScreen.dart';
import 'package:ridee/AllScreens/mainScreen.dart';
import 'package:ridee/AllScreens/mapSample.dart';
import 'package:ridee/Provider/appdata.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      ChangeNotifierProvider(
        create: (context)=>AppData(),
        child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        // home: MapSample(),
        home: const MySplashScreen(),
        debugShowCheckedModeBanner: false,
    ),
      );
  }
}
