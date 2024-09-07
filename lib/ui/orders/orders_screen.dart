import 'package:action_slider/action_slider.dart';
import 'package:aktau_go/domains/order_request/order_request_domain.dart';
import 'package:aktau_go/forms/driver_registration_form.dart';
import 'package:aktau_go/ui/orders/widgets/order_request_card.dart';
import 'package:aktau_go/ui/widgets/primary_button.dart';
import 'package:aktau_go/ui/widgets/text_locale.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/colors.dart';
import '../../core/text_styles.dart';

import 'package:elementary/elementary.dart';

import '../../domains/driver_registered_category/driver_registered_category_domain.dart';
import '../../router/router.dart';
import 'orders_wm.dart';

class OrdersScreen extends ElementaryWidget<IOrdersWM> {
  OrdersScreen({
    Key? key,
  }) : super(
          (context) => defaultOrdersWMFactory(context),
        );

  @override
  Widget build(IOrdersWM wm) {
    return TripleSourceBuilder(
        firstSource: wm.tabIndex,
        secondSource: wm.showNewOrders,
        thirdSource: wm.orderType,
        builder: (
          context,
          int? tabIndex,
          bool? showNewOrders,
          DriverType? orderType,
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
            body: DoubleSourceBuilder(
                firstSource: wm.orderRequests,
                secondSource: wm.driverRegisteredCategories,
                builder: (
                  context,
                  List<OrderRequestDomain>? orderRequests,
                  List<DriverRegisteredCategoryDomain>?
                      driverRegisteredCategories,
                ) {
                  return Stack(
                    children: [
                      RefreshIndicator(
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
                                  ...DriverType.values.asMap().entries.map(
                                        (e) => InkWell(
                                          onTap: () =>
                                              wm.tabIndexChanged(e.key),
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(right: 8),
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
                                                        color:
                                                            Color(0xFFB4AAA9))
                                                    : BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(102),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  e.value.asset!,
                                                  color: tabIndex == e.key
                                                      ? Colors.white
                                                      : Colors.grey,
                                                ),
                                                const SizedBox(width: 8),
                                                TextLocale(
                                                  e.value.value!,
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
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                            if ((driverRegisteredCategories ?? []).any(
                                (category) =>
                                    category.categoryType == orderType))
                              ...(orderRequests ?? []).map(
                                (e) => InkWell(
                                  onTap: () => wm.onOrderRequestTap(e),
                                  child: OrderRequestCard(orderRequest: e),
                                ),
                              )
                            else
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'Чтобы начать принимать заказы нужно зарегться на категорию',
                                          style: text400Size16Greyscale90,
                                        ),
                                      ),
                                      PrimaryButton.primary(
                                        onPressed: () {
                                          Routes.router.navigate(
                                              Routes.driverRegistrationScreen);
                                        },
                                        text: 'Зарегестрироваться',
                                        textStyle: text400Size16White,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      AnimatedPositioned(
                        top: showNewOrders == true ? 16 : -100,
                        left: 16,
                        right: 16,
                        duration: Duration(
                          seconds: 1,
                        ),
                        child: Center(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: wm.tapNewOrders,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x1E000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 0),
                                      spreadRadius: 5,
                                    ),
                                  ]),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Показать новые заказы',
                                    style: text400Size16Greyscale90,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                }),
          );
        });
  }
}
