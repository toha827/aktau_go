import 'dart:convert';

import 'package:aktau_go/core/colors.dart';
import 'package:aktau_go/core/text_styles.dart';
import 'package:aktau_go/interactors/common/map_tiler_cloud_api/map_tiler_cloud_api.dart';
import 'package:aktau_go/interactors/common/mapbox_api/mapbox_api.dart';
import 'package:aktau_go/interactors/common/open_street_map_api/open_street_map_api.dart';
import 'package:aktau_go/interactors/common/rest_client.dart';
import 'package:aktau_go/interactors/main_navigation_interactor.dart';
import 'package:aktau_go/models/mapbox/mapbox_feature_model.dart';
import 'package:aktau_go/router/router.dart';
import 'package:aktau_go/ui/map_picker/map_picker_screen.dart';
import 'package:aktau_go/ui/tenant_home/forms/driver_order_form.dart';
import 'package:aktau_go/ui/widgets/primary_button.dart';
import 'package:aktau_go/ui/widgets/primary_dropdown.dart';
import 'package:aktau_go/ui/widgets/rounded_text_field.dart';
import 'package:aktau_go/utils/text_editing_controller.dart';
import 'package:aktau_go/utils/utils.dart';
import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/v4.dart';

import '../../../core/images.dart';
import '../../../forms/inputs/required_formz_input.dart';
import '../../../models/map_tiler/map_tiler_geo_coding_response.dart';

class TenantHomeCreateOrderView extends StatefulWidget {
  final bool isIntercity;
  final ScrollController scrollController;
  final Function(DriverOrderForm) onSubmit;

  const TenantHomeCreateOrderView({
    super.key,
    required this.scrollController,
    required this.onSubmit,
    this.isIntercity = false,
  });

  @override
  State<TenantHomeCreateOrderView> createState() =>
      _TenantHomeCreateOrderViewState();
}

class _TenantHomeCreateOrderViewState extends State<TenantHomeCreateOrderView> {
  bool isLoading = false;
  DriverOrderForm driverOrderForm = DriverOrderForm();

  List<Features> suggestions = [];

  List<String> cities = [
    'Актау',
    'Кызылтобе',
    'Акшукур',
    'Батыр',
    'Курык',
    'Жынгылды',
    'Жетыбай',
    'Таушик',
    'Шетпе',
    'Жанаозен',
    'Бейнеу',
    'Форт-Шевчкенко',
  ];

  late final TextEditingController fromAddressTextController =
      createTextEditingController(
    initialText: '',
    onChanged: (fromAddress) {
      setState(() {
        driverOrderForm = driverOrderForm.copyWith(
          fromAddress: Required.dirty(fromAddress),
        );
      });
    },
  );
  late final TextEditingController toAddressTextController =
      createTextEditingController(
    initialText: '',
    onChanged: (toAddress) {
      setState(() {
        driverOrderForm = driverOrderForm.copyWith(
          toAddress: Required.dirty(toAddress),
        );
      });
    },
  );
  late final TextEditingController costTextController =
      createTextEditingController(
    initialText: '',
    onChanged: (cost) {
      setState(() {
        driverOrderForm = driverOrderForm.copyWith(
          cost: Required.dirty(num.tryParse(cost)),
        );
      });
    },
  );
  late final TextEditingController commentTextController =
      createTextEditingController(
    initialText: '',
    onChanged: (comment) {
      setState(() {
        driverOrderForm = driverOrderForm.copyWith(
          comment: comment,
        );
      });
    },
  );

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   inject<MainNavigationInteractor>().lastMapTapped.addListener(() async {
    //     LatLng point = inject<MainNavigationInteractor>().lastMapTapped.value!;
    //     final response = await inject<MapTilerCloudApi>().geoCoding(
    //       longitude: point.longitude,
    //       latitude: point.latitude,
    //       accessToken: 'HcgJnGUrEU9K93fPa6qG',
    //     );
    //
    //     if (!driverOrderForm.toMapboxId.isPure ||
    //         driverOrderForm.fromMapboxId.isPure) {
    //       setState(() {
    //         fromAddressTextController.text =
    //             response.features?.first.text ?? "";
    //         // driverOrderForm = driverOrderForm.copyWith(
    //         //   fromMapboxId:
    //         //       Required.dirty(response.features!.first.properties?.mapboxId),
    //         // );
    //         toAddressTextController.text = '';
    //         driverOrderForm = driverOrderForm.copyWith(
    //           toMapboxId: Required.pure(),
    //         );
    //       });
    //     } else {
    //       setState(() {
    //         toAddressTextController.text = response.features?.first.text ?? "";
    //         driverOrderForm = driverOrderForm.copyWith(
    //             // toMapboxId:
    //             //     Required.dirty(response.features!.first.properties?.mapboxId),
    //             );
    //       });
    //     }
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (widget.isIntercity)
            Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 16),
              child: PrimaryDropdown(
                  initialOption: driverOrderForm.fromAddress.value,
                  options: [
                    ...cities
                        .map((city) => SelectOption(
                              value: city,
                              label: city,
                            ))
                        .toList()
                  ],
                  hintText: 'Выберите город',
                  onChanged: (option) {
                    setState(() {
                      driverOrderForm = driverOrderForm.copyWith(
                        fromAddress: Required.dirty(option?.value),
                      );
                    });
                  }),
            )
          else
            InkWell(
              onTap: () {
                LatLng? latLng = (driverOrderForm.fromMapboxId.value ?? '')
                        .isNotEmpty
                    ? LatLng(
                        double.parse(
                            driverOrderForm.fromMapboxId.value!.split(';')[0]),
                        double.parse(
                            driverOrderForm.fromMapboxId.value!.split(';')[1]))
                    : null;
                Routes.router.navigate(Routes.selectMapPicker,
                    args: MapAddressPickerScreenArgs(
                      latLng: latLng,
                      placeName: driverOrderForm.fromAddress.value,
                      onSubmit: (latLng, text) async {
                        final response =
                            await inject<RestClient>().getPlaceDetail(
                          longitude: latLng.longitude,
                          latitude: latLng.latitude,
                        );

                        fromAddressTextController.text = response ?? "";
                        setState(() {
                          driverOrderForm = driverOrderForm.copyWith(
                            fromMapboxId: Required.dirty(
                              '${latLng.latitude};${latLng.longitude}',
                            ),
                          );
                        });
                      },
                    ));
              },
              child: IgnorePointer(
                ignoring: true,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: greyscale30,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: EasyAutocomplete(
                    controller: fromAddressTextController,
                    asyncSuggestions: getSuggesstions,
                    progressIndicatorBuilder: Center(
                      child: CircularProgressIndicator(
                        color: greyscale30,
                      ),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Откуда*',
                      border: InputBorder.none,
                      prefixIcon: SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: SvgPicture.asset(
                            icPlacemark,
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    suggestionBuilder: (String json) {
                      return ListTile(
                        title: Text(jsonDecode(json)['label']),
                      );
                    },
                    onSubmitted: _onFromSubmitted,
                    onChanged: (String json) async {
                      // widget.onSubmit(
                      //   LatLng(
                      //     response.result?.geometry?.location?.lat ?? 0,
                      //     response.result?.geometry?.location?.lng ?? 0,
                      //   ),
                      //   feature.description ?? '',
                      // );
                    },
                  ),
                ),
              ),
            ),
          // Container(
          //   height: 48,
          //   margin: const EdgeInsets.only(bottom: 16),
          //   child: RoundedTextField(
          //     backgroundColor: Colors.white,
          //     controller: fromAddressTextController,
          //     hintText: 'Откуда*',
          //     decoration: InputDecoration(
          //       prefixIcon: SizedBox(
          //         width: 20,
          //         height: 20,
          //         child: Center(
          //           child: SvgPicture.asset(
          //             icPlacemark,
          //           ),
          //         ),
          //       ),
          //       contentPadding: const EdgeInsets.symmetric(
          //         horizontal: 16,
          //         vertical: 14,
          //       ),
          //     ),
          //   ),
          // ),
          if (widget.isIntercity)
            Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 16),
              child: PrimaryDropdown(
                initialOption: driverOrderForm.toAddress.value,
                options: [
                  ...cities
                      .map((city) => SelectOption(
                            value: city,
                            label: city,
                          ))
                      .toList()
                ],
                hintText: 'Выберите город',
                onChanged: (option) {
                  setState(
                    () {
                      driverOrderForm = driverOrderForm.copyWith(
                        toAddress: Required.dirty(option?.value),
                      );
                    },
                  );
                },
              ),
            )
          else
            InkWell(
              onTap: () {
                LatLng? latLng = (driverOrderForm.toMapboxId.value ?? "")
                        .isNotEmpty
                    ? LatLng(
                        double.parse(
                            driverOrderForm.toMapboxId.value!.split(';')[0]),
                        double.parse(
                            driverOrderForm.toMapboxId.value!.split(';')[1]))
                    : null;
                Routes.router.navigate(Routes.selectMapPicker,
                    args: MapAddressPickerScreenArgs(
                      latLng: latLng,
                      placeName: driverOrderForm.toAddress.value,
                      onSubmit: (latLng, text) async {
                        final response =
                            await inject<RestClient>().getPlaceDetail(
                          longitude: latLng.longitude,
                          latitude: latLng.latitude,
                        );

                        toAddressTextController.text = response ?? "";
                        setState(() {
                          driverOrderForm = driverOrderForm.copyWith(
                            toMapboxId: Required.dirty(
                              '${latLng.latitude};${latLng.longitude}',
                            ),
                          );
                        });
                      },
                    ));
              },
              child: IgnorePointer(
                ignoring: true,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: greyscale30,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: EasyAutocomplete(
                    controller: toAddressTextController,
                    asyncSuggestions: getSuggesstions,
                    progressIndicatorBuilder: Center(
                      child: CircularProgressIndicator(
                        color: greyscale30,
                      ),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Куда*',
                      border: InputBorder.none,
                      prefixIcon: SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: SvgPicture.asset(
                            icPlacemark,
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    suggestionBuilder: (String json) {
                      return ListTile(
                        title: Text(jsonDecode(json)['label']),
                      );
                    },
                    onSubmitted: _onToSubmitted,
                    onChanged: (String json) async {
                      // widget.onSubmit(
                      //   LatLng(
                      //     response.result?.geometry?.location?.lat ?? 0,
                      //     response.result?.geometry?.location?.lng ?? 0,
                      //   ),
                      //   feature.description ?? '',
                      // );
                    },
                  ),
                ),
              ),
            ),
          // Container(
          //   height: 48,
          //   margin: const EdgeInsets.only(bottom: 16),
          //   child: RoundedTextField(
          //     backgroundColor: Colors.white,
          //     controller: toAddressTextController,
          //     hintText: 'Куда*',
          //     decoration: InputDecoration(
          //       prefixIcon: SizedBox(
          //         width: 20,
          //         height: 20,
          //         child: Center(
          //           child: SvgPicture.asset(
          //             icPlacemark,
          //           ),
          //         ),
          //       ),
          //       contentPadding: const EdgeInsets.symmetric(
          //         horizontal: 16,
          //         vertical: 14,
          //       ),
          //     ),
          //   ),
          // ),
          Container(
            height: 48,
            margin: const EdgeInsets.only(bottom: 16),
            child: RoundedTextField(
              backgroundColor: Colors.white,
              controller: costTextController,
              hintText: 'Укажите цену*',
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          Container(
            // height: 48,
            margin: const EdgeInsets.only(bottom: 24),
            child: RoundedTextField(
              backgroundColor: Colors.white,
              controller: commentTextController,
              hintText: 'Комментарий',
              maxLines: 2,
              inputFormatters: [LengthLimitingTextInputFormatter(30)],
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton.primary(
              isLoading: isLoading,
              onPressed: driverOrderForm.isValid ? handleOrderSubmit : null,
              text: 'Заказать',
              textStyle: text400Size16White,
            ),
          )
        ],
      ),
    );
  }

  Future<void> handleOrderSubmit() async {
    setState(() {
      isLoading = true;
    });
    try {
      await widget.onSubmit(driverOrderForm);
    } on Exception catch (e) {
      final snackBar = SnackBar(
        content: Text(
          'Не удалось создать заказ',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<List<String>> getSuggesstions(String searchValue) async {
    String? sessionId = inject<SharedPreferences>().getString('sessionId');

    if (sessionId == null) {
      sessionId = const UuidV4().generate();
      inject<SharedPreferences>().setString('sessionId', sessionId);
    }

    final response = await inject<MapTilerCloudApi>().geoCodingByQuery(
      query: searchValue,
      accessToken: 'HcgJnGUrEU9K93fPa6qG',
    );

    setState(() {
      suggestions = response.features ?? [];
    });
    return (response.features ?? [])
        .map(
          (feature) => jsonEncode({
            'label': [
              feature.text ?? '',
              // feature.placeFormatted ?? '',
            ].join(','),
            // "mapbox_id": '${feature.mapboxId}'
          }),
        )
        .toList();
  }

  _onFromSubmitted(String json) {
    fromAddressTextController.text = (jsonDecode(json))['label'];
    setState(() {
      driverOrderForm = driverOrderForm.copyWith(
          fromAddress: Required.dirty((jsonDecode(json))['label']),
          fromMapboxId: Required.dirty((jsonDecode(json))['mapbox_id']));
    });
  }

  _onToSubmitted(String json) {
    toAddressTextController.text = (jsonDecode(json))['label'];
    setState(() {
      driverOrderForm = driverOrderForm.copyWith(
          toAddress: Required.dirty((jsonDecode(json))['label']),
          toMapboxId: Required.dirty((jsonDecode(json))['mapbox_id']));
    });
  }
}
