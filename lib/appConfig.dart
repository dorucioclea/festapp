import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'models/LanguageModel.dart';

class AppConfig {
  static const String supabaseUrl = 'https://hvtsoseaywurkmhywdbd.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh2dHNvc2VheXd1cmttaHl3ZGJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTYwMzk1MDYsImV4cCI6MjAzMTYxNTUwNn0.LIFBDLrSxTrI4z_Wwnt_5mS5SW2FC9ysVIhJ3m7FD10';
  static const String appName = 'Slunovrat 2024';
  static String mapTitle = "Map".tr();
  static const bool showPWAInstallOption = true;
  static const bool isOwnProgramSupportedWithoutSignIn = false;
  static const bool isOwnProgramSupported = true;
  static const bool isNotificationsSupported = true;
  static const bool isUsersImportSupported = false;
  static const String oneSignalAppId = '4c5b7280-510f-4628-8fb8-b4bdd4fed1b2';
  static const String defaultLink = "2024";

  //frosty style
  static const primaryColor = 0xFF0D0D0D;
  static const backgroundColor = Color(0xFFf9f9f9);
  static const color1 = Color(primaryColor);
  static const color2 = Color(0xFFf5ca00);
  static const color3 = Color(0xFF2ba29d);
  static const color4 = Color(0xFFa70f08);
  static const color5 = Color(0xFF40E0D0);
  static const attentionColor = Color(0xFF8B0000);

  static const timelineSplitLabelColor = color1;
  static const timelineTabLabelColor = color1;
  static const timelineTabIndicatorColor = color1;
  static const timelineColor = color1;
  static const mapPinColor = color1;
  static const newsPageColor = color1;
  static const profileButtonColor = color1;

  static const timetableColor = color1;
  static const timetableSelectedColor = color2;

  static const button1Color = color1;
  static const button2Color = color3;
  static const button3Color = color2;
  static const button4Color = color4;

  static const bool isSplitByPlace = false;

  static Color eventTypeToColor(String? type)
  {
    switch (type){
      case "music": return color2;
      case "talk": return color3;
      case "other": return color4;
      case "children": return color5;
    }
    return AppConfig.timetableSelectedColor;
  }

  static List<LanguageModel> availableLanguages = [
    LanguageModel(const Locale("cs"), "Čeština"),
    LanguageModel(const Locale("en"), "English"),
    LanguageModel(const Locale("pl"), "Polski"),
  ];
}