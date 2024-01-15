import 'dart:async';

import 'package:flutter/material.dart';

class CountdownProvider with ChangeNotifier {
  int _seconds = 900; // Initial value, representing 15 minutes
  Timer? _timer;

  int get seconds => _seconds;

  CountdownProvider() {
    // Start the countdown timer when the provider is created
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        _seconds--;
        notifyListeners();
      } else {
        // Countdown finished
        _timer?.cancel();
        _timer = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the provider is disposed
    _timer?.cancel();
    super.dispose();
  }
}
