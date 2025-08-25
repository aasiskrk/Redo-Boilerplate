import 'dart:io';

import '../utils/logger.dart';
import 'package:yaml_edit/yaml_edit.dart';

Future<void> addDependencies(Map<String, String> deps,
    {required String directoryPath, Logger? logger}) async {
  final pubspec = File(_pathJoin(directoryPath, 'pubspec.yaml'));
  if (!await pubspec.exists()) {
    await _writeMinimalFlutterPubspec(pubspec, directoryPath, logger);
  }
  final text = await pubspec.readAsString();
  final editor = YamlEditor(text);

  for (final entry in deps.entries) {
    editor.update(['dependencies', entry.key], entry.value);
    logger?.info('Added dependency ${entry.key}: ${entry.value}');
  }

  await pubspec.writeAsString(editor.toString());
}

String _pathJoin(String a, String b) {
  if (a == '.' || a.isEmpty) return b;
  final sep = Platform.pathSeparator;
  final left = a.endsWith(sep) ? a.substring(0, a.length - 1) : a;
  final right = b.startsWith(sep) ? b.substring(1) : b;
  return left + sep + right;
}

Future<void> _writeMinimalFlutterPubspec(
    File pubspec, String directoryPath, Logger? logger) async {
  final appName =
      _basename(directoryPath).isEmpty ? 'app' : _basename(directoryPath);
  final content = '''
name: $appName
description: A new Flutter project.
publish_to: "none"
version: 1.0.0+1
environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.19.0"
dependencies:
  flutter:
    sdk: flutter
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
''';
  await pubspec.create(recursive: true);
  await pubspec.writeAsString(content);
  logger?.info('Created minimal Flutter pubspec at ' + pubspec.path);
}

String _basename(String path) {
  if (path.isEmpty) return '';
  final sep = Platform.pathSeparator;
  final normalized =
      path.endsWith(sep) ? path.substring(0, path.length - 1) : path;
  final idx = normalized.lastIndexOf(sep);
  return idx == -1 ? normalized : normalized.substring(idx + 1);
}
