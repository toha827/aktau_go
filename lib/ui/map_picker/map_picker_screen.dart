import 'dart:async';

import 'package:aktau_go/core/colors.dart';
import 'package:aktau_go/core/text_styles.dart';
import 'package:aktau_go/interactors/common/map_tiler_cloud_api/map_tiler_cloud_api.dart';
import 'package:aktau_go/interactors/location_interactor.dart';
import 'package:aktau_go/ui/widgets/primary_button.dart';
import 'package:aktau_go/utils/utils.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:geolocator/geolocator.dart' as geoLocator;
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:location/location.dart';
import 'package:seafarer/seafarer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/map_tiler/map_tiler_geo_coding_response.dart';
import '../../router/router.dart';
import '../../utils/text_editing_controller.dart';
import '../orders/widgets/order_request_bottom_sheet.dart';

class MapAddressPickerScreenArgs extends BaseArguments {
  final Function(
    LatLng latLng,
    String placeName,
  ) onSubmit;

  final Function(
    Features prediction,
  )? onSubmit2;

  MapAddressPickerScreenArgs({
    required this.onSubmit,
    this.onSubmit2,
  });
}

class MapAddressPickerScreen extends StatefulWidget {
  final MapAddressPickerScreenArgs args;

  const MapAddressPickerScreen({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  State<MapAddressPickerScreen> createState() => _MapAddressPickerScreenState();
}

class _MapAddressPickerScreenState extends State<MapAddressPickerScreen> {
  final MapController _mapController = MapController();
  late TextEditingController _textFieldController = createTextEditingController(
    initialText: '',
    onChanged: onPlaceSearchChanged,
  );
  bool _showDeleteButton = false;

  // late final MapboxMapController _mapController;

  // late latlong2.LatLng latlng = sharedPreference.getLatLngFromSharedPrefs();
  List<Features> suggestions = [];
  latlong2.LatLng? latlng;
  bool myLocationEnabled = false;
  String _addressName = '';
  Features? _selectedGooglePredictions;
  Features? _selectedGooglePlace;
  bool isLoading = false;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeMap();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _textFieldController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void _clearText() {
    _textFieldController.clear();
    setState(() {
      _showDeleteButton = false;
    });
  }

  Future<void> _updateAddressName(double latitude, double longitude) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await inject<MapTilerCloudApi>().geoCoding(
        latitude: latitude,
        longitude: longitude,
        accessToken: 'HcgJnGUrEU9K93fPa6qG',
      );

      if ((response.features?.first.text ?? '').isNotEmpty) {
        final placeName = response.features?.first.text;

        setState(() {
          _addressName = placeName ?? '';
          _selectedGooglePlace = response.features?.first;
          _selectedGooglePredictions = response.features?.first;
        });
      }
    } on Exception catch (e) {
      // TODO
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DoubleSourceBuilder(
          firstSource: inject<LocationInteractor>().locationStatus,
          secondSource: inject<LocationInteractor>().userLocation,
          builder: (
            context,
            geoLocator.LocationPermission? locationStatus,
            latlong2.LatLng? userLocation,
          ) {
            // if (![PermissionStatus.granted, PermissionStatus.grantedLimited]
            //     .contains(locationStatus)) {
            //   return SafeArea(
            //       child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Center(
            //           child:
            //               lottie.Lottie.asset('assets/lottie/no_location.json'),
            //         ),
            //         Container(
            //           width: double.infinity,
            //           margin: const EdgeInsets.only(bottom: 16),
            //           child: Text(
            //             'Пожалуйста, разрешите доступ к вашему местоположению',
            //             style: text500Size20Greyscale90,
            //             textAlign: TextAlign.center,
            //           ),
            //         ),
            //         Container(
            //           width: double.infinity,
            //           margin: const EdgeInsets.only(bottom: 16),
            //           child: Text(
            //             'Поделитесь вашим местоположением или введите вручную',
            //             style: text500Size12Greyscale90,
            //             textAlign: TextAlign.center,
            //           ),
            //         ),
            //         PrimaryButton.primary(
            //           onPressed: inject<LocationInteractor>().requestLocation,
            //           text: 'Поделиться местополежием',
            //         )
            //       ],
            //     ),
            //   ));placemark
            // }
            return Stack(
              children: [
                Positioned.fill(
                  child: FlutterMap(
                    options: MapOptions(
                      minZoom: 7,
                      // maxZoom: 16,
                      initialCenter: userLocation != null
                          ? latlong2.LatLng(
                              userLocation.latitude, userLocation.longitude)
                          : latlng ?? latlong2.LatLng(43.239337, 76.893156),
                      initialZoom: 13,
                    ),
                    mapController: _mapController,
                    children: [
                      openStreetMapTileLayer,
                      CurrentLocationLayer(),
                    ],
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.center_focus_weak_sharp,
                    size: 50,
                    color: primaryColor,
                  ),
                ),
                Positioned(
                  bottom: 50,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      if (myLocationEnabled) {
                        // serviceLocator<UserLocationCubit>()
                        //     .disposeUserLocationListener();
                      } else {
                        _mapController.move(
                          userLocation != null
                              ? latlong2.LatLng(userLocation!.latitude,
                                  userLocation!.longitude)
                              : latlng ?? latlong2.LatLng(43.239337, 76.893156),
                          14,
                        );
                        inject<LocationInteractor>().requestLocation();
                      }
                      setState(() {
                        myLocationEnabled = !myLocationEnabled;
                      });
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.my_location,
                        color: myLocationEnabled ? primaryColor : null,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 54,
                  left: 24,
                  right: 24,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: Routes.router.pop,
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 17,
                              color: Color(0xff7A7A7A),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white,
                          ),
                          child: EasyAutocomplete(
                            controller: _textFieldController,
                            asyncSuggestions: getSuggestions,
                            progressIndicatorBuilder: Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ).copyWith(
                                top: 14,
                                bottom: 13,
                              ),
                              border: InputBorder.none,
                              hintText: 'Введите адресс'.tr(),
                              hintStyle: text400Size12Greyscale30,
                              suffixIcon: _showDeleteButton
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.cancel,
                                        color: primaryColor,
                                      ),
                                      onPressed: _clearText,
                                    )
                                  : null,
                            ),
                            suggestionBuilder: (String json) {
                              return ListTile(
                                title: Text(json),
                              );
                            },
                            onChanged: (String json) async {
                              Features feature = suggestions.firstWhere(
                                  (element) => element.text == json);

                              _mapController.move(
                                latlong2.LatLng(
                                  feature.center![1],
                                  feature.center![0],
                                ),
                                14,
                              );
                              setState(() {
                                _addressName = feature.text ?? '';
                                _selectedGooglePredictions = feature;
                                _selectedGooglePlace = feature;
                              });
                              widget.args.onSubmit(
                                LatLng(
                                  feature.center![1],
                                  feature.center![0],
                                ),
                                feature.text ?? '',
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedPositioned(
                  bottom: _addressName.isNotEmpty ? 100 : -200,
                  left: 16,
                  right: 16,
                  child: isLoading
                      ? Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Container(
                          height: _addressName.isNotEmpty ? 100 : 0,
                          width: MediaQuery.of(context).size.width * 0.8,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  _addressName,
                                  textAlign: TextAlign.center,
                                  style: text500Size16Greyscale90,
                                ),
                              ),
                              SizedBox(
                                width: 140,
                                child: PrimaryButton.primary(
                                  height: 30,
                                  onPressed: () async {
                                    final coordinates =
                                        await _mapController.camera.center;
                                    widget.args.onSubmit(
                                      LatLng(
                                        coordinates.latitude,
                                        coordinates.longitude,
                                      ),
                                      _addressName,
                                    );
                                    widget.args.onSubmit2?.call(
                                      _selectedGooglePredictions!,
                                    );
                                    Routes.router.pop();
                                  },
                                  child: Text(
                                    'Выбрать'.tr(),
                                    style: text400Size16White,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  duration: Duration(
                    milliseconds: 600,
                  ),
                ),
              ],
            );
          }),
    );
  }

  Future<List<String>> getSuggestions(String query) async {
    try {
      final response = await inject<MapTilerCloudApi>().geoCodingByQuery(
        query: query,
        accessToken: 'HcgJnGUrEU9K93fPa6qG',
      );

      suggestions = response.features ?? [];
      return response.features?.map((e) => e.text ?? '').toList() ?? [];
    } on Exception catch (e) {}
    return [];
  }

  onPlaceSearchChanged(String searchValue) {
    setState(() {
      _showDeleteButton = _textFieldController.text.isNotEmpty;
    });
  }

  Future<void> initializeMap() async {
    await inject<LocationInteractor>().requestLocation();
    latlng = latlong2.LatLng(
      inject<SharedPreferences>().getDouble('latitude') ?? 0,
      inject<SharedPreferences>().getDouble('longitude') ?? 0,
    );

    _mapController.mapEventStream.listen((event) {
      if (event.source == MapEventSource.mapController) {
        return;
      }
      final coordinates = _mapController.camera.center;
      // final center = coordinates.northeast;
      if (timer?.isActive ?? false) {
        timer!.cancel();
      }
      timer = Timer(
        Duration(seconds: 1),
        () => _updateAddressName(
          coordinates!.latitude,
          coordinates.longitude,
        ),
      );
    });
  }
}
