import 'package:aktau_go/models/order_request/order_request_model.dart';
import 'package:aktau_go/models/user/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../order_request/order_request_props_model.dart';
import '../props/props_model.dart';

part 'active_client_request_model.g.dart';

@JsonSerializable()
class ActiveClientRequestModel {
  final OrderRequestPropsModel? order;
  final UserModel? driver;

  const ActiveClientRequestModel({
    this.order,
    this.driver,
  });

  factory ActiveClientRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ActiveClientRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActiveClientRequestModelToJson(this);
}
