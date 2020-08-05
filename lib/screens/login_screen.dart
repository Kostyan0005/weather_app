import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/login_card.dart';
import '../models/auth.dart';

class LoginScreenArgs {
  final bool isInternetConnected;
  final Auth auth;
  LoginScreenArgs(this.isInternetConnected, this.auth);
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LoginScreenArgs args = ModalRoute.of(context).settings.arguments;
    final Auth auth = args.auth;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: kBackgroundGradient,
        ),
        child: SafeArea(
          child: Stack(children: [
            Positioned(
              top: 10,
              right: 15,
              child: FloatingActionButton(
                backgroundColor: Colors.lightBlue,
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            args.isInternetConnected
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        LoginCard(
                          text: 'Sing in with Google',
                          leading: Image.asset(
                            'images/google.png',
                            width: 30,
                            height: 30,
                          ),
                          onTap: () async {
                            await auth.signInWithGoogle();
                            Navigator.pop(context);
                          },
                        ),
                        LoginCard(
                          text: 'Sing in with Facebook',
                          leading: Image.asset(
                            'images/facebook.png',
                            width: 30,
                            height: 30,
                          ),
                          onTap: () async {
                            await auth.signInWithFacebook();
                            Navigator.pop(context);
                          },
                        ),
                        !auth.isAnonymous()
                            ? LoginCard(
                                text: 'Sing out',
                                leading: Icon(
                                  Icons.exit_to_app,
                                  size: 35,
                                  color: Colors.black.withOpacity(0.75),
                                ),
                                onTap: () async {
                                  await auth.signOut();
                                  Navigator.pop(context);
                                },
                              )
                            : SizedBox(),
                      ],
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Enable internet connection to sign in or sign out',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
          ]),
        ),
      ),
    );
  }
}
