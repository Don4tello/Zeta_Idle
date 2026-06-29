import 'package:flutter/widgets.dart';

/// InheritedWidget provided by HeroHubScreen so that deep children
/// (e.g. DashboardHeader hint) can switch hero tabs without prop drilling.
class HeroTabController extends InheritedWidget {
  const HeroTabController({
    super.key,
    required this.switchTo,
    required super.child,
  });

  final void Function(int tabIndex) switchTo;

  static HeroTabController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroTabController>();

  @override
  bool updateShouldNotify(HeroTabController old) => false;
}
