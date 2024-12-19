import 'dart:io';
import 'package:flutter/material.dart';

class HomeProvider with ChangeNotifier {
  static final HomeProvider homeSharedInstanace = HomeProvider._internal();

  factory HomeProvider() => homeSharedInstanace;

  HomeProvider._internal();

  String? _message;

  String? get message => _message;

  List<String> servicesType = [];

  String? serviceType;

  dynamic stripeCharge;
  dynamic adminCharge;

  String? initialGarageCategory;
  String? initialGarageCategoryId;

  changeWorkshopCategory(String category, String categoryId) {
    initialGarageCategory = category;
    initialGarageCategoryId = categoryId;
    notifyListeners();
  }
}
