// ignore_for_file: deprecated_member_use, unused_field

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_task/utils/util_methods.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../commons/api_loader.dart';
import '../../commons/my_textform_field.dart';
import '../../service/googlemap_screen.dart';
import '../../service/navigation_widget.dart';
import '../../service/notification_service.dart';
import '../../utils/utils.dart';
import '../controller/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isPermissionDenied = false;
  double? latitude;
  double? longtitude;

  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(26.912434, 75.787270),
    zoom: 15.0,
  );
  CameraPosition _position = _kInitialPosition;
  bool isMapCreated = false;
  final bool _compassEnabled = true;
  final bool _mapToolbarEnabled = true;
  final CameraTargetBounds _cameraTargetBounds = CameraTargetBounds.unbounded;
  final MinMaxZoomPreference _minMaxZoomPreference =
      MinMaxZoomPreference.unbounded;
  final MapType _mapType = MapType.normal;
  final bool _rotateGesturesEnabled = true;
  final bool _scrollGesturesEnabled = true;
  final bool _tiltGesturesEnabled = true;
  final bool _zoomControlsEnabled = false;
  final bool _zoomGesturesEnabled = true;
  final bool _indoorViewEnabled = true;
  final bool _myLocationEnabled = false;
  final bool _myTrafficEnabled = true;
  final bool _myLocationButtonEnabled = true;
  late GoogleMapController _controller;
  final TextEditingController _addressController = TextEditingController();

  void _addMarker(LatLng location, String address) async {
    markers.removeWhere((marker) => marker.markerId.toString() == "current");
    setState(() {
      markers.add(
        Marker(
          markerId: const MarkerId("current"),
          position: location,
          infoWindow: InfoWindow(title: address),
          onTap: () async {},
        ),
      );
    });
  }

  void _circlesMarker(LatLng location, String address) async {
    markers.removeWhere((marker) => marker.markerId.toString() == "current");
    setState(() {
      circles.add(
        Circle(
          circleId: const CircleId("current"),
          center: location,
          radius: 50,
          fillColor: Colors.blue.withOpacity(0.6),
          onTap: () async {},
        ),
      );
    });
  }

  Set<Marker> markers = {};
  Set<Circle> circles = {};
  Circle? geofenceCircle;
  bool isInsideGeofence = false;

  @override
  void initState() {
    NotificationService.initialize();
    _init();
    _startLocationTracking();
    super.initState();
  }

  void _startLocationTracking() {
    Geolocator.getPositionStream().listen((Position position) {
      print("object ===== > ${position}");
      final userLocation = LatLng(position.latitude, position.longitude);

      if (geofenceCircle != null) {
        final distance = Geolocator.distanceBetween(
          userLocation.latitude,
          userLocation.longitude,
          geofenceCircle!.center.latitude,
          geofenceCircle!.center.longitude,
        );

        if (distance <= geofenceCircle!.radius) {
          if (!isInsideGeofence) {
            isInsideGeofence = true;
            NotificationService.normaldisplay(1, "Geofence Alert.",
                "You entered the geofenced area.", context);
          }
        } else {
          if (isInsideGeofence) {
            isInsideGeofence = false;
            NotificationService.normaldisplay(
                1, "Geofence Alert", "You exited the geofenced area.", context);
          }
        }
      }
    });
  }

  Future _init() async {
    markers.clear();
    circles.clear();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showLoader(context);
    });

    final location = await UtilMethods.utilSharedInstanace.location(context);
    if (location != null) {
      _position = CameraPosition(
        target: LatLng(location.lat, location.long),
        zoom: 17.0,
      );
      final GoogleMapController controller = _controller;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        _position,
      ));
      setState(() {
        _controller = controller;
      });
      _addMarker(LatLng(location.lat, location.long), location.address);
      _circlesMarker(LatLng(location.lat, location.long), location.address);
      latitude = location.lat;
      longtitude = location.long;
      _addressController.text = location.address;

      isPermissionDenied = false;
    } else {
      isPermissionDenied = true;
    }

    if (!mounted) {
      return;
    }
    Navigator.pop(context);
    setState(() {});
  }

  void _updateCameraPosition(CameraPosition position) {
    setState(() {
      _position = position;
    });
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      //_controller.setMapStyle(HomeProvider.homeSharedInstanace.customMapStyle);
      isMapCreated = true;
    });
  }

  void _setGeofence(LatLng location) {
    print('Method Called');
    setState(() {
      geofenceCircle = Circle(
        circleId: const CircleId("geofence"),
        center: location,
        radius: 50,
        fillColor: Colors.blue.withOpacity(0.5),
        strokeColor: Colors.blueAccent,
        strokeWidth: 2,
      );
      circles.add(geofenceCircle!);
      NotificationService.normaldisplay(
          1,
          "Geofence Set",
          "Geofence set at ${location.latitude}, ${location.longitude}",
          context);
    });
  }

  Future<void> _goToMyLocation() async {
    final location = await UtilMethods.utilSharedInstanace.location(context);
    if (location != null) {
      _position = CameraPosition(
        target: LatLng(location.lat, location.long),
        zoom: 17.0,
      );
      final GoogleMapController controller = _controller;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(location.lat, location.long), zoom: 15),
      ));
      setState(() {
        _controller = controller;
      });
      _addMarker(LatLng(location.lat, location.long), location.address);
      _circlesMarker(LatLng(location.lat, location.long), location.address);
      latitude = location.lat;
      longtitude = location.long;
      _addressController.text = location.address;
    }
  }

  final FocusNode _focusNode = FocusNode();

  TextEditingController searchTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _position,
      compassEnabled: false,
      mapToolbarEnabled: _mapToolbarEnabled,
      cameraTargetBounds: _cameraTargetBounds,
      minMaxZoomPreference: _minMaxZoomPreference,
      mapType: _mapType,
      rotateGesturesEnabled: _rotateGesturesEnabled,
      scrollGesturesEnabled: _scrollGesturesEnabled,
      tiltGesturesEnabled: _tiltGesturesEnabled,
      zoomGesturesEnabled: _zoomGesturesEnabled,
      zoomControlsEnabled: _zoomControlsEnabled,
      indoorViewEnabled: _indoorViewEnabled,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      trafficEnabled: _myTrafficEnabled,
      markers: markers,
      circles: circles,
      onTap: (LatLng tappedLocation) {
        _setGeofence(tappedLocation);
      },
      onCameraMove: _updateCameraPosition,
    );
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            googleMap,
            Consumer<HomeProvider>(builder: (context, homeGarageList, child) {
              return Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.all(15),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  // Set a specific width or adjust as needed
                  decoration: BoxDecoration(
                    borderRadius: getBorderRadius(),
                    color: Colors.grey,
                    border: Border.all(
                      color: Colors.transparent,
                      width: 0.3,
                    ),
                  ),
                  // padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: MyTextFormField(
                    controller: searchTitleController,
                    hintText: "Search Location",
                    readOnly: true,
                    onPressed: () {
                      pushTo(context, const GoogleMapScreen()).then((value) {
                        if (value != null) {
                          searchTitleController.text = value['address'];
                          _setGeofence(LatLng(double.parse("${value["lat"]}"), double.parse("${value["long"]}")));
                        }
                      });
                    },
                  ),
                ),
              );
            }),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _goToMyLocation,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
