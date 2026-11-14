# ASTROCARE

Application mobile **offline-first** de surveillance sanitaire des astronautes en mission
(NASA Space Apps Challenge). Le nom du logiciel est **ASTROCARE** — tout ancien nom
est à proscrire dans le code, les écrans et les documents de rendu.

> Branche de travail : `dev/teme-israel`.
> Base : `origin/main` + les deux commits fonctionnels de `origin/dev/tagne-julio`
> (reportés par `cherry-pick`). Cette branche ajoute une couche **rotative 360°,
> mobile-first et découplée des sources de données** sans réécrire le moteur
> existant. Voir « Compatibilité entre branches » plus bas.

---

## 1. Ce que fait l'application

| Écran | Contenu |
|---|---|
| **VITALS** | Triage 30 s, radar d'homéostasie 6 axes, 6 canaux de télémétrie, courbes 24 h, injecteur de scénarios jury |
| **TWIN** | Jumeau anatomique **volumétrique rotatif à 360°**, passe de scan, inspecteur clinique par région |
| **SYNERGIES** | Moteur combinatoire NASA HRP (risques multi-dangers) |
| **PROTOCOLS** | Checklists FDF d'urgence exécutables sans lien Terre |
| **EARTH SYNC** | File de paquets *store-and-forward* type Deep Space Network |

Le tout est **100 % autonome** : aucune requête réseau n'est nécessaire au
fonctionnement, les mesures et la file de transmission survivent au redémarrage
(`SharedPreferences`, 150 relevés / 200 paquets conservés). Bilingue **FR / EN**.

---

## 2. Architecture

```
lib/
├── main.dart                          # bootstrap, Provider, navigation 5 onglets
├── models/
│   ├── vitals.dart                    # VitalsRecord, Astronaut, HealthStatus
│   ├── synergy.dart                   # facteurs de risque combinés
│   ├── protocol.dart                  # protocoles + SyncPacket
│   └── twin_projection.dart           # ★ géométrie 3D projetée (Dart pur, testable)
├── services/
│   ├── storage_service.dart           # persistance offline + seed 24 h
│   ├── synergy_engine.dart            # règles HRP
│   └── telemetry_source.dart          # ★ frontière d'ingestion des données
├── providers/
│   └── astrocare_provider.dart        # état réactif, scénarios, sync DSN
└── ui/
    ├── responsive.dart                # ★ breakpoints mobile-first (Dart pur)
    ├── theme.dart / localization.dart
    ├── screens/                       # 7 écrans
    └── widgets/
        ├── rotating_digital_twin.dart # ★ interaction, scan, gestes
        ├── rotating_twin_painter.dart # ★ rendu vectoriel des volumes
        ├── digital_twin_painter.dart  # ancienne vue statique (conservée)
        └── ...                        # jauges, radar, chartes, cartes
test/
├── widget_test.dart                   # smoke test applicatif
└── twin_projection_test.dart          # ★ 12 tests de géométrie + responsive
```

★ = ajout de `dev/teme-israel`.

Les fichiers en **Dart pur** (`twin_projection.dart`, `responsive.dart`,
`telemetry_source.dart`, les `models/`) n'importent pas Flutter : la logique
métier reste testable sans moteur de rendu et réutilisable sur une autre plateforme.

---

## 3. Responsive : mobile d'abord

La cible finale est un **téléphone**. La mise en page est donc écrite pour
390 px puis élargie, pas l'inverse. Les seuils sont centralisés dans
`lib/ui/responsive.dart` (aucun `MediaQuery` dispersé dans les écrans).

| Largeur | Grille télémétrie | Jumeau | Marges |
|---|---|---|---|
| `< 340` | 1 colonne | `min(34 % hauteur, 220 px plancher)` | 12 px |
| `340 – 639` | 2 colonnes | idem | 12 px |
| `640 – 999` | 3 colonnes | 44 % hauteur, plafond 360 px | 20 px |
| `≥ 1000` | 4 colonnes | idem | 20 px |

Trois points traités explicitement :

1. **Le jumeau ne mange pas deux écrans** : hauteur plafonnée à 34 % du viewport
   sur téléphone, mise à l'échelle uniforme du corps (320 unités) dans le canvas.
2. **Aucun conflit de geste** : seul le drag *horizontal* est capté par le
   jumeau ; le défilement *vertical* reste au `ListView` parent. Équivalent
   Flutter de `touch-action: pan-y`.
3. **Aucune information uniquement au survol** : toutes les régions sont
   atteignables au toucher (hit-test dans le painter, ruban de raccourcis,
   boutons ±15°, curseur).

Les lignes de HUD qui débordaient (`Row` fixes, hotspots `Positioned(left: 105)`
de l'ancienne vue) sont remplacées par des `Wrap` et une géométrie calculée.

---

## 4. Jumeau rotatif : la rotation est le point de vue, le scan est l'information

Chaque segment est un volume (largeur frontale `w`, profondeur sagittale `d`) :
`largeur_apparente = |cos a|·w + |sin a|·d`. À 0° on voit le torse de face,
à 90° de profil — les profondeurs sont réalistes (torse 42 × 26) pour que le
profil reste un corps et non une planche.

- Rotation au doigt, au curseur 0–359°, ou par pas de ±15°.
- Repère au sol (point cyan) indiquant où se trouve l'avant du corps.
- **Passe de scan 360°** (8 s) : le corps effectue un tour complet, les six
  régions s'éclairent l'une après l'autre, les autres s'estompent, et la fiche
  clinique suit le balisage (`BALISAGE 3/6 — …`).

**Choix assumé : pas de maillage 3D / WebGL.** Pour six régions, une projection
vectorielle en `CustomPainter` rend le même service en quelques kilo-octets,
sans dépendance GPU ni assets. Un vrai mesh coûterait plusieurs jours et
2–5 Mo pour un gain nul sur la démonstration clinique.

---

## 5. Origine des données

`TelemetrySource` est la frontière unique. Le moteur ne voit qu'un
`VitalsRecord` : il ne sait jamais si la mesure vient d'une saisie manuelle,
d'un scénario jury, d'un instrument de bord ou d'un flux externe.

```dart
enum TelemetryOrigin { demo, earth, inflight, env }

await provider.ingestFrom(const LocalDemoTelemetrySource());
// plus tard, sans toucher au moteur ni à l'UI :
// await provider.ingestFrom(NasaOpenDataTelemetrySource(endpoint: uri));
```

`NasaOpenDataTelemetrySource` est un **adaptateur à implémenter** (OSDR, HRP,
environnement radiatif). Il lève volontairement `UnimplementedError` : une démo
ne doit jamais dépendre du réseau. C'est le point d'accroche pour la source
NASA open data exigée par le concours.

---

## 6. Traçabilité avec le cahier des charges de la session « je veux démarrer… »

| Exigence de la session | État sur cette branche |
|---|---|
| Nom **ASTROCARE** partout | ✅ déjà le cas (`main.dart`, thème, `AstroStrings`, README) |
| Version finale **mobile** | ✅ mobile-first, breakpoints centralisés, gestes tactiles |
| Silhouette **rotative 360°** au lieu d'un statique | ✅ `rotating_digital_twin.dart` + passe de scan |
| Surveillance 360° démontrable | ✅ balisage des 6 régions + repère d'orientation |
| Surveillance des constantes vitales | ✅ moteur HRP existant |
| **Offline-first** avec stockage local | ✅ `SharedPreferences`, 150 relevés, file DSN |
| Bilan psychologique / sommeil | ✅ fatigue, sommeil, radar d'homéostasie |
| Alerte médicale SOS / protocoles | ✅ checklists FDF + scénarios critiques |
| Bilingue FR / EN | ✅ `AstroStrings`, bascule persistée |
| Source NASA open data | 🟡 frontière prête, adaptateur HTTP à écrire |
| Identifiant équipage `AC-01` (CDC) | 🟡 divergent : `ASTRO-084` / `PHOENIX-1` côté Flutter — à harmoniser avant le rendu |
| APK signé à version incrémentée | ✅ workflow `.github/workflows/build-apk.yml` (push sur `main`) |

Les deux points 🟡 sont les seuls écarts fonctionnels identifiés entre le cahier des
charges et le code. Ils sont volontairement laissés visibles plutôt que
corrigés silencieusement (ils touchent aux données de démo et au rendu).

---

## 7. Compatibilité entre branches

- `dev/teme-israel` part du même commit initial que `main` et
  `dev/tagne-julio` ; les deux commits de `dev/tagne-julio` ont été **reportés
  par cherry-pick**, donc l'arbre de fichiers était identique avant nos ajouts.
- Ajouts = **5 nouveaux fichiers** + modifications minimales (un import et un
  appel de widget dans `body_twin_screen.dart`, un `Wrap` et la grille dans
  `dashboard_screen.dart`, un point d'ingestion dans le provider, ce README).
- L'ancienne vue statique `digital_twin_painter.dart` est **conservée** pour ne
  rien casser chez les autres branches ; elle n'est plus référencée par l'écran.
- Conséquence : un `git merge dev/tagne-julio` ou un rebase ultérieur reste
  propre (pas de réécriture de fichiers tiers, pas de renommage, pas de
  changement de `pubspec.yaml` ni de `pubspec.lock`).

---

## 8. Lancer / vérifier

```bash
flutter pub get
flutter analyze
flutter test          # widget_test.dart + twin_projection_test.dart
flutter run           # téléphone / émulateur
flutter build apk --release
```

Le workflow GitHub Actions compile et publie l'APK à chaque push sur `main`
(`versionCode` incrémenté automatiquement, même signature si les secrets
`KEYSTORE_*` sont configurés). Les branches `dev/*` ne déclenchent pas de build.

> Le SDK Flutter n'est pas installé dans l'environnement où cette branche a
> été préparée : `flutter analyze` et `flutter test` doivent être exécutés en
> local ou en CI avant le merge vers `main`.

---

## 9. Limites assumées

- Les valeurs de télémétrie sont **simulées** (seed 24 h + 4 scénarios jury) ;
  aucune mesure instrumentale réelle n'est encore ingérée.
- Le stockage local est `SharedPreferences`, **non chiffré** : pour une vraie
  application médicale il faudra `flutter_secure_storage` / SQLCipher et une
  file de transmission sur disque.
- Pas de WebGL, pas de maillage 3D, pas de backend, pas d'authentification.
- La navigation reste une `BottomNavigationBar` sur tablette ; un
  `NavigationRail` est une évolution possible, pas un prérequis.
