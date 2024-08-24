import 'package:json_annotation/json_annotation.dart';

part 'order_request_props_model.g.dart';

@JsonSerializable()
class OrderRequestPropsModel {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  @JsonKey(name: 'driverId', fromJson: _propsToString)
  final String? driverId;
  final String? user_phone;
  final String? orderType;
  final String? orderstatus;
  final String? from;
  final String? to;
  final DateTime? startTime;
  final DateTime? arrivalTime;
  final num? lat;
  final num? lng;
  final num? price;
  final String? comment;
  final num? rating;
  final String? sessionid;

  const OrderRequestPropsModel({
    this.createdAt,
    this.updatedAt,
    this.driverId,
    this.user_phone,
    this.orderType,
    this.orderstatus,
    this.from,
    this.to,
    this.startTime,
    this.arrivalTime,
    this.lat,
    this.lng,
    this.price,
    this.comment,
    this.rating,
    this.sessionid,
  });

  factory OrderRequestPropsModel.fromJson(Map<String, dynamic> json) =>
      _$OrderRequestPropsModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderRequestPropsModelToJson(this);

  static _propsToString(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return json['props']['value'];
  }
}
