import 'package:injectable/injectable.dart';

import 'package:aktau_go/interactors/common/rest_client.dart';
import 'package:aktau_go/models/user/mapper/user_mapper.dart';

import '../domains/user/user_domain.dart';

abstract class IProfileInteractor {
  Future<UserDomain> fetchUserProfile();
}

@singleton
class ProfileInteractor extends IProfileInteractor {
  final RestClient _restClient;

  ProfileInteractor(this._restClient);

  @override
  Future<UserDomain> fetchUserProfile() async =>
      userMapper(await _restClient.getUserProfile());
}
