import 'package:flutter/widgets.dart';

enum ScreenSize { phone, tablet, desktop }

class Responsive {
  static ScreenSize of(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 600) return ScreenSize.phone;
    if (w < 1024) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double fontSize(BuildContext context, double desktop) =>
      isPhone(context) ? desktop * 0.85 : desktop;

  static double iconSize(BuildContext context, double desktop) =>
      isPhone(context) ? desktop * 0.8 : desktop;

  static EdgeInsets padding(BuildContext context, {double desktop = 16}) =>
      EdgeInsets.all(isPhone(context) ? desktop * 0.65 : desktop);
}
