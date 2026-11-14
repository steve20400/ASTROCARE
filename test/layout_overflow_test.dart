// Garde-fou de mise en page : aucun écran ne doit déborder sur un téléphone.
// Les tests widget de Flutter utilisent par défaut une police de substitution
// très large, qui produit de faux débordements ; on charge donc Roboto comme
// sur un appareil réel avant de mesurer.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:astrocare/providers/astrocare_provider.dart';
import 'package:astrocare/ui/screens/body_twin_screen.dart';
import 'package:astrocare/ui/screens/dashboard_screen.dart';
import 'package:astrocare/ui/screens/mission_sync_screen.dart';
import 'package:astrocare/ui/screens/protocols_screen.dart';
import 'package:astrocare/ui/screens/synergies_screen.dart';
import 'package:astrocare/ui/theme.dart';

const _screens = <String, Widget>{
  'dashboard': DashboardScreen(),
  'twin': BodyTwinScreen(),
  'synergies': SynergiesScreen(),
  'protocols': ProtocolsScreen(),
  'sync': MissionSyncScreen(),
};

// Petit téléphone d'entrée de gamme et iPhone 13 : deux largeurs de référence.
const _sizes = <String, Size>{
  'petit-telephone-320x568': Size(320, 568),
  'telephone-390x844': Size(390, 844),
};

Future<void> _loadFonts() async {
  final bytes = File('test/fonts/Roboto-Regular.ttf').readAsBytesSync();
  for (final family in ['Roboto', 'monospace']) {
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }
}

void main() {
  setUpAll(_loadFonts);

  for (final size in _sizes.entries) {
    for (final screen in _screens.entries) {
      testWidgets('${screen.key} tient sur ${size.key}', (tester) async {
        tester.view.physicalSize = size.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final provider = AstroCareProvider();
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: provider,
            child: MaterialApp(
              theme: AstroTheme.darkTheme,
              debugShowCheckedModeBanner: false,
              home: screen.value,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));

        final ex = tester.takeException();
        expect(ex, isNull, reason: '${screen.key} déborde en ${size.key}');
      });
    }
  }
}
