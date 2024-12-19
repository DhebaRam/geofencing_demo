// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:

/// Popup widget that you can use by default to show some information
class CustomSnackBar extends StatefulWidget {

  const CustomSnackBar.info({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.isError
  });
  final String message;
  final Color backgroundColor;
  final bool isError;

  @override
  CustomSnackBarState createState() => CustomSnackBarState();
}

class CustomSnackBarState extends State<CustomSnackBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        // boxShadow: widget.boxShadow,
      ),
      width: double.infinity,
      alignment: AlignmentDirectional.centerStart,
      child:   Padding(
        padding: const EdgeInsets.all(10.0),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(widget.isError?Icons.error_outline:Icons.check_circle_outline,color: Colors.white,),
              const SizedBox(width: 5,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isError?"Error":"Success",
                      style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 15,decoration: TextDecoration.none
                          ,fontFamily: "Muli"),
                    ),
                    const SizedBox(height: 5,),
                    Text(
                      widget.message,
                      style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w400,fontSize: 13,decoration: TextDecoration.none
                      ,fontFamily: "Muli"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const kDefaultBoxShadow = [
  BoxShadow(
    color: Colors.black26,
    offset: Offset(0, 8),
    spreadRadius: 1,
    blurRadius: 30,
  ),
];

const kDefaultBorderRadius = BorderRadius.all(Radius.circular(12));
