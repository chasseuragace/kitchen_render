// Fake JWT — base64url only, NOT cryptographically signed. Local dev only.
import 'dart:convert';
import 'package:contracts/contracts.dart';
import 'store.dart';

String _b64(Map<String, dynamic> o) => base64Url.encode(utf8.encode(jsonEncode(o)));

String signToken(String userId) {
  final header = _b64({'alg': 'none', 'typ': 'JWT'});
  final payload = _b64({'sub': userId, 'iat': DateTime.now().millisecondsSinceEpoch});
  return '$header.$payload.mock';
}

UserDto? userFromAuthHeader(String? header) {
  if (header == null || !header.startsWith('Bearer ')) return null;
  final token = header.substring(7);
  try {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    final payload = jsonDecode(utf8.decode(base64Url.decode(parts[1]))) as Map<String, dynamic>;
    return users[payload['sub']];
  } catch (_) {
    return null;
  }
}
