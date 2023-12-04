import 'package:flutter_web_plugins/flutter_web_plugins.dart';

int i = 0;
void configureApp() {
  if(i < 1) {
    setUrlStrategy(PathUrlStrategy());
    i++;
  }
}