import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;


TextTheme createTextTheme(BuildContext context, String primaryFont, String secondaryFont) {
  return TextTheme(
    displayLarge: TextStyle(
      inherit: true,
      fontFamily: primaryFont,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      height: 1.1,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    displayMedium: TextStyle(
      inherit: true,
      fontFamily: primaryFont,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      height: 1.1,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    displaySmall: TextStyle(
      inherit: true,
      fontFamily: primaryFont,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 1.1,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    bodyLarge: TextStyle(
      inherit: true,
      fontFamily: secondaryFont,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    bodyMedium: TextStyle(
      inherit: true,
      fontFamily: secondaryFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface,
    ),
    bodySmall: TextStyle(
      inherit: true,
      fontFamily: secondaryFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );
}



String obtenerFechaActual() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  return formattedDate;
}

void showCustomNotification({
  required BuildContext context,
  required String title,
  required String description,
  required Color background,
  required IconData  iconData, 
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ElegantNotification(
      animationDuration: const Duration(seconds: 1),
      toastDuration: const Duration(seconds: 4),
      background: background,
      width: 360,
      position: Alignment.bottomLeft,
      animation: AnimationType.fromLeft,
      title: Text(title),
      description: Text(description),
      onDismiss: () {},
      icon: Icon(iconData),
    ).show(context);
  });
}

