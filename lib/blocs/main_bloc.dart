import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/model/superhero.dart';

class MainBloc {
  static const minSymbols = 3;

  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();
  final favoriteSuperheroesSubject =
      BehaviorSubject<List<SuperheroInfo>>.seeded(SuperheroInfo.mocked);
  final searchSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubject = BehaviorSubject<String>.seeded('');

  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;

  http.Client? client;

  MainBloc({this.client}) {
    stateSubject.sink.add(MainPageState.noFavorites);

    textSubscription = Rx.combineLatest2<String, List<SuperheroInfo>, MainPageStateInfo>(
        currentTextSubject.distinct().debounceTime(Duration(microseconds: 500)),
        favoriteSuperheroesSubject,
        (searchedText, favorites) => MainPageStateInfo(
              searchedText,
              favorites.isNotEmpty,
            )).listen((value) {
              print('CHNAGED $value');
      searchSubscription?.cancel();
      if (value.searchText.isEmpty) {
        if (value.haveFavourites) {
          stateSubject.add(MainPageState.favorites);
        } else {
          stateSubject.add(MainPageState.noFavorites);
        }
      } else if (value.searchText.length < minSymbols) {
        stateSubject.add(MainPageState.minSymbols);
      } else {
        searchForSuperheroes(value.searchText);
      }
    });
  }

  void searchForSuperheroes(final String text) {
    stateSubject.add(MainPageState.loading);
    searchSubscription = search(text).asStream().listen((searchResults) {
      if (searchResults.isEmpty) {
        stateSubject.add(MainPageState.nothingFound);
      } else {
        searchSuperheroesSubject.add(searchResults);
        stateSubject.add(MainPageState.searchResults);
      }
    }, onError: (error, stackTrace) {
      print(error);
      stateSubject.add(MainPageState.loadingError);
    });
  }

  void retry() {
    final currentText = currentTextSubject.value;
    searchForSuperheroes(currentText);
  }

  Stream<List<SuperheroInfo>> observeFavoriteSuperheroes() =>
      favoriteSuperheroesSubject;

  Stream<List<SuperheroInfo>> observeSearchSuperheroes() =>
      searchSuperheroesSubject;

  Future<List<SuperheroInfo>> search(final String text) async {
    final token = dotenv.env['SUPERHERO_TOKEN'];
    final response = await (client ??= http.Client())
        .get(Uri.parse('https://superheroapi.com/api/$token/search/$text'));

    if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ApiException('Server error happened');
    }
    if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw ApiException('Client error happened');
    }

    final decoded = json.decode(response.body);

    if (decoded['response'] == 'success') {
      final List<dynamic> results = decoded['results'];
      final List<Superhero> superhero = results
          .map((rawSuperhero) => Superhero.fromJson(rawSuperhero))
          .toList();
      final List<SuperheroInfo> found = superhero.map((superhero) {
        return SuperheroInfo(
          name: superhero.name,
          realName: superhero.biography.fullName,
          imageUrl: superhero.image.url,
        );
      }).toList();
      return found;
    } else if (decoded['response'] == 'error') {
      if (decoded['error'] == 'character with given name not found') {
        return [];
      }
      throw ApiException('Client error happened');
    }
    throw Exception('Unknown error happened');
  }

  Stream<MainPageState> observeMainPageState() => stateSubject;

  void removeFavorite() {
    final List<SuperheroInfo> currentFavorites =
        favoriteSuperheroesSubject.value;
    if (currentFavorites.isEmpty) {
      favoriteSuperheroesSubject.add(SuperheroInfo.mocked);
    } else {
      favoriteSuperheroesSubject
          .add(currentFavorites.sublist(0, currentFavorites.length - 1));
    }
  }

  void nextState() {
    final currentState = stateSubject.value;
    final nextState = MainPageState.values[
        (MainPageState.values.indexOf(currentState) + 1) %
            MainPageState.values.length];
    stateSubject.add(nextState);
  }

  void updateText(final String? text) {
    currentTextSubject.add(text ?? '');
  }

  void dispose() {
    stateSubject.close();
    favoriteSuperheroesSubject.close();
    searchSuperheroesSubject.close();
    currentTextSubject.close();

    textSubscription?.cancel();
    searchSubscription?.cancel();

    client?.close();
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

class SuperheroInfo {
  final String name;
  final String realName;
  final String imageUrl;

  const SuperheroInfo(
      {required this.name, required this.realName, required this.imageUrl});

  @override
  String toString() {
    return 'SuperheroInfo{name: $name, realName: $realName, imageUrl: $imageUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuperheroInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          realName == other.realName &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => name.hashCode ^ realName.hashCode ^ imageUrl.hashCode;

  static const mocked = [
    SuperheroInfo(
      name: 'Batman',
      realName: 'Bruce Wayne',
      imageUrl:
          'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg',
    ),
    SuperheroInfo(
      name: 'Iron Man',
      realName: 'Tony Stark',
      imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/85.jpg",
    ),
    SuperheroInfo(
      name: 'Venom',
      realName: 'Eddie Brock',
      imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/22.jpg",
    )
  ];
}

class MainPageStateInfo {
  final String searchText;
  final bool haveFavourites;

  MainPageStateInfo(this.searchText, this.haveFavourites);

  @override
  String toString() {
    return 'MainPageStateInfo{searchText: $searchText, haveFavourites: $haveFavourites}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainPageStateInfo &&
          runtimeType == other.runtimeType &&
          searchText == other.searchText &&
          haveFavourites == other.haveFavourites;

  @override
  int get hashCode => searchText.hashCode ^ haveFavourites.hashCode;
}
