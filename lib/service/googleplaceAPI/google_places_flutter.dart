// ignore_for_file: library_private_types_in_public_api

library google_places_flutter;


import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

import '../../utils/utils.dart';
import 'dio_error_handler.dart';
import 'model/place_details.dart';
import 'model/prediction.dart';

class GooglePlaceAutoCompleteTextField extends StatefulWidget {
  InputDecoration inputDecoration;
  ItemClick? itemClick;
  GetPlaceDetailswWithLatLng? getPlaceDetailWithLatLng;
  bool isLatLngRequired = true;

  TextStyle textStyle;
  String googleAPIKey;
  int debounceTime = 600;
  List<String>? countries = [];
  TextEditingController textEditingController = TextEditingController();
  ListItemBuilder? itemBuilder;
  Widget? seperatedBuilder;
  void clearData;
  BoxDecoration? boxDecoration;
  bool isCrossBtnShown;
  bool showError;
  double? containerHorizontalPadding;
  double? containerVerticalPadding;
  String? Function(String? val)? validator;

  GooglePlaceAutoCompleteTextField(
      {super.key, required this.textEditingController,
      required this.googleAPIKey,
      this.debounceTime= 600,
        required this.validator,
      this.inputDecoration= const InputDecoration(),
      this.itemClick,
      this.isLatLngRequired = true,
      this.textStyle= const TextStyle(),
      this.countries,
      this.getPlaceDetailWithLatLng,
      this.itemBuilder,
      this.boxDecoration,
      this.isCrossBtnShown = true,
      this.seperatedBuilder,this.showError=true,this
      .containerHorizontalPadding,this.containerVerticalPadding});

  @override
  _GooglePlaceAutoCompleteTextFieldState createState() =>
      _GooglePlaceAutoCompleteTextFieldState();
}

class _GooglePlaceAutoCompleteTextFieldState
    extends State<GooglePlaceAutoCompleteTextField> {
  final subject =  PublishSubject<String>();
  OverlayEntry? _overlayEntry;
  List<Prediction> alPredictions = [];

  TextEditingController controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  bool isSearched = false;

  bool isCrossBtn = true;
  late var _dio;

  CancelToken? _cancelToken = CancelToken();




  @override
  Widget build(BuildContext context) {

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: widget.containerHorizontalPadding??0, vertical: widget.containerVerticalPadding??0),
        alignment: Alignment.centerLeft,
        // decoration: widget.boxDecoration ??
        //     BoxDecoration(
        //         shape: BoxShape.rectangle,
        //         border: Border.all(color: Colors.grey, width: 0.6),
        //         borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: TextFormField(
                decoration: widget.inputDecoration,
                style: widget.textStyle,
                controller: widget.textEditingController,
                validator: widget.validator,
                onChanged: (string) {
                  subject.add(string);
                  if (widget.isCrossBtnShown) {
                    isCrossBtn = string.isNotEmpty ? true : false;
                    setState(() {});
                  }
                },
              ),
            ),
            (!widget.isCrossBtnShown)
                ? const SizedBox()
                : isCrossBtn && _showCrossIconWidget()
                    ? IconButton(onPressed: clearData, icon: const Icon(Icons.close))
                    : const SizedBox()
          ],
        ),
      ),
    );
  }

  getLocation(String text) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$text&key=${widget.googleAPIKey}";

    if (widget.countries != null) {
      // in

      for (int i = 0; i < widget.countries!.length; i++) {
        String country = widget.countries![i];

        if (i == 0) {
          url = "$url&components=country:$country";
        } else {
          url = "$url|country:$country";
        }
      }
    }

    if (_cancelToken?.isCancelled == false) {
      _cancelToken?.cancel();
      _cancelToken = CancelToken();
    }


    try {
      Response response = await _dio.get(url);
      if(!mounted){
        return;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      Map map = response.data;
      if (map.containsKey("error_message")) {
        throw response.data;
      }

      PlacesAutocompleteResponse subscriptionResponse =
          PlacesAutocompleteResponse.fromJson(response.data);

      if (text.isEmpty) {
        alPredictions.clear();
        _overlayEntry!.remove();
        return;
      }

      isSearched = false;
      alPredictions.clear();
      if (subscriptionResponse.predictions!.isNotEmpty && (widget.textEditingController.text.toString().trim()).isNotEmpty) {
        alPredictions.addAll(subscriptionResponse.predictions!);
      }


      _overlayEntry = null;
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } catch (e) {
      var errorHandler = ErrorHandler.internal().handleError(e);
      _showSnackBar("${errorHandler.message}");
    }
  }

  @override
  void initState() {
    super.initState();
    _dio = Dio();
    subject.stream
        .distinct()
        .debounceTime(Duration(milliseconds: widget.debounceTime))
        .listen(textChanged);
  }

  textChanged(String text) async {
    getLocation(text);
  }

  OverlayEntry? _createOverlayEntry() {
    if (context != null && context.findRenderObject() != null) {
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      var size = renderBox.size;
      var offset = renderBox.localToGlobal(Offset.zero);
      return OverlayEntry(
          builder: (context) => Positioned(
                left: offset.dx,
                top: size.height + offset.dy,
                width: size.width,
                child: CompositedTransformFollower(
                  showWhenUnlinked: false,
                  link: _layerLink,
                  offset: Offset(0.0, size.height + 5.0),
                  child: Material(
                      child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: alPredictions.length,
                    separatorBuilder: (context, pos) =>
                        widget.seperatedBuilder ?? const SizedBox(),
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          var selectedData = alPredictions[index];
                          if (index < alPredictions.length) {
                            widget.itemClick!(selectedData);

                            if (widget.isLatLngRequired) {
                              getPlaceDetailsFromPlaceId(selectedData);
                            }
                            removeOverlay();
                          }
                        },
                        child: widget.itemBuilder != null
                            ? widget.itemBuilder!(
                                context, index, alPredictions[index])
                            : Container(
                                padding: const EdgeInsets.all(10),
                                child: Text(alPredictions[index].description!)),
                      );
                    },
                  )),
                ),
              ));
    }
  }

  removeOverlay() {
    alPredictions.clear();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _overlayEntry!.markNeedsBuild();
    }

  Future<Response?> getPlaceDetailsFromPlaceId(Prediction prediction) async {
    //String key = GlobalConfiguration().getString('google_maps_key');

    var url =
        "https://maps.googleapis.com/maps/api/place/details/json?placeid=${prediction.placeId}&key=${widget.googleAPIKey}";
    Response response = await Dio().get(
      url,
    );

    PlaceDetails placeDetails = PlaceDetails.fromJson(response.data);

    prediction.lat = placeDetails.result!.geometry!.location!.lat.toString();
    prediction.lng = placeDetails.result!.geometry!.location!.lng.toString();

    widget.getPlaceDetailWithLatLng!(prediction);
  }

  void clearData() {
    widget.textEditingController.clear();
    if (_cancelToken?.isCancelled == false) {
      _cancelToken?.cancel();
    }

    setState(() {
      alPredictions.clear();
      isCrossBtn = false;
    });

    if (_overlayEntry != null) {
      try {
        _overlayEntry?.remove();
      } catch (e) {
        safePrint(e);
      }
    }
  }

  _showCrossIconWidget() {
    return (widget.textEditingController.text.isNotEmpty);
  }

  _showSnackBar(String errorData) {
    if(widget.showError){
      final snackBar = SnackBar(
        content: Text(errorData),
      );

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

  }
}

PlacesAutocompleteResponse parseResponse(Map responseBody) {
  return PlacesAutocompleteResponse.fromJson(
      responseBody as Map<String, dynamic>);
}

PlaceDetails parsePlaceDetailMap(Map responseBody) {
  return PlaceDetails.fromJson(responseBody as Map<String, dynamic>);
}

typedef ItemClick = void Function(Prediction postalCodeResponse);
typedef GetPlaceDetailswWithLatLng = void Function(
    Prediction postalCodeResponse);

typedef ListItemBuilder = Widget Function(
    BuildContext context, int index, Prediction prediction);
