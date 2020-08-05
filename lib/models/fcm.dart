import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'dart:convert';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/material.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

void configure() {
  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      showSimpleNotification(
        Column(
          children: <Widget>[
            SizedBox(height: 10),
            Text(
              message['notification']['title'],
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 7),
            Text(
              message['notification']['body'],
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 7),
          ],
        ),
        background: Colors.white,
        duration: Duration(seconds: 5),
      );
    },
  );
}

void sendSuccessfulLoginMessage(String userName, String userEmail) {
  Future.delayed(Duration(seconds: 3), () async {
    http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$kServerToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': 'Successful login',
            'body': 'You successfully signed in as $userName ($userEmail).'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'to': await _firebaseMessaging.getToken(),
        },
      ),
    );
  });
}
