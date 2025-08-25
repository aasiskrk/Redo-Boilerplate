import 'dart:io';

import '../utils/logger.dart';

Future<void> createBaseStructure(
    {required Logger logger, required String targetDir}) async {
  final directories = <String>[
    'lib',
    'lib/app',
    'lib/constants',
    'lib/constants/failure',
    'lib/constants/navigator',
    'lib/constants/navigator_key',
    'lib/constants/networking',
    'lib/constants/theme',
    'lib/src',
    'test',
  ].map((p) => _pathJoin(targetDir, p)).toList();

  for (final dir in directories) {
    final directory = Directory(dir);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      logger.info('Created $dir');
    }
  }

  // Seed files for quicker start
  final mainFile = File(_pathJoin(targetDir, 'lib/main.dart'));
  if (!await mainFile.exists()) {
    await mainFile.writeAsString('''
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
    logger.info('Created ' + _pathJoin(targetDir, 'lib/main.dart'));
  }
}

Future<void> createArchitectureStructure(
    {required String architecture,
    required Logger logger,
    required String targetDir}) async {
  final dirs = <String>[
    if (architecture == 'clean') ...[
      'lib/src/core',
      'lib/src/features',
      'lib/src/routes',
      'lib/src/core/usecases',
      'lib/src/core/utils',
      'lib/src/core/errors',
      'lib/src/core/network',
      'lib/src/core/widgets',
    ],
    if (architecture == 'mvvm') ...[
      'lib/src/core',
      'lib/src/routes',
      'lib/src/features',
      'lib/src/shared',
      'lib/src/shared/widgets',
      'lib/src/shared/services',
      'lib/src/shared/viewmodels',
    ],
  ].map((p) => _pathJoin(targetDir, p)).toList();

  for (final dir in dirs) {
    final directory = Directory(dir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      logger.info('Created ' + dir);
    }
  }
}

String _pathJoin(String a, String b) {
  if (a == '.' || a.isEmpty) return b;
  final sep = Platform.pathSeparator;
  final left = a.endsWith(sep) ? a.substring(0, a.length - 1) : a;
  final right = b.startsWith(sep) ? b.substring(1) : b;
  return left + sep + right;
}
