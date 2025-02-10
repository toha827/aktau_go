import 'dart:async';
import 'dart:io';

import 'package:elementary_helper/elementary_helper.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';
import 'package:geolocator/geolocator.dart' as geoLocator;

abstract class ILocationInteractor {
  StateNotifier<geoLocator.LocationPermission> get locationStatus;

  StateNotifier<bool> get locationServiceEnabled;

  StateNotifier<LatLng> get userLocation;

  Future<void> requestLocation();
}

@singleton
class LocationInteractor extends ILocationInteractor {
  final SharedPreferences sharedPreferences;

  LocationInteractor(
    this.sharedPreferences,
  );

  late StreamSubscription<LocationData> onUserLocationChanged;

  @override
  final StateNotifier<geoLocator.LocationPermission> locationStatus =
      StateNotifier();

  @override
  StateNotifier<bool> locationServiceEnabled = StateNotifier(
    initValue: false,
  );

  @override
  late final StateNotifier<LatLng> userLocation = StateNotifier(
      initValue: LatLng(
    sharedPreferences.getDouble('latitude') ?? 0,
    sharedPreferences.getDouble('longitude') ?? 0,
  ));

  @override
  Future<geoLocator.LocationPermission?> requestLocation() async {
    Location _location = Location();

    bool? _locationServiceEnabled = await _location.serviceEnabled();
    if (!_locationServiceEnabled) {
      _locationServiceEnabled = await _location.requestService();
    }

    geoLocator.LocationPermission? _permissionGranted =
        await geoLocator.Geolocator.checkPermission();
    if (_permissionGranted == geoLocator.LocationPermission.denied) {
      _permissionGranted = await geoLocator.Geolocator.requestPermission();
    }
    LatLng currentLLatLng;

    /// Get capture the current user location
    if (Platform.isAndroid) {
      geoLocator.Position position =
          await geoLocator.Geolocator.getCurrentPosition(
        locationSettings: geoLocator.LocationSettings(
          accuracy: geoLocator.LocationAccuracy.bestForNavigation,
        ),
      );
      currentLLatLng = LatLng(
        position.latitude,
        position.longitude,
      );
    } else {
      var position = await geoLocator.Geolocator.getLastKnownPosition();
      currentLLatLng = LatLng(
        position?.latitude ?? 0,
        position?.longitude ?? 0,
      );
    }
    // LocationData _locationData = await _location.getLocation();

    sharedPreferences.setDouble('latitude', currentLLatLng.latitude);
    sharedPreferences.setDouble('longitude', currentLLatLng.longitude);

    locationServiceEnabled.accept(_locationServiceEnabled);
    locationStatus.accept(_permissionGranted);

    onUserLocationChanged = _location.onLocationChanged.listen((data) {
      userLocation.accept(LatLng(
        data.latitude!,
        data.longitude!,
      ));
      sharedPreferences.setDouble('latitude', data.latitude!);
      sharedPreferences.setDouble('longitude', data.longitude!);
    });

    return _permissionGranted;
  }
}
