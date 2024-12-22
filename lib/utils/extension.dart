import 'package:flutter/cupertino.dart';

extension MediaQueryX on BuildContext {
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;
}
