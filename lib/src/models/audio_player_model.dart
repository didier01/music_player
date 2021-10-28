import 'package:flutter/material.dart';

class AudioPlayerModel with ChangeNotifier {
  bool _playing = false;
  Duration _songDuration = new Duration(milliseconds: 0);
  Duration _current = new Duration(milliseconds: 0);

  String get songTotalDuration => this.printDuration(this._songDuration);
  String get currentSecond => this.printDuration(this._current);

  double get percent => (this._songDuration.inSeconds > 0)
      ? this._current.inSeconds / this._songDuration.inSeconds
      : 0;

  late AnimationController _controller;

  set controller(AnimationController value) {
    this._controller = value;
  }

  AnimationController get controller => this._controller;

  bool get playind => this._playing;
  set playing(bool value) {
    this._playing = value;
    notifyListeners();
  }

  Duration get songDuration => this._songDuration;
  set songDuration(Duration value) {
    this._songDuration = value;
    notifyListeners();
  }

  Duration get current => this._current;
  set current(Duration value) {
    this._current = value;
    notifyListeners();
  }

  String printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitsMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitsSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "$twoDigitsMinutes:$twoDigitsSeconds";
  }
}
