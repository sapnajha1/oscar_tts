import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Widget icon;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03, horizontal: screenWidth * 0.05), backgroundColor: Colors.blue,
        minimumSize: Size(double.infinity, screenWidth * 0.12), // Button color
      ),
      onPressed: onPressed,
      icon: icon,
      label: Text(
        text,
        style: TextStyle(fontSize: screenWidth * 0.04), // 4% of screen width
      ),
    );
  }
}
