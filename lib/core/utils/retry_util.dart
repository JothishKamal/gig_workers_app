import 'dart:math';

Future<T> retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  int attempts = 0;
  while (true) {
    try {
      attempts++;
      return await operation();
    } catch (e) {
      if (attempts >= maxRetries) {
        rethrow;
      }
      final delay = initialDelay * pow(2, attempts - 1);
      await Future.delayed(delay);
    }
  }
}
