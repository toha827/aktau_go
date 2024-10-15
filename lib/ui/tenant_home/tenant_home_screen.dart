import 'package:aktau_go/domains/food/food_category_domain.dart';
import 'package:aktau_go/domains/food/food_domain.dart';
import 'package:aktau_go/ui/tenant_home/widgets/tenant_home_create_food_view.dart';
import 'package:aktau_go/ui/tenant_home/widgets/tenant_home_create_order_view.dart';
import 'package:aktau_go/ui/tenant_home/widgets/tenant_home_tab_view.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/material.dart';
import 'package:elementary/elementary.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../core/colors.dart';
import '../../domains/user/user_domain.dart';
import '../../forms/driver_registration_form.dart';
import '../../models/active_client_request/active_client_request_model.dart';
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
    return StateNotifierBuilder(
        listenableState: wm.userLocation,
        builder: (
          context,
          LatLng? userLocation,
        ) {
          return Scaffold(
            body: Stack(
              children: [
                MapWidget(
                  onMapCreated: wm.onMapCreated,
                  styleUri: MapboxStyles.STANDARD,
                  cameraOptions: CameraOptions(
                    center: Point(
                      coordinates: Position(
                        userLocation!.longitude,
                        userLocation!.latitude,
                      ),
                    ),
                    zoom: 12,
                    bearing: 0,
                    pitch: 0,
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
                        return DraggableScrollableSheet(
                          minChildSize: 0.2,
                          maxChildSize: activeOrder != null ? 0.5 : 0.95,
                          expand: false,
                          builder: (
                            context,
                            scrollController,
                          ) {
                            return TripleSourceBuilder(
                              firstSource: wm.currentTab,
                              secondSource: wm.activeOrder,
                              thirdSource: wm.me,
                              builder: (
                                context,
                                int? currentTab,
                                ActiveClientRequestModel? activeOrder,
                                UserDomain? me,
                              ) {
                                if (activeOrder != null) {
                                  return Container(
                                    color: Colors.white,
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      child: ActiveClientOrderBottomSheet(
                                        me: me!,
                                        activeOrder: activeOrder,
                                        activeOrderListener: wm.activeOrder,
                                        onCancel: wm.cancelActiveClientOrder,
                                      ),
                                    ),
                                  );
                                }
                                return SingleChildScrollView(
                                  controller: scrollController,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
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
                                                BorderRadius.circular(1.40),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TabBar(
                                          controller: wm.tabController,
                                          isScrollable: true,
                                          padding: EdgeInsets.only(left: 16),
                                          tabAlignment: TabAlignment.start,
                                          dividerColor: Colors.transparent,
                                          indicatorColor: Colors.transparent,
                                          enableFeedback: false,
                                          labelPadding: EdgeInsets.only(right: 8),
                                          tabs: [
                                            ...[
                                              DriverType.TAXI,
                                              "FOOD",
                                              DriverType.CARGO,
                                              DriverType.INTERCITY_TAXI,
                                            ].asMap().entries.map(
                                                  (e) => InkWell(
                                                    onTap: () =>
                                                        wm.tabIndexChanged(e.key),
                                                    child: TenantHomeTabView(
                                                      isActive:
                                                          currentTab == e.key,
                                                      label: e.value is DriverType
                                                          ? (e.value
                                                                  as DriverType)
                                                              .value!
                                                          : 'Eда',
                                                      asset: e.value is DriverType
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
                                            scrollController: scrollController,
                                            onSubmit: (form) => wm.onSubmit(
                                                form, DriverType.TAXI),
                                          ),
                                        if (currentTab == 1)
                                          EntityStateNotifierBuilder(
                                            listenableEntityState: wm.foods,
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
                                                    foods: foods ?? [],
                                                    foodCategories:
                                                        foodCategories ?? [],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        if (currentTab == 2)
                                          TenantHomeCreateOrderView(
                                            scrollController: scrollController,
                                            onSubmit: (form) => wm.onSubmit(
                                                form, DriverType.CARGO),
                                          ),
                                        if (currentTab == 3)
                                          TenantHomeCreateOrderView(
                                            scrollController: scrollController,
                                            onSubmit: (form) => wm.onSubmit(
                                                form, DriverType.INTERCITY_TAXI),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }),
                )
              ],
            ),
          );
        });
  }
}
