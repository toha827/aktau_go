// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_request_props_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderRequestPropsModel _$OrderRequestPropsModelFromJson(
        Map<String, dynamic> json) =>
    OrderRequestPropsModel(
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      driverId: OrderRequestPropsModel._propsToString(
          json['driverId'] as Map<String, dynamic>?),
      user_phone: json['user_phone'] as String?,
      orderType: json['orderType'] as String?,
      orderstatus: json['orderstatus'] as String?,
      from: json['from'] as String?,
      to: json['to'] as String?,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      arrivalTime: json['arrivalTime'] == null
          ? null
          : DateTime.parse(json['arrivalTime'] as String),
      lat: json['lat'] as num?,
      lng: json['lng'] as num?,
      price: json['price'] as num?,
      comment: json['comment'] as String?,
      rating: json['rating'] as num?,
      sessionid: json['sessionid'] as String?,
    );

Map<String, dynamic> _$OrderRequestPropsModelToJson(
        OrderRequestPropsModel instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'driverId': instance.driverId,
      'user_phone': instance.user_phone,
      'orderType': instance.orderType,
      'orderstatus': instance.orderstatus,
      'from': instance.from,
      'to': instance.to,
      'startTime': instance.startTime?.toIso8601String(),
      'arrivalTime': instance.arrivalTime?.toIso8601String(),
      'lat': instance.lat,
      'lng': instance.lng,
      'price': instance.price,
      'comment': instance.comment,
      'rating': instance.rating,
      'sessionid': instance.sessionid,
    };
