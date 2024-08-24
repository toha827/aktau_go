import 'package:aktau_go/forms/inputs/phone_formz_input.dart';
import 'package:aktau_go/interactors/authorization_interactor.dart';
import 'package:aktau_go/router/router.dart';
import 'package:aktau_go/ui/otp/otp_screen.dart';
import 'package:aktau_go/utils/logger.dart';
import 'package:aktau_go/utils/text_editing_controller.dart';
import 'package:aktau_go/utils/utils.dart';
import 'package:elementary/elementary.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../forms/phone_login_form.dart';
import 'login_model.dart';
import 'login_screen.dart';

defaultLoginWMFactory(BuildContext context) => LoginWM(LoginModel(
      inject<AuthorizationInteractor>(),
    ));

abstract class ILoginWM implements IWidgetModel {
  StateNotifier<PhoneLoginForm> get phoneLoginForm;

  TextEditingController get phoneTextEditingController;

  MaskTextInputFormatter get phoneFormatter;

  Future<void> submitPhoneLogin();
}

class LoginWM extends WidgetModel<LoginScreen, LoginModel> implements ILoginWM {
  LoginWM(
    LoginModel model,
  ) : super(model);

  @override
  final StateNotifier<PhoneLoginForm> phoneLoginForm = StateNotifier(
    initValue: PhoneLoginForm(),
  );

  @override
  final MaskTextInputFormatter phoneFormatter = MaskTextInputFormatter(
    mask: '+#(###) ###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
    initialText: '+7',
  );

  @override
  late final TextEditingController phoneTextEditingController =
      createTextEditingController(
    initialText: '',
    onChanged: _phoneTextChanged,
  );

  void _phoneTextChanged(String phoneText) {
    PhoneFormzInput phone = PhoneFormzInput.dirty(phoneText);

    phoneLoginForm.accept(phoneLoginForm.value!.copyWith(
      phone: phone,
    ));
  }

  @override
  Future<void> submitPhoneLogin() async {
    try {
      String phoneNumber = phoneLoginForm.value!.phone.value;
      final response = await model.signInByPhone(
        phone: phoneFormatter.unmaskText(phoneNumber),
      );

      Routes.router.navigate(
        Routes.otpScreen,
        args: OtpScreenArgs(
          phoneNumber: phoneNumber,
        ),
      );
    } on Exception catch (e) {
      logger.e(e);
    }
  }
}
