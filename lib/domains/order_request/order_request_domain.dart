import 'package:aktau_go/domains/user/user_domain.dart';

class OrderRequestDomain {
  final String id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? startTime;
  final DateTime? arrivalTime;

  final String driverId;
  final String userPhone;
  final String orderType;
  final String orderStatus;
  final String from;
  final String to;
  final num lat;
  final num lng;
  final num price;
  final String comment;
  final num rating;
  final String sessionid;

  final UserDomain? user;

  const OrderRequestDomain({
    String? id,
    this.createdAt,
    this.updatedAt,
    this.startTime,
    this.arrivalTime,
    String? driverId,
    String? user_phone,
    String? orderType,
    String? orderStatus,
    String? from,
    String? to,
    num? lat,
    num? lng,
    num? price,
    String? comment,
    num? rating,
    String? sessionid,
    UserDomain? user,
  })  : id = id ?? '',
        driverId = driverId ?? '',
        userPhone = user_phone ?? '',
        orderType = orderType ?? '',
        orderStatus = orderStatus ?? '',
        from = from ?? '',
        to = to ?? '',
        lat = lat ?? 0,
        lng = lng ?? 0,
        price = price ?? 0,
        comment = comment ?? '',
        rating = rating ?? 0,
        sessionid = sessionid ?? '',
        user = user ?? const UserDomain();
}
