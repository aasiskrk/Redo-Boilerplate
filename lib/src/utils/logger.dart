class Logger {
  void info(String message) => _print('[INFO] ' + message);
  void warn(String message) => _print('[WARN] ' + message);
  void err(String message) => _print('[ERROR] ' + message);
  void success(String message) => _print('[SUCCESS] ' + message);

  void _print(String message) {
    // Keep simple for cross-platform terminals
    // ignore: avoid_print
    print(message);
  }
}
