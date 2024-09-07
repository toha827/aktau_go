import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aktau_go/domains/active_request/active_request_domain.dart';
import 'package:aktau_go/forms/driver_registration_form.dart';
import 'package:aktau_go/interactors/profile_interactor.dart';
import 'package:flutter/material.dart';
import 'package:elementary/elementary.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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

  StateNotifier<bool> get showNewOrders;

  StateNotifier<DriverType> get orderType;

  void tabIndexChanged(int tabIndex);

  Future<void> fetchOrderRequests();

  Future<void> onOrderRequestTap(OrderRequestDomain e);

  void tapNewOrders();
}

class OrdersWM extends WidgetModel<OrdersScreen, OrdersModel>
    implements IOrdersWM {
  OrdersWM(
    OrdersModel model,
  ) : super(model);

  late final IO.Socket newOrderSocket;

  @override
  final StateNotifier<int> tabIndex = StateNotifier(
    initValue: 0,
  );

  @override
  final StateNotifier<bool> showNewOrders = StateNotifier(
    initValue: false,
  );

  @override
  final StateNotifier<DriverType> orderType = StateNotifier(
    initValue: DriverType.TAXI,
  );

  @override
  void tabIndexChanged(int tabIndex) {
    this.tabIndex.accept(tabIndex);
    orderType.accept(DriverType.values[tabIndex]);
    fetchOrderRequests();
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

    // Timer.periodic(
    //   Duration(seconds: 10),
    //   (timer) {
    //     fetchOrderRequestsCount();
    //   },
    // );
  }

  @override
  Future<void> fetchOrderRequests() async {
    try {
      final response = await model.getOrderRequests(
        type: orderType.value!,
      );
      orderRequests.accept(response);
      showNewOrders.accept(false);
    } on Exception catch (e) {
      logger.e(e);
    }
  }

  Future<void> fetchOrderRequestsCount() async {
    try {
      final response = await model.getOrderRequests(
        type: orderType.value!,
      );
      // orderRequests.accept(response);

      if (response.length != orderRequests.value!.length) {
        showNewOrders.accept(true);
      }
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
      useSafeArea: true,
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

    initializeSocket();
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
      useSafeArea: true,
      builder: (context) => ActiveOrderBottomSheet(
        me: me.value!,
        activeOrder: activeOrder.value!,
        onCancel: () {},
      ),
    );
  }

  @override
  void tapNewOrders() {
    fetchOrderRequests();
  }

  Future<void> initializeSocket() async {
    try {
      await _determinePosition();

      var location = await Geolocator.getCurrentPosition();

      newOrderSocket = IO.io(
        'https://taxi.aktau-go.kz',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'query': {
            'userId': 'fb437deb-32db-4e4a-8c3e-3fb7c0f532e1',
            // Замена параметром userId
          },
        },
      );
      logger.w('https://taxi.aktau-go.kz/?userId=${me.value!.id}');
      newOrderSocket.onConnect((_) {
        logger.w(_);
        logger.w('ASDASDASDADSASDASD ${{
          "driverId": me.value!.id,
          "latitude": location.latitude,
          "longitude": location.longitude,
        }}');
        newOrderSocket.emit(
          'updateLocation',
          jsonEncode(
            {
              "driverId": me.value!.id,
              "latitude": location.latitude.toString(),
              "longitude": location.longitude.toString(),
            },
          ),
        );
      });
      newOrderSocket.on('newOrder', (data) {
        print('Received new order: $data');
        // Обработка полученных данных
        fetchOrderRequests();
        // showNewOrders.accept(true);
      });
      newOrderSocket.onDisconnect((_) => logger.e('disconnect'));
      newOrderSocket.connect();

      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 3,
        ),
      ).listen(
        (position) {
          newOrderSocket.emit(
            'updateLocation',
            jsonEncode(
              {
                "driverId": me.value!.id,
                "latitude": position.latitude.toString(),
                "longitude": position.longitude.toString(),
              },
            ),
          );
        },
      );
    } on Exception catch (e) {
      logger.e(e);
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.requestPermission();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }
}
