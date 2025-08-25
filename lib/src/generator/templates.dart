import 'dart:io';

import '../utils/logger.dart';

class AppThemeTemplate {
  static String light() => '''
import 'package:flutter/material.dart';

class AppTheme {
	static final ThemeData light = ThemeData.light(useMaterial3: true);
	static final ThemeData dark = ThemeData.dark(useMaterial3: true);
}
''';
}

Future<void> generateAppFile(
    {required Logger logger, required String directoryPath}) async {
  final file = File(_pathJoin(directoryPath, 'lib/app/app.dart'));
  await file.parent.create(recursive: true);
  await file.writeAsString('''
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'your proj',
      home: const Scaffold(body: Center(child: Text('Hello'))),
    );
  }
}
''');
  logger.info('Wrote ' + file.path);
}

Future<void> generateMainFile(
    {required Logger logger, required String directoryPath}) async {
  final file = File(_pathJoin(directoryPath, 'lib/main.dart'));
  await file.parent.create(recursive: true);
  await file.writeAsString('''
import 'package:flutter/material.dart';
import 'app/app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
''');
  logger.info('Wrote ' + file.path);
}

Future<void> generateConstantsFiles(
    {required Logger logger, required String directoryPath}) async {
  await Directory(_pathJoin(directoryPath, 'lib/constants/failure'))
      .create(recursive: true);
  await File(_pathJoin(directoryPath, 'lib/constants/failure/exceptions.dart'))
      .writeAsString('''
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'No internet connection']);
}

class NotFoundException implements Exception {
  final String message;

  const NotFoundException([this.message = 'Resource not found']);
}

class AuthorizationException implements Exception {
  final String message;

  const AuthorizationException([this.message = 'Unauthorized access']);
}
''');
  await File(_pathJoin(directoryPath, 'lib/constants/failure/failure.dart'))
      .writeAsString('''
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);
}

class ServerFailure extends Failure {
  const ServerFailure(String message, [int? statusCode]) : super(message, statusCode);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure() : super('Requested resource not found', 404);
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure(String message) : super(message, 401);
}
''');

  await Directory(_pathJoin(directoryPath, 'lib/constants/navigator_key'))
      .create(recursive: true);
  await File(_pathJoin(
          directoryPath, 'lib/constants/navigator_key/navigator_key.dart'))
      .writeAsString('''
import 'package:flutter/material.dart';

class AppNavigator {
  AppNavigator._();

  static final navigatorKey = GlobalKey<NavigatorState>();
}
''');

  await Directory(_pathJoin(directoryPath, 'lib/constants/navigator'))
      .create(recursive: true);
  await File(_pathJoin(directoryPath, 'lib/constants/navigator/navigator.dart'))
      .writeAsString('''
import 'package:flutter/material.dart';

import '../navigator_key/navigator_key.dart';

class NavigateRoute {
  NavigateRoute._();

  static void pushRoute(Widget view) {
    Navigator.push(
      AppNavigator.navigatorKey.currentState!.context,
      MaterialPageRoute(builder: (context) => view),
    );
  }

  static void popAndPushRoute(Widget view) {
    Navigator.pushReplacement(
      AppNavigator.navigatorKey.currentState!.context,
      MaterialPageRoute(builder: (context) => view),
    );
  }

  static void pop() {
    Navigator.pop(AppNavigator.navigatorKey.currentState!.context);
  }
}
''');
}

Future<void> generateNetworkingFiles(
    {required Logger logger, required String directoryPath}) async {
  await Directory(_pathJoin(directoryPath, 'lib/constants/networking'))
      .create(recursive: true);
  await File(_pathJoin(
          directoryPath, 'lib/constants/networking/dio_error_interceptor.dart'))
      .writeAsString('''
import 'package:dio/dio.dart';

class DioErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      if (err.response!.statusCode! >= 300) {
        err = DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: err.response!.data is Map && err.response!.data['message'] != null
              ? err.response!.data['message']
              : (err.response!.statusMessage ?? 'Server error'),
          type: err.type,
        );
      } else {
        err = DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: 'Something went wrong',
          type: err.type,
        );
      }
    } else {
      err = DioException(
        requestOptions: err.requestOptions,
        error: 'Connection error',
        type: err.type,
      );
    }
    super.onError(err, handler);
  }
}
''');

  await File(_pathJoin(
          directoryPath, 'lib/constants/networking/http_service.dart'))
      .writeAsString('''
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../api_endpoints.dart';
import 'dio_error_interceptor.dart';

class HttpService {
  final Dio _dio;

  HttpService(this._dio) {
    _setupDio();
  }

  void _setupDio() {
    _dio
      ..options.baseUrl = ApiEndpoints.baseUrl
      ..options.connectTimeout = ApiEndpoints.connectionTimeout
      ..options.receiveTimeout = ApiEndpoints.receiveTimeout
      ..interceptors.add(DioErrorInterceptor())
      ..interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
      )
      ..options.headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.get(path,
        queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    return await _dio.post(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    return await _dio.put(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> patch(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    return await _dio.patch(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    return await _dio.delete(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Dio get dio => _dio;
}
''');
}

Future<void> generateApiEndpoints(
    {required Logger logger, required String directoryPath}) async {
  await File(_pathJoin(directoryPath, 'lib/constants/api_endpoints.dart'))
      .writeAsString('''
class ApiEndpoints {
  ApiEndpoints._();

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  static const String baseUrl = "https://yoururl/";

  static const String imageBaseUrl = "https://yoururll/";
}
''');
}

Future<void> generateConstantsThemeFiles(
    {required Logger logger, required String directoryPath}) async {
  final themeDir = Directory(_pathJoin(directoryPath, 'lib/constants/theme'));
  await themeDir.create(recursive: true);

  await File(_pathJoin(directoryPath, 'lib/constants/theme/colors.dart'))
      .writeAsString('''
import 'package:flutter/material.dart';

class AppColor {
  static const Color primary = Color(0xFF3799FF);
  static Color lightPrimary = Color(0xFF3799FF).withValues(alpha: 0.25);

  static const Color secondary = Color(0xffe0e0e0);

  static const Color errorColor = Color(0xFFFF4A4A);

  static const Color yellowColor = Color(0xFFFFCC00);

  static const surfaceColor = {
    Brightness.light: lightWhite,
    Brightness.dark: lightDark,
  };

  static const backgroundColor = {
    Brightness.light: white,
    Brightness.dark: dark,
  };

  static const textColor = {
    Brightness.light: textColorForLight,
    Brightness.dark: textColorForDark,
  };

  static const secondaryTextColor = {
    Brightness.light: secondaryTextColorForLight,
    Brightness.dark: secondaryTextColorForDark,
  };

  static const secondaryButtonColor = {
    Brightness.light: secondaryButtonColorForLight,
    Brightness.dark: secondaryButtonColorForDark,
  };

  static const borderColor = {
    Brightness.light: borderColorForLight,
    Brightness.dark: borderColorForDark,
  };

  static const dividerColor = {
    Brightness.light: dividerColorForLight,
    Brightness.dark: dividerColorForDark,
  };

  static const onPrimary = {
    Brightness.light: lightWhite,
    Brightness.dark: lightDark,
  };

  static const textColorSecondary = {
    Brightness.light: textColorSecondaryLight,
    Brightness.dark: textColorSecondaryDark,
  };

  static const Color white = Color(0xffe0e0e0);
  static const Color lightWhite = Color(0xFFFFFFFF);
  static const Color borderColorForLight = Color(0xffe0e0e0);
  static const Color textColorForLight = white;
  static const Color textColorSecondaryLight = Colors.black;
  static const Color dividerColorForLight = Color(0xFF000000);
  static const Color secondaryButtonColorForLight = Color(0xFF6EC1E4);
  static const Color secondaryTextColorForLight = Color(0xFF000000);

  static const Color dark = Color(0xff0f0d13);
  static const Color lightDark = Color(0xff211f26);
  static const Color borderColorForDark = Color(0xff0f0d13);
  static const Color textColorForDark = Colors.black;
  static const Color textColorSecondaryDark = Colors.white;
  static const Color dividerColorForDark = Color(0xff0f0d13);
  static const Color secondaryButtonColorForDark = Color(0xFF3799FF);
  static const Color secondaryTextColorForDark = Color(0xFF3D3D3D);
}
''');

  await File(_pathJoin(directoryPath, 'lib/constants/theme/font_theme.dart'))
      .writeAsString('''
import 'package:flutter/material.dart';

TextTheme lightTextTheme = TextTheme(
  displayLarge: TextStyle().copyWith(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25, color: Colors.black87),
  displayMedium: TextStyle().copyWith(fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.black87),
  displaySmall: TextStyle().copyWith(fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.black87),
  headlineLarge: TextStyle().copyWith(fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.black87),
  headlineMedium: TextStyle().copyWith(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.black87),
  headlineSmall: TextStyle().copyWith(fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.black87),
  titleLarge: TextStyle().copyWith(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0, color: Colors.black87),
  titleMedium: TextStyle().copyWith(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: Colors.black87),
  titleSmall: TextStyle().copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Colors.black87),
  bodyLarge: TextStyle().copyWith(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: Colors.black54),
  bodyMedium: TextStyle().copyWith(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: Colors.black54),
  bodySmall: TextStyle().copyWith(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: Colors.black54),
  labelLarge: TextStyle().copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Colors.black87),
  labelMedium: TextStyle().copyWith(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: Colors.black87),
  labelSmall: TextStyle().copyWith(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: Colors.black87),
);

TextTheme darkTextTheme = TextTheme(
  displayLarge: TextStyle().copyWith(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25, color: Colors.white),
  displayMedium: TextStyle().copyWith(fontSize: 45, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.white),
  displaySmall: TextStyle().copyWith(fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.white),
  headlineLarge: TextStyle().copyWith(fontSize: 32, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.white),
  headlineMedium: TextStyle().copyWith(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.white),
  headlineSmall: TextStyle().copyWith(fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 0, color: Colors.white),
  titleLarge: TextStyle().copyWith(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 0, color: Colors.white),
  titleMedium: TextStyle().copyWith(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: Colors.white),
  titleSmall: TextStyle().copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Colors.white),
  bodyLarge: TextStyle().copyWith(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: Colors.white70),
  bodyMedium: TextStyle().copyWith(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: Colors.white70),
  bodySmall: TextStyle().copyWith(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: Colors.white70),
  labelLarge: TextStyle().copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Colors.white),
  labelMedium: TextStyle().copyWith(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: Colors.white),
  labelSmall: TextStyle().copyWith(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: Colors.white),
);
''');

  await File(_pathJoin(directoryPath, 'lib/constants/theme/theme.dart'))
      .writeAsString('''
import 'package:flutter/material.dart';

import 'colors.dart';
import 'font_theme.dart';

ThemeData lightModeTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'PlusJakarta-Regular',
  primaryColor: AppColor.primary,
  scaffoldBackgroundColor: AppColor.white,
  textTheme: lightTextTheme,
  colorScheme: ColorScheme.light(
    brightness: Brightness.light,
    primary: AppColor.primary,
    secondary: AppColor.secondary,
    surface: AppColor.lightWhite,
    tertiary: AppColor.white,
    onPrimary: AppColor.white,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColor.lightWhite,
    selectedItemColor: AppColor.secondary,
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: AppColor.primary,
    linearTrackColor: AppColor.primary.withValues(alpha: 0.12),
    circularTrackColor: AppColor.primary.withValues(alpha: 0.12),
    trackGap: 8,
  ),
);

ThemeData darkModeTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'PlusJakarta-Regular',
  primaryColor: AppColor.primary,
  scaffoldBackgroundColor: AppColor.dark,
  textTheme: darkTextTheme,
  colorScheme: ColorScheme.light(
    brightness: Brightness.dark,
    primary: AppColor.primary,
    secondary: AppColor.secondary,
    surface: AppColor.lightDark,
    onSurface: AppColor.white,
    tertiary: AppColor.dark,
    onPrimary: AppColor.white,
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: AppColor.primary,
    linearTrackColor: AppColor.primary.withValues(alpha: 0.12),
    circularTrackColor: AppColor.primary.withValues(alpha: 0.12),
    trackGap: 8,
  ),
);
''');

  logger.info('Wrote constants theme files');
}

Future<void> generateThemeFiles(String choice,
    {required Logger logger, required String directoryPath}) async {
  final file = File(_pathJoin(directoryPath, 'lib/src/theme/app_theme.dart'));
  if (!await file.parent.exists()) {
    await file.parent.create(recursive: true);
  }

  final content = switch (choice) {
    'light' => AppThemeTemplate.light(),
    'dark' => AppThemeTemplate.light(),
    _ => AppThemeTemplate.light(),
  };
  await file.writeAsString(content);
  logger.info(
      'Wrote ' + _pathJoin(directoryPath, 'lib/src/theme/app_theme.dart'));
}

String _pathJoin(String a, String b) {
  if (a == '.' || a.isEmpty) return b;
  final sep = Platform.pathSeparator;
  final left = a.endsWith(sep) ? a.substring(0, a.length - 1) : a;
  final right = b.startsWith(sep) ? b.substring(1) : b;
  return left + sep + right;
}
