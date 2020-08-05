import 'package:flutter/material.dart';

class LoginCard extends StatelessWidget {
  final String text;
  final Widget leading;
  final Function onTap;

  LoginCard(
      {@required this.text, @required this.leading, @required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 70,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
              color: Colors.black45,
              offset: Offset(0, 5),
              spreadRadius: -3,
              blurRadius: 5)
        ],
      ),
      child: ListTile(
        leading: leading,
        title: Text(
          text,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
