import 'package:aktau_go/interactors/main_navigation_interactor.dart';
import 'package:aktau_go/interactors/session_interactor.dart';
import 'package:elementary/elementary.dart';
import 'package:elementary_helper/elementary_helper.dart';

class MainModel extends ElementaryModel {
  final SessionInteractor _sessionInteractor;
  final MainNavigationInteractor _mainNavigationInteractor;

  MainModel(
    this._sessionInteractor,
    this._mainNavigationInteractor,
  ) : super();

  StateNotifier<String> get role => _sessionInteractor.role;

  StateNotifier<int> get currentTab => _mainNavigationInteractor.currentTab;
}
