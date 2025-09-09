import 'package:flutter/material.dart';

ButtonStyle getCustomButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFD91B24),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}
