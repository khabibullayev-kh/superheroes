import 'package:flutter/material.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/widgets/action_button.dart';

class InfoWithButton extends StatelessWidget {
  final String title;
  final String subTitle;
  final String buttonText;
  final String assetImage;
  final double imageHeight;
  final double imageWidth;
  final double imageTopPadding;
  final VoidCallback onTap;

  const InfoWithButton({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.buttonText,
    required this.assetImage,
    required this.imageHeight,
    required this.imageWidth,
    required this.imageTopPadding,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              height: 108,
              width: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SuperheroesColors.blue,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: imageTopPadding),
              child: Image.asset(
                assetImage,
                width: imageWidth,
                height: imageHeight,
              ),
            )
          ],
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          subTitle.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 30),
        ActionButton(
          text: buttonText,
          onTap: onTap,
        )
      ],
    );
  }
}
