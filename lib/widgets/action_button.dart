import 'package:flutter/material.dart';
import 'package:superheroes/resources/superheroes_colors.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const ActionButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: SuperheroesColors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
