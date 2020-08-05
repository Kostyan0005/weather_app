import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../widgets/tile_text.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WeatherDisplay extends StatelessWidget {
  final Weather weather;
  WeatherDisplay({@required this.weather});

  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: weather.getIconPath(),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Padding(
                padding: EdgeInsets.only(right: 15, top: 27, bottom: 27),
                child: Icon(
                  Icons.error,
                  size: 45,
                ),
              ),
            ),
            Text(
              weather.getGroup(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              weather.getTemperature(),
              style: TextStyle(
                fontSize: 150,
                fontWeight: FontWeight.w200,
              ),
            ),
            Text(
              '°',
              style: TextStyle(
                fontSize: 90,
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Learn more',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 7),
                width: 200,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          trailing: SizedBox(),
          children: <Widget>[
            Container(
              width: 200,
              margin: EdgeInsets.only(top: 5, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TileText('Feels like:  ${weather.getFeelsLike()}°'),
                  TileText('Precipitation:  ${weather.getPrecipitation()}%'),
                  TileText('Wind:  ${weather.getWind()}m/s'),
                  TileText('Cloudiness:  ${weather.getCloudiness()}%'),
                  TileText('Humidity:  ${weather.getHumidity()}%'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
