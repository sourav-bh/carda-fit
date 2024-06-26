import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../app.dart';

//Passwort vergessen bei lokaler Authentifizierung Bildschirm


class LocalAuth{
  static Future<void> handleForgotPassword(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Bitte authentifizieren Sie sich, um Ihr Passwort zurückzusetzen',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (!context.mounted) return;

    if (authenticated) {
      Navigator.pushNamedAndRemoveUntil(context, landingRoute, (r) => false);
    } else {
      const snackBar = SnackBar(content: Text('Lokale Authentifizierung fehlgeschlagen'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

