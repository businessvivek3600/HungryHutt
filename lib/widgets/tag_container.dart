// Helper Widgets
import 'package:flutter/material.dart';

Widget buildBadge(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3)),
    child: Text(text,
        style: TextStyle(
            color: color, fontSize: 8, fontWeight: FontWeight.bold)),
  );
}