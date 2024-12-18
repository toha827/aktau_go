import 'package:aktau_go/core/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seafarer/seafarer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/common_strings.dart';
import '../../di/di_container.dart';
import '../../interactors/session_interactor.dart';
import '../../router/router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/launcher_icon.png'),
      ),
    );
  }

  Future<void> _initializeApp() async {
    SharedPreferences storage = await SharedPreferences.getInstance();
    await getIt<SessionInteractor>().checkAccessTokenExpired();
    if ((storage.getString(ACCESS_TOKEN) ?? '').isNotEmpty) {
      Routes.router.navigate(
        Routes.mainScreen,
        navigationType: NavigationType.pushReplace,
      );
    } else {
      Routes.router.navigate(
        Routes.loginScreen,
        navigationType: NavigationType.pushReplace,
      );
    }
  }
}
