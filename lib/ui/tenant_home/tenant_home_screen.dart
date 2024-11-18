import 'package:aktau_go/core/images.dart';
import 'package:aktau_go/domains/food/food_category_domain.dart';
import 'package:aktau_go/domains/food/food_domain.dart';
import 'package:aktau_go/ui/tenant_home/widgets/tenant_home_create_food_view.dart';
import 'package:aktau_go/ui/tenant_home/widgets/tenant_home_create_order_view.dart';
import 'package:aktau_go/ui/tenant_home/widgets/tenant_home_tab_view.dart';
import 'package:aktau_go/ui/widgets/primary_bottom_sheet.dart';
import 'package:aktau_go/ui/widgets/primary_button.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/material.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../../domains/user/user_domain.dart';
import '../../forms/driver_registration_form.dart';
import '../../models/active_client_request/active_client_request_model.dart';
import '../orders/widgets/order_request_bottom_sheet.dart';
import './tenant_home_wm.dart';
import 'widgets/active_client_order_bottom_sheet.dart';

class TenantHomeScreen extends ElementaryWidget<ITenantHomeWM> {
  TenantHomeScreen({
    Key? key,
  }) : super(
          (context) => defaultTenantHomeWMFactory(context),
        );

  @override
  Widget build(ITenantHomeWM wm) {
    return TripleSourceBuilder(
        firstSource: wm.userLocation,
        secondSource: wm.driverLocation,
        thirdSource: wm.draggableScrolledSize,
        builder: (
          context,
          LatLng? userLocation,
          LatLng? driverLocation,
          double? draggableScrolledSize,
        ) {
          return Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: (MediaQuery.of(context).size.height * (draggableScrolledSize ?? 0)) - 50,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: wm.mapboxMapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            userLocation!.latitude.toDouble(),
                            userLocation!.longitude.toDouble(),
                          ),
                        ),
                        children: [
                          openStreetMapTileLayer,
                          MarkerLayer(
                            // rotate: counterRotate,
                            markers: [
                              if (userLocation != null)
                                Marker(
                                  point: LatLng(
                                    userLocation.latitude.toDouble(),
                                    userLocation.longitude.toDouble(),
                                  ),
                                  width: 16,
                                  height: 16,
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.red,
                                  ),
                                ),
                              if (driverLocation != null)
                                Marker(
                                  point: LatLng(
                                    driverLocation.latitude.toDouble(),
                                    driverLocation.longitude.toDouble(),
                                  ),
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.centerLeft,
                                  child: SvgPicture.asset(
                                    icTaxi,
                                    color: primaryColor,
                                  ),
                                ),
                              // Marker(
                              //   point:
                              //       LatLng(47.18664724067855, -1.5436768515939427),
                              //   width: 64,
                              //   height: 64,
                              //   alignment: Alignment.centerRight,
                              //   child: ColoredBox(
                              //     color: Colors.pink,
                              //     child: Align(
                              //       alignment: Alignment.centerLeft,
                              //       child: Text('<--'),
                              //     ),
                              //   ),
                              // ),
                              // Marker(
                              //   point:
                              //       LatLng(47.18664724067855, -1.5436768515939427),
                              //   rotate: false,
                              //   child: ColoredBox(color: Colors.black),
                              // ),
                            ],
                          ),
                          CurrentLocationLayer(),
                        ],
                      ),
                      Positioned(
                        top: 32,
                        right: 32,
                        child: InkWell(
                          onTap: wm.getMyLocation,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(Icons.location_searching),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: 0,
                  child: TripleSourceBuilder(
                      firstSource: wm.currentTab,
                      secondSource: wm.activeOrder,
                      thirdSource: wm.me,
                      builder: (
                        context,
                        int? currentTab,
                        ActiveClientRequestModel? activeOrder,
                        UserDomain? me,
                      ) {
                        return TripleSourceBuilder(
                            firstSource: wm.draggableMaxChildSize,
                            secondSource: wm.locationPermission,
                            thirdSource: wm.showFood,
                            builder: (
                              context,
                              double? draggableMaxChildSize,
                              LocationPermission? locationPermission,
                              bool? showFood,
                            ) {
                              return DraggableScrollableSheet(
                                initialChildSize: draggableMaxChildSize!,
                                controller: wm.draggableScrollableController,
                                minChildSize: 0.3,
                                maxChildSize: draggableMaxChildSize,
                                snap: true,
                                expand: false,
                                builder: (
                                  context,
                                  scrollController,
                                ) {
                                  return Container(
                                    color: Colors.white,
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      child: TripleSourceBuilder(
                                        firstSource: wm.currentTab,
                                        secondSource: wm.activeOrder,
                                        thirdSource: wm.me,
                                        builder: (
                                          context,
                                          int? currentTab,
                                          ActiveClientRequestModel? activeOrder,
                                          UserDomain? me,
                                        ) {
                                          if (![
                                            LocationPermission.always,
                                            LocationPermission.whileInUse
                                          ].contains(locationPermission)) {
                                            return Container(
                                              color: Colors.white,
                                              child: PopScope(
                                                canPop: false,
                                                child: PrimaryBottomSheet(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    vertical: 8,
                                                    horizontal: 16,
                                                  ),
                                                  child: SizedBox(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Center(
                                                          child: Container(
                                                            width: 38,
                                                            height: 4,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  greyscale30,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          1.4),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 24,
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: Text(
                                                            'Для заказа пожалуйста поделитесь геолокацией',
                                                            style:
                                                                text400Size24Greyscale60,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 24,
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: PrimaryButton
                                                              .primary(
                                                            onPressed: () => wm
                                                                .determineLocationPermission(
                                                              force: true,
                                                            ),
                                                            text:
                                                                'Включить геолокацию',
                                                            textStyle:
                                                                text400Size16White,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          if (activeOrder != null) {
                                            return Container(
                                              color: Colors.white,
                                              child:
                                                  ActiveClientOrderBottomSheet(
                                                me: me!,
                                                activeOrder: activeOrder,
                                                activeOrderListener:
                                                    wm.activeOrder,
                                                onCancel:
                                                    wm.cancelActiveClientOrder,
                                              ),
                                            );
                                          }
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 38,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: greyscale30,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1.40),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                TabBar(
                                                  controller: wm.tabController,
                                                  isScrollable: true,
                                                  padding:
                                                      EdgeInsets.only(left: 16),
                                                  tabAlignment:
                                                      TabAlignment.start,
                                                  dividerColor:
                                                      Colors.transparent,
                                                  indicatorColor:
                                                      Colors.transparent,
                                                  enableFeedback: false,
                                                  labelPadding:
                                                      EdgeInsets.only(right: 8),
                                                  tabs: [
                                                    ...[
                                                      DriverType.TAXI,
                                                      DriverType.DELIVERY,
                                                      if (showFood == true)
                                                      "FOOD",
                                                      DriverType.CARGO,
                                                      DriverType.INTERCITY_TAXI,
                                                    ].asMap().entries.map(
                                                          (e) => InkWell(
                                                            onTap: () => wm
                                                                .tabIndexChanged(
                                                                    e.key),
                                                            child:
                                                                TenantHomeTabView(
                                                              isActive:
                                                                  currentTab ==
                                                                      e.key,
                                                              label: e.value
                                                                      is DriverType
                                                                  ? (e.value
                                                                          as DriverType)
                                                                      .value!
                                                                  : 'Eда',
                                                              asset: e.value
                                                                      is DriverType
                                                                  ? (e.value
                                                                          as DriverType)
                                                                      .asset!
                                                                  : 'assets/icons/food.svg',
                                                            ),
                                                          ),
                                                        )
                                                  ],
                                                ),
                                                const SizedBox(height: 24),
                                                if (currentTab == 0)
                                                  TenantHomeCreateOrderView(
                                                    scrollController:
                                                        scrollController,
                                                    onSubmit: (form) =>
                                                        wm.onSubmit(form,
                                                            DriverType.TAXI),
                                                  ),
                                                if (currentTab == 1 && showFood == true)
                                                  EntityStateNotifierBuilder(
                                                    listenableEntityState:
                                                        wm.foods,
                                                    builder: (
                                                      context,
                                                      List<FoodDomain>? foods,
                                                    ) {
                                                      return StateNotifierBuilder(
                                                        listenableState:
                                                            wm.foodCategories,
                                                        builder: (
                                                          context,
                                                          List<FoodCategoryDomain>?
                                                              foodCategories,
                                                        ) {
                                                          return TenantHomeFoodsView(
                                                            scrollController:
                                                                scrollController,
                                                            onScrollDown: wm
                                                                .scrollDraggableSheetDown,
                                                            foods: foods ?? [],
                                                            foodCategories:
                                                                foodCategories ??
                                                                    [],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                if (showFood == true ? currentTab == 2 : currentTab == 1)
                                                  TenantHomeCreateOrderView(
                                                    scrollController:
                                                        scrollController,
                                                    onSubmit: (form) =>
                                                        wm.onSubmit(form,
                                                            DriverType.CARGO),
                                                  ),
                                                if (showFood == true ? currentTab == 3 : currentTab == 2)
                                                  TenantHomeCreateOrderView(
                                                    isIntercity: true,
                                                    scrollController:
                                                        scrollController,
                                                    onSubmit: (form) =>
                                                        wm.onSubmit(
                                                            form,
                                                            DriverType
                                                                .INTERCITY_TAXI),
                                                  ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              );
                            });
                      }),
                )
              ],
            ),
          );
        });
  }
}
