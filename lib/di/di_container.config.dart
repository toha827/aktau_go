// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:aktau_go/interactors/authorization_interactor.dart' as _i12;
import 'package:aktau_go/interactors/common/rest_client.dart' as _i10;
import 'package:aktau_go/interactors/order_requests_interactor.dart' as _i13;
import 'package:aktau_go/interactors/profile_interactor.dart' as _i14;
import 'package:aktau_go/interactors/session_interactor.dart' as _i11;
import 'package:aktau_go/modules/dio/base/material_message_controller.dart'
    as _i5;
import 'package:aktau_go/modules/dio/base/standard_error_handler.dart' as _i7;
import 'package:aktau_go/modules/dio/dio_module.dart' as _i9;
import 'package:aktau_go/modules/flavor/flavor.dart' as _i3;
import 'package:aktau_go/modules/flavor/flavor_interactor.dart' as _i4;
import 'package:aktau_go/modules/shared_preferences_module.dart' as _i15;
import 'package:dio/dio.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i6;

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
  await gh.factoryAsync<_i6.SharedPreferences>(
    () => sharedPreferencesModule.prefs,
    preResolve: true,
  );
  gh.singleton<_i7.StandardErrorHandler>(
      () => _i7.StandardErrorHandler(gh<_i5.MaterialMessageController>()));
  gh.lazySingleton<_i8.Dio>(() => dioModule.getDio(gh<_i3.Flavor>()));
  gh.singleton<_i9.DioInteractor>(() => _i9.DioInteractor(gh<_i8.Dio>()));
  gh.singleton<_i10.RestClient>(() => _i10.RestClient(gh<_i8.Dio>()));
  gh.lazySingleton<_i11.SessionInteractor>(
      () => _i11.SessionInteractor(gh<_i6.SharedPreferences>()));
  gh.singleton<_i12.AuthorizationInteractor>(() => _i12.AuthorizationInteractor(
        gh<_i10.RestClient>(),
        gh<_i11.SessionInteractor>(),
      ));
  gh.singleton<_i13.OrderRequestsInteractor>(
      () => _i13.OrderRequestsInteractor(gh<_i10.RestClient>()));
  gh.singleton<_i14.ProfileInteractor>(
      () => _i14.ProfileInteractor(gh<_i10.RestClient>()));
  return getIt;
}

class _$SharedPreferencesModule extends _i15.SharedPreferencesModule {}

class _$DioModule extends _i9.DioModule {}
