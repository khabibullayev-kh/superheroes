import 'package:flutter/material.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/widgets/action_button.dart';

class SuperHeroPage extends StatelessWidget {
  final String name;

  const SuperHeroPage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SuperHeroesColors.background,
      body: SafeArea(
          child: Stack(
        children: [
          Center(
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ActionButton(
              text: 'Back',
              onTap: () => Navigator.pop(context),
            ),
          )
        ],
      )),
    );
  }
}
