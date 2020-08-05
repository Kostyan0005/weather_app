import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../screens/weather_screen.dart';
import '../models/auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Weather weather = Weather();
  Auth auth = Auth();

  Future<void> getWeatherScreen() async {
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();

    await auth.init();
    auth.printUser();

    String uid = auth.getUid();
    if (uid != null) {
      await weather.updateUid(uid);
    }
    stopwatch.stop();

    Future.delayed(
      Duration(milliseconds: 2000 - stopwatch.elapsedMilliseconds),
      () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/weather',
            arguments: WeatherScreenArgs(weather, auth));
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getWeatherScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/logo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
