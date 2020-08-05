import 'package:flutter/material.dart';
import 'package:weather_app/utils.dart';
import '../models/weather.dart';
import '../widgets/weather_display.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../models/auth.dart';
import '../constants.dart';
import 'login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/fcm.dart' as fcm;
import 'dart:io' show Platform;

class WeatherScreenArgs {
  final Weather weather;
  final Auth auth;
  WeatherScreenArgs(this.weather, this.auth);
}

class WeatherScreen extends StatefulWidget {
  final BuildContext context;
  WeatherScreen(this.context);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Weather weather;
  Auth auth;
  String selectedDate;
  String selectedTime;
  String errorMessage;
  bool showSpinner = false;
  final TextEditingController controller = TextEditingController();

  List<DropdownMenuItem> getDropdownItems(List<String> itemList) {
    List<DropdownMenuItem> items = [];
    for (String item in itemList) {
      items.add(DropdownMenuItem(
        value: item,
        child: Text(item),
      ));
    }
    return items;
  }

  @override
  void initState() {
    final WeatherScreenArgs args =
        ModalRoute.of(widget.context).settings.arguments;
    weather = args.weather;
    auth = args.auth;
    fcm.configure();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Container(
          decoration: BoxDecoration(
            gradient: kBackgroundGradient,
          ),
          child: SafeArea(
            child: !weather.isEmpty()
                ? Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Container(),
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                weather.getCity(),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                weather.getDisplayDateTime(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                GestureDetector(
                                  child: CachedNetworkImage(
                                    imageUrl: auth.getAvatarUrl(),
                                    imageBuilder: (context, imageProvider) =>
                                        CircleAvatar(
                                      backgroundImage: imageProvider,
                                    ),
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                  ),
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      '/login',
                                      arguments: LoginScreenArgs(
                                        await isInternetConnected(),
                                        auth,
                                      ),
                                    );

                                    await auth.init();
                                    auth.printUser();

                                    if (auth.getUid() != weather.getUid()) {
                                      if (!auth.isAnonymous() &&
                                          Platform.isAndroid) {
                                        fcm.sendSuccessfulLoginMessage(
                                          auth.getDisplayName(),
                                          auth.getEmail(),
                                        );
                                      }

                                      setState(() {
                                        showSpinner = true;
                                      });
                                      await weather.updateUid(auth.getUid());
                                      setState(() {
                                        showSpinner = false;
                                      });
                                    }
                                  },
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: controller,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Change city',
                                  labelStyle: TextStyle(fontSize: 16),
                                  hintText: 'Enter city',
                                  helperText: errorMessage,
                                  helperStyle: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                  ),
                                ),
                                onSubmitted: (typedCity) async {
                                  if (typedCity == '') return;

                                  setState(() {
                                    showSpinner = true;
                                  });

                                  String error = await weather
                                      .getWeatherApiData(typedCity);

                                  setState(() {
                                    if (error != null) {
                                      errorMessage = error;
                                    } else {
                                      selectedDate = null;
                                      selectedTime = null;
                                      controller.text = '';
                                    }
                                    showSpinner = false;
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    errorMessage = null;
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  value: selectedDate,
                                  hint: Text('Select date'),
                                  items:
                                      getDropdownItems(weather.getDatesList()),
                                  onChanged: (date) {
                                    setState(() {
                                      weather.setSelectedDate(date);
                                      selectedDate = date;
                                      selectedTime = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                  value: selectedTime,
                                  hint: Text('Select time'),
                                  items:
                                      getDropdownItems(weather.getTimesList()),
                                  onChanged: (time) {
                                    setState(() {
                                      weather.setSelectedTime(time);
                                      selectedTime = time;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: WeatherDisplay(weather: weather),
                      ),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Enable internet connection and restart the app',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
