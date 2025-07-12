import 'package:flutter/services.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({this.decimalRange = 2})
      : assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text == '') return newValue;

    final newText = RegExp(r'^\d*\.?\d{0,' + decimalRange.toString() + r'}$');

    if (newText.hasMatch(text)) {
      return newValue;
    }

    return oldValue;
  }
}
