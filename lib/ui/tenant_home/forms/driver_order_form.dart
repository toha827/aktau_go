import 'package:aktau_go/forms/inputs/required_formz_input.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

class DriverOrderForm with EquatableMixin, FormzMixin {
  final Required<String> fromAddress;
  final Required<String> toAddress;
  final Required<num> cost;
  final String comment;

  DriverOrderForm({
    this.fromAddress = const Required.pure(),
    this.toAddress = const Required.pure(),
    this.cost = const Required.pure(),
    this.comment = '',
  });

  @override
  List<FormzInput> get inputs => [
        fromAddress,
        toAddress,
        cost,
      ];

  @override
  List<Object?> get props => [
        fromAddress,
        toAddress,
        cost,
        comment,
      ];

  DriverOrderForm copyWith({
    Required<String>? fromAddress,
    Required<String>? toAddress,
    Required<num>? cost,
    String? comment,
  }) =>
      DriverOrderForm(
        fromAddress: fromAddress ?? this.fromAddress,
        toAddress: toAddress ?? this.toAddress,
        cost: cost ?? this.cost,
        comment: comment ?? this.comment,
      );
}
