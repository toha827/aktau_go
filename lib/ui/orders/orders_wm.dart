import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aktau_go/domains/active_request/active_request_domain.dart';
import 'package:aktau_go/forms/driver_registration_form.dart';
import 'package:aktau_go/interactors/profile_interactor.dart';
import 'package:flutter/material.dart';
import 'package:elementary/elementary.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../core/colors.dart';
import '../../core/images.dart';
import '../../core/text_styles.dart';
import '../../domains/driver_registered_category/driver_registered_category_domain.dart';
import '../../domains/order_request/order_request_domain.dart';
import '../../domains/user/user_domain.dart';
import '../../interactors/order_requests_interactor.dart';
import '../../router/router.dart';
import '../../utils/logger.dart';
import '../../utils/utils.dart';
import '../widgets/primary_bottom_sheet.dart';
import '../widgets/primary_button.dart';
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

  StateNotifier<List<DriverRegisteredCategoryDomain>>
      get driverRegisteredCategories;

  StateNotifier<UserDomain> get me;

  StateNotifier<bool> get showNewOrders;

  StateNotifier<bool> get isWebsocketConnected;

  StateNotifier<LocationPermission> get locationPermission;

  StateNotifier<DriverType> get orderType;

  StateNotifier<Position> get driverPosition;

  ValueNotifier<bool> get statusController;

  StateNotifier<bool> get isOrderRejected;

  void tabIndexChanged(int tabIndex);

  Future<void> fetchOrderRequests();

  Future<void> onOrderRequestTap(OrderRequestDomain e);

  void tapNewOrders();

  void requestLocationPermission();

  void registerOrderType();
}

class OrdersWM extends WidgetModel<OrdersScreen, OrdersModel>
    with WidgetsBindingObserver
    implements IOrdersWM {
  OrdersWM(
    OrdersModel model,
  ) : super(model);

  IO.Socket? newOrderSocket;

  @override
  final StateNotifier<int> tabIndex = StateNotifier(
    initValue: 0,
  );

  @override
  final ValueNotifier<bool> statusController = ValueNotifier(false);

  @override
  final StateNotifier<bool> showNewOrders = StateNotifier(
    initValue: false,
  );

  @override
  final StateNotifier<bool> isWebsocketConnected = StateNotifier(
    initValue: false,
  );

  @override
  final StateNotifier<bool> isOrderRejected = StateNotifier(
    initValue: false,
  );

  @override
  final StateNotifier<DriverType> orderType = StateNotifier(
    initValue: DriverType.TAXI,
  );

  @override
  final StateNotifier<List<DriverRegisteredCategoryDomain>>
      driverRegisteredCategories = StateNotifier(
    initValue: const [],
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
  final StateNotifier<Position> driverPosition = StateNotifier();

  @override
  final StateNotifier<List<OrderRequestDomain>> orderRequests = StateNotifier(
    initValue: const [],
  );

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    fetchDriverRegisteredCategories();
    fetchOrderRequests();
    fetchUserProfile();
    fetchActiveOrder();
    statusController.addListener(() async {
      if (statusController.value) {
        await initializeSocket();
      } else {
        await disconnectWebsocket();
      }
    });
    // Timer.periodic(
    //   Duration(seconds: 10),
    //   (timer) {
    //     fetchOrderRequestsCount();
    //   },
    // );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    fetchOrderRequests();
    initializeSocket();
  }

  Future<void> fetchDriverRegisteredCategories() async {
    try {
      final response =
          await inject<ProfileInteractor>().fetchDriverRegisteredCategories();

      driverRegisteredCategories.accept(response);
    } on Exception catch (e) {
      logger.e(e);
    }
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
    try {
      final response = await model.getUserProfile();

      me.accept(response);

      await initializeSocket();
    } on Exception catch (e) {
      logger.e(e);
    }
  }

  @override
  final StateNotifier<ActiveRequestDomain> activeOrder = StateNotifier();

  void fetchActiveOrder({
    bool openBottomSheet = true,
  }) async {
    try {
      final response = await model.getActiveOrder();
      await fetchUserProfile();
      activeOrder.accept(response);
      if (openBottomSheet) {
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => ActiveOrderBottomSheet(
            me: me.value!,
            activeOrder: activeOrder.value!,
            activeOrderListener: activeOrder,
            onCancel: () {},
          ),
        );
      }
    } on Exception catch (e) {
      logger.e(e);
      if (!openBottomSheet) {
        Navigator.of(context).popUntil(
          (predicate) => predicate.isFirst,
        );
        final snackBar = SnackBar(
          content: Text(
            'Заказ был отменен',
          ),
        );
        fetchOrderRequests();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  void tapNewOrders() {
    fetchOrderRequests();
  }

  Future<void> initializeSocket() async {
    try {
      await _determinePosition();

      newOrderSocket = IO.io(
        'https://taxi.aktau-go.kz',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'force new connection': true,
          'query': {
            'userId': me.value!.id,
          },
        },
      );

      newOrderSocket?.onError((_) => logger.w(_));
      newOrderSocket?.onConnect(
        (_) {
          logger.w(_);
          isWebsocketConnected.accept(true);
          statusController.value = true;

          newOrderSocket?.emit(
            'updateLocation',
            jsonEncode(
              {
                "driverId": me.value!.id,
                "latitude": driverPosition.value?.latitude.toString(),
                "longitude": driverPosition.value?.longitude.toString(),
              },
            ),
          );
        },
      );

      newOrderSocket?.on('orderRejected', (data) async {
        print('Received new order: $data');
        // Обработка полученных данных
        fetchActiveOrder(
          openBottomSheet: false,
        );
        isOrderRejected.accept(true);
        await showModalBottomSheet(
          context: context,
          isDismissible: true,
          isScrollControlled: true,
          builder: (context) => PrimaryBottomSheet(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: greyscale30,
                      borderRadius: BorderRadius.circular(1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SvgPicture.asset(icPlacemarkError),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Поездка отклонена',
                    style: text500Size20Greyscale90,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton.primary(
                    onPressed: () async {
                      isOrderRejected.accept(false);
                      Navigator.of(context).pop();
                    },
                    text: 'Закрыть',
                    textStyle: text400Size16White,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
        // showNewOrders.accept(true);
      });

      newOrderSocket?.on('newOrder', (data) {
        print('Received new order: $data');
        // Обработка полученных данных
        fetchOrderRequests();
        // showNewOrders.accept(true);
      });
      newOrderSocket?.onDisconnect((_) {
        logger.e(_);
        isWebsocketConnected.accept(false);
        statusController.value = false;
        if (_ != 'io client disconnect') {
          initializeSocket();
        }
      });
      newOrderSocket?.connect();

      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 3,
        ),
      ).listen(
        (position) {
          newOrderSocket?.emit(
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

  Future<void> disconnectWebsocket() async {
    newOrderSocket?.disconnect();
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
      final response = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );
      driverPosition.accept(response);

      Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      ).listen((position) {
        driverPosition.accept(position);
      });
    }

    permission = await Geolocator.checkPermission();
    locationPermission.accept(permission);
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

  @override
  final StateNotifier<LocationPermission> locationPermission = StateNotifier();

  @override
  Future<void> requestLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    locationPermission.accept(permission);
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      locationPermission.accept(permission);
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      openAppSettings();
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  @override
  Future<void> registerOrderType() async {
    await Routes.router.navigate(Routes.driverRegistrationScreen);
    await fetchDriverRegisteredCategories();
    await fetchOrderRequests();
  }
}
