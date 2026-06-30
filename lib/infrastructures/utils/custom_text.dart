import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  String data;
  double? minFontSize;
  double? fontSize = 12;
  int? maxLines = 1;
  TextOverflow? overflow = TextOverflow.ellipsis;
  FontWeight? fontWeight;
  String? fontFamily;
  Color? color;
  TextAlign? textAlign;

  TextDecoration? decoration;

  CustomText(
      {Key? key,
      required this.data,
      this.fontSize,
      this.maxLines,
      this.overflow,
      this.minFontSize = 6,
      this.fontFamily,
      this.fontWeight,
      this.decoration,
      this.textAlign,
      this.color, required TextAlign align})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(data,
        style: GoogleFonts.roboto(
            fontSize: fontSize,
            fontWeight: fontWeight,
            decoration: decoration,
            color: color),
        textAlign: textAlign,
        minFontSize: minFontSize!,
        maxLines: maxLines,
        overflow: overflow);
  }
}
