// Flutter imports:
import 'package:flutter/material.dart';

void showLoader(context) async => await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
            child: Container(
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: FlutterLogo(
                    size: 10,
                  ),
                ),
              ],
            ),
            //CircularProgressIndicator(color: AppColors.btnBgColor),
            // Container(
            //   color: Colors.black26,
            //   height: MediaQuery.of(context).size.height,
            //   width: MediaQuery.of(context).size.width,
            //   child: const Center(
            //     child: CircularProgressIndicator.adaptive(
            //       valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            //     ),
            //   ),
            // ),
          ),
        ))));
