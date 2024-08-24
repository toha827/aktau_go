import 'package:aktau_go/ui/main/main_screen.dart';
import 'package:aktau_go/ui/registration/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:seafarer/seafarer.dart';

import '../ui/login/login_screen.dart';
import '../ui/otp/otp_screen.dart';

class Routes {
  Routes._();

  static final router = Seafarer(
    options: SeafarerOptions(
      defaultTransitionDuration: Duration(milliseconds: 500),
    ),
  );

  static initRoutes() {
    router.addRoutes([
      SeafarerRoute(
        name: mainScreen,
        builder: (context, args, params) => MainScreen(),
      ),
      SeafarerRoute(
        name: loginScreen,
        builder: (context, args, params) => LoginScreen(
            // popOnSuccess: (args as LoginScreenArgs?)?.popOnSuccess ?? false,
            ),
      ),
      SeafarerRoute(
        name: otpScreen,
        builder: (context, args, params) => OtpScreen(
          phoneNumber: (args as OtpScreenArgs).phoneNumber,
        ),
      ),
      SeafarerRoute(
        name: registrationScreen,
        builder: (context, args, params) => RegistrationScreen(
          phoneNumber: (args as RegistrationScreenArgs).phoneNumber,
        ),
      ),
    ]);
  }

  static const String mainScreen = '/main_screen';
  static const String loginScreen = '/login_screen';
  static const String otpScreen = '/otp_screen';
  static const String registrationScreen = '/registration_screen';
}

class MyCustomTransition extends CustomSeafarerTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = 0.0;
    const end = 1.0;
    var tween = Tween(begin: begin, end: end);
    var curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    );

    return ScaleTransition(
      scale: tween.animate(curvedAnimation),
      child: child,
    );
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}
