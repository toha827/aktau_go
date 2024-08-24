import '../../../domains/active_request/active_request_domain.dart';
import '../active_request_model.dart';
import '../../order_request/mapper/order_request_mapper.dart';
import '../../user/mapper/user_mapper.dart';

ActiveRequestDomain activeRequestMapper(
  ActiveRequestModel model,
) =>
    ActiveRequestDomain(
      whatsappUser: userMapper(model.whatsappUser!),
      orderRequest: orderRequestMapper(
        model.orderRequest!,
        model.whatsappUser!,
      ),
    );

List<ActiveRequestDomain> activeRequestListMapper(
  List<ActiveRequestModel> list,
) =>
    list.map((e) => activeRequestMapper(e)).toList();
