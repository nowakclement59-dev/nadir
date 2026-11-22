---
name: godot-gameplay-systems
description: Conventions d'architecture gameplay, typage strict Godot 4.7, couches de collision et accès Autoload pour systems-dev.
---

# Godot Gameplay Systems (`systems-dev`)

## 1. Architecture & Typage strict
- Respecter `untyped_declaration=2` et `unsafe_property_access=2` sur **100 %** des variables, paramètres, retours et boucles `for x: Type in ...`.
- Typer explicitement toute donnée issue d'un `Dictionary` ou de `JSON.parse_string(...)` avant d'y accéder.
- Séparer strictement : lecture d'`Input` (`DiverInput`, `RefCounted`), logique métier (`Node` découplés via `signal` typés), et données (`Resource` typées dans `scripts/data/` + `resources/`).
- Garder chaque script **strictement `< 150` lignes** : extraire des helpers `RefCounted` (`SaveStore`, `GameCatalog`, etc.) dès qu'un script approche ~135 lignes.

## 2. Accès Autoload `GameState`
- **Toujours** accéder à l'état persistant via `var state: GameStateService = GameStateService.from(self)` (avec test `if state != null:`).
- **Ne jamais** déclarer `class_name GameState` ni référencer directement l'identifiant global `GameState.*` dans les scripts (cela fait échouer `godot_console --headless --check-only --script ...`).

## 3. Table officielle des `collision_layer` (Jolt Physics)
- **Layer `1`** : Géométrie solide, murs/sols (`StaticBody3D`) et contrôleurs joueur (`DiverController`, `StationWalker` avec `collision_mask = 1`).
- **Layer `2`** : Zones interactives `Area3D` (`LootPickup`, `ExtractionPod`, `BaseInteractable`) avec `collision_mask = 0`, ciblées par `InteractionRay` (`RayCast3D`, `collide_with_areas = true`, `collision_mask = 2` ou `3`).
- **Layer `3`** *(Jalon 3+)* : Créatures, hurtboxes et zones de détection prédateurs.

## 4. Game feel validé (à préserver)
- Nage 3D (`DiverController`) : `swim_speed = 5.5`, `swim_acceleration = 10.0`, `water_drag = 5.0` (changements de direction réactifs).
- Marche station (`StationWalker`) : `walk_speed = 4.2`, `gravity = 14.0`, capsule `radius = 0.35`, `height = 1.75`.
