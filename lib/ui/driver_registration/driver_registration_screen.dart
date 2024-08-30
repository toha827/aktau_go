import 'package:aktau_go/domains/driver_registered_category/driver_registered_category_domain.dart';
import 'package:aktau_go/forms/driver_registration_form.dart';
import 'package:aktau_go/ui/widgets/primary_dropdown.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elementary/elementary.dart';

import '../../core/colors.dart';
import '../../core/text_styles.dart';
import '../widgets/primary_button.dart';
import '../widgets/rounded_text_field.dart';
import 'driver_registration_wm.dart';

class DriverRegistrationScreen extends ElementaryWidget<IDriverRegistrationWM> {
  DriverRegistrationScreen({
    Key? key,
  }) : super(
          (context) => defaultDriverRegistrationWMFactory(context),
        );

  @override
  Widget build(IDriverRegistrationWM wm) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Регистрация',
          style: text400Size16Black,
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
          firstSource: wm.driverRegistrationForm,
          secondSource: wm.driverRegisteredCategories,
          builder: (
            context,
            DriverRegistrationForm? driverRegistrationForm,
            List<DriverRegisteredCategoryDomain>? driverRegisteredCategories,
          ) {
            return ListView(
              children: [
                const SizedBox(
                  height: 40,
                ),
                if (driverRegisteredCategories!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Зарегестрированные категории',
                            style: text500Size24Greyscale90,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 150,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              const SizedBox(width: 16),
                              ...?driverRegisteredCategories
                                  ?.map(
                                    (e) => Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'Категория: ${e.categoryType.value}'),
                                          Text('Авто: ${e.brand} ${e.model}'),
                                          Text('Гос. номер: ${e.number}'),
                                          Text('Цвет: ${e.color}'),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: Color(0xFFE7E1E1)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Заполните анкету',
                            style: text500Size24Greyscale90,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Выберите, в какой категории вы будете работать',
                            style: text400Size12Greyscale50,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Заполните бренд',
                            style: text400Size12Greyscale50,
                          ),
                        ),
                        RoundedTextField(
                          backgroundColor: Colors.white,
                          hintText: 'Бренд',
                          hintStyle: text400Size16Greyscale30,
                          controller: wm.brandTextEditingController,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Заполните модель авто',
                            style: text400Size12Greyscale50,
                          ),
                        ),
                        RoundedTextField(
                          backgroundColor: Colors.white,
                          hintText: 'Модель',
                          hintStyle: text400Size16Greyscale30,
                          controller: wm.modelTextEditingController,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Заполните гос. номер',
                            style: text400Size12Greyscale50,
                          ),
                        ),
                        RoundedTextField(
                          backgroundColor: Colors.white,
                          hintText: 'Гос. номер',
                          hintStyle: text400Size16Greyscale30,
                          controller: wm.governmentNumberTextEditingController,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Заполните ИИН',
                            style: text400Size12Greyscale50,
                          ),
                        ),
                        RoundedTextField(
                          backgroundColor: Colors.white,
                          hintText: 'ИИН',
                          hintStyle: text400Size16Greyscale30,
                          controller: wm.ssnTextEditingController,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Выберите категорию',
                            style: text400Size12Greyscale50,
                          ),
                        ),
                        Container(
                          height: 40,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: PrimaryDropdown<DriverType>(
                            initialOption: driverRegistrationForm?.type.value,
                            options: DriverType.values
                                .where((e) => !driverRegisteredCategories.any(
                                    (category) => category.categoryType == e))
                                .map((e) => SelectOption(
                                      value: e,
                                      label: e.value,
                                    ))
                                .toList(),
                            onChanged: (option) =>
                                wm.handleDriverTypeChanged(option!.value),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Выберите цвет',
                            style: text400Size12Greyscale50,
                          ),
                        ),
                        Container(
                          height: 40,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: PrimaryDropdown<CarColor>(
                            initialOption: driverRegistrationForm!.color.value,
                            options: wm.carColors
                                .map((e) => SelectOption(
                                      value: e,
                                      label: e.label,
                                    ))
                                .toList(),
                            onChanged: (option) =>
                                wm.handleColorChanged(option!.value),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton.primary(
                            onPressed: driverRegistrationForm.isValid
                                ? wm.submitProfileRegistration
                                : null,
                            text: 'Продолжить',
                            textStyle: text400Size16White,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }
}
