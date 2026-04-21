import 'dart:math';

class OrgCodeGenerator {
  static String generateCode({required String orgName, int codeLength = 6}) {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    final rand = Random.secure();

    String prefix = orgName
        .replaceAll(RegExp(r'[^A-Za-z]'), '')
        .toUpperCase()
        .substring(0, 3);

    String randomPart = List.generate(
      codeLength,
      (index) => chars[rand.nextInt(chars.length)],
    ).join();

    return "$prefix-$randomPart";
  }
}
