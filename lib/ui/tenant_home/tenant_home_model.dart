import 'package:aktau_go/interactors/profile_interactor.dart';
import 'package:elementary/elementary.dart';

import '../../domains/active_request/active_request_domain.dart';
import '../../domains/food/foods_response_domain.dart';
import '../../domains/user/user_domain.dart';
import '../../interactors/food_interactor.dart';
import '../../interactors/order_requests_interactor.dart';
import '../../models/active_client_request/active_client_request_model.dart';

class TenantHomeModel extends ElementaryModel {
  final FoodInteractor _foodInteractor;
  final ProfileInteractor _profileInteractor;
  final OrderRequestsInteractor _orderRequestsInteractor;

  TenantHomeModel(
    this._foodInteractor,
    this._profileInteractor,
    this._orderRequestsInteractor,
  ) : super();

  Future<FoodsResponseDomain> fetchFoods() => _foodInteractor.fetchFoods();

  Future<UserDomain> getUserProfile() => _profileInteractor.fetchUserProfile();

  Future<ActiveClientRequestModel> getMyClientActiveOrder() =>
      _orderRequestsInteractor.getMyClientActiveOrder();

  Future<void> rejectOrderByClientRequest({
    required String orderRequestId,
  }) =>
      _orderRequestsInteractor.rejectOrderByClientRequest(
        orderRequestId: orderRequestId,
      );
}
