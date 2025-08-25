import 'dart:io';

class SimplePrompts {
  static String choose(String label, List<String> options) {
    stdout.writeln(label + ' ' + options.toString());
    stdout.write('Enter choice number [1-' +
        options.length.toString() +
        '] (default 1): ');
    final input = stdin.readLineSync();
    final index = int.tryParse((input ?? '').trim());
    if (index == null || index < 1 || index > options.length)
      return options.first;
    return options[index - 1];
  }
}
