import 'package:aktau_go/models/active_request/active_request_model.dart';
import 'package:aktau_go/models/user/user_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../models/order_request/order_request_response_model.dart';
import '../../models/sign_in/sign_in_by_phone_confirm_code_response_model.dart';
import '../../models/sign_in/sign_in_by_phone_response_model.dart';

part 'rest_client.g.dart';

@singleton
@RestApi()
abstract class RestClient {
  @factoryMethod
  factory RestClient(Dio dio) = _RestClient;

  /// запрос профиля пользователя
  @POST('v1/user/sing-in-by-phone')
  Future<SignInByPhoneResponseModel> signInByPhone({
    @Field('phone') required String phone,
  });

  /// запрос профиля пользователя
  @POST('v1/user/sing-in-by-phone-confirm-code')
  Future<SignInByPhoneConfirmCodeResponseModel> signInByPhoneConfirmCode({
    @Field('phone') required String phone,
    @Field('smscode') required String smsCode,
  });

  /// запрос профиля пользователя
  @POST('v1/user/sing-up-by-phone')
  Future<SignInByPhoneConfirmCodeResponseModel> signUpByPhone({
    @Field('phone') required String phone,
    @Field('firstName') required String firstName,
    @Field('lastName') required String lastName,
  });

  /// запрос профиля пользователя
  @GET('v1/order-requests/active-orders')
  Future<List<OrderRequestResponseModel>> getPendingOrderRequests();

  /// запрос профиля пользователя
  @GET('v1/user/GetMe')
  Future<UserModel> getUserProfile();

  /// запрос профиля пользователя
  @POST('v1/order-requests/accept')
  Future<void> acceptOrderRequest({
    @Field('driverId') required String driverId,
    @Field('orderId') required String orderRequestId,
  });

  /// запрос профиля пользователя
  @POST('v1/order-requests/driver-arrived')
  Future<void> arrivedOrderRequest({
    @Field('driverId') required String driverId,
    @Field('orderId') required String orderRequestId,
  });

  /// запрос профиля пользователя
  @POST('v1/order-requests/start')
  Future<void> startOrderRequest({
    @Field('driverId') required String driverId,
    @Field('orderId') required String orderRequestId,
  });

  /// запрос профиля пользователя
  @POST('v1/order-requests/end')
  Future<void> endOrderRequest({
    @Field('driverId') required String driverId,
    @Field('orderId') required String orderRequestId,
  });

  /// запрос профиля пользователя
  @GET('v1/order-requests/my-active-order')
  Future<ActiveRequestModel> getMyActiveOrder();

  /// запрос профиля пользователя
  @GET('v1/order-requests/history')
  Future<List<ActiveRequestModel>> getHistoryOrders();
}
