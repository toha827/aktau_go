import 'package:action_slider/action_slider.dart';
import 'package:aktau_go/domains/order_request/order_request_domain.dart';
import 'package:aktau_go/ui/orders/widgets/order_request_card.dart';
import 'package:aktau_go/ui/widgets/text_locale.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/colors.dart';
import '../../core/text_styles.dart';

import 'package:elementary/elementary.dart';

import 'orders_wm.dart';

class OrdersScreen extends ElementaryWidget<IOrdersWM> {
  OrdersScreen({
    Key? key,
  }) : super(
          (context) => defaultOrdersWMFactory(context),
        );

  @override
  Widget build(IOrdersWM wm) {
    return StateNotifierBuilder(
        listenableState: wm.tabIndex,
        builder: (
          context,
          int? tabIndex,
        ) {
          return Scaffold(
            appBar: AppBar(
              title: SizedBox(
                width: double.infinity,
                child: Text(
                  'Поиск заказов',
                  style: text500Size24Black,
                ),
              ),
              centerTitle: false,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(
                  height: 1,
                  color: greyscale10,
                ),
              ),
            ),
            body: StateNotifierBuilder(
                listenableState: wm.orderRequests,
                builder: (
                  context,
                  List<OrderRequestDomain>? orderRequests,
                ) {
                  return RefreshIndicator(
                    onRefresh: wm.fetchOrderRequests,
                    child: ListView(
                      children: [
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              const SizedBox(width: 16),
                              ...[
                                {
                                  'label': 'Такси',
                                  'asset': 'assets/icons/taxi.svg',
                                },
                                {
                                  'label': 'Груз',
                                  'asset': 'assets/icons/truck.svg',
                                },
                                {
                                  'label': 'Доставка',
                                  'asset': 'assets/icons/delivery.svg',
                                },
                              ].asMap().entries.map(
                                    (e) => InkWell(
                                      onTap: () => wm.tabIndexChanged(e.key),
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: ShapeDecoration(
                                          color: tabIndex == e.key
                                              ? Color(0xFFF73C4E)
                                              : Colors.white,
                                          shape: RoundedRectangleBorder(
                                            side: tabIndex != e.key
                                                ? BorderSide(
                                                    width: 1,
                                                    color: Color(0xFFB4AAA9))
                                                : BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(102),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              e.value['asset']!,
                                              color: tabIndex == e.key
                                                  ? Colors.white
                                                  : Colors.grey,
                                            ),
                                            const SizedBox(width: 8),
                                            TextLocale(
                                              e.value['label']!,
                                              style: tabIndex == e.key
                                                  ? text400Size16White
                                                  : text400Size16Greyscale30,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x26261619),
                                blurRadius: 15,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Принимайте заказы',
                                      textAlign: TextAlign.center,
                                      style: text400Size16Black,
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      child: SvgPicture.asset(
                                          'assets/icons/close.svg'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                child: Text(
                                  'Нажмите на красную кнопку в карточке заказа, чтобы узнать подробнее',
                                  style: text400Size12Greyscale50,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        ...(orderRequests ?? []).map(
                          (e) => InkWell(
                            onTap: () => wm.onOrderRequestTap(e),
                            child: OrderRequestCard(orderRequest: e),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          );
        });
  }
}
