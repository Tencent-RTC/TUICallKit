import 'dart:async';

class Debounce {
  static final Map<String, Timer> _timers = {};

  static void run(String key, Duration duration, Function callback) {
    if (_timers.containsKey(key)) {
      return;
    }

    callback();

    _timers[key] = Timer(duration, () {
      _timers.remove(key);
    });
  }

  static void cancel(String key) {
    if (_timers.containsKey(key)) {
      _timers[key]!.cancel();
      _timers.remove(key);
    }
  }

  static void cancelAll() {
    _timers.forEach((key, timer) {
      timer.cancel();
    });
    _timers.clear();
  }

  static bool isPending(String key) {
    return _timers.containsKey(key);
  }
}

class DebounceKeys {
  static const String switchMic = 'switch_mic';
  static const String switchAudioDevice = 'switch_audio_device';
  static const String openCloseCamera = 'open_close_camera';
  static const String hangUp = 'hang_up';
  static const String reject = 'reject';
  static const String accept = 'accept';
  static const String switchCamera = 'switch_camera';
  static const String openBlurBackground = 'open_blur_background';
  static const String virtualBackground = 'virtual_background';
}