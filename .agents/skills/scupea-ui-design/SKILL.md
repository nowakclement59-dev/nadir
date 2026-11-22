---
name: scupea-ui-design
description: Charte visuelle SCUPEA, règles de lisibilité, glyphes validés et bonnes pratiques d'interface Godot 4.7 pour ui-dev.
---

# SCUPEA UI Design (`ui-dev`)

## 1. Palette & Esthétique validées
- **Fonds de panneaux / cartes** : bleu marine translucide `Color(0.012, 0.032, 0.062, 0.45)` à `0.72` (jamais de panneau noir opaque `Color(0, 0, 0, 0.9)`).
- **Bordures techniques** : cyan fin `Color(0.24, 0.84, 1.0, 0.32..0.42)` ; utiliser `ModuleBezel` (`scripts/ui/module_bezel.gd`) + scanlines (`shaders/visor_module.gdshader`) sur les fenêtres principales.
- **États & accents** :
  - Nominal / En ligne : émeraude `Color(0.25, 0.96, 0.68, 1.0)`
  - Info / Actif : cyan `Color(0.24, 0.92, 1.0, 1.0)`
  - Alerte O₂ bas / Hors service : ambre doux `Color(1.0, 0.68, 0.25, 1.0)`
  - Hypoxie / Critique : rouge doux `Color(1.0, 0.35, 0.35, 1.0)`

## 2. Lisibilité & Typographie
- **Texte principal** : blanc / blanc glacé **100 % opaque** (`Color(0.96, 0.99, 1.0, 1.0)`), jamais de texte doré/jaune.
- **Superposition sur scène 3D** : ajouter `outline_size = 1` avec `font_outline_color = Color(0, 0.01, 0.03, 0.55..0.6)` pour garantir le contraste sans encadré noir.
- **Monnaie & glyphes sûrs** : toujours utiliser **`¤`** (`U+00A4`) ; éviter `₵`, `◈` et `★` (absents ou non garantis dans `ThemeDB.fallback_font`).
- **Chaînes formatées GDScript** : toujours doubler le signe pourcent (`%%`) dans le format de l'opérateur `%` (ex. `"+30%%"`).

## 3. Identité plug-in & Résolutions
- Conserver les en-têtes modulaires in-universe : `SCUPEA // MK-IV`, `NAV // GYRO-1`, `SONAR // BATHYS-S1..S4`, `SCUPEA // STATION NADIR-01`.
- Mettre `mouse_filter = 2` (Ignore) sur tous les calques visuels (`ModuleBezel`, `Scanlines`, conteneurs racines transparents) afin de ne jamais bloquer les clics ou la caméra.
- Utiliser des ancres/conteneurs responsives (`canvas_items` / `expand`) compatibles 1080p, 1440p et 4K.
