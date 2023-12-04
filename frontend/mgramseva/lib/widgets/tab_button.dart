import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';


class TabButton extends StatelessWidget {
  final String buttonLabel;
  final bool? isSelected;
  final bool? isMainTab;
  final Function()? onPressed;

  TabButton(this.buttonLabel, {this.isSelected, this.isMainTab, this.onPressed});


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: LayoutBuilder(
        builder: (context, constraints)=> Container(
          width: (isMainTab ?? false) ? constraints.maxWidth / 2 : null,
          height: (isMainTab ?? false) ? 50 : null,
          decoration: (isMainTab ?? false) ?  BoxDecoration(
              color: (isSelected ?? false) ? Colors.white : null,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(0.0)
          ) :  BoxDecoration(
              color: (isSelected ?? false) ? Colors.white : Color.fromRGBO(244, 119, 56, 0.12),
              borderRadius: BorderRadius.circular(18.0)
          ),
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
          child: Text(ApplicationLocalizations.of(context).translate( buttonLabel),
            style: TextStyle(color: (isMainTab ?? false) && !(isSelected ?? false) ? Theme.of(context).primaryColorDark :
            Theme.of(context).primaryColor, fontSize: (isMainTab ?? false) ? 16 : 14, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,),
        ),
      ),
    );
  }
}