// Security building blocks written in plain Dart, with no extra package:
// SHA-256 (FIPS 180-4), HMAC-SHA-256 (RFC 2104), the ChaCha20 cipher (RFC 8439) and the
// CRC-16 used by CCSDS (CCITT, polynomial 0x1021, start value 0xFFFF).
// Each function is checked in test/ against the published test vectors.
 
import 'dart:typed_data';
 
const int _mask = 0xFFFFFFFF;
 
const List<int> _k = [
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
  0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
  0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
  0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
  0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
  0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];
 
int _rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & _mask;
 
int _rotl(int x, int n) => ((x << n) | (x >> (32 - n))) & _mask;
 
Uint8List sha256(List<int> data) {
  final builder = BytesBuilder();
  builder.add(data);
  builder.addByte(0x80);
  while (builder.length % 64 != 56) {
    builder.addByte(0);
  }
  final bits = data.length * 8;
  for (var i = 7; i >= 0; i--) {
    builder.addByte((bits >> (8 * i)) & 0xFF);
  }
  final bytes = builder.toBytes();
  final h = [
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
  ];
  final w = List<int>.filled(64, 0);
  for (var off = 0; off < bytes.length; off += 64) {
    for (var i = 0; i < 16; i++) {
      final p = off + i * 4;
      w[i] = (bytes[p] << 24) | (bytes[p + 1] << 16) | (bytes[p + 2] << 8) | bytes[p + 3];
    }
    for (var i = 16; i < 64; i++) {
      final s0 = _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
      final s1 = _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & _mask;
    }
    var a = h[0];
    var b = h[1];
    var c = h[2];
    var d = h[3];
    var e = h[4];
    var f = h[5];
    var g = h[6];
    var hh = h[7];
    for (var i = 0; i < 64; i++) {
      final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ ((~e & _mask) & g);
      final t1 = (hh + s1 + ch + _k[i] + w[i]) & _mask;
      final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final t2 = (s0 + maj) & _mask;
      hh = g;
      g = f;
      f = e;
      e = (d + t1) & _mask;
      d = c;
      c = b;
      b = a;
      a = (t1 + t2) & _mask;
    }

    h[0] = (h[0] + a) & _mask;
    h[1] = (h[1] + b) & _mask;
    h[2] = (h[2] + c) & _mask;
    h[3] = (h[3] + d) & _mask;
    h[4] = (h[4] + e) & _mask;
    h[5] = (h[5] + f) & _mask;
    h[6] = (h[6] + g) & _mask;
    h[7] = (h[7] + hh) & _mask;
  }
  final out = Uint8List(32);
  for (var i = 0; i < 8; i++) {
    out[i * 4] = (h[i] >> 24) & 0xFF;
    out[i * 4 + 1] = (h[i] >> 16) & 0xFF;
    out[i * 4 + 2] = (h[i] >> 8) & 0xFF;
    out[i * 4 + 3] = h[i] & 0xFF;
  }
  return out;
}
 
/// Keyed signature of a message: proves who wrote it and that it was not changed.
Uint8List hmacSha256(List<int> key, List<int> message) {
  var k = key;
  if (k.length > 64) k = sha256(k);
  final inner = Uint8List(64);
  final outer = Uint8List(64);
  for (var i = 0; i < 64; i++) {
    final b = i < k.length ? k[i] : 0;
    inner[i] = b ^ 0x36;
    outer[i] = b ^ 0x5c;
  }
  return sha256([...outer, ...sha256([...inner, ...message])]);
}
 
/// ChaCha20 stream cipher. The same call encrypts and decrypts.
/// [key] has 32 bytes and [nonce] 12 bytes; a nonce is never used twice with a key.
Uint8List chacha20(List<int> key, List<int> nonce, List<int> data, {int counter = 1}) {
  int word(List<int> b, int p) => b[p] | (b[p + 1] << 8) | (b[p + 2] << 16) | (b[p + 3] << 24);
 
  final start = List<int>.filled(16, 0);
  start[0] = 0x61707865;
  start[1] = 0x3320646e;
  start[2] = 0x79622d32;
  start[3] = 0x6b206574;
  for (var i = 0; i < 8; i++) {
    start[4 + i] = word(key, i * 4);
  }
  for (var i = 0; i < 3; i++) {
    start[13 + i] = word(nonce, i * 4);
  }
 
  final x = List<int>.filled(16, 0);
  void quarter(int a, int b, int c, int d) {
    x[a] = (x[a] + x[b]) & _mask;
    x[d] = _rotl(x[d] ^ x[a], 16);
    x[c] = (x[c] + x[d]) & _mask;
    x[b] = _rotl(x[b] ^ x[c], 12);
    x[a] = (x[a] + x[b]) & _mask;
    x[d] = _rotl(x[d] ^ x[a], 8);
    x[c] = (x[c] + x[d]) & _mask;
    x[b] = _rotl(x[b] ^ x[c], 7);
  }
 
  final out = Uint8List(data.length);
  for (var off = 0; off < data.length; off += 64) {
    start[12] = (counter + off ~/ 64) & _mask;
    for (var i = 0; i < 16; i++) {
      x[i] = start[i];
    }
    for (var round = 0; round < 10; round++) {
      quarter(0, 4, 8, 12);
      quarter(1, 5, 9, 13);
      quarter(2, 6, 10, 14);
      quarter(3, 7, 11, 15);
      quarter(0, 5, 10, 15);
      quarter(1, 6, 11, 12);
      quarter(2, 7, 8, 13);
      quarter(3, 4, 9, 14);
    }
    for (var i = 0; i < 64 && off + i < data.length; i++) {
      final v = (x[i ~/ 4] + start[i ~/ 4]) & _mask;
      out[off + i] = data[off + i] ^ ((v >> (8 * (i % 4))) & 0xFF);
    }
  }
  return out;

}
 
/// CRC-16 of CCSDS packets and frames.
int crc16(List<int> data) {
  var crc = 0xFFFF;
  for (final byte in data) {
    crc ^= byte << 8;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 0x8000) != 0 ? ((crc << 1) ^ 0x1021) & 0xFFFF : (crc << 1) & 0xFFFF;
    }
  }
  return crc;
}
 
String hex(List<int> bytes) {
  final out = StringBuffer();
  for (final b in bytes) {
    out.write(b.toRadixString(16).padLeft(2, '0'));
  }
  return out.toString();
}
 
Uint8List unhex(String text) {
  final out = Uint8List(text.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(text.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}
