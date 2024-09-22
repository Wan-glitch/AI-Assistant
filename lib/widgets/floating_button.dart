import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20.0,
      right: 20.0,
      child: FloatingActionButton(
        onPressed: onPressed,
        child: Icon(Icons.settings),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
