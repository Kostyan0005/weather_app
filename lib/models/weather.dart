import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/constants.dart';
import '../utils.dart';

class Weather {
  String _uid;
  String _city;
  Map _map;
  Map _selectedDay;
  Map _selectedHour;
  Map _current;
  String _mode;
  final Geolocator _geolocator = Geolocator();
  final Firestore _db = Firestore.instance;

  Future<void> updateUid(String newUid) async {
    _uid = newUid;
    if (await isInternetConnected()) {
      _city = await _getCachedFirestoreCity();
      String error = await getWeatherApiData(_city ?? kDefaultCity);
      if (error == null) {
        return;
      }
    }
    await _getCachedFirestoreData();
  }

  Future<String> getWeatherApiData(String city) async {
    if (!await isInternetConnected()) {
      return 'No internet';
    }

    List<Placemark> placemark;
    try {
      placemark = await _geolocator.placemarkFromAddress(city);
    } catch (e) {
      print(e);
      return 'No such city';
    }

    var response = await http.get(
        '$kWeatherApiString&lat=${placemark[0].position.latitude}&lon=${placemark[0].position.longitude}');

    Map data;
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
    } else {
      print(response.statusCode);
      return 'Network error';
    }

    _city = city;
    _constructMapFromData(data);
    _updateFirestoreData();

    _current = _map['current'];
    _mode = 'current';
    return null;
  }

  Future<void> _getCachedFirestoreData() async {
    DocumentSnapshot doc;
    try {
      doc = await _db.collection('weather_maps').document(_uid).get();
    } catch (e) {
      print(e);
      return;
    }

    _city = doc.data['city'];
    _map = jsonDecode(doc.data['weather_map']);

    _current = _map['current'];
    _mode = 'current';
  }

  Future<String> _getCachedFirestoreCity() async {
    DocumentSnapshot doc;
    try {
      doc = await _db.collection('weather_maps').document(_uid).get();
      return doc.data['city'];
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _updateFirestoreData() async {
    _db.collection('weather_maps').document(_uid).setData({
      'city': _city,
      'weather_map': jsonEncode(_map),
    });
  }

  void _constructMapFromData(data) {
    _map = {};
    DateTime now = DateTime.now();
    _map['current'] = {
      'display':
          DateFormat('MMMd').format(now) + ',  ' + DateFormat('Hm').format(now),
      'forecast': data['current'],
    };

    _map['days'] = [];
    for (Map day in data['daily']) {
      _map['days'].add({
        'display': getDisplayDate(day['dt']),
        'forecast': day,
        'hours': [],
      });
    }

    for (Map hour in data['hourly']) {
      String dayDisplay = getDisplayDate(hour['dt']);
      _findDay(dayDisplay)['hours'].add({
        'display': getDisplayTime(hour['dt']),
        'forecast': hour,
      });
    }
  }

  Map _findDay(String dateDisplay) {
    for (Map day in _map['days']) {
      if (day['display'] == dateDisplay) {
        return day;
      }
    }
    return null;
  }

  Map _findHour(String timeDisplay) {
    for (Map hour in _selectedDay['hours']) {
      if (hour['display'] == timeDisplay) {
        return hour;
      }
    }
    return null;
  }

  List<String> getDatesList() {
    List<String> dates = [];
    for (Map day in _map['days']) {
      dates.add(day['display']);
    }
    return dates;
  }

  List<String> getTimesList() {
    List<String> times = [];
    if (_selectedDay != null) {
      for (Map hour in _selectedDay['hours']) {
        times.add(hour['display']);
      }
    }
    return times;
  }

  void setSelectedDate(String dateDisplay) {
    _selectedDay = _findDay(dateDisplay);
    _current = _selectedDay;
    _mode = 'daily';
  }

  void setSelectedTime(String timeDisplay) {
    _selectedHour = _findHour(timeDisplay);
    _current = _selectedHour;
    _mode = 'hourly';
  }

  static String getDisplayDate(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('MMMd').format(date);
  }

  static String getDisplayTime(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('Hm').format(date);
  }

  String getDisplayDateTime() {
    if (_mode == 'hourly') {
      return _selectedDay['display'] + ',  ' + _current['display'];
    }
    return _current['display'];
  }

  String getTemperature() {
    if (_mode == 'daily') {
      return _current['forecast']['temp']['day'].round().toString();
    }
    return _current['forecast']['temp'].round().toString();
  }

  int getFeelsLike() {
    if (_mode == 'daily') {
      return _selectedDay['forecast']['feels_like']['day'].round();
    }
    return _current['forecast']['feels_like'].round();
  }

  int getPrecipitation() {
    if (_mode == 'current') {
      return (_map['days'][0]['hours'][0]['forecast']['pop'] * 100).round();
    }
    return (_current['forecast']['pop'] * 100).round();
  }

  String getIconPath() =>
      'http://openweathermap.org/img/wn/${_current['forecast']['weather'][0]['icon']}@2x.png';
  String getGroup() => _current['forecast']['weather'][0]['main'];
  int getWind() => _current['forecast']['wind_speed'].round();
  int getCloudiness() => _current['forecast']['clouds'];
  int getHumidity() => _current['forecast']['humidity'];
  String getCity() => _city;
  String getUid() => _uid;
  bool isEmpty() => _map == null;
}
