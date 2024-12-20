// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:aktau_go/interactors/authorization_interactor.dart' as _i13;
import 'package:aktau_go/interactors/common/rest_client.dart' as _i11;
import 'package:aktau_go/interactors/food_interactor.dart' as _i14;
import 'package:aktau_go/interactors/main_navigation_interactor.dart' as _i15;
import 'package:aktau_go/interactors/notification_interactor.dart' as _i6;
import 'package:aktau_go/interactors/order_requests_interactor.dart' as _i16;
import 'package:aktau_go/interactors/profile_interactor.dart' as _i17;
import 'package:aktau_go/interactors/session_interactor.dart' as _i12;
import 'package:aktau_go/modules/dio/base/material_message_controller.dart'
    as _i5;
import 'package:aktau_go/modules/dio/base/standard_error_handler.dart' as _i8;
import 'package:aktau_go/modules/dio/dio_module.dart' as _i10;
import 'package:aktau_go/modules/flavor/flavor.dart' as _i3;
import 'package:aktau_go/modules/flavor/flavor_interactor.dart' as _i4;
import 'package:aktau_go/modules/shared_preferences_module.dart' as _i18;
import 'package:dio/dio.dart' as _i9;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i7;

const String _prod = 'prod';
const String _test = 'test';
const String _dev = 'dev';

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i1.GetIt> init(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final sharedPreferencesModule = _$SharedPreferencesModule();
  final dioModule = _$DioModule();
  gh.factory<_i3.Flavor>(
    () => _i3.ProdFlavor(),
    registerFor: {_prod},
  );
  gh.factory<_i3.Flavor>(
    () => _i3.QAFlavor(),
    registerFor: {_test},
  );
  gh.factory<_i3.Flavor>(
    () => _i3.DevFlavor(),
    registerFor: {_dev},
  );
  gh.singleton<_i4.FlavorInteractor>(
      () => _i4.FlavorInteractor(gh<_i3.Flavor>()));
  gh.factory<_i5.MaterialMessageController>(
      () => _i5.MaterialMessageController());
  gh.singleton<_i6.NotificationInteractor>(() => _i6.NotificationInteractor());
  await gh.factoryAsync<_i7.SharedPreferences>(
    () => sharedPreferencesModule.prefs,
    preResolve: true,
  );
  gh.singleton<_i8.StandardErrorHandler>(
      () => _i8.StandardErrorHandler(gh<_i5.MaterialMessageController>()));
  gh.lazySingleton<_i9.Dio>(() => dioModule.getDio(gh<_i3.Flavor>()));
  gh.singleton<_i10.DioInteractor>(() => _i10.DioInteractor(gh<_i9.Dio>()));
  gh.singleton<_i11.RestClient>(() => _i11.RestClient(gh<_i9.Dio>()));
  gh.lazySingleton<_i12.SessionInteractor>(() => _i12.SessionInteractor(
        gh<_i7.SharedPreferences>(),
        gh<_i11.RestClient>(),
      ));
  gh.singleton<_i13.AuthorizationInteractor>(() => _i13.AuthorizationInteractor(
        gh<_i11.RestClient>(),
        gh<_i12.SessionInteractor>(),
      ));
  gh.singleton<_i14.FoodInteractor>(
      () => _i14.FoodInteractor(gh<_i11.RestClient>()));
  gh.singleton<_i15.MainNavigationInteractor>(
      () => _i15.MainNavigationInteractor(gh<_i12.SessionInteractor>()));
  gh.singleton<_i16.OrderRequestsInteractor>(
      () => _i16.OrderRequestsInteractor(gh<_i11.RestClient>()));
  gh.singleton<_i17.ProfileInteractor>(
      () => _i17.ProfileInteractor(gh<_i11.RestClient>()));
  return getIt;
}

class _$SharedPreferencesModule extends _i18.SharedPreferencesModule {}

class _$DioModule extends _i10.DioModule {}
