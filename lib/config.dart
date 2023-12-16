import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'models/LanguageModel.dart';

class config {
  static const String supabase_url = 'https://jyghacisbuntbrshhhey.supabase.co';
  static const String anon_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5Z2hhY2lzYnVudGJyc2hoaGV5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODIxMjAyMjksImV4cCI6MTk5NzY5NjIyOX0.SLVxu1YRl2iBYRqk2LTm541E0lwBiP4FBebN8PS0Rqg';
  static const String home_page = 'Absolventský Velehrad';
  static String map_page = "Map".tr();

  static const primaryColor = 0xFF2C677B;
  static const backgroundColor = Color(0xFFFFFFFF);
  static const color1 = Color(primaryColor);
  static const color2 = Color(0xFFBA5D3F);
  static const color3 = Color(0xFFE0B73B);
  static const color4 = Color(0xFF2A77A0);
  static const attentionColor = Color(0xFF8B0000);

  static const bool isServiceRoleSafety = false;
  static const bool isNotificationsSupported = false;
  static const String OneSignalAppId = '';

  static const String generatedPasswordPrefix = "av";
  static const String welcomeEmailTemplate = "jy7zpl9nqe545vx6";

  static List<LanguageModel> AvailableLanguages = [
    LanguageModel(const Locale("en"), "English"),
    LanguageModel(const Locale("cs"), "Čeština"),
    LanguageModel(const Locale("sk"), "Slovenčina"),
    LanguageModel(const Locale("pl"), "Polski"),
    LanguageModel(const Locale("de"), "Deutsch"),
  ];
}