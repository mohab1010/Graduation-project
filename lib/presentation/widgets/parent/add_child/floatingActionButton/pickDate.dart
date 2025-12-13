import 'package:wesal/logic/services/variables_app.dart';
import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////
////////////             birthdate               /////////////
//////////////////////////////////////////////////////////////
Future<void> pickDate(BuildContext context) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
  );

  if (picked != null) {
    // تنسيق التاريخ ليتناسب مع قاعدة البيانات YYYY-MM-DD
    addChildbirthdate.text = picked.toIso8601String().split('T').first;
  }
}
