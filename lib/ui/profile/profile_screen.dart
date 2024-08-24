import 'package:aktau_go/domains/user/user_domain.dart';
import 'package:aktau_go/ui/earning_analytics/earning_analytics_bottom_sheet.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/material.dart';
import 'package:elementary/elementary.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/colors.dart';
import '../../core/images.dart';
import '../../core/text_styles.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_locale.dart';
import './profile_wm.dart';

class ProfileScreen extends ElementaryWidget<IProfileWM> {
  ProfileScreen({
    Key? key,
  }) : super(
          (context) => defaultProfileWMFactory(context),
        );

  @override
  Widget build(IProfileWM wm) {
    return DoubleSourceBuilder(
      firstSource: wm.role,
      secondSource: wm.me,
      builder: (
        context,
        String? role,
        UserDomain? me,
      ) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Профиль',
                    style: text500Size24Black,
                  ),
                ),
                if (role != 'TENANT')
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Войдите в аккаунт',
                      style: text400Size16Black,
                    ),
                  ),
              ],
            ),
            centerTitle: false,
            bottom: role == 'TENANT'
                ? null
                : PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(
                      height: 1,
                      color: greyscale10,
                    ),
                  ),
          ),
          body: role == 'TENANT'
              ? ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Container(
                      width: 343,
                      height: 96,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
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
                                  Expanded(
                                    child: Text(
                                      me?.fullName ?? '',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF261619),
                                        fontSize: 20,
                                        fontFamily: 'Rubik',
                                        fontWeight: FontWeight.w400,
                                        height: 0.06,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        IgnorePointer(
                                          ignoring: true,
                                          child: RatingBar.builder(
                                            initialRating:
                                                me?.rating.toDouble() ?? 0,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 20,
                                            itemPadding: EdgeInsets.symmetric(
                                              horizontal: 4.0,
                                            ),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: primaryColor,
                                            ),
                                            onRatingUpdate: (rating) {
                                              print(rating);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '(4 отзыва)',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF261619),
                                            fontSize: 12,
                                            fontFamily: 'Rubik',
                                            fontWeight: FontWeight.w400,
                                            height: 0.11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Color(0xFFF73C4E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  child: SvgPicture.asset(
                                      'assets/icons/subscription.svg'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                          'Подписка активна',
                                          textAlign: TextAlign.center,
                                          style: text600Size16White,
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          width: 16,
                                          height: 16,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 16,
                                                height: 16,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                        width: 16,
                                                        height: 16,
                                                        child: Stack()),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Начало подписки: 02.06.24',
                                          textAlign: TextAlign.center,
                                          style: text400Size10White,
                                        ),
                                        Text(
                                          'Конец подписки:  02.07.24',
                                          textAlign: TextAlign.center,
                                          style: text400Size10White,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: SvgPicture.asset(icRegistration),
                      title: Text(
                        'Регистрация',
                        style: text400Size16Black,
                      ),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        builder: (context) => EarningAnalyticsBottomSheet(
                          me: me
                        ),
                      ),
                      leading: SvgPicture.asset(icAnalytics),
                      title: Text(
                        'Аналитика',
                        style: text400Size16Black,
                      ),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: SvgPicture.asset(icSupport),
                      title: Text(
                        'Поддержка',
                        style: text400Size16Black,
                      ),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: SvgPicture.asset(icInfo),
                      title: Text(
                        'О приложении',
                        style: text400Size16Black,
                      ),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      onTap: () {},
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title: TextLocale(
                        'Выйти',
                        style: text400Size16Primary,
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 24),
                    PrimaryButton.primary(
                      onPressed: wm.navigateToLogin,
                      text: 'Войти',
                      textStyle: text400Size16White,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: SvgPicture.asset(icSupport),
                      title: Text(
                        'Поддержка',
                        style: text400Size16Black,
                      ),
                      trailing: Icon(Icons.chevron_right),
                    ),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: SizedBox(),
                      title: Text(
                        'О приложении',
                        style: text400Size16Black,
                      ),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
