import 'dart:async';

import 'package:aktau_go/domains/active_request/active_request_domain.dart';
import 'package:aktau_go/domains/user/user_domain.dart';
import 'package:aktau_go/interactors/order_requests_interactor.dart';
import 'package:aktau_go/ui/widgets/primary_button.dart';
import 'package:aktau_go/utils/num_utils.dart';
import 'package:aktau_go/utils/utils.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
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

  int waitingTimerLeft = 180;

  Timer? waitingTimer;

  bool isOrderFinished = false;

  @override
  void initState() {
    super.initState();
    widget.activeOrderListener.addListener(() {
      fetchActiveOrder();
    });
  }

  Future<void> fetchActiveOrder() async {
    try {
      final response = await inject<OrderRequestsInteractor>().getActiveOrder();

      activeRequest = response;

      setState(() {});
    } on Exception catch (e) {
      setState(() {
        isOrderFinished = true;
      });
    }
  }

  Future<void> arrivedDriver() async {
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
  }

  Future<void> rejectOrder() async {
    await inject<OrderRequestsInteractor>().rejectOrderRequest(
      orderRequestId: widget.activeOrder.orderRequest!.id,
    );
    fetchActiveOrder();
  }

  Future<void> startDrive() async {
    await inject<OrderRequestsInteractor>().startOrderRequest(
      driver: widget.me,
      orderRequest: widget.activeOrder.orderRequest!,
    );
    waitingTimer?.cancel();
    fetchActiveOrder();
  }

  Future<void> endDrive() async {
    await inject<OrderRequestsInteractor>().endOrderRequest(
      driver: widget.me,
      orderRequest: widget.activeOrder.orderRequest!,
    );
    fetchActiveOrder();
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
                      if (!isOrderFinished &&
                          activeRequest.orderRequest?.orderStatus == 'STARTED')
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
                            side:
                                BorderSide(width: 1, color: Color(0xFFE7E1E1)),
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
                                  image: NetworkImage(
                                      "https://via.placeholder.com/48x48"),
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
                                      widget.activeOrder.whatsappUser?.name ??
                                          '',
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
                      if ((widget.activeOrder.orderRequest?.comment ?? '')
                          .isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1, color: Color(0xFFE7E1E1)),
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
                                    widget.activeOrder.orderRequest?.comment ??
                                        '',
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
                            side:
                                BorderSide(width: 1, color: Color(0xFFE7E1E1)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 300,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    "https://via.placeholder.com/344x98",
                                  ),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: MapWidget(
                                styleUri: MapboxStyles.STANDARD,
                                cameraOptions: CameraOptions(
                                  zoom: 12,
                                  bearing: 0,
                                  pitch: 0,
                                  center: Point(
                                    coordinates: Position(
                                      widget.activeOrder.orderRequest?.lng ?? 0,
                                      widget.activeOrder.orderRequest?.lat ?? 0,
                                    ),
                                  ),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icons/placemark.svg',
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      widget
                                                              .activeOrder
                                                              .orderRequest
                                                              ?.from ??
                                                          '',
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Куда',
                                              textAlign: TextAlign.center,
                                              style: text400Size10Greyscale60,
                                            ),
                                            Container(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icons/placemark.svg',
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      widget.activeOrder
                                                              .orderRequest?.to ??
                                                          '',
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
                            side:
                                BorderSide(width: 1, color: Color(0xFFE7E1E1)),
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
                              side: BorderSide(
                                  width: 1, color: Color(0xFFE7E1E1)),
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
              if (!isOrderFinished &&
                  activeRequest.orderRequest?.orderStatus == 'STARTED')
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton.primary(
                    onPressed: arrivedDriver,
                    text: 'Включить ожидание',
                    textStyle: text400Size16White,
                  ),
                )
              else if (!isOrderFinished &&
                  activeRequest.orderRequest?.orderStatus == 'WAITING')
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton.primary(
                    onPressed: startDrive,
                    text: 'Начать поездку',
                    textStyle: text400Size16White,
                  ),
                )
              else if (!isOrderFinished &&
                  activeRequest.orderRequest?.orderStatus == 'ONGOING')
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton.primary(
                    onPressed: endDrive,
                    text: 'Завершить',
                    textStyle: text400Size16White,
                  ),
                )
              else if (isOrderFinished ||
                  activeRequest.orderRequest?.orderStatus == "REJECTED")
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
