import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:superheroes/widgets/info_with_button.dart';
import 'package:superheroes/widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  final http.Client? client;

  MainPage({Key? key, this.client}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = MainBloc(client: widget.client);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperheroesColors.background,
        body: SafeArea(
          child: MainPageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class MainPageContent extends StatefulWidget {
  @override
  State<MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  late FocusNode searchFieldFocusNode;

  @override
  void initState() {
    super.initState();
    searchFieldFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MainPageStateWidget(
          searchFieldFocusNode: searchFieldFocusNode,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
          child: SearchWidget(
            searchFieldFocusNode: searchFieldFocusNode,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchFieldFocusNode.dispose();
    super.dispose();
  }
}

class SearchWidget extends StatefulWidget {
  final FocusNode searchFieldFocusNode;

  const SearchWidget({
    Key? key,
    required this.searchFieldFocusNode,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController controller = TextEditingController();
  bool haveSearchedText = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
      final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
      controller.addListener(() {
        bloc.updateText(controller.text);
        final haveText = controller.text.isNotEmpty;
        if (haveSearchedText != haveText) {
          setState(() {
            haveSearchedText = haveText;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: widget.searchFieldFocusNode,
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        color: Colors.white,
        fontSize: 20,
      ),
      cursorColor: Colors.white,
      textInputAction: TextInputAction.search,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        filled: true,
        fillColor: SuperheroesColors.indigo75,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Colors.white54,
          size: 24,
        ),
        suffix: GestureDetector(
          onTap: () => controller.clear(),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: 24,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: haveSearchedText
              ? BorderSide(color: Colors.white, width: 2)
              : BorderSide(color: Colors.white24),
        ),
      ),
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  final FocusNode searchFieldFocusNode;

  const MainPageStateWidget({
    Key? key,
    required this.searchFieldFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context, listen: false);
    return StreamBuilder<MainPageState>(
      stream: bloc.observeMainPageState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }
        final MainPageState state = snapshot.data!;
        switch (state) {
          case MainPageState.loading:
            return LoadingIndicator();
          case MainPageState.noFavorites:
            return Stack(
              children: [
                NoFavoritesWidget(
                  searchFieldFocusNode: searchFieldFocusNode,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ActionButton(
                    text: 'Remove',
                    onTap: bloc.removeFavorite,
                  ),
                )
              ],
            );
          case MainPageState.minSymbols:
            return MinSymbolsWidget();
          case MainPageState.nothingFound:
            return NothingFoundWidget(
              searchFieldFocusNode: searchFieldFocusNode,
            );
          case MainPageState.searchResults:
            return SuperheroesList(
              title: 'Search results',
              stream: bloc.observeSearchSuperheroes(),
            );
          case MainPageState.favorites:
            return Stack(
              children: [
                SuperheroesList(
                  title: 'Your favorites',
                  stream: bloc.observeFavoriteSuperheroes(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ActionButton(
                    text: 'Remove',
                    onTap: bloc.removeFavorite,
                  ),
                )
              ],
            );
          case MainPageState.loadingError:
            return LoadingErrorWidget(
              searchFieldFocusNode: searchFieldFocusNode,
            );
          default:
            return Center(
              child: Text(
                state.toString(),
                style: TextStyle(color: Colors.white),
              ),
            );
        }
      },
    );
  }
}

class SuperheroesList extends StatelessWidget {
  final String title;
  final Stream<List<SuperheroInfo>> stream;

  const SuperheroesList({
    Key? key,
    required this.title,
    required this.stream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SuperheroInfo>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final List<SuperheroInfo> superheroes = snapshot.data!;
        return ListView.separated(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: superheroes.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 90.0, bottom: 12.0),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
              );
            }
            final SuperheroInfo item = superheroes[index - 1];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SuperheroCard(
                superheroInfo: item,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SuperheroPage(
                        name: item.name,
                      ),
                    ),
                  );
                },
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 8);
          },
        );
      },
    );
  }
}

class NoFavoritesWidget extends StatelessWidget {
  final FocusNode searchFieldFocusNode;

  const NoFavoritesWidget({Key? key, required this.searchFieldFocusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InfoWithButton(
        title: 'No favourites yet',
        subTitle: 'Search and add',
        buttonText: 'Search',
        assetImage: SuperheroesImages.ironman,
        imageHeight: 119,
        imageWidth: 108,
        imageTopPadding: 9,
        onTap: () => searchFieldFocusNode.requestFocus(),
      ),
    );
  }
}

class NothingFoundWidget extends StatelessWidget {
  final FocusNode searchFieldFocusNode;

  const NothingFoundWidget({
    Key? key,
    required this.searchFieldFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InfoWithButton(
        title: 'Nothing found',
        subTitle: 'Search for something else',
        buttonText: 'Search',
        assetImage: SuperheroesImages.hulk,
        imageHeight: 112,
        imageWidth: 84,
        imageTopPadding: 16,
        onTap: () => searchFieldFocusNode.requestFocus(),
      ),
    );
  }
}

class LoadingErrorWidget extends StatelessWidget {
  final FocusNode searchFieldFocusNode;

  const LoadingErrorWidget({Key? key, required this.searchFieldFocusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<MainBloc>(context, listen: false);
    return Center(
      child: InfoWithButton(
        title: 'Error happened',
        subTitle: 'Please try again',
        buttonText: 'Retry',
        assetImage: SuperheroesImages.superman,
        imageHeight: 106,
        imageWidth: 126,
        imageTopPadding: 16,
        onTap: bloc.retry,
      ),
    );
  }
}

class MinSymbolsWidget extends StatelessWidget {
  const MinSymbolsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: Text(
          'Enter at least 3 symbols',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 110.0),
        child: CircularProgressIndicator(
          color: SuperheroesColors.blue,
          strokeWidth: 4,
        ),
      ),
    );
  }
}
