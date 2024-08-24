import 'package:aktau_go/domains/user/user_domain.dart';
import 'package:aktau_go/models/user/user_model.dart';

UserDomain userMapper(
  UserModel model,
) =>
    UserDomain(
      id: model.id,
      phone: model.props?.phone,
      name: model.props?.name,
      firstName: model.props?.firstName,
      lastName: model.props?.lastName,
      middleName: model.props?.middleName,
      session: model.props?.session,
      rating: model.rating,
      today: model.earnings?.today,
      thisWeek: model.earnings?.thisWeek,
      thisMonth: model.earnings?.thisMonth,
    );
