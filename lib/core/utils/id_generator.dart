import 'dart:math';

/// Membuat id unik sederhana untuk data lokal.
class IdGenerator {
  const IdGenerator._();

  static final Random _random = Random.secure();

  static String newId() {
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final noise = List.generate(
      6,
      (_) => _random.nextInt(36).toRadixString(36),
    ).join();
    return '$time$noise';
  }
}
