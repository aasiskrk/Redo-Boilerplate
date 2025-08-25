import 'dart:io';

import 'package:args/args.dart';
import 'utils/logger.dart';
import 'utils/prompts.dart';

import 'generator/pubspec_edit.dart';
import 'generator/structure.dart';
import 'generator/templates.dart';

Future<void> runCli(List<String> args) async {
  final logger = Logger();
  final parser = ArgParser()
    ..addCommand('init')
    ..addFlag('yes',
        abbr: 'y', help: 'Accept defaults non-interactively', negatable: false)
    ..addOption('dir',
        abbr: 'd', help: 'Target directory to scaffold into', defaultsTo: '.')
    ..addFlag('help', abbr: 'h', help: 'Show usage', negatable: false);

  ArgResults results;
  try {
    results = parser.parse(args);
  } catch (e) {
    logger.err('Error: $e');
    stdout.writeln(parser.usage);
    return;
  }

  if (results['help'] == true || (results.command == null && args.isEmpty)) {
    stdout.writeln('Usage: boiler init [options]');
    stdout.writeln(parser.usage);
    return;
  }

  if (results.command?.name == 'init') {
    final acceptDefaults = results['yes'] == true;
    final dirOpt = (results['dir'] as String?) ?? '.';
    final targetDir = dirOpt.trim().isEmpty ? '.' : dirOpt;
    await _handleInit(logger,
        acceptDefaults: acceptDefaults, targetDir: targetDir);
    return;
  }

  logger.warn('Unknown command. Try: boiler init');
}

Future<void> _handleInit(Logger logger,
    {required bool acceptDefaults, required String targetDir}) async {
  logger.info('Scaffolding Flutter boilerplate...');

  final architecture = acceptDefaults
      ? 'clean'
      : SimplePrompts.choose('Architecture:', ['clean', 'mvvm']);

  await createBaseStructure(logger: logger, targetDir: targetDir);
  await createArchitectureStructure(
      architecture: architecture, logger: logger, targetDir: targetDir);

  // Always add networking deps
  await addDependencies({
    'dio': '^5.7.0',
    'pretty_dio_logger': '^1.3.1',
  }, directoryPath: targetDir, logger: logger);

  // Generate required files/subtrees
  await generateConstantsFiles(logger: logger, directoryPath: targetDir);
  await generateNetworkingFiles(logger: logger, directoryPath: targetDir);
  await generateApiEndpoints(logger: logger, directoryPath: targetDir);
  await generateConstantsThemeFiles(logger: logger, directoryPath: targetDir);
  await generateThemeFiles('both', logger: logger, directoryPath: targetDir);
  await generateAppFile(logger: logger, directoryPath: targetDir);
  await generateMainFile(logger: logger, directoryPath: targetDir);

  // Optionally run pub get
  await _runPubGet(logger, workingDirectory: targetDir);

  logger.success('Done.');
}

Future<void> _runPubGet(Logger logger,
    {required String workingDirectory}) async {
  try {
    final flutter = await Process.start('flutter', ['pub', 'get'],
        workingDirectory: workingDirectory);
    await stdout.addStream(flutter.stdout);
    await stderr.addStream(flutter.stderr);
    final flutterCode = await flutter.exitCode;
    if (flutterCode == 0) {
      return;
    }
  } catch (_) {
    // flutter not installed or not in PATH
  }

  final dart = await Process.start('dart', ['pub', 'get'],
      workingDirectory: workingDirectory);
  await stdout.addStream(dart.stdout);
  await stderr.addStream(dart.stderr);
  final dartCode = await dart.exitCode;
  if (dartCode != 0) {
    logger.warn(
        'pub get failed ($dartCode) in $workingDirectory. You may need to run it manually.');
  }
}
