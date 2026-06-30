import 'package:flutter/material.dart';

class AppBarLogo extends StatelessWidget {
  const AppBarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      background: Padding(
        padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
        child: Image.asset(
          'assets/images/logo.png',
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
