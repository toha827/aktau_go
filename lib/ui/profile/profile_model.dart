import 'package:aktau_go/interactors/profile_interactor.dart';
import 'package:elementary/elementary.dart';
import 'package:elementary_helper/elementary_helper.dart';

import '../../domains/user/user_domain.dart';
import '../../interactors/session_interactor.dart';

class ProfileModel extends ElementaryModel {
  final SessionInteractor _sessionInteractor;
  final ProfileInteractor _profileInteractor;

  ProfileModel(
    this._sessionInteractor,
    this._profileInteractor,
  ) : super();

  StateNotifier<String> get role => _sessionInteractor.role;

  Future<UserDomain> fetchUserProfile() =>
      _profileInteractor.fetchUserProfile();
}
