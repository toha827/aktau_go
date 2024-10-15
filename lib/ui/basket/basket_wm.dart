import 'package:aktau_go/domains/food/food_domain.dart';
import 'package:elementary/elementary.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

import '../../forms/inputs/required_formz_input.dart';
import '../../utils/text_editing_controller.dart';
import './basket_model.dart';
import './basket_screen.dart';
import 'forms/food_order_form.dart';

defaultBasketWMFactory(BuildContext context) => BasketWM(BasketModel());

abstract class IBasketWM implements IWidgetModel {
  StateNotifier<int> get step;

  StateNotifier<FoodOrderForm> get foodOrderForm;

  StateNotifier<FormzSubmissionStatus> get foodOrderStatus;

  StateNotifier<List<Map<String, dynamic>>> get selectedProducts;

  TextEditingController get streetTextController;

  TextEditingController get buildingTextController;

  TextEditingController get apartmentTextController;

  TextEditingController get entranceTextController;

  TextEditingController get levelTextController;

  TextEditingController get commentTextController;

  Future<void> handleSubmit();

  void handleNextStep();

  handleAddQuantity(int i, FoodDomain selectedProduct);

  handleSubstractQuantity(int i, FoodDomain selectedProduct);

  void onPop();
}

class BasketWM extends WidgetModel<BasketScreen, BasketModel>
    implements IBasketWM {
  BasketWM(
    BasketModel model,
  ) : super(model);

  @override
  StateNotifier<int> step = StateNotifier(
    initValue: 0,
  );

  @override
  StateNotifier<FoodOrderForm> foodOrderForm = StateNotifier(
    initValue: FoodOrderForm(),
  );

  @override
  final StateNotifier<FormzSubmissionStatus> foodOrderStatus = StateNotifier(
    initValue: FormzSubmissionStatus.initial,
  );

  @override
  late final StateNotifier<List<Map<String, dynamic>>> selectedProducts =
      StateNotifier(
    initValue: widget.selectedProducts,
  );

  @override
  late final TextEditingController apartmentTextController =
      createTextEditingController(
    initialText: '',
    onChanged: (apartment) {
      foodOrderForm.accept(foodOrderForm.value!.copyWith(
        apartment: Required.dirty(num.tryParse(apartment)),
      ));
    },
  );

  @override
  late final TextEditingController buildingTextController =
      createTextEditingController(
    initialText: '',
    onChanged: (building) {
      foodOrderForm.accept(foodOrderForm.value!.copyWith(
        building: Required.dirty(num.tryParse(building)),
      ));
    },
  );

  @override
  late final TextEditingController commentTextController =
      createTextEditingController(
    initialText: '',
    onChanged: (comment) {
      foodOrderForm.accept(foodOrderForm.value!.copyWith(
        comment: comment,
      ));
    },
  );

  @override
  late final TextEditingController entranceTextController =
      createTextEditingController(
    initialText: '',
    onChanged: (entrance) {
      foodOrderForm.accept(foodOrderForm.value!.copyWith(
        entrance: Required.dirty(num.tryParse(entrance)),
      ));
    },
  );

  @override
  late final TextEditingController levelTextController =
      createTextEditingController(
    initialText: '',
    onChanged: (level) {
      foodOrderForm.accept(foodOrderForm.value!.copyWith(
        level: Required.dirty(num.tryParse(level)),
      ));
    },
  );

  @override
  late final TextEditingController streetTextController =
      createTextEditingController(
    initialText: '',
    onChanged: (street) {
      foodOrderForm.accept(foodOrderForm.value!.copyWith(
        street: Required.dirty(street),
      ));
    },
  );

  @override
  Future<void> handleSubmit() {
    // TODO: implement handleSubmit
    throw UnimplementedError();
  }

  @override
  void handleNextStep() {
    step.accept(1);
  }

  @override
  handleAddQuantity(int i, FoodDomain selectedProduct) {
    List<Map<String, dynamic>> temp = [...(selectedProducts.value ?? [])];

    temp[i] = {
      ...temp[i],
      'quantity': (temp[i]['quantity'] as num) + 1,
    };

    selectedProducts.accept(temp);
  }

  @override
  handleSubstractQuantity(int i, FoodDomain selectedProduct) {
    List<Map<String, dynamic>> temp = [...(selectedProducts.value ?? [])];

    if ((temp[i]['quantity'] as num) == 1) {
      temp.removeAt(i);
    } else {
      temp[i] = {
        ...temp[i],
        'quantity': (temp[i]['quantity'] as num) - 1,
      };
    }

    selectedProducts.accept(temp);
  }

  @override
  void onPop() {
    if (step.value == 0) {
      Navigator.of(context).pop();
    } else {
      step.accept(step.value! - 1);
    }
  }
}
