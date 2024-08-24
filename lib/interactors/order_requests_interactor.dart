import 'package:aktau_go/domains/active_request/active_request_domain.dart';
import 'package:aktau_go/domains/user/user_domain.dart';
import 'package:aktau_go/models/active_request/mapper/active_request_mapper.dart';
import 'package:injectable/injectable.dart';
import 'package:aktau_go/domains/order_request/order_request_domain.dart';
import 'package:aktau_go/interactors/common/rest_client.dart';
import 'package:aktau_go/models/order_request/mapper/order_request_mapper.dart';

abstract class IOrderRequestsInteractor {
  Future<List<OrderRequestDomain>> getOrderRequests();

  Future<void> acceptOrderRequest({
    required UserDomain driver,
    required OrderRequestDomain orderRequest,
  });

  Future<void> arrivedOrderRequest({
    required UserDomain driver,
    required OrderRequestDomain orderRequest,
  });

  Future<void> startOrderRequest({
    required UserDomain driver,
    required OrderRequestDomain orderRequest,
  });

  Future<void> endOrderRequest({
    required UserDomain driver,
    required OrderRequestDomain orderRequest,
  });

  Future<ActiveRequestDomain> getActiveOrder();

  Future<List<ActiveRequestDomain>> getHistoryOrders();
}

@singleton
class OrderRequestsInteractor extends IOrderRequestsInteractor {
  final RestClient _restClient;

  OrderRequestsInteractor(
    RestClient restClient,
  ) : _restClient = restClient;

  @override
  Future<List<OrderRequestDomain>> getOrderRequests() async =>
      orderRequestListMapper(await _restClient.getPendingOrderRequests());

  @override
  Future<void> acceptOrderRequest({
    required UserDomain driver,
    required OrderRequestDomain orderRequest,
  }) =>
      _restClient.acceptOrderRequest(
        driverId: driver.id,
        orderRequestId: orderRequest.id,
      );

  @override
  Future<ActiveRequestDomain> getActiveOrder() async =>
      activeRequestMapper(await _restClient.getMyActiveOrder());

  @override
  Future<void> arrivedOrderRequest({
    required UserDomain driver,
    required OrderRequestDomain orderRequest,
  }) =>
      _restClient.arrivedOrderRequest(
        driverId: driver.id,
        orderRequestId: orderRequest.id,
      );

  @override
  Future<void> endOrderRequest({
    required UserDomain driver,
    required OrderRequestDomain orderRequest,
  }) =>
      _restClient.endOrderRequest(
        driverId: driver.id,
        orderRequestId: orderRequest.id,
      );

  @override
  Future<void> startOrderRequest({
    required UserDomain driver,
    required OrderRequestDomain orderRequest,
  }) =>
      _restClient.startOrderRequest(
        driverId: driver.id,
        orderRequestId: orderRequest.id,
      );

  @override
  Future<List<ActiveRequestDomain>> getHistoryOrders() async =>
      activeRequestListMapper(await _restClient.getHistoryOrders());
}
