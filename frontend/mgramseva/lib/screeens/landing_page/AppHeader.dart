import 'package:flutter/material.dart';

class AppHeader extends StatefulWidget {
  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Image.asset("assets/png/svgg.png"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Image.asset("assets/png/jal_jeevan.png"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Image.asset("assets/png/national-emblem-india.png"),
            ),
          ],
        ),
      ),
    );
  }
}
