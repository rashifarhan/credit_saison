import 'package:logger/logger.dart';

class LoggerHelper {
  Logger logger;
  LoggerHelper({required this.logger});

  void logInfo(String message) {
    logger.i(message);
  }

  void logError(String message) {
    logger.e(message);
  }

  void logDev(String message) {
    logger.d(message);
  }
}
