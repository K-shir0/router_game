import 'dart:io';

import 'package:logger/logger.dart' as logger;

class Logger {
  Logger._();

  static final _logger = logger.Logger(
    // iOS だとコンソールの色がうまく反映されない。
    printer: logger.PrettyPrinter(colors: !Platform.isIOS),
  );

  static void info(dynamic message) {
    _logger.i(message);
  }

  static void warning(dynamic message) {
    _logger.w(message);
  }

  static void error(dynamic error, [StackTrace? stack]) {
    _logger.e('Error!', error, stack);
  }
}
