import 'package:flutter/material.dart';


myTextFieldDesign(hintText, labelText, prefixIcon, suffixIcon) {
  return InputDecoration(
    hintText: hintText,
    labelText: labelText,
    prefixIcon: Icon(prefixIcon),
    suffixIcon: Icon(suffixIcon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.green),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.grey),
    ),
  );
}

