import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class Custom_container extends StatelessWidget {
  Color backgroundColor;
  double? height;
  double width;
  TextOverflow? overflow = TextOverflow.ellipsis;
  Color borderColor;
  double leftPadding;
  double rightPadding;
  double leftMargin;
  double rightMargin;
  double topMargin;
  double topPadding;
  double bottomMargin;
  double bottomPadding;
  Widget child;

  double borderRadius;

  Custom_container({
    Key? key,
    required this.backgroundColor,
    required this.width,
    this.height,
    required this.leftPadding,
    required this.rightPadding,
    required this.leftMargin,
    required this.rightMargin,
    required this.topMargin,
    required this.topPadding,
    required this.bottomMargin,
    required this.bottomPadding,
    required this.child,
    this.overflow,
    required this.borderColor,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.only(
        left: leftPadding,
        right: rightPadding,
        top: topPadding,
        bottom: bottomPadding,
      ),
      margin: EdgeInsets.only(
        left: leftMargin,
        right: rightMargin,
        top: topMargin,
        bottom: bottomMargin,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(
          Radius.circular(
            borderRadius!,
          ),
        ),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: child,
    );
  }
}
