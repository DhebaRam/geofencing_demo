// Flutter imports:
import 'package:flutter/material.dart';

import '../utils/utils.dart';

// Project imports:
class BaseButton extends StatelessWidget {
  final String title;
  final double? textSize;
  final double? btnWidth;
  final double? btnHeight;
  final Function()? onPressed;
  final double? borderRadius;
  final Color btnColor;

  const BaseButton(
      {super.key,
      required this.title,
      this.textSize,
      required this.onPressed,
      this.btnColor = Colors.blue,
      this.borderRadius,
      this.btnWidth,
      this.btnHeight});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: Container(
            alignment: Alignment.center,
            width: btnWidth,
            height: btnHeight,
            padding: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.circular(borderRadius ?? 15),
            ),
            child:
                addText(title, textSize ?? 14, Colors.white, FontWeight.w600)));
  }
}
