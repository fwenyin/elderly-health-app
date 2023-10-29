import 'package:flutter/material.dart';

import '../widget/app_bar.dart';
import '../widget/navigation_bar.dart';

class ExplorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            SizedBox(height: 20),
            SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 4),
    );
  }
}
