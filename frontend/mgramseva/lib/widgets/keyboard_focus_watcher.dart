import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardFocusWatcher extends StatelessWidget {
  final Widget child;
  final Function()? onUnFocus;
  const KeyboardFocusWatcher({required this.child, this.onUnFocus, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(WidgetsBinding.instance.window.viewInsets.bottom > 0.0) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        }else{
          FocusScope.of(context).unfocus();
          if(onUnFocus != null) onUnFocus!();
        }
      },
      child: child,
    );
  }
}
