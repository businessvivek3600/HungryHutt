import 'package:flutter/material.dart';


Padding buildGradientHeadingRow(BuildContext context ,String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  // Dark Gray
                  Colors.black,
                  Colors.black54, // Light Gray
                  Colors.black12, // Black
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  Colors.black12, // Light Gray
                  Colors.black54, // Dark Gray
                  Colors.black, // Black
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}