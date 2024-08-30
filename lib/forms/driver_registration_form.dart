import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../ui/driver_registration/driver_registration_wm.dart';
import './inputs/required_formz_input.dart';
import './inputs/ssn_formz_input.dart';

class DriverRegistrationForm with FormzMixin, EquatableMixin {
  final Required<String> governmentNumber;
  final Required<String> model;
  final Required<String> brand;
  final Required<CarColor> color;
  final Required<DriverType> type;
  final SSNFormzInput SSN;

  DriverRegistrationForm({
    this.governmentNumber = const Required.pure(),
    this.type = const Required.pure(),
    this.model = const Required.pure(),
    this.brand = const Required.pure(),
    this.color = const Required.pure(),
    this.SSN = const SSNFormzInput.pure(),
  });

  @override
  List<FormzInput> get inputs => [
        governmentNumber,
        type,
        model,
        brand,
        color,
        SSN,
      ];

  @override
  List<Object?> get props => [
        governmentNumber,
        type,
        model,
        brand,
        color,
        SSN,
      ];

  DriverRegistrationForm copyWith({
    Required<String>? governmentNumber,
    Required<DriverType>? type,
    Required<String>? model,
    Required<String>? brand,
    Required<CarColor>? color,
    SSNFormzInput? SSN,
  }) =>
      DriverRegistrationForm(
        governmentNumber: governmentNumber ?? this.governmentNumber,
        type: type ?? this.type,
        model: model ?? this.model,
        brand: brand ?? this.brand,
        color: color ?? this.color,
        SSN: SSN ?? this.SSN,
      );
}

enum DriverType {
  TAXI,
  DELIVERY,
  INTERCITY_TAXI,
  CARGO,
}

extension IdentityStatusTypeExt on DriverType {
  static const keyMap = {
    DriverType.TAXI: "TAXI",
    DriverType.DELIVERY: "DELIVERY",
    DriverType.INTERCITY_TAXI: "INTERCITY_TAXI",
    DriverType.CARGO: "CARGO",
  };

  static const valueMap = {
    DriverType.TAXI: "Такси",
    DriverType.DELIVERY: "Доставка",
    DriverType.INTERCITY_TAXI: "Межгород",
    DriverType.CARGO: "Груз",
  };

  String? get value => valueMap[this];

  String? get key => keyMap[this];
}
