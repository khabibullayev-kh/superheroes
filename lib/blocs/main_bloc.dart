import 'dart:async';

import 'package:rxdart/rxdart.dart';

class MainBloc {

  final BehaviorSubject<MainPageState> stateController = BehaviorSubject();
  Stream<MainPageState> observeMainPageState() => stateController;
  
  MainBloc() {
    stateController.sink.add(MainPageState.noFavorites);
  }

  void nextState() {
      final currentState = stateController.value;
      final nextState = MainPageState.values[(MainPageState.values.indexOf(
          currentState) + 1) % MainPageState.values.length];
      stateController.add(nextState);
  }

  void dispose() {
    stateController.close();
  }
}

enum MainPageState {
  noFavorites,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResults,
  favorites,
}