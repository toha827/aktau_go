import 'package:aktau_go/core/text_styles.dart';
import 'package:aktau_go/ui/tenant_home/forms/driver_order_form.dart';
import 'package:aktau_go/ui/widgets/primary_button.dart';
import 'package:aktau_go/ui/widgets/rounded_text_field.dart';
import 'package:aktau_go/utils/text_editing_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/images.dart';
import '../../../forms/inputs/required_formz_input.dart';

class TenantHomeCreateOrderView extends StatefulWidget {
  final ScrollController scrollController;
  final Function(DriverOrderForm) onSubmit;

  const TenantHomeCreateOrderView({
    super.key,
    required this.scrollController,
    required this.onSubmit,
  });

  @override
  State<TenantHomeCreateOrderView> createState() =>
      _TenantHomeCreateOrderViewState();
}

class _TenantHomeCreateOrderViewState extends State<TenantHomeCreateOrderView> {
  bool isLoading = false;
  DriverOrderForm driverOrderForm = DriverOrderForm();

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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 48,
            margin: const EdgeInsets.only(bottom: 16),
            child: RoundedTextField(
              backgroundColor: Colors.white,
              controller: fromAddressTextController,
              hintText: 'Откуда*',
              decoration: InputDecoration(
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
            ),
          ),
          Container(
            height: 48,
            margin: const EdgeInsets.only(bottom: 16),
            child: RoundedTextField(
              backgroundColor: Colors.white,
              controller: toAddressTextController,
              hintText: 'Куда*',
              decoration: InputDecoration(
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
            ),
          ),
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
            height: 48,
            margin: const EdgeInsets.only(bottom: 24),
            child: RoundedTextField(
              backgroundColor: Colors.white,
              controller: commentTextController,
              hintText: 'Комментарий',
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
              onPressed: driverOrderForm.isValid
                  ? handleOrderSubmit
                  : null,
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
      // TODO
    }
    setState(() {
      isLoading = false;
    });
  }
}
