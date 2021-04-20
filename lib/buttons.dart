import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  final Function onTap;
  final IconData icontest;
  final double iconSize;

  Buttons({this.onTap, this.icontest, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: myBoxDecoration(),
      child: IconButton(
        iconSize: iconSize,
        color: Colors.white,
        icon: Icon(icontest),
        onPressed: onTap,
      ),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.white, width: 2),
      shape: BoxShape.circle,
    );
  }
}
