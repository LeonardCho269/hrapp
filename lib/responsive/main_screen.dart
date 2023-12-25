import 'package:flutter/material.dart';
import 'package:responsive_ht/constants.dart';
import 'package:responsive_ht/responsive/home_page_data.dart';
import 'package:responsive_ht/responsive/responsive_layout.dart';

class YourMainScreen extends StatelessWidget {
  const YourMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileScaffold: Scaffold(
        backgroundColor: myDefaultBackgroundColor,
        body: const MyHomePage(),
      ),
      tabletScaffold: Scaffold(
        backgroundColor: myDefaultBackgroundColor,
        body: const Row(
          children: [
            Expanded(
              child: MyHomePage(),
            ),
          ],
        ),
      ),
      desktopScaffold: Scaffold(
        backgroundColor: myDefaultBackgroundColor,
        body: Row(
          children: [
            myDrawer(context),
            const Expanded(
              child: MyHomePage(),
            ),
          ],
        ),
      ),
    );
  }
}
