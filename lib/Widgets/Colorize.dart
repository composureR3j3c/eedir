import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class Colorize  extends StatelessWidget {
  const Colorize ({Key? key}) : super(key: key);
  static
  const colorizeColors = [
    // Colors.purple,
    Colors.teal,
    Colors.blue,
    Colors.yellow,
    Colors.red,
    Colors.amber
  ];

  static const colorizeTextStyle = TextStyle(
    fontSize: 55.0,
    fontFamily: 'Canterbury',
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedTextKit(
        animatedTexts: [
          ColorizeAnimatedText(
            'Requesting a Ride....',
            textStyle: colorizeTextStyle,
            colors: colorizeColors,
            textAlign:TextAlign.center,
          ),
          ColorizeAnimatedText(
            'Processing please wait....',
            textStyle: colorizeTextStyle,
            colors: colorizeColors,

            textAlign:TextAlign.center,
          ),
          ColorizeAnimatedText(
            'Finding a driver....',
            textStyle: colorizeTextStyle,
            colors: colorizeColors,

            textAlign:TextAlign.center,
          ),

        ],
        isRepeatingAnimation: true,
        onTap: () {
          print("Tap Event");
        },
      ),
    );
  }
}
