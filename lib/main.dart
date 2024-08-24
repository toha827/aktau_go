import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import './router/router.dart';
import './app.dart';
import 'di/di_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  Routes.initRoutes();
  MapboxOptions.setAccessToken('sk.eyJ1IjoidmFuZGVydmFpeiIsImEiOiJjbTA1azhkNjEwNDF2MmtzNHA0eWJ3eTR0In0.cSGmIeLW1Wc44gyBBWJsYA');
  await initDi(Environment.prod);

  runApp(
    EasyLocalization(
      child: MyApp(),
      supportedLocales: [
        Locale('kk'),
        Locale('ru'),
        Locale('en'),
      ],
      path: 'assets/localizations',
      // <-- change the path of the translation files
      fallbackLocale: Locale('en', 'US'),
    ),
  );
}
