import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuth{
  static final _auth = LocalAuthentication();

  static Future<bool> _canAuthenticate() async {
    final canCheckBiometrics = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    return canCheckBiometrics || isDeviceSupported;
  }

  static Future<bool> authenticate() async{
  try{
    if(!await _canAuthenticate()) return false;
    
    return await _auth.authenticate(localizedReason: "Please authenticate to login again",
       );
    } catch(e){
    debugPrint('error $e');
    return false;
  }
  }
}

