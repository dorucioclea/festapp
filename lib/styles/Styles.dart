import 'package:flutter/material.dart';
import 'package:fstapp/appConfig.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_shadow/simple_shadow.dart';

MaterialColor primarySwatch = const MaterialColor(
  AppConfig.primaryColor,
  <int, Color>{
    50: Color(0xFFE1F0F4),
    100: Color(0xFFB4D9E4),
    200: Color(0xFF84BFD3),
    300: Color(0xFF55A5C2),
    400: Color(0xFF3994B6),
    500: Color(0xFF1D838A),
    600: Color(0xFF176E6F),
    700: Color(0xFF125954),
    800: Color(0xFF0C4239),
    900: Color(0xFF062E1E),
  },
);

TextStyle timeLineTabNameTextStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.bold);
TextStyle timeLineSmallTextStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.bold);
TextStyle timeLineSplitTextStyle = const TextStyle(
    color: AppConfig.color1, fontWeight: FontWeight.bold, fontSize: 15);
TextStyle normalTextStyle = const TextStyle(fontSize: 18);
double appMaxWidth = 820;


ButtonStyle mainPageButtonStyle = OutlinedButton.styleFrom(
    padding: const EdgeInsets.all(8),
    minimumSize: const Size(70, 50),

    maximumSize: const Size(80, 60),
    tapTargetSize: MaterialTapTargetSize.padded,
    backgroundColor: AppConfig.color2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));

class MainPageButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final EdgeInsets margin;
  final Color backgroundColor;

  const MainPageButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = AppConfig.color2,
    this.margin = const EdgeInsets.symmetric(horizontal: 8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ElevatedButton(
        onPressed: onPressed,
        style: mainPageButtonStyle.copyWith(
          backgroundColor: MaterialStateProperty.all(backgroundColor),
        ),
        child: child,
      ),
    );
  }
}

class CircularButton extends MainPageButton {
  final Size size;

  const CircularButton({
    Key? key,
    required VoidCallback onPressed,
    required Widget child,
    backgroundColor = AppConfig.color2,
    this.size = const Size(50, 50),
  }) : super(
          key: key,
          onPressed: onPressed,
          child: child,
          backgroundColor: backgroundColor,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ElevatedButton(
        onPressed: onPressed,
        style: mainPageButtonStyle.copyWith(
          backgroundColor: MaterialStateProperty.all(backgroundColor),
          shape: MaterialStateProperty.all(const CircleBorder()),
          minimumSize: MaterialStateProperty.all(size),
        ),
        child: child,
      ),
    );
  }
}

class SvgIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String iconPath;
  final double splashRadius;
  final double iconSize;


  const SvgIconButton({
    required this.onPressed,
    required this.iconPath,
    this.splashRadius = 32,
    this.iconSize = 58,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        padding: const EdgeInsets.all(0),
        splashRadius: splashRadius,
        iconSize: iconSize,
        icon: SimpleShadow(
          opacity: 0.2,
          offset: const Offset(0,2),
          //sigma: 10,
          child: SvgPicture.asset(
            iconPath,
          ),
        ),
        onPressed: onPressed,
    );
  }
}


//coffee
// static const primaryColor = 0xFF122640;
// static const backgroundColor = Color(0xFFFFFFFF);
// static const color1 = Color(primaryColor);
// static const color2 = Color(0xFFBF8641);
// static const color3 = Color(0xFF593E25);
// static const color4 = Color(0xFF1B3659);
// static const attentionColor = Color(0xFF8B0000);

//raven theme
// static const primaryColor = 0xFF1D2026;
// static const backgroundColor = Color(0xFFFFFFFF);
// static const color1 = Color(primaryColor);
// static const color2 = Color(0xFF5E6D8C);
// static const color3 = Color(0xFFBFBFBF);
// static const color4 = Color(0xFF2C3540);
// static const attentionColor = Color(0xFF8B0000);

//rock style
// static const primaryColor = 0xFF260101;
// static const backgroundColor = Color(0xFFFFFFFF);
// static const color1 = Color(primaryColor);
// static const color2 = Color(0xFFBF4904);
// static const color3 = Color(0xFFF29D52);
// static const color4 = Color(0xFF731702);
// static const attentionColor = Color(0xFF8B0000);


//galaxy
// static const primaryColor = 0xFF023059;
// static const backgroundColor = Color(0xFFFFFFFF);
// static const color1 = Color(primaryColor);
// static const color2 = Color(0xFF8C331F);
// static const color3 = Color(0xFFA65424);
// static const color4 = Color(0xFF26080D);
// static const attentionColor = Color(0xFF8B0000);

//coffee
// static const primaryColor = 0xFF261914;
// static const backgroundColor = Color(0xFFFFFFFF);
// static const color1 = Color(primaryColor);
// static const color2 = Color(0xFF735A4C);
// static const color3 = Color(0xFFA69485);
// static const color4 = Color(0xFF592C22);
// static const attentionColor = Color(0xFF8B0000);

// static const primaryColor = 0xFF261914;
// static const backgroundColor = Color(0xFFFFFFFF);
// static const color1 = Color(primaryColor);
// static const color2 = Color(0xFF692F00);
// static const color3 = Color(0xFF472705);
// static const color4 = Color(0xFF2B1000);
// static const attentionColor = Color(0xFF8B0000);

// static const primaryColor = 0xFF072026;
// static const backgroundColor = Color(0xFFFFFFFF);
// static const color1 = Color(primaryColor);
// static const color2 = Color(0xFF8C7E6C);
// static const color3 = Color(0xFFD9B79A);
// static const color4 = Color(0xFF2D3E40);
// static const attentionColor = Color(0xFF8B0000);