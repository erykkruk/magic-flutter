import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class OAuthChallenge {
  OAuthChallenge() {
    // SHA256 encrypt and encode to base64
    final base64Str =
        base64Encode(sha256.convert(utf8.encode(verifier)).bytes);
    challenge =
        base64Str.replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
  }

  String state = _createRandomString(128);
  String verifier = _createRandomString(128);
  late String challenge;
}

String _createRandomString(int length) {
  const letters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  final rnd = Random.secure();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => letters.codeUnitAt(rnd.nextInt(letters.length)),
    ),
  );
}
