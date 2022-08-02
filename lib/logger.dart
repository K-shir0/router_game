import 'dart:developer' as developer;

class Logger {
  Logger._();

  static void debug(String message) {
    developer.log(message, name: 'debug');
  }
}
