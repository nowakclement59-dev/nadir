---
name: abyssal-world-design
description: Métrique 3D, presets d'éclairage/brouillard et règles de construction de scènes Godot 4.7 pour world-dev.
---

# Abyssal World Design (`world-dev`)

## 1. Sécurité `.tscn` & Assemblage
- **Règle absolue** : ne jamais modifier un `.tscn` à la main si cette scène est ouverte dans l'éditeur Godot. En cas de doute, créer de nouvelles scènes ou instancier dynamiquement par script.
- Relier scène et systèmes uniquement via `@export` typés et signaux ; ne pas mélanger de logique métier lourde dans les nœuds de géométrie.
- Vérifier chaque `SubResource(...)` et `ExtResource(...)` dans les `.tscn` générés à la main avant de commiter.

## 2. Contraste d'ambiances validé
- **Secteurs abyssaux (`test_abyss.tscn`)** :
  - `ambient_light_energy = 0.3`, `AbyssSun.light_energy = 0.12`
  - `fog_density = 0.05`, `volumetric_fog_density = 0.038`, `volumetric_fog_emission_energy = 0.25`
  - Lampe torche joueur : `spot_angle = 48.0`, `spot_range = 42.0`, `light_energy = 8.5`, `spot_attenuation = 1.2`
- **Intérieurs pressurisés (`station_hub.tscn`, `base_interior.tscn`)** :
  - Pas de brouillard dense intérieur ; éclairage chaleureux (`OmniLight3D` ambre/blanc) + accents cyan SCUPEA pour créer un contraste immédiat de soulagement après extraction.
  - Grandes baies vitrées ouvrant sur les fonds abyssaux pour rappeler l'environnement océanique.

## 3. Métrique, Radar & Optimisation 3D
- **Échelle joueur** : hauteur debout `1.75 m`, yeux à `y = 1.60 m`, rayon `0.35 m`. Prévoir des couloirs/ouvertures d'au moins `2.5–4.0 m` de large (grille modulaire cible `4×4 m`).
- **Groupes radar 3D** : `radar_pod` (sas d'extraction, losange cyan) et `radar_poi` (points d'intérêt/loot, point émeraude).
- **Performance** : privilégier `MultiMeshInstance3D` pour le set dressing répétitif (rochers, flore, débris) et réserver le détail fin aux zones de gameplay (greyboxing avant assets lourds).
