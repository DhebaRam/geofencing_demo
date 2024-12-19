// Dart imports:

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../packages/top-snackbar-flutter/custom_snack_bar.dart';
import '../packages/top-snackbar-flutter/top_snack_bar.dart';
// Package imports:

bool isEmail(String input) {
  // Regular expression for a simple email validation
  RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
  return emailRegex.hasMatch(input);
}

bool isMobileNumber(String input) {
  // Regular expression for a simple mobile number validation
  RegExp mobileRegex = RegExp(r'^[0-9]{10}$');
  return mobileRegex.hasMatch(input);
}

void myCustomToast(String message, context) {
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.info(
      message: message,
      backgroundColor: Colors.green.shade800,
      isError: false,
    ),
  );
}

void myCustomToastOtpPop(String message, context) {
  showTopSnackBar(
    Overlay.of(context),
    displayDuration: const Duration(seconds: 5),
    CustomSnackBar.info(
      message: message,
      backgroundColor: Colors.green.shade800,
      isError: false,
    ),
  );
}

void myCustomErrorToast(Object error, context) {
  String errorMesg = error.toString();
  if (errorMesg.contains("Doctype") || errorMesg.contains("Connection time")) {
    return;
  }
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.info(
      message:
          errorMesg.replaceFirst("HttpException: ", "").replaceAll("\\", ''),
      backgroundColor: Colors.red,
      isError: true,
    ),
  );
}

safePrint(dynamic message) {
  if (kDebugMode) {
    print(message);
  }
}

Text addText(String text, double size, Color color, FontWeight fontWeight) {
  return Text(text,
      // textAlign: TextAlign.center,
      style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: fontWeight,
          fontFamily: "Muli"));
}

Text addTextheight(
    String text, double size, Color color, FontWeight fontWeight) {
  return Text(text,
      style: TextStyle(
          color: color,
          fontSize: size,
          height: 1.5,
          fontWeight: fontWeight,
          fontFamily: "Muli"));
}

Text addOverflowText(
    String text, double size, Color color, FontWeight fontWeight) {
  return Text(text,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: fontWeight,
          fontFamily: "Muli"));
}

Text addAlignedText(
    String text, double size, Color color, FontWeight fontWeight) {
  return Text(text,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: fontWeight,
          fontFamily: "Muli",
          height: 1.0));
}

Text addAlignedTextheight(
    String text, double size, Color color, FontWeight fontWeight) {
  return Text(text,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: fontWeight,
          fontFamily: "Muli",
          height: 1.5));
}

BorderRadius getBorderRadius() {
  return BorderRadius.circular(10);
}

BorderRadius getMidBorderRadius() {
  return BorderRadius.circular(15);
}

BorderRadius getCurvedBorderRadius() {
  return BorderRadius.circular(20);
}

BorderRadius getCustomBorderRadius(double radius) {
  return BorderRadius.circular(radius);
}
