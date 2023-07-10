import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  int thickness;
  CustomDivider({super.key, required this.thickness});

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness.toDouble(),
      indent: 20,
      endIndent: 20,
      color: const Color.fromARGB(255, 253, 253, 253),
    );
  }
}
