import 'package:aktau_go/interactors/session_interactor.dart';
import 'package:elementary/elementary.dart';
import 'package:elementary_helper/elementary_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

abstract class IMainNavigationInteractor {
  StateNotifier<bool> get doubleTappedListener;

  StateNotifier<int> get currentTab;

  StateNotifier<int> get currentSubTab;

  StateNotifier<int> get myAdsSubTab;

  PageController get pageController;

  void changeTab(int newTab);

  void doubleTapped();

  void changeMyAdsSubTab(int newTab);
}

@singleton
class MainNavigationInteractor extends IMainNavigationInteractor {
  final SessionInteractor _sessionInteractor;

  MainNavigationInteractor(this._sessionInteractor);

  @override
  void changeTab(
    int newTab, [
    int? newSubTab,
  ]) {
    currentTab.accept(newTab);
    if (newSubTab != null) {
      currentSubTab.accept(newSubTab);
    }
    // pageController.jumpToPage(
    //   newTab,
    // );
  }

  @override
  void doubleTapped() {
    doubleTappedListener.accept(true);
    doubleTappedListener.accept(false);
  }

  @override
  void changeMyAdsSubTab(
    int newTab,
  ) {
    myAdsSubTab.accept(newTab);
  }

  @override
  final StateNotifier<int> currentTab = StateNotifier(initValue: 0);

  @override
  final StateNotifier<bool> doubleTappedListener =
      StateNotifier(initValue: false);

  @override
  final StateNotifier<int> currentSubTab = StateNotifier(initValue: 0);

  @override
  final StateNotifier<int> myAdsSubTab = StateNotifier(initValue: 0);

  @override
  final PageController pageController = PageController();
}
