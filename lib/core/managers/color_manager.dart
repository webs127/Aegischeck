import 'package:flutter/material.dart';

extension HexColor on Color {
  static Color hexString(String color) {
    color = color.replaceAll("#", "");
    if(color.length == 6) {
      color = "FF$color";
    }
    return Color(int.parse(color, radix: 16));
  }
}

class ColorManager {
  static Color black = HexColor.hexString("#000000");
  static Color white = HexColor.hexString("#FFFFFF");
  static Color primary = HexColor.hexString("#0B66FF");
  static Color background = HexColor.hexString("#F0F3F6");
  static Color grey = HexColor.hexString("#949FAE");
  static Color greybackground = HexColor.hexString("#E6E8ED");
  static Color orange = HexColor.hexString("#F39D0B");
  static Color background1 = HexColor.hexString("#EFF3F9");
  static Color primary1= HexColor.hexString("#1E3A8A");
  static Color tableHeadingColor= HexColor.hexString("#F0F4F8");
  static Color icon = HexColor.hexString("#68788E");
}