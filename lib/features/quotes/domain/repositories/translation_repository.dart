/// Kontrak penerjemah teks (contoh: kutipan English -> Indonesia).
abstract class TranslationRepository {
  Future<String> translate(
    String text, {
    String from = 'en',
    required String to,
  });
}
