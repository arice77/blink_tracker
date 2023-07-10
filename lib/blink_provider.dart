import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlinkProvider extends ChangeNotifier {
  int _blinkThreshold = 8;
  int get blinkThreshold => _blinkThreshold;
  String _text = 'OFF';
  String get text => _text;

  getText() async {
    FlutterBackgroundService bg = FlutterBackgroundService();
    _text = await bg.isRunning() ? 'OFF' : 'ON';
    notifyListeners();
  }

  Future<int> getBlinkThrehold() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _blinkThreshold = pref.getInt('threshold') ?? 8;

    notifyListeners();
    return _blinkThreshold;
  }

  setBlinkThreshold(int blinkT) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt('threshold', blinkT);
    _blinkThreshold = blinkT;
    notifyListeners();
  }
}
