// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: UserModel._propsToString(json['_id'] as Map<String, dynamic>?),
      props: json['props'] == null
          ? null
          : UserPropsModel.fromJson(json['props'] as Map<String, dynamic>),
      rating: json['rating'] as num?,
      earnings: json['earnings'] == null
          ? null
          : EarningsModel.fromJson(json['earnings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      '_id': instance.id,
      'props': instance.props,
      'rating': instance.rating,
      'earnings': instance.earnings,
    };
