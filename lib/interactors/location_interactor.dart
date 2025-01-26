import 'dart:async';

import 'package:elementary_helper/elementary_helper.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

abstract class ILocationInteractor {
  StateNotifier<PermissionStatus> get locationStatus;

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
  final StateNotifier<PermissionStatus> locationStatus = StateNotifier();

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
  Future<PermissionStatus?> requestLocation() async {
    Location _location = Location();

    bool? _locationServiceEnabled = await _location.serviceEnabled();
    if (!_locationServiceEnabled) {
      _locationServiceEnabled = await _location.requestService();
    }

    PermissionStatus? _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
    }

    /// Get capture the current user location
    LocationData _locationData = await _location.getLocation();
    LatLng currentLLatLng = LatLng(
      _locationData.latitude!,
      _locationData.longitude!,
    );

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
