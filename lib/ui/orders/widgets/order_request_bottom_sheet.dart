import 'package:aktau_go/ui/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../domains/order_request/order_request_domain.dart';
import '../../../core/colors.dart';
import '../../../core/images.dart';
import '../../../core/text_styles.dart';
import '../../../utils/num_utils.dart';
import '../../widgets/primary_bottom_sheet.dart';

class OrderRequestBottomSheet extends StatefulWidget {
  final OrderRequestDomain orderRequest;
  final VoidCallback onAccept;

  const OrderRequestBottomSheet({
    super.key,
    required this.orderRequest,
    required this.onAccept,
  });

  @override
  State<OrderRequestBottomSheet> createState() =>
      _OrderRequestBottomSheetState();
}

class _OrderRequestBottomSheetState extends State<OrderRequestBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return PrimaryBottomSheet(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
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
          SizedBox(
            width: double.infinity,
            child: Text(
              'Поиск водителя...',
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
                          widget.orderRequest.user?.name ?? '',
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
                        'https://wa.me/${(widget.orderRequest.user?.phone ?? '').replaceAll('+', '')}');
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
          Container(
            width: double.infinity,
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
                      widget.orderRequest.comment,
                      style: text400Size12Greyscale90,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                // Container(
                //   width: double.infinity,
                //   height: 300,
                //   decoration: BoxDecoration(
                //     image: DecorationImage(
                //       image: NetworkImage(
                //         "https://via.placeholder.com/344x98",
                //       ),
                //       fit: BoxFit.fill,
                //     ),
                //   ),
                //   child: MapWidget(
                //     onMapCreated: _onMapCreated,
                //     styleUri: MapboxStyles.STANDARD,
                //     cameraOptions: CameraOptions(
                //       zoom: 12,
                //       bearing: 0,
                //       pitch: 0,
                //       center: Point(
                //         coordinates: Position(
                //           widget.orderRequest.lng,
                //           widget.orderRequest.lat,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
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
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        widget.orderRequest.lat.toDouble(),
                        widget.orderRequest.lng.toDouble(),
                      ),
                    ),
                    children: [
                      openStreetMapTileLayer,
                      MarkerLayer(
                        // rotate: counterRotate,
                        markers: [
                          Marker(
                            point: LatLng(
                              widget.orderRequest.lat.toDouble(),
                              widget.orderRequest.lng.toDouble(),
                            ),
                            width: 16,
                            height: 16,
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.location_on_rounded,
                              color: Colors.red,
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
                      Column(
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/placemark.svg',
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.orderRequest.from,
                                  textAlign: TextAlign.center,
                                  style: text400Size16Black,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
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
                                Text(
                                  widget.orderRequest.to,
                                  textAlign: TextAlign.center,
                                  style: text400Size16Black,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                      'Цена поездки: ${NumUtils.humanizeNumber(widget.orderRequest.price)} ₸ ',
                      style: text400Size16Greyscale90,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton.secondary(
                    onPressed: Navigator.of(context).pop,
                    text: 'Отказаться',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton.primary(
                    onPressed: widget.onAccept,
                    text: 'Принять заказ',
                    textStyle: text400Size16White,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
      // Use the recommended flutter_map_cancellable_tile_provider package to
      // support the cancellation of loading tiles.
      tileProvider: CancellableNetworkTileProvider(),
    );
