// Sending a report to the ground the way space missions move files.
//
// What is real in this file:
// - each message travels in a CCSDS Space Packet (CCSDS 133.0-B): 6-byte primary
//   header, then the data, then a CRC-16;
// - the exchange follows the CCSDS File Delivery Protocol, class 2 (CCSDS 727.0-B):
//   Metadata, File Data, EOF, NAK for the missing parts, Finished, ACK, with the
//   file checksum of the standard;
// - the file is encrypted (ChaCha20) and signed (HMAC-SHA-256) before it leaves, and
//   the ground station checks the signature before it decrypts.
// What is simulated: the radio link. Both ends run inside the app, and the link loses
// one packet on purpose to show the repair. The messages are a simplified form of the
// standard: enough to be read by the other end of this app, not a certified stack.
//
// CFDP replaced the older SCPS file protocol (SCPS-FP, CCSDS 717.0-B), which CCSDS now
// lists as historical.
 
import 'dart:convert';
import 'dart:typed_data';
 
import 'crypto.dart';
 
/// Application process identifier of AstroCare packets (11 bits).
const int kApid = 0x0AC;
 
/// Entity numbers of the two ends of the file transfer.
const int kSpacecraftEntity = 1;
const int kGroundEntity = 2;
 
// File directive codes of CFDP.
const int kEof = 0x04;
const int kFinished = 0x05;
const int kAck = 0x06;
const int kMetadata = 0x07;
const int kNak = 0x08;
 
List<int> _u16(int v) => [(v >> 8) & 0xFF, v & 0xFF];
 
List<int> _u32(int v) => [(v >> 24) & 0xFF, (v >> 16) & 0xFF, (v >> 8) & 0xFF, v & 0xFF];
int _read32(List<int> b, int p) => (b[p] << 24) | (b[p + 1] << 16) | (b[p + 2] << 8) | b[p + 3];
 
/// Builds one CCSDS Space Packet around [data] and ends it with a CRC-16.
Uint8List spacePacket(int sequenceCount, List<int> data) {
  final length = data.length + 2; // data field: the data and the CRC
  final packet = <int>[
    // Version 000, type 0 (telemetry), no secondary header, then the APID.
    (kApid >> 8) & 0x07,
    kApid & 0xFF,
    // Sequence flags 11 (the packet is complete by itself), then the 14-bit counter.
    0xC0 | ((sequenceCount >> 8) & 0x3F),
    sequenceCount & 0xFF,
    // Length of the data field, minus one.
    ..._u16(length - 1),
    ...data,
  ];
  packet.addAll(_u16(crc16(packet)));
  return Uint8List.fromList(packet);
}
 
/// Returns the data of a Space Packet, or null when the packet is damaged.
Uint8List? openSpacePacket(Uint8List packet) {
  if (packet.length < 9) return null;
  final length = ((packet[4] << 8) | packet[5]) + 1;
  if (packet.length != 6 + length) return null;
  final body = packet.sublist(0, packet.length - 2);
  final crc = (packet[packet.length - 2] << 8) | packet[packet.length - 1];
  if (crc16(body) != crc) return null;
  return Uint8List.fromList(packet.sublist(6, packet.length - 2));
}
 
/// Fixed header of a CFDP message, followed by the two entity numbers and the
/// transaction number.
List<int> _pduHeader(bool fileData, bool towardSender, int dataLength, int transaction) => [
  // Version 001, type, direction, acknowledged mode, no CRC flag, small file.
  0x20 | (fileData ? 0x10 : 0) | (towardSender ? 0x08 : 0),
  ..._u16(dataLength),
  // Entity numbers on 1 byte, transaction number on 2 bytes.
  0x01,

  kSpacecraftEntity,
  ..._u16(transaction),
  kGroundEntity,
];
 
Uint8List _pdu(bool fileData, bool towardSender, int transaction, List<int> body) =>
    Uint8List.fromList([..._pduHeader(fileData, towardSender, body.length, transaction), ...body]);
 
List<int> _text(String s) {
  final bytes = utf8.encode(s);
  return [bytes.length, ...bytes];
}
 
/// File checksum of CFDP: sum of the 4-byte words of the file, modulo 2^32.
int cfdpChecksum(List<int> file) {
  var sum = 0;
  for (var i = 0; i < file.length; i++) {
    sum = (sum + (file[i] << (8 * (3 - i % 4)))) & 0xFFFFFFFF;
  }
  return sum;
}
 
Uint8List metadataPdu(int transaction, int fileSize, String name, List<int> signature) => _pdu(
  false,
  false,
  transaction,
  [
    kMetadata,
    0x40, // closure requested, modular checksum
    ..._u32(fileSize),
    ..._text(name),
    ..._text(name),
    // "Message to user" option carrying the signature of the file.
    0x02,
    signature.length,
    ...signature,
  ],
);
 
Uint8List fileDataPdu(int transaction, int offset, List<int> data) =>
    _pdu(true, false, transaction, [..._u32(offset), ...data]);
Uint8List eofPdu(int transaction, int checksum, int fileSize) =>
    _pdu(false, false, transaction, [kEof, 0x00, ..._u32(checksum), ..._u32(fileSize)]);
 
/// Asks again for the missing parts. Each part is [start, end), in bytes.
Uint8List nakPdu(int transaction, int fileSize, List<List<int>> missing) => _pdu(
  false,
  true,
  transaction,
  [
    kNak,
    ..._u32(0),
    ..._u32(fileSize),
    for (final m in missing) ...[..._u32(m[0]), ..._u32(m[1])],
  ],
);
 
/// End of the transfer, sent by the ground. [complete] says the file is whole and valid.
Uint8List finishedPdu(int transaction, bool complete) =>
    _pdu(false, true, transaction, [kFinished, complete ? 0x02 : 0x46]);
 
Uint8List ackPdu(int transaction, int directive, bool towardSender) => _pdu(
  false,
  towardSender,
  transaction,
  [kAck, (directive << 4) | (directive == kFinished ? 1 : 0), 0x02],
);
 
/// A CFDP message once read: its kind and its fields.
class Pdu {
  final bool fileData;
  final int transaction;
  final Uint8List body;
 
  Pdu(this.fileData, this.transaction, this.body);
 
  int get directive => fileData ? -1 : body[0];
 
  static Pdu? read(Uint8List bytes) {
    if (bytes.length < 9) return null;
    final length = (bytes[1] << 8) | bytes[2];
    if (bytes.length != 8 + length) return null;
    return Pdu((bytes[0] & 0x10) != 0, (bytes[5] << 8) | bytes[6], bytes.sublist(8));
  }

}
 
/// Encrypts and signs a file with the mission key. Returns [nonce + encrypted file]
/// and its signature.
List<Uint8List> seal(List<int> missionKey, List<int> nonce, List<int> file) {
  final encKey = sha256([...missionKey, ...utf8.encode('encrypt')]);
  final macKey = sha256([...missionKey, ...utf8.encode('sign')]);
  final sealed = Uint8List.fromList([...nonce, ...chacha20(encKey, nonce, file)]);
  return [sealed, hmacSha256(macKey, sealed)];
}
 
/// Checks the signature, then decrypts. Returns null when the signature is wrong.
Uint8List? unseal(List<int> missionKey, List<int> sealed, List<int> signature) {
  if (sealed.length < 12) return null;
  final encKey = sha256([...missionKey, ...utf8.encode('encrypt')]);
  final macKey = sha256([...missionKey, ...utf8.encode('sign')]);
  final expected = hmacSha256(macKey, sealed);
  if (expected.length != signature.length) return null;
  var diff = 0;
  for (var i = 0; i < expected.length; i++) {
    diff |= expected[i] ^ signature[i];
  }
  if (diff != 0) return null;
  return chacha20(encKey, sealed.sublist(0, 12), sealed.sublist(12));
}
 
/// The ground end of the transfer. It only knows what arrives in the packets.
class GroundStation {
  final List<int> missionKey;
  int fileSize = -1;
  String fileName = '';
  List<int> signature = const [];
  int? announcedChecksum;
  final Map<int, Uint8List> _parts = {};
 
  /// Packets refused because their CRC was wrong.
  int damaged = 0;
 
  GroundStation(this.missionKey);
 
  /// Takes one Space Packet from the link.
  void receive(Uint8List packet) {
    final data = openSpacePacket(packet);
    final pdu = data == null ? null : Pdu.read(data);
    if (pdu == null) {
      damaged++;
      return;
    }
    final b = pdu.body;
    if (pdu.fileData) {
      _parts[_read32(b, 0)] = b.sublist(4);
    } else if (pdu.directive == kMetadata) {
      fileSize = _read32(b, 2);
      final nameLength = b[6];
      fileName = utf8.decode(b.sublist(7, 7 + nameLength));
      var p = 7 + nameLength;
      p += 1 + b[p]; // destination name
      if (p + 1 < b.length && b[p] == 0x02) signature = b.sublist(p + 2, p + 2 + b[p + 1]);
    } else if (pdu.directive == kEof) {
      announcedChecksum = _read32(b, 2);
      fileSize = _read32(b, 6);
    }
  }
 
  /// Parts of the file that have not arrived, as [start, end) pairs.
  List<List<int>> missing() {
    if (fileSize < 0) return const [];
    final gaps = <List<int>>[];
    final starts = _parts.keys.toList()..sort();
    var at = 0;
    for (final s in starts) {
      if (s > at) gaps.add([at, s]);
      final end = s + _parts[s]!.length;
      if (end > at) at = end;
    }
    if (at < fileSize) gaps.add([at, fileSize]);
    return gaps;
  }
 
  Uint8List assemble() {
    final file = Uint8List(fileSize < 0 ? 0 : fileSize);
    for (final e in _parts.entries) {
      for (var i = 0; i < e.value.length && e.key + i < file.length; i++) {
        file[e.key + i] = e.value[i];

      }
    }
    return file;
  }
 
  bool get checksumOk =>
      announcedChecksum != null &&
      missing().isEmpty &&
      cfdpChecksum(assemble()) == announcedChecksum;
 
  /// The report, readable again, or null when the signature does not match.
  Uint8List? open() => checksumOk ? unseal(missionKey, assemble(), signature) : null;
}
 
/// One message on the link, for the display and the log.
class LinkEvent {
  /// "md", "fd", "eof", "ackeof", "nak", "refd", "fin", "ackfin".
  final String kind;
 
  /// True from the spacecraft to the ground.
  final bool down;
  final bool lost;
 
  /// For file data: number of the part, total of parts, first and last byte.
  final int index;
  final int total;
  final int from;
  final int to;
 
  /// When the message leaves, in milliseconds after the start of the transfer.
  final int startMs;
  const LinkEvent(
    this.kind,
    this.startMs, {
    this.down = true,
    this.lost = false,
    this.index = 0,
    this.total = 0,
    this.from = 0,
    this.to = 0,
  });
}
 
/// A whole transfer: what happened on the link and how it ended.
class TransferPlan {
  final List<LinkEvent> events;
  final int durationMs;
  final bool ok;
  final int packets;
  final int resent;
  final int bytes;
  final String digest;
  final String fileName;
 
  const TransferPlan({
    required this.events,
    required this.durationMs,
    required this.ok,
    required this.packets,
    required this.resent,
    required this.bytes,
    required this.digest,
    required this.fileName,
  });
}
 
/// Time a message takes to cross the link in the display. The real delay to Mars is
/// 4 to 24 minutes: the display compresses it.
const int kFlightMs = 1100;
const int _gapMs = 330;
/// Sends [report] to a ground station through the simulated link and returns what
/// happened. The whole protocol really runs: packets are built, one is lost, the
/// ground asks for it again, checks the file, verifies the signature and decrypts.
TransferPlan runTransfer({
  required List<int> report,
  required List<int> missionKey,
  required List<int> nonce,
  required int transaction,
  required String fileName,
  bool loseOnePacket = true,
}) {
  final sealed = seal(missionKey, nonce, report);
  final file = sealed[0];
  final signature = sealed[1];

  final ground = GroundStation(missionKey);
 
  // At most 12 parts, of at least 256 bytes each.
  final wanted = (file.length / 12).ceil();
  final segment = wanted < 256 ? 256 : wanted;
  final total = (file.length / segment).ceil();
  final lostPart = loseOnePacket && total >= 3 ? total ~/ 2 : -1;
 
  final events = <LinkEvent>[];
  var counter = 0;
  var packets = 0;
  var clock = 0;
  void send(Uint8List pdu, {bool lost = false}) {
    packets++;
    final packet = spacePacket(counter++ & 0x3FFF, pdu);
    if (!lost) ground.receive(packet);
  }
 
  // A message from the ground: it also crosses the link in a checked packet.
  Pdu fromGround(Uint8List pdu) {
    packets++;
    return Pdu.read(openSpacePacket(spacePacket(counter++ & 0x3FFF, pdu))!)!;
  }
 
  send(metadataPdu(transaction, file.length, fileName, signature));
  events.add(LinkEvent('md', clock, to: file.length));
  for (var i = 0; i < total; i++) {
    clock += _gapMs;
    final start = i * segment;
    final end = start + segment > file.length ? file.length : start + segment;
    final lost = i == lostPart;
    send(fileDataPdu(transaction, start, file.sublist(start, end)), lost: lost);
    events.add(
      LinkEvent('fd', clock, lost: lost, index: i + 1, total: total, from: start, to: end),
    );
  }
  clock += _gapMs;
  send(eofPdu(transaction, cfdpChecksum(file), file.length));
  events.add(LinkEvent('eof', clock, to: file.length));
 
  // The ground answers once the EOF has arrived.
  clock += kFlightMs + 250;
  fromGround(ackPdu(transaction, kEof, true));
  events.add(LinkEvent('ackeof', clock, down: false));
 
  var resent = 0;
  final gaps = ground.missing();
  if (gaps.isNotEmpty) {
    clock += _gapMs;
    // The request travels back in a real packet, read by the sender.
    final request = fromGround(nakPdu(transaction, file.length, gaps));
    events.add(LinkEvent('nak', clock, down: false, from: gaps.first[0], to: gaps.last[1]));
    clock += kFlightMs + 250;
    for (var p = 9; p + 8 <= request.body.length; p += 8) {
      final start = _read32(request.body, p);
      final end = _read32(request.body, p + 4);
      send(fileDataPdu(transaction, start, file.sublist(start, end)));
      resent++;
      events.add(
        LinkEvent(
          'refd',
          clock,
          index: start ~/ segment + 1,
          total: total,
          from: start,
          to: end,
        ),
      );
      clock += _gapMs;
    }
    clock += kFlightMs;
  }
 
  final opened = ground.open();
  var ok = false;
  if (opened != null && opened.length == report.length) {
    ok = true;
    for (var i = 0; i < report.length; i++) {
      if (opened[i] != report[i]) ok = false;
    }
  }
  clock += 250;
  final finished = fromGround(finishedPdu(transaction, ok));
  ok = ok && finished.directive == kFinished && finished.body[1] == 0x02;

  events.add(LinkEvent('fin', clock, down: false, lost: !ok));
  clock += kFlightMs + 250;
  send(ackPdu(transaction, kFinished, false));
  events.add(LinkEvent('ackfin', clock));
  clock += kFlightMs + 300;
 
  return TransferPlan(
    events: events,
    durationMs: clock,
    ok: ok,
    packets: packets,
    resent: resent,
    bytes: file.length,
    digest: hex(sha256(report)).substring(0, 16),
    fileName: fileName,
  );
}
