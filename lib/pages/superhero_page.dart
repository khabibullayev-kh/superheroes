import 'package:flutter/material.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/widgets/action_button.dart';

class SuperheroPage extends StatelessWidget {
  final String name;

  const SuperheroPage({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SuperheroesColors.background,
      body: SafeArea(
          child: Stack(
        children: [
          Center(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ActionButton(
              onTap: () {
                Navigator.of(context).pop();
              },
              text: 'Back',
            ),
          )
        ],
      )),
    );
  }
}
