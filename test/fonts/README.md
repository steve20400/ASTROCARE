# Polices de test

`Roboto-Regular.ttf` est utilisée uniquement par `test/layout_overflow_test.dart`.

Les tests widget de Flutter dessinent le texte avec une police de substitution
(Ahem) dont les glyphes sont beaucoup plus larges que ceux d'une police réelle :
tout écran paraît alors déborder. Charger Roboto dans le test reproduit les
conditions d'un appareil et rend la mesure de débordement fiable.

Licence : Apache 2.0 (police Roboto, Google).
