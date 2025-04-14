import 'dart:async';

import 'package:aktau_go/domains/active_request/active_request_domain.dart';
import 'package:aktau_go/domains/user/user_domain.dart';
import 'package:aktau_go/interactors/common/mapbox_api/mapbox_api.dart';
import 'package:aktau_go/interactors/order_requests_interactor.dart';
import 'package:aktau_go/ui/widgets/primary_button.dart';
import 'package:aktau_go/utils/logger.dart';
import 'package:aktau_go/utils/num_utils.dart';
import 'package:aktau_go/utils/utils.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as mapboxGl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../core/colors.dart';
import '../../../core/images.dart';
import '../../../core/text_styles.dart';
import '../../widgets/primary_bottom_sheet.dart';

class ActiveOrderBottomSheet extends StatefulWidget {
  final UserDomain me;
  final ActiveRequestDomain activeOrder;
  final VoidCallback onCancel;
  final StateNotifier<ActiveRequestDomain> activeOrderListener;

  const ActiveOrderBottomSheet({
    super.key,
    required this.me,
    required this.activeOrder,
    required this.onCancel,
    required this.activeOrderListener,
  });

  @override
  State<ActiveOrderBottomSheet> createState() => _ActiveOrderBottomSheetState();
}

class _ActiveOrderBottomSheetState extends State<ActiveOrderBottomSheet> {
  late ActiveRequestDomain activeRequest = widget.activeOrder;
  late final mapboxGl.MapboxMapController mapboxMapController;
  // List<Polyline> polylines = [];

  int waitingTimerLeft = 180;

  Timer? waitingTimer;

  bool isLoading = false;
  bool isOrderFinished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.activeOrderListener.addListener(() {
        fetchActiveOrder();
      });
    });
  }

  Future<void> fetchActiveOrder() async {
    try {
      final response = await inject<OrderRequestsInteractor>().getActiveOrder();

      activeRequest = response;

      String? sessionId = inject<SharedPreferences>().getString('sessionId');
      setState(() {});

      final route = await inject<MapboxApi>().getDirections(
        fromLat: double.parse(activeRequest.orderRequest!.fromMapboxId.split(';')[0]),
        fromLng: double.parse(activeRequest.orderRequest!.fromMapboxId.split(';')[1]),
        toLat: double.parse(activeRequest.orderRequest!.toMapboxId.split(';')[0]),
        toLng: double.parse(activeRequest.orderRequest!.toMapboxId.split(';')[1]),
      );

      logger.w(route['routes'][0]['geometry']);

      // setState(() {
      //   polylines = [
      //     Polyline(
      //       points: directions['routes'][0]['geometry'],
      //     )
      //   ];
      // });

      await mapboxMapController.removeLayer('lines');
      await mapboxMapController.removeSource('fills');

      await mapboxMapController.addSource(
        'fills',
        mapboxGl.GeojsonSourceProperties(
          data: {
            "type": "FeatureCollection",
            "features": [
              {
                "type": "Feature",
                "id": 0,
                "properties": <String, dynamic>{},
                "geometry": route['routes'][0]['geometry'],
              }
            ],
          },
        ),
      );
      await mapboxMapController.addLineLayer(
        "fills",
        "lines",
        mapboxGl.LineLayerProperties(
          lineColor: Colors.purpleAccent.toHexStringRGB(),
          lineCap: "round",
          lineJoin: "round",
          lineWidth: 2,
        ),
      );
    } on Exception catch (e) {
      setState(() {
        isOrderFinished = true;
      });
    }
  }

  Future<void> arrivedDriver() async {
    setState(() {
      isLoading = false;
    });
    try {
      await inject<OrderRequestsInteractor>().arrivedOrderRequest(
        driver: widget.me,
        orderRequest: widget.activeOrder.orderRequest!,
      );

      waitingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (waitingTimerLeft > 0) {
          setState(() {
            waitingTimerLeft--;
          });
        } else {
          rejectOrder();
          timer.cancel();
        }
      });

      fetchActiveOrder();
    } on Exception catch (e) {
      // TODO
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> rejectOrder() async {
    await showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  'Вы уверены что хотите отменить заказ?',
                  style: text400Size16Greyscale90,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton.secondary(
                      text: 'Назад',
                      onPressed: Navigator.of(context).pop,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton.primary(
                      text: 'Отменить',
                      textStyle: text400Size16White,
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await inject<OrderRequestsInteractor>().rejectOrderRequest(
                          orderRequestId: widget.activeOrder.orderRequest!.id,
                        );
                        fetchActiveOrder();
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> startDrive() async {
    setState(() {
      isLoading = true;
    });
    try {
      await inject<OrderRequestsInteractor>().startOrderRequest(
        driver: widget.me,
        orderRequest: widget.activeOrder.orderRequest!,
      );
      waitingTimer?.cancel();
      fetchActiveOrder();
    } on Exception catch (e) {
      // TODO
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> endDrive() async {
    setState(() {
      isLoading = true;
    });
    try {
      await inject<OrderRequestsInteractor>().endOrderRequest(
        driver: widget.me,
        orderRequest: widget.activeOrder.orderRequest!,
      );
      fetchActiveOrder();
    } on Exception catch (e) {
      // TODO
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: PrimaryBottomSheet(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
                      if (!isOrderFinished && activeRequest.orderRequest?.orderStatus == 'STARTED')
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Вы приняли заказ',
                            style: TextStyle(
                              color: Color(0xFF261619),
                              fontSize: 20,
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      else if (!isOrderFinished &&
                          activeRequest.orderRequest?.orderStatus == 'WAITING')
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Вы ожидаете клиента',
                            style: TextStyle(
                              color: Color(0xFF261619),
                              fontSize: 20,
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      else if (!isOrderFinished &&
                          activeRequest.orderRequest?.orderStatus == 'ONGOING')
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Вы в пути',
                            style: TextStyle(
                              color: Color(0xFF261619),
                              fontSize: 20,
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      else if (isOrderFinished &&
                          activeRequest.orderRequest?.orderStatus == 'REJECTED')
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Заказ отменен',
                            style: TextStyle(
                              color: Color(0xFF261619),
                              fontSize: 20,
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      else if (isOrderFinished)
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Заказ завершен',
                            style: TextStyle(
                              color: Color(0xFF261619),
                              fontSize: 20,
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 80,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: Color(0xFFE7E1E1)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                  image: NetworkImage("https://via.placeholder.com/48x48"),
                                  fit: BoxFit.cover,
                                ),
                                shape: OvalBorder(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.activeOrder.whatsappUser?.fullName ?? '',
                                      textAlign: TextAlign.center,
                                      style: text400Size16Greyscale90,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Клиент',
                                      textAlign: TextAlign.center,
                                      style: text400Size12Greyscale60,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                launchUrlString(
                                    'https://wa.me/${(widget.activeOrder.whatsappUser?.phone ?? '').replaceAll('+', '')}');
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                child: SvgPicture.asset(icWhatsapp),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if ((widget.activeOrder.orderRequest?.comment ?? '').isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: Color(0xFFE7E1E1)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  child: Text(
                                    widget.activeOrder.orderRequest?.comment ?? '',
                                    style: text400Size12Greyscale90,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: Color(0xFFE7E1E1)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 300,
                              child: mapboxGl.MapboxMap(
                                accessToken:
                                    'sk.eyJ1IjoidmFuZGVydmFpeiIsImEiOiJjbTA1azhkNjEwNDF2MmtzNHA0eWJ3eTR0In0.cSGmIeLW1Wc44gyBBWJsYA',
                                // myLocationEnabled: true,
                                onMapCreated: (mapboxController) {
                                  setState(() {
                                    mapboxMapController = mapboxController;
                                  });
                                },
                                onStyleLoadedCallback: () {},
                                myLocationRenderMode: mapboxGl.MyLocationRenderMode.GPS,
                                initialCameraPosition: mapboxGl.CameraPosition(
                                  target: mapboxGl.LatLng(
                                    activeRequest.orderRequest!.lat.toDouble(),
                                    activeRequest.orderRequest!.lng.toDouble(),
                                  ),
                                  zoom: 7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Откуда',
                                              textAlign: TextAlign.center,
                                              style: text400Size10Greyscale60,
                                            ),
                                            Container(
                                              width: double.infinity,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icons/placemark.svg',
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      widget.activeOrder.orderRequest?.from ?? '',
                                                      textAlign: TextAlign.left,
                                                      style: text400Size16Black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Куда',
                                              textAlign: TextAlign.center,
                                              style: text400Size10Greyscale60,
                                            ),
                                            Container(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icons/placemark.svg',
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      widget.activeOrder.orderRequest?.to ?? '',
                                                      textAlign: TextAlign.left,
                                                      style: text400Size16Black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 36,
                        padding: const EdgeInsets.all(8),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: Color(0xFFE7E1E1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: Text(
                                  'Цена поездки: ${NumUtils.humanizeNumber(activeRequest.orderRequest?.price)} ₸ ',
                                  style: text400Size16Greyscale90,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (activeRequest.orderRequest?.orderStatus == 'WAITING')
                        Container(
                          width: double.infinity,
                          height: 36,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 24),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1, color: Color(0xFFE7E1E1)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  child: Text(
                                    'Ожидание: ${waitingTimerLeft ~/ 60}:${waitingTimerLeft % 60}',
                                    style: text400Size16Greyscale90,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              if (!isOrderFinished && activeRequest.orderRequest?.orderStatus == 'STARTED')
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton.primary(
                    onPressed: arrivedDriver,
                    isLoading: isLoading,
                    text: 'Включить ожидание',
                    textStyle: text400Size16White,
                  ),
                )
              else if (!isOrderFinished && activeRequest.orderRequest?.orderStatus == 'WAITING')
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton.primary(
                    onPressed: startDrive,
                    isLoading: isLoading,
                    text: 'Начать поездку',
                    textStyle: text400Size16White,
                  ),
                )
              else if (!isOrderFinished && activeRequest.orderRequest?.orderStatus == 'ONGOING')
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton.primary(
                    onPressed: endDrive,
                    isLoading: isLoading,
                    text: 'Завершить',
                    textStyle: text400Size16White,
                  ),
                )
              else if (isOrderFinished || activeRequest.orderRequest?.orderStatus == "REJECTED")
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton.primary(
                    onPressed: Navigator.of(context).pop,
                    text: 'Продолжить',
                    textStyle: text400Size16White,
                  ),
                ),
              const SizedBox(height: 8),
              if (!isOrderFinished)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: Row(
                    children: [
                      Expanded(
                        child: PrimaryButton.secondary(
                          onPressed: () {
                            launchUrlString(
                                'tel://${(widget.activeOrder.whatsappUser?.phone ?? '')}');
                          },
                          text: 'Отказаться',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(icCall),
                              const SizedBox(width: 8),
                              Text(
                                'Позвонить',
                                style: text400Size16Greyscale60,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PrimaryButton.secondary(
                          onPressed: () {
                            rejectOrder();
                          },
                          text: 'Отменить заказ',
                          textStyle: text400Size16Greyscale60,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
//
// TileLayer get openStreetMapTileLayer => TileLayer(
//       urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//       userAgentPackageName: 'dev.fleaflet.flutter_map.example',
//       // Use the recommended flutter_map_cancellable_tile_provider package to
//       // support the cancellation of loading tiles.
//       tileProvider: CancellableNetworkTileProvider(),
//     );
