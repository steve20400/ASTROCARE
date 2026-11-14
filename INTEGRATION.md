# Intégration des deux branches — état et marche à suivre

## Le problème constaté

`origin/main` ne contient que le premier commit (`a85aaf5`). Chacun y a ensuite
poussé **sa propre version** des mêmes fichiers :

| Fichier | `dev/teme-israel` | `dev/tagne-julio` |
|---|---|---|
| `lib/providers/astrocare_provider.dart` | créé | créé |
| `lib/ui/theme.dart` | créé | créé |
| `lib/ui/screens/dashboard_screen.dart` | créé | créé |
| `lib/ui/screens/body_twin_screen.dart` | créé | créé |
| `lib/ui/screens/synergies_screen.dart` | créé | créé |
| `lib/main.dart` | dérivé du tronc | dérivé du tronc |
| `test/widget_test.dart` | créé | créé |

Git ne peut donc pas fusionner : ce sont des conflits **add/add**, c'est-à-dire
du travail dupliqué, pas des lignes concurrentes. `main` ne contient qu'une
lignée commune (`f736614`, `781dc94`, `d64d4be`, `8b8c47e`).

## Ce qui a été fait

Branche `integration/astrocare`, construite depuis `main` :

1. fusion de `dev/teme-israel` ; conflits tranchés ainsi :
   - `main.dart` → **tronc conservé** (écran de démarrage + `MainNavigationShell`) ;
     ta branche n'apportait rien d'autre sur ce fichier ;
   - `theme.dart`, `astrocare_provider.dart`, `body_twin_screen.dart`,
     `dashboard_screen.dart`, `widget_test.dart` → **version teme conservée**
     (elle ajoute le jumeau 360°, la frontière télémétrique, `responsive.dart`) ;
   - `gradle-wrapper.properties` → **9.3.1 conservé** (correctif de build de `main`).
2. reprise de l'apport propre à Julio : palette NASA officielle + heatmap
   omique GeneLab OSD-288. Vérifié avant de fusionner : **tous les membres
   `AstroTheme` utilisés par son code existent** dans ta version du thème, donc
   aucun conflit de fond.
3. `flutter analyze` : aucune erreur. `flutter test` : **22/22**.

## Le vrai défaut trouvé en chemin

Aucun test ne mesurait la **mise en page**. En rendant les écrans sur un
téléphone de 390 dp avec de vraies métriques de police, 11 débordements
apparaissaient — dont 5 barres de titre qui poussaient les boutons hors écran.
À 320 dp (petits téléphones d'entrée de gamme), 4 écrans débordaient encore.

C'est corrigé, et verrouillé par `test/layout_overflow_test.dart` : 5 écrans ×
2 largeurs, avec Roboto chargée. Ces corrections sont dans `integration/astrocare`
et à reporter dans vos branches.

## Marche à suivre

Ne fusionnez plus vos branches entre elles. Le tronc devient `integration/astrocare`.

**Julio** doit repartir de cette branche, car son code y est déjà intégré :

```bash
git checkout integration/astrocare        # à récupérer d'abord si elle est distante
git checkout -B dev/tagne-julio
```

**Toi** : ta branche est intégrée, mais elle a aussi vieilli (pas de correctif
Gradle, pas de palette NASA, pas de heatmap). Repars du même point :

```bash
git fetch origin
git checkout integration/astrocare
git checkout -B dev/teme-israel
```

Ensuite, la règle qui évite la récidive : **une fonctionnalité = un fichier
nouveau**, jamais une réécriture d'un fichier existant. Les conflits add/add
qu'on vient de payer viennent tous de là.
