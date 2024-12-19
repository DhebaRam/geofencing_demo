// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../commons/api_loader.dart';
import '../commons/base_button.dart';
import '../commons/google_places_flutter.dart';
import '../utils/util_methods.dart';
import '../utils/utils.dart';
import 'googleplaceAPI/model/prediction.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(26.912434, 75.787270),
    zoom: 15.0,
  );
  CameraPosition _position = _kInitialPosition;
  bool isMapCreated = false;
  final bool isMoving = false;
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
  final bool _myTrafficEnabled = false;
  final bool _myLocationButtonEnabled = true;
  late GoogleMapController _controller;
  double? latitude;
  double? longtitude;
  String? city;
  String? region;
  String? country;
  String? postalCode;
  final TextEditingController _locationController = TextEditingController();

  bool isPermissionDenied = false;

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future _init() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showLoader(context);
    });
    final location = await UtilMethods.utilSharedInstanace.location(context);
    if (location != null) {
      _position = CameraPosition(
        target: LatLng(location.lat, location.long),
        zoom: 15.0,
      );
      final GoogleMapController controller = _controller;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        _position,
      ));
      setState(() {
        _controller = controller;
      });
      latitude = location.lat;
      longtitude = location.long;
      _addMarker(LatLng(location.lat, location.long));
      String address = location.address;
      country = location.country.toString();
      region = location.state.toString();
      city = location.city.toString();
      postalCode = location.postalCode.toString();
      _locationController.text = address;
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

  @override
  void dispose() {
    super.dispose();
  }

  void _addMarker(LatLng location) {
    setState(() {
      markers = {
        Marker(
          markerId: MarkerId(location.toString()),
          position: location,
          onTap: () async {},
        ),
      };
    });
  }

  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _position,
      compassEnabled: _compassEnabled,
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
      myLocationEnabled: _myLocationEnabled,
      myLocationButtonEnabled: _myLocationButtonEnabled,
      trafficEnabled: _myTrafficEnabled,
      markers: markers,
      onCameraMove: _updateCameraPosition,
      onTap: (LatLng location) async {
        _position = CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: 15.0,
        );
        final GoogleMapController controller = _controller;
        controller.animateCamera(CameraUpdate.newCameraPosition(
          _position,
        ));

        latitude = location.latitude;
        longtitude = location.longitude;
        _addMarker(location);
        var address = await UtilMethods.utilSharedInstanace
            .getAllAddressFromLatLng(latitude!, longtitude!);
        _locationController.text = address['address'].toString();
        city = address['address'].toString();
        region = address['state'].toString();
        country = address['country'].toString();
        postalCode = address['postalCode'].toString();
        setState(() {
          _controller = controller;
        });
      },
    );

    return Scaffold(
        bottomSheet: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              _locationController.text.isNotEmpty
                  ? Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  color: Colors.black),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: addText(_locationController.text, 12,
                                      Colors.black45, FontWeight.w400))
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        InkWell(
                          onTap: _init,
                          child: const Icon(Icons.gps_fixed_sharp,
                              color: Colors.black),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
              const SizedBox(
                height: 30,
              ),
              BaseButton(
                title: !isPermissionDenied
                    ? 'Confirm Location'
                    : "Give Location Permission",
                onPressed: () async {
                  if (!isPermissionDenied) {
                    var address = await UtilMethods.utilSharedInstanace
                        .getAllAddressFromLatLng(latitude!, longtitude!);
                    address['lat'] = latitude.toString();
                    address['long'] = longtitude.toString();
                    if (!mounted) {
                      return;
                    }
                    Navigator.pop(context, address);
                  } else {
                    openAppSettings().then((value) => _init());
                  }
                },
                btnHeight: 50,
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: InkWell(
            child: const Icon(Icons.arrow_back),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          title:
              addText("Search Location", 16, Colors.black45, FontWeight.w500),
        ),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            googleMap,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: SafeArea(
                  child: SizedBox(
                height: 70,
                child: GooglePlaceAutoCompleteTextField(
                    textEditingController: _locationController,
                    isCrossBtnShown: false,
                    textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: MediaQuery.of(context).size.width / 30) ??
                        const TextStyle(),
                    validator: (val) {
                      if (val!.isEmpty) return "Please enter location";
                      return null;
                    },
                    googleAPIKey: "AIzaSyD2BGWy5q1Hl_3ZQIsn9XfBX6_QisZHTMI",
                    inputDecoration: InputDecoration(
                      // contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black38),
                          borderRadius: getCustomBorderRadius(15)),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.black),
                          borderRadius: getCustomBorderRadius(15)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(width: 1, color: Colors.blue),
                          borderRadius: getCustomBorderRadius(15)),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Search Location",
                      // hintMaxLines: null,
                      hintStyle: const TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Muli",
                          fontSize: 13),
                      suffixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Icon(Icons.search, color: Colors.black)),
                      suffixIconConstraints:
                          const BoxConstraints(minHeight: 30, maxWidth: 40),
                    ),
                    debounceTime: 800,
                    // default 600 ms,
                    isLatLngRequired: true,
                    // if you required coordinates from place detail
                    getPlaceDetailWithLatLng: (Prediction prediction) async {
                      // this method will return latlng with place detail
                      // _lat=double.parse(prediction.lat.toString());
                      // _long=double.parse(prediction.lng.toString());
                      setState(() {});
                      _position = CameraPosition(
                        target: LatLng(double.parse(prediction.lat.toString()),
                            double.parse(prediction.lng.toString())),
                        zoom: 15.0,
                      );
                      final GoogleMapController controller = _controller;
                      controller.animateCamera(CameraUpdate.newCameraPosition(
                        _position,
                      ));

                      setState(() {
                        _controller = controller;
                      });
                      latitude = double.parse(prediction.lat.toString());
                      longtitude = double.parse(prediction.lng.toString());
                      _addMarker(LatLng(double.parse(prediction.lat.toString()),
                          double.parse(prediction.lng.toString())));
                      var address = await UtilMethods.utilSharedInstanace
                          .getAllAddressFromLatLng(latitude!, longtitude!);
                      _locationController.text = address['address'].toString();
                      city = address['city'].toString();
                      region = address['state'].toString();
                      country = address['country'].toString();
                      postalCode = address['postalCode'].toString();
                      if (!mounted) {
                        return;
                      }
                      Navigator.pop(context);
                    },
                    // this callback is called when isLatLngRequired is true
                    itemClick: (Prediction prediction) {
                      showLoader(context);
                      _locationController.text = prediction.description!;
                      _locationController.selection =
                          TextSelection.fromPosition(TextPosition(
                              offset: prediction.description!.length));
                    }),
              )),
            ),
          ],
        ));
  }

  void _updateCameraPosition(CameraPosition position) {
    setState(() {
      _position = position;
    });
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      isMapCreated = true;
    });
  }
}
