import '../order_request/order_request_domain.dart';
import '../user/user_domain.dart';

class ActiveRequestDomain {
  final UserDomain? whatsappUser;
  final OrderRequestDomain? orderRequest;

  const ActiveRequestDomain({
    this.whatsappUser,
    this.orderRequest,
  });
}
