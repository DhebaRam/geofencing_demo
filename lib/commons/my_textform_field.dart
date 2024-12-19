// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/utils.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String titleText, hintText, lableText;
  final String? errorMsg;
  final bool obsecureText,
      readOnly,
      isEmail,
      isPhone,
      isEmiratedID,
      isRequired,
      isUrl,
      isCarAdded,
      isFocus;
  final String dialcode;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final Widget suffix;
  final Widget preffix;
  final int maxLines;
  final Color borderColor, color;
  final Function()? onPressed;
  final Function(dynamic value)? onChange;
  final double borderRadius;
  final Widget? iconRow;
  final bool isFormatter;
  final bool isOrderNumber;

  const MyTextFormField({
    super.key,
    required this.controller,
    this.titleText = "",
    this.obsecureText = false,
    this.readOnly = false,
    this.isEmail = false,
    this.isEmiratedID = false,
    this.isUrl = false,
    this.isCarAdded = false,
    this.isPhone = false,
    this.isRequired = true,
    this.hintText = "",
    this.lableText = "",
    this.errorMsg,
    this.color = Colors.transparent,
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.suffix = const SizedBox(),
    this.preffix = const SizedBox(
      height: 25,
      width: 15,
    ),
    this.borderColor = Colors.black45,
    this.maxLines = 1,
    this.borderRadius = 5,
    this.isFocus = true,
    this.iconRow,
    this.isFormatter = false,
    this.isOrderNumber = false,
    this.onPressed,
    this.onChange,
    this.dialcode = "+1",
  });

  @override
  Padding build(BuildContext context) {
    const subtitleStyle = TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontFamily: "Muli",
        fontSize: 13);
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 0, bottom: 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          !isPhone
              ? Expanded(
                  child: TextFormField(
                    obscureText: obsecureText,
                    controller: controller,
                    textAlign: TextAlign.start,
                    onTap: onPressed ?? () {},
                    inputFormatters: isCarAdded
                        ? [
                            LengthLimitingTextInputFormatter(4),
                          ]
                        : null,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      isDense: true,
                      hintText: hintText,
                      labelText: lableText,
                      fillColor: color,
                      filled: true,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: borderColor),
                          borderRadius: getBorderRadius()),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: borderColor),
                          borderRadius: getBorderRadius()),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: borderColor),
                          borderRadius: getBorderRadius()),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: suffix,
                      ),
                      errorMaxLines: 2,
                      suffixIconConstraints:
                          const BoxConstraints(minHeight: 55, maxWidth: 50),
                      prefixIconConstraints: const BoxConstraints(
                        minHeight: 55,
                        maxWidth: 40,
                      ),
                      prefixIcon: preffix,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Muli",
                          fontSize: 13),
                      hintStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Muli",
                          fontSize: 13),
                    ),
                    readOnly: readOnly,
                    maxLines: maxLines,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Muli",
                        fontSize: 13),
                    keyboardType: textInputType,
                    textInputAction: textInputAction,
                    validator: (val) {
                      if (!isRequired) return null;
                      val = val!.trim();
                      if (errorMsg == null) {
                        if (val.isEmpty) return "This filed is required.";
                      }
                      if (val.isEmpty) return errorMsg;
                      // if (isEmail) {
                      //   if (!Validator.validatorInstanace.isValidEmail(val)) {
                      //     return "Please enter valid email.";
                      //   }
                      // }
                      // if (isPhone){
                      //   if (!Validator.validatorInstanace.isValidPhone(val)) {
                      //     return "Please enter valid phone no. length should be 7 to 15";
                      //   }
                      // }
                      if (isUrl) {
                        String patttern =
                            r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?";
                        RegExp regExp = RegExp(patttern);
                        if (!regExp.hasMatch(val)) {
                          return "Please enter valid url.";
                        }
                      }
                      return null;
                    },
                    onSaved: (val) => controller.text = val!,
                    onChanged: onChange ?? (val) {},
                  ),
                )
              : Expanded(
                  child: TextFormField(
                    obscureText: obsecureText,
                    controller: controller,
                    textAlign: TextAlign.start,
                    onTap: onPressed ?? () {},
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      isDense: true,
                      hintText: "Phone Number",
                      labelText: lableText,
                      fillColor: color,
                      filled: true,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: borderColor),
                          borderRadius: getCustomBorderRadius(15)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: borderColor),
                          borderRadius: getCustomBorderRadius(15)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: borderColor),
                          borderRadius: getCustomBorderRadius(15)),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: suffix,
                      ),
                      errorMaxLines: 2,
                      suffixIconConstraints:
                          const BoxConstraints(minHeight: 55, maxWidth: 50),
                      prefixIcon: preffix,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Muli",
                          fontSize: 13),
                      hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Muli",
                          fontSize: 13),
                    ),
                    readOnly: readOnly,
                    maxLines: maxLines,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Muli",
                        fontSize: 13),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: textInputAction,
                    validator: (val) {
                      if (!isRequired) return null;
                      val = val!.trim();
                      // if (!Validator.validatorInstanace.isValidPhone(val)) {
                      //   return "Please enter valid phone no. length should be 7 to 15";
                      // }
                      return null;
                    },
                    onSaved: (val) => controller.text = val!,
                    onChanged: onChange ?? (val) {},
                  ),
                ),
        ],
      ),
    );
  }
}
