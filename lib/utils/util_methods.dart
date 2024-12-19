// Dart imports:
// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_task/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

// Project imports:

class UtilMethods {
  static final UtilMethods utilSharedInstanace = UtilMethods._internal();

  factory UtilMethods() => utilSharedInstanace;

  UtilMethods._internal();

  String capitalize(String val) =>
      "${val[0].toUpperCase()}${val.substring(1).toLowerCase()}";

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyD2BGWy5q1Hl_3ZQIsn9XfBX6_QisZHTMI';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'] != null) {
        return data['results'][0]['formatted_address'];
      }
    }

    return "";
  }

  Future<Map<String, String>> getAllAddressFromLatLng(
      double latitude, double longitude) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyBk3I1Mc-CXfZ2a5nyqQ-5fZ-SCgy0HKH4';
    print(url);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'] != null) {
        final addressComponents = data['results'][0]['address_components'];

        String country = '';
        String state = '';
        String city = '';
        String postalCode = '';

        for (final component in addressComponents) {
          final List<String> types = List<String>.from(component['types']);

          if (types.contains('country')) {
            country = component['long_name'];
          } else if (types.contains('administrative_area_level_1')) {
            state = component['long_name'];
          } else if (types.contains('locality')) {
            city = component['long_name'];
          } else if (types.contains('postal_code')) {
            postalCode = component['long_name'];
          }
        }
        return ({
          'country': country,
          'state': state,
          'city': city,
          "address": data['results'][0]['formatted_address'],
          'postalCode': postalCode
        });
      }
    }

    return ({});
  }


  Future<LocationDataModel?> location(context) async {
    LocationPermission locationPermission;
    LocationDataModel? location;

    // Check for location permission
    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      print("asmhdvas");
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        return null;
      }
    }

    // Check for network connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      myCustomErrorToast("No Internet Connection", context);
      // Handle no internet connectivity
      return null;
    }

    try {
      var position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      var address =
          await getAllAddressFromLatLng(position.latitude, position.longitude);

      location = LocationDataModel(
        address: address['address'].toString(),
        lat: position.latitude,
        city: address['city'].toString(),
        long: position.longitude,
        state: address['state'].toString(),
        country: address['country'].toString(),
        postalCode: address['postalCode'].toString(),
      );

      return location;
    } on PlatformException catch (e) {
      safePrint(e);
      myCustomErrorToast("Network error", context);
      return null;
    } catch (e) {
      // Handle other exceptions
      return null;
    }
  }

  Future<bool> microphone(context) async {
    PermissionStatus microPhonePermission;
    microPhonePermission = await Permission.microphone.status;
    if (microPhonePermission == PermissionStatus.denied ||
        microPhonePermission == PermissionStatus.permanentlyDenied) {
      microPhonePermission = await Permission.microphone.request();
      if (microPhonePermission == PermissionStatus.denied ||
          microPhonePermission == PermissionStatus.permanentlyDenied) {
        microPhonePermission = await Permission.microphone.request();
        return false;
      }
    }
    return true;
  }

  Future<bool> storage(context) async {
    PermissionStatus storagePermission;
    storagePermission = await Permission.storage.status;
    if (storagePermission == PermissionStatus.denied ||
        storagePermission == PermissionStatus.permanentlyDenied) {
      storagePermission = await Permission.storage.request();
      if (storagePermission == PermissionStatus.denied ||
          storagePermission == PermissionStatus.permanentlyDenied) {
        myCustomToast("Microphone Permission Denied", context);
        return false;
      }
    }
    return true;
  }
}

class LocationDataModel {
  String address, city, state, country;
  String postalCode;
  double lat, long;

  LocationDataModel({
    required this.address,
    required this.lat,
    required this.city,
    required this.long,
    required this.state,
    required this.country,
    required this.postalCode,
  });
}
