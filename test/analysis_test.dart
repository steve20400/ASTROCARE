import 'dart:convert';
 
import 'package:astrocare/app/app_state.dart';
import 'package:astrocare/data/remote_api.dart';
import 'package:astrocare/data/simple_pdf.dart';
import 'package:astrocare/domain/analysis.dart';
import 'package:astrocare/domain/catalog.dart';
import 'package:astrocare/domain/ccsds.dart';
import 'package:astrocare/domain/crypto.dart';
import 'package:astrocare/domain/models.dart';
import 'package:astrocare/l10n/strings.dart';
import 'package:astrocare/ui/body_page.dart';
import 'package:astrocare/ui/first_aid_page.dart';
import 'package:astrocare/ui/indicator_page.dart';
import 'package:astrocare/ui/login_page.dart';
import 'package:astrocare/ui/theme.dart';
import 'package:astrocare/ui/transmission_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
 
void main() {
  const engine = AnalysisEngine(kSynergyRules);
  final allHazards = Hazard.values.toList();
 
  test('thresholds give nominal, attention and critical', () {
    final heart = indicatorByCode('heartRate');
    expect(heart.levelFor(70), AlertLevel.nominal);
    expect(heart.levelFor(110), AlertLevel.attention);
    expect(heart.levelFor(150), AlertLevel.critical);
  });
 
  test('trend needs enough history and detects a strong deviation', () {
    const detector = TrendDetector();
    expect(detector.zScore(70, [68, 69, 70]), isNull);
    final history = <double>[68, 70, 69, 71, 68, 70, 69, 71, 70, 69];
    expect(detector.isAbnormal(detector.zScore(70, history)), isFalse);
    expect(detector.isAbnormal(detector.zScore(95, history)), isTrue);
  });
 
  test('a combined risk raises the level when its hazard is active', () {
    final result = engine.analyze(
      indicator: indicatorByCode('heartRate'),
      value: 112,
      history: const [],
      latest: {'temperature': AlertLevel.attention},
      activeHazards: allHazards,
    );
    expect(result.thresholdLevel, AlertLevel.attention);
    expect(result.level, AlertLevel.critical);
    expect(result.cause, AlertCause.synergy);
  });
 
  test('no combined risk when the hazard is not active', () {
    final result = engine.analyze(
      indicator: indicatorByCode('heartRate'),
      value: 112,
      history: const [],
      latest: {'temperature': AlertLevel.attention},
      activeHazards: const [Hazard.radiation],
    );
    expect(result.level, AlertLevel.attention);
    expect(result.cause, AlertCause.threshold);
  });
 
  test('a measurement survives the trip to the online database and back', () {
    final at = DateTime(2026, 11, 14, 22, 30);
    final m = Measurement(id: 'm1', indicator: 'mood', value: 4, at: at);
    final row = jsonDecode(jsonEncode(m.toRemote('user-1'))) as Map<String, dynamic>;
    expect(row['user_id'], 'user-1');
    final back = Measurement.fromRemote(row);
    expect(back.indicator, 'mood');
    expect(back.value, 4);
    expect(back.at.isAtSameMomentAs(at), isTrue);
    expect(back.synced, isTrue);
  });
 
  test('Supabase errors become short codes', () {
    expect(

      RemoteApi.errorCode('{"code":400,"error_code":"invalid_credentials","msg":"x"}', 400),
      'INVALID_CREDENTIALS',
    );
    expect(RemoteApi.errorCode('{"code":"42501","message":"rls"}', 403), 'PERMISSION_DENIED');
    expect(RemoteApi.errorCode('not json', 500), 'HTTP_500');
  });
 
  test('the PDF writer produces a well-formed file', () {
    final bytes = SimplePdf.build([
      const PdfLine('AstroCare - Rapport de santé', size: 18, bold: true),
      for (var i = 0; i < 120; i++) PdfLine('Ligne $i : fréquence cardiaque (72 bpm)'),
    ]);
    final text = latin1.decode(bytes);
    expect(text.startsWith('%PDF-1.4'), isTrue);
    expect(text.trimRight().endsWith('%%EOF'), isTrue);
    expect('/Type /Page '.allMatches(text).length, greaterThan(1));
  });
 
  test('every first-aid situation has its texts in English and French', () {
    for (final c in kAidCases) {
      final key = 'aid.${c[0]}.${c[1]}';
      for (final lang in ['en', 'fr']) {
        for (final part in ['title', 'steps', 'urgent']) {
          expect(translate(lang, '$key.$part'), isNot('$key.$part'));
        }
      }
      expect(kNasaRisk[c[0]], isNotNull);
    }
    final heart = indicatorByCode('heartRate');
    expect(aidSide(heart, 130), 'high');
    expect(aidSide(heart, 38), 'low');
  });
 
  testWidgets('sign-in and first-aid screens draw in both themes', (tester) async {
    for (final dark in [false, true]) {
      await tester.pumpWidget(MaterialApp(theme: buildTheme(dark), home: const LoginPage()));
      expect(find.byType(TextField), findsWidgets);
      await tester.pumpWidget(MaterialApp(theme: buildTheme(dark), home: const FirstAidPage()));
      await tester.tap(find.byType(ExpansionTile).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
 
  testWidgets('the 3D figure draws, turns, zooms and opens the touched part', (tester) async {
    tester.view.physicalSize = const Size(400, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final dark in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(dark),
          home: const Scaffold(body: BodyPage()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      // The chest is touched on the body itself, not on a marker.
      final box = tester.getRect(find.byType(BodyPage));
      await tester.tapAt(Offset(box.center.dx - 30, box.top + box.height * 0.26));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Chest and heart'), findsOneWidget);
      expect(find.text('Health and illness thresholds'), findsOneWidget);
      await tester.tap(find.byTooltip('Whole body'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Chest and heart'), findsNothing);
      await tester.tap(find.byTooltip('Zoom in'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.dragFrom(box.center, const Offset(120, 40));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
  });
 
  testWidgets('the curve follows the chosen period', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final now = DateTime.now();
    appState.measurements.addAll([
      Measurement(id: 't1', indicator: 'heartRate', value: 64, at: now),
      Measurement(
        id: 't2',
        indicator: 'heartRate',

        value: 80,
        at: now.subtract(const Duration(days: 3)),
      ),
      Measurement(
        id: 't3',
        indicator: 'heartRate',
        value: 110,
        at: now.subtract(const Duration(days: 20)),
      ),
    ]);
    addTearDown(() => appState.measurements.removeWhere((m) => m.id.startsWith('t')));
    await tester.pumpWidget(
      MaterialApp(theme: buildTheme(false), home: const IndicatorPage(code: 'heartRate')),
    );
    await tester.tap(find.text('24 h'));
    await tester.pump();
    expect(find.text('1 measurement(s) in this period'), findsOneWidget);
    await tester.tap(find.text('7 days'));
    await tester.pump();
    expect(find.text('2 measurement(s) in this period'), findsOneWidget);
    await tester.tap(find.text('All'));
    await tester.pump();
    expect(find.text('3 measurement(s) in this period'), findsOneWidget);
    expect(find.text('110 bpm'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
 
  test('security functions match the published test vectors', () {
    expect(
      hex(sha256(utf8.encode('abc'))),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
    expect(
      hex(sha256([for (var i = 0; i < 200; i++) i])),
      '1901da1c9f699b48f6b2636e65cbf73abf99d0441ef67f5c540a42f7051dec6f',
    );
    expect(
      hex(hmacSha256(utf8.encode('Jefe'), utf8.encode('what do ya want for nothing?'))),
      '5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843',
    );
    expect(
      hex(
        hmacSha256([for (var i = 0; i < 100; i++) i], [for (var i = 0; i < 200; i++) i]),
      ),
      'd3cd072b3e0181f795ddd3d7a49e845e5efeb888c07c503b4bf96645fec24f6f',
    );
    // ChaCha20, RFC 8439 section 2.4.2.
    const text =
        "Ladies and Gentlemen of the class of '99: If I could offer you only one tip "
        'for the future, sunscreen would be it.';
    final key = [for (var i = 0; i < 32; i++) i];
    final nonce = unhex('000000000000004a00000000');
    final secret = chacha20(key, nonce, utf8.encode(text));
    expect(hex(secret).startsWith('6e2e359a2568f98041ba0728dd0d6981e97e7aec1d4360c2'), isTrue);
    expect(hex(secret).endsWith('8eedf2785e42874d'), isTrue);
    expect(utf8.decode(chacha20(key, nonce, secret)), text);
    // CRC-16 of CCSDS: the reference value for "123456789" is 0x29B1.
    expect(crc16(utf8.encode('123456789')), 0x29B1);
  });
 
  test('a report crosses the simulated link: lost packet repaired, file verified', () {
    final report = SimplePdf.build([
      for (var i = 0; i < 60; i++) PdfLine('Line $i: heart rate 72 bpm, temperature 36.8'),
    ]);
    final key = [for (var i = 0; i < 32; i++) 200 - i];
    final nonce = [for (var i = 0; i < 12; i++) i + 1];
    final plan = runTransfer(
      report: report,
      missionKey: key,
      nonce: nonce,
      transaction: 7,
      fileName: 'astrocare_report_0007.pdf',
    );
    expect(plan.ok, isTrue);
    expect(plan.resent, 1);
    expect(plan.events.where((e) => e.kind == 'fd' && e.lost).length, 1);
    expect(plan.events.any((e) => e.kind == 'nak'), isTrue);
    expect(plan.events.last.kind, 'ackfin');
    // A Space Packet with one changed byte is refused by its CRC.
    final packet = spacePacket(3, fileDataPdu(7, 0, [1, 2, 3, 4]));
    expect(openSpacePacket(packet), isNotNull);
    expect(packet[0] << 8 | packet[1], kApid);
    packet[8] ^= 0x01;
    expect(openSpacePacket(packet), isNull);

    // The ground refuses a file signed with another key, and cannot read it.
    final sealed = seal(key, nonce, report);
    expect(unseal(key, sealed[0], sealed[1]), report);
    expect(unseal([for (var i = 0; i < 32; i++) i], sealed[0], sealed[1]), isNull);
    expect(latin1.decode(sealed[0]).contains('%PDF'), isFalse);
  });
 
  testWidgets('a report is created after the waiting time and sent when the link opens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    appState.setLink(false);
    appState.setReportDelay(2);
    await tester.pumpWidget(
      MaterialApp(theme: buildTheme(false), home: const TransmissionPage()),
    );
    final before = appState.reports.length;
    appState.record('heartRate', 72);
    await tester.pump(const Duration(seconds: 1));
    // A new measurement before the end of the wait restarts it.
    appState.record('temperature', 36.8);
    await tester.pump(const Duration(milliseconds: 1500));
    expect(appState.reports.length, before);
    await tester.pump(const Duration(seconds: 1));
    expect(appState.reports.length, before + 1);
    final report = appState.reports.last;
    expect(report.auto, isTrue);
    expect(report.newCount, greaterThanOrEqualTo(2));
    expect(report.sent, isFalse);
    expect(find.textContaining('Waiting on board'), findsWidgets);
    // The link opens: the report leaves, and the ground confirms it.
    appState.setLink(true);
    await tester.pump();
    expect(appState.transfer, isNotNull);
    final duration = appState.transfer!.durationMs;
    await tester.pump(Duration(milliseconds: duration ~/ 2));
    expect(report.sent, isFalse);
    await tester.pump(Duration(milliseconds: duration ~/ 2 + 300));
    expect(report.sent, isTrue);
    expect(report.resent, 1);
    expect(appState.transfer, isNull);
    expect(tester.takeException(), isNull);
 
    appState.setLink(false);
    appState.setReportDelay(600);
    appState.measurements.clear();
    appState.alerts.clear();
    appState.reports.clear();
    await tester.pumpWidget(const SizedBox());
  });
}
