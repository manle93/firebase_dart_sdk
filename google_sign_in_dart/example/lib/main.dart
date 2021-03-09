// // Copyright 2019 The Flutter Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_dartio/google_sign_in_dartio.dart';

import 'platform_js.dart' if (dart.library.io) 'platform_io.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
  'email',
  'profile',
]);

Future<void> main() async {
  if (isDesktop) {
    await GoogleSignInDart.register(
      exchangeEndpoint:
          'https://us-central1-flutter-sdk.cloudfunctions.net/authHandler',
      clientId:
          '233259864964-go57eg1ones74e03adlqvbtg2av6tivb.apps.googleusercontent.com',
    );
  }

  runApp(
    MaterialApp(
      title: 'Google Sign In',
      home: SignInDemo(),
    ),
  );
}

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  late StreamSubscription<GoogleSignInAccount> sub;
  late GoogleSignInAccount _currentUser;
  late String _contactText;
  late String _emailText;

  @override
  void initState() {
    super.initState();
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  void _handleSignOut() {
    _googleSignIn.disconnect();
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign In'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (_currentUser == null) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('You are not currently signed in.'),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _handleSignIn,
                    child: const Text('SIGN IN'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: <Widget>[
              ListTile(
                leading: kIsWeb
                    ? GoogleUserCircleAvatar(
                        identity: _currentUser,
                      )
                    : ClipOval(
                        child: Image.network(
                          _currentUser.photoUrl ??
                              'https://lh3.googleusercontent.com/a/default-user=s160-c',
                        ),
                      ),
                title: Text(_currentUser.displayName ?? ''),
                subtitle: Text(_currentUser.email),
              ),
              if (_contactText != null)
                ListTile(
                  title: Text(
                    _contactText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text('People Api'),
                ),
              if (_emailText != null)
                ListTile(
                  title: Text(
                    _emailText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: const Text('Gmail Api'),
                ),
              ButtonBar(
                children: <Widget>[
                  TextButton(
                    onPressed: _handleSignOut,
                    child: const Text('SIGN OUT'),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
