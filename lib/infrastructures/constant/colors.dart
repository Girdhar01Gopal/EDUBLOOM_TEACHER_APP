import 'dart:ui';

class AppColor {
  static const Color blackColor = Color(0xff000000);
}

class MyColors {
  static Color logoPurpleColor = _colorFromHex('#6f42c1');
  static Color logoPinkColor = _colorFromHex('#e83e8c');
  static Color logoRedColor = _colorFromHex('#dc3545');
  static Color babaColor = _colorFromHex('#FF7722');

  static Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
}
