import 'package:base_framework/common/local/preference_manager.dart';
import 'package:base_framework/common/utlis/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;
Future<void> init() async {
  getIt.registerLazySingleton<Logger>(() => Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          printTime: false,
        ),
      ));

  getIt.registerLazySingleton<LoggerHelper>(
      () => LoggerHelper(logger: getIt<Logger>()));

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  getIt.registerLazySingleton<PreferenceManager>(
      () => PreferenceManager(sharedPreference: getIt<SharedPreferences>()));
}
