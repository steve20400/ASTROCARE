# ASTROCARE

Application mobile tout-en-un de suivi sanitaire des astronautes en mission (NASA Challenge).

## Fonctionnalités principales
- Suivi des constantes vitales en temps réel (Fréquence cardiaque, SpO2, Température, Radiations)
- Mode Offline-First avec stockage local chiffré
- Bilan psychologique & suivi du sommeil
- Déclenchement d'alerte médicale d'urgence (SOS)
- Protocoles de premiers secours embarqués

## Build & Déploiement
Les APK Android sont compilés automatiquement via **GitHub Actions** à chaque push sur `main`.
Chaque build incrémente automatiquement le `versionCode` et conserve la même signature, permettant la mise à jour directe sur Android sans désinstallation.
