import 'package:flutter/material.dart';

class HeadingText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;

  const HeadingText(this.text, {this.textAlign = TextAlign.left, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: CustomTextStyles.heading1,
    );
  }
}

// Define a class to hold your styles
class CustomTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500
  );
  static const TextStyle heading2 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  // You can add more styles here
}
