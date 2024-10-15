import 'dart:convert';

import 'package:aktau_go/core/text_styles.dart';
import 'package:aktau_go/interactors/order_requests_interactor.dart';
import 'package:aktau_go/interactors/profile_interactor.dart';
import 'package:aktau_go/ui/widgets/primary_bottom_sheet.dart';
import 'package:aktau_go/ui/widgets/primary_button.dart';
import 'package:aktau_go/utils/text_editing_controller.dart';
import 'package:elementary/elementary.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart' as geoLocator;
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../core/colors.dart';
import '../../domains/active_request/active_request_domain.dart';
import '../../domains/food/food_category_domain.dart';
import '../../domains/food/food_domain.dart';
import '../../domains/user/user_domain.dart';
import '../../forms/driver_registration_form.dart';
import '../../interactors/common/rest_client.dart';
import '../../interactors/food_interactor.dart';
import '../../models/active_client_request/active_client_request_model.dart';
import '../../utils/logger.dart';
import '../../utils/utils.dart';
import '../orders/widgets/active_order_bottom_sheet.dart';
import '../widgets/rounded_text_field.dart';
import './forms/driver_order_form.dart';

import './tenant_home_model.dart';
import './tenant_home_screen.dart';
import 'widgets/active_client_order_bottom_sheet.dart';

defaultTenantHomeWMFactory(BuildContext context) => TenantHomeWM(
      TenantHomeModel(
        inject<FoodInteractor>(),
        inject<ProfileInteractor>(),
        inject<OrderRequestsInteractor>(),
      ),
    );

abstract class ITenantHomeWM implements IWidgetModel {
  MapboxMap get mapboxMapController;

  StateNotifier<LatLng> get userLocation;

  StateNotifier<geoLocator.LocationPermission> get locationPermission;

  TabController get tabController;

  StateNotifier<int> get currentTab;

  StateNotifier<List<FoodCategoryDomain>> get foodCategories;

  EntityStateNotifier<List<FoodDomain>> get foods;

  StateNotifier<ActiveClientRequestModel> get activeOrder;

  StateNotifier<UserDomain> get me;

  Future<void> determineLocationPermission();

  void onMapCreated(MapboxMap controller);

  void tabIndexChanged(int newTabIndex);

  Future<void> onSubmit(DriverOrderForm form, DriverType taxi);

  void cancelActiveClientOrder();
}

class TenantHomeWM extends WidgetModel<TenantHomeScreen, TenantHomeModel>
    with SingleTickerProviderWidgetModelMixin
    implements ITenantHomeWM {
  TenantHomeWM(
    TenantHomeModel model,
  ) : super(model);

  IO.Socket? newOrderSocket;

  @override
  final StateNotifier<LatLng> userLocation = StateNotifier(
    initValue: const LatLng(
      43.693695,
      51.260834,
    ),
  );

  @override
  late MapboxMap mapboxMapController;

  @override
  late final TabController tabController = TabController(
    length: 4,
    vsync: this,
  );

  @override
  final StateNotifier<int> currentTab = StateNotifier(
    initValue: 0,
  );

  @override
  final StateNotifier<double> rateTaxi = StateNotifier(
    initValue: 0,
  );

  @override
  final StateNotifier<List<FoodCategoryDomain>> foodCategories = StateNotifier(
    initValue: const [],
  );

  @override
  final EntityStateNotifier<List<FoodDomain>> foods = EntityStateNotifier();
  @override
  final StateNotifier<ActiveClientRequestModel> activeOrder = StateNotifier();

  @override
  final StateNotifier<UserDomain> me = StateNotifier();

  @override
  final StateNotifier<geoLocator.LocationPermission> locationPermission =
      StateNotifier();

  late final TextEditingController commentTextController =
      createTextEditingController();

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    fetchUserProfile();
    fetchFoods();
    fetchActiveOrder();
  }

  @override
  Future<void> determineLocationPermission() async {
    bool serviceEnabled;
    geoLocator.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await geoLocator.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await geoLocator.Geolocator.requestPermission();
    }

    permission = await geoLocator.Geolocator.checkPermission();
    locationPermission.accept(permission);
    if (permission == geoLocator.LocationPermission.denied) {
      permission = await geoLocator.Geolocator.requestPermission();
      if (permission == geoLocator.LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == geoLocator.LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  @override
  Future<void> onMapCreated(MapboxMap controller) async {
    mapboxMapController = controller;
    determineLocationPermission();

    var location = await geoLocator.Geolocator.getCurrentPosition();

    userLocation.accept(
      LatLng(
        location.latitude,
        location.longitude,
      ),
    );

    mapboxMapController.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            location.longitude,
            location.latitude,
          ),
        ),
        zoom: 17,
        bearing: 180,
        pitch: 30,
      ),
      MapAnimationOptions(duration: 2000, startDelay: 0),
    );
  }

  @override
  void tabIndexChanged(int newTabIndex) {
    currentTab.accept(newTabIndex);
    tabController.animateTo(newTabIndex);
  }

  Future<void> fetchFoods() async {
    foods.loading();

    try {
      final response = await model.fetchFoods();
      foodCategories.accept(response.folders);
      foods.content(response.items);
    } on Exception catch (e) {
      logger.e(e);
    }
  }

  Future<void> fetchUserProfile() async {
    final response = await model.getUserProfile();

    me.accept(response);

    initializeSocket();
  }

  @override
  Future<void> onSubmit(DriverOrderForm form, DriverType taxi) async {
    await inject<RestClient>().createDriverOrder(body: {
      "from": form.fromAddress.value,
      "to": form.toAddress.value,
      "lng": userLocation.value?.longitude,
      "lat": userLocation.value?.latitude,
      "price": form.cost.value,
      "orderType": taxi.key,
      "comment": form.comment,
    });

    fetchActiveOrder();
  }

  Future<void> initializeSocket() async {
    try {
      await determineLocationPermission();

      newOrderSocket = IO.io(
        'https://taxi.aktau-go.kz',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'query': {
            'userId': me.value!.id,
          },
        },
      );

      newOrderSocket?.on('orderRejected', (data) {
        print('Received new order: $data');
        // Обработка полученных данных
        // fetchActiveOrder(
        //   openBottomSheet: false,
        // );
        // showNewOrders.accept(true);
        fetchActiveOrder();
      });

      newOrderSocket?.on('orderStarted', (data) {
        print('Received new order: $data');
        // Обработка полученных данных
        // fetchActiveOrder(
        //   openBottomSheet: false,
        // );
        // showNewOrders.accept(true);
        fetchActiveOrder();
      });

      newOrderSocket?.on('driverArrived', (data) {
        print('Received new order: $data');
        // Обработка полученных данных
        // fetchActiveOrder(
        //   openBottomSheet: false,
        // );
        // showNewOrders.accept(true);
        fetchActiveOrder();
      });

      newOrderSocket?.on('rideStarted', (data) {
        print('Received new order: $data');
        // Обработка полученных данных
        // fetchActiveOrder(
        //   openBottomSheet: false,
        // );
        // showNewOrders.accept(true);
        fetchActiveOrder();
      });

      newOrderSocket?.on('rideEnded', (data) {
        print('Received new order: $data');
        // Обработка полученных данных
        // fetchActiveOrder(
        //   openBottomSheet: false,
        // );
        // showNewOrders.accept(true);
        fetchActiveOrder();
      });

      newOrderSocket?.on('orderAccepted', (data) {
        print('Received new order: $data');
        // Обработка полученных данных
        // fetchActiveOrder(
        //   openBottomSheet: false,
        // );
        // showNewOrders.accept(true);
        fetchActiveOrder();
      });

      newOrderSocket?.on('driverLocation', (data) {
        print('Received new order: $data');
        // Обработка полученных данных
        // fetchActiveOrder(
        //   openBottomSheet: false,
        // );
        // showNewOrders.accept(true);
        fetchActiveOrder();
      });

      newOrderSocket?.onDisconnect((_) {
        // isWebsocketConnected.accept(false);
        // statusController.value = false;
        initializeSocket();
      });
      newOrderSocket?.connect();
    } on Exception catch (e) {
      logger.e(e);
    }
  }

  Future<void> disconnectWebsocket() async {
    newOrderSocket?.disconnect();
  }

  Future<void> fetchActiveOrder() async {
    try {
      final response = await model.getMyClientActiveOrder();
      if (response.order?.orderStatus == 'COMPLETED' &&
          response.order?.rating == null) {
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
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Заказ завершён, поставьте оценку',
                    style: text500Size20Greyscale90,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: StateNotifierBuilder(
                    listenableState: rateTaxi,
                    builder: (
                      context,
                      double? rateTaxi,
                    ) {
                      return Center(
                        child: RatingStars(
                          value: rateTaxi ?? 0,
                          onValueChanged: (value) {
                            this.rateTaxi.accept(value);
                          },
                          starBuilder: (
                            index,
                            color,
                          ) =>
                              index >= (rateTaxi ?? 0)
                                  ? SvgPicture.asset('assets/icons/star.svg')
                                  : SvgPicture.asset(
                                      'assets/icons/star.svg',
                                      color: color,
                                    ),
                          starCount: 5,
                          starSize: 48,
                          maxValue: 5,
                          starSpacing: 16,
                          maxValueVisibility: false,
                          valueLabelVisibility: false,
                          animationDuration: Duration(
                            milliseconds: 1000,
                          ),
                          starOffColor: greyscale50,
                          starColor: primaryColor,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 48,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: RoundedTextField(
                    backgroundColor: Colors.white,
                    controller: commentTextController,
                    hintText: 'Ваш комментарий',
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton.primary(
                    onPressed: () async {
                      await inject<RestClient>().makeReview(body: {
                        "orderRequestId": response.order!.id,
                        "comment": commentTextController.text,
                        "rating": rateTaxi.value,
                      });
                      Navigator.of(context).pop();
                      fetchActiveOrder();
                    },
                    text: 'Отправить',
                    textStyle: text400Size16White,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }
      if (response.order?.orderStatus != 'COMPLETED') {
        activeOrder.accept(response);
      }
    } on Exception catch (e) {
      activeOrder.accept(null);
      // TODO
    }
    // showModalBottomSheet(
    //   context: context,
    //   isDismissible: false,
    //   enableDrag: false,
    //   isScrollControlled: true,
    //   useSafeArea: true,
    //   builder: (context) => ActiveClientOrderBottomSheet(
    //     me: me.value!,
    //     activeOrder: activeOrder.value!,
    //     activeOrderListener: activeOrder,
    //     onCancel: () {
    //       model.rejectOrderByClientRequest(
    //         orderRequestId: activeOrder.value!.order!.id!,
    //       );
    //     },
    //   ),
    // );
  }

  @override
  Future<void> cancelActiveClientOrder() async {
    await model.rejectOrderByClientRequest(
      orderRequestId: activeOrder.value!.order!.id!,
    );
    fetchActiveOrder();
  }
}
