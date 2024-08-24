import 'package:aktau_go/domains/active_request/active_request_domain.dart';
import 'package:aktau_go/interactors/profile_interactor.dart';
import 'package:flutter/material.dart';
import 'package:elementary/elementary.dart';
import 'package:elementary_helper/elementary_helper.dart';

import '../../domains/order_request/order_request_domain.dart';
import '../../domains/user/user_domain.dart';
import '../../interactors/order_requests_interactor.dart';
import '../../utils/logger.dart';
import '../../utils/utils.dart';
import './widgets/order_request_bottom_sheet.dart';
import './orders_model.dart';
import './orders_screen.dart';
import 'widgets/active_order_bottom_sheet.dart';

defaultOrdersWMFactory(BuildContext context) => OrdersWM(OrdersModel(
      inject<OrderRequestsInteractor>(),
      inject<ProfileInteractor>(),
    ));

abstract class IOrdersWM implements IWidgetModel {
  StateNotifier<int> get tabIndex;

  StateNotifier<List<OrderRequestDomain>> get orderRequests;

  StateNotifier<ActiveRequestDomain> get activeOrder;

  StateNotifier<UserDomain> get me;

  void tabIndexChanged(int tabIndex);

  Future<void> fetchOrderRequests();

  Future<void> onOrderRequestTap(OrderRequestDomain e);
}

class OrdersWM extends WidgetModel<OrdersScreen, OrdersModel>
    implements IOrdersWM {
  OrdersWM(
    OrdersModel model,
  ) : super(model);

  @override
  final StateNotifier<int> tabIndex = StateNotifier(initValue: 0);

  @override
  void tabIndexChanged(int tabIndex) {
    this.tabIndex.accept(tabIndex);
  }

  @override
  final StateNotifier<UserDomain> me = StateNotifier();

  @override
  final StateNotifier<List<OrderRequestDomain>> orderRequests = StateNotifier(
    initValue: const [],
  );

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    fetchOrderRequests();
    fetchUserProfile();
    fetchActiveOrder();
  }

  @override
  Future<void> fetchOrderRequests() async {
    try {
      final response = await model.getOrderRequests();
      orderRequests.accept(response);
    } on Exception catch (e) {
      logger.e(e);
    }
  }

  @override
  Future<void> onOrderRequestTap(OrderRequestDomain e) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      builder: (context) => OrderRequestBottomSheet(
        orderRequest: e,
        onAccept: () async {
          await acceptOrderRequest(e);
          Navigator.of(context).pop();
          fetchOrderRequests();
        },
      ),
    );
  }

  Future<void> acceptOrderRequest(OrderRequestDomain orderRequest) async {
    await model.acceptOrderRequest(
      driver: me.value!,
      orderRequest: orderRequest,
    );

    fetchActiveOrder();
  }

  Future<void> fetchUserProfile() async {
    final response = await model.getUserProfile();

    me.accept(response);
  }

  @override
  final StateNotifier<ActiveRequestDomain> activeOrder = StateNotifier();

  void fetchActiveOrder() async {
    final response = await model.getActiveOrder();
    await fetchUserProfile();
    activeOrder.accept(response);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => ActiveOrderBottomSheet(
        me: me.value!,
        activeOrder: activeOrder.value!,
        onCancel: () {},
      ),
    );
  }
}
