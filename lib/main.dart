import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/login_screen.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  runApp(
    OverlaySupport(
      child: MaterialApp(
        title: 'Weather App',
        theme: ThemeData.dark(),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => SplashScreen(),
          '/weather': (context) => WeatherScreen(context),
          '/login': (context) => LoginScreen(),
        },
      ),
    ),
  );
}
