import 'dart:io';

import 'package:aktau_go/ui/history/history_screen.dart';
import 'package:aktau_go/ui/orders/orders_screen.dart';
import 'package:aktau_go/ui/profile/profile_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/images.dart';
import '../../core/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPage = 0;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page?.toInt() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // logger.w(context.locale.languageCode);
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (newPage) {
          setState(() {
            currentPage = newPage;
          });
        },
        children: getUserScreenByRole('', currentPage),
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          // decoration: BoxDecoration(
          //   border: Border(
          //     top: BorderSide(
          //       color: greyscale20,
          //     ),
          //   ),
          // ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white.withOpacity(0.85),
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            elevation: 0,
            // selectedLabelStyle: text500Size10BottomActiveColor.copyWith(
            //   height: 2,
            // ),
            // unselectedLabelStyle:
            // text500Size10BottomInActiveColor.copyWith(
            //   height: 2,
            // ),
            unselectedFontSize: 10,
            selectedItemColor: primaryColor,
            onTap: (newPage) {
              setState(() {
                currentPage = newPage;
              });
              _pageController.animateToPage(
                newPage,
                duration: Duration(
                  milliseconds: 1,
                ),
                curve: Curves.linear,
              );
            },
            currentIndex: currentPage ?? 0,
            items: getUserBottomItemsByRole('', currentPage ?? 0),
          ),
        ),
      ),
    );
  }

  List<Widget> getUserScreenByRole(
    String? role, [
    int? currentSubTab,
  ]) {
    return [
      OrdersScreen(),
      HistoryScreen(),
      ProfileScreen(),
    ];
  }

  getUserBottomItemsByRole(String? role, int currentTab) {
    return ([
      {
        'icon': icOrders,
        'label': 'orders',
      },
      {
        'icon': icHistory,
        'label': 'history',
      },
      {
        'icon': icProfile,
        'label': 'profile',
      },
    ])
        .asMap()
        .entries
        .map(
          (e) => BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: SizedBox(
                height: 24,
                width: 24,
                child: SvgPicture.asset(
                  e.value['icon'] as String,
                  colorFilter: ColorFilter.mode(
                    currentTab == e.key ? primaryColor : greyscale30,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            label: (e.value['label'] as String).tr(),
          ),
        )
        .toList();
  }
}
