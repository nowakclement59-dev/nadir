# Architecture du Projet (Carte rapide)

> Index compact pour localiser les fichiers en 1 lecture sans scanner les répertoires. Mettre à jour à chaque ajout majeur.

## Répertoires
- `docs/` : [GDD.md](GDD.md) (vision, mécaniques, jalons) et ce fichier.
- `scenes/` : scènes `.tscn` du jeu :
  - `scenes/player/diver.tscn` : scène autonome du plongeur (`CharacterBody3D`, `DiverController`, `HeadPivot`, `Camera3D`, `SpotLight3D`).
  - `scenes/ui/dive_hud.tscn` : HUD de plongée (`DiveHUD` : boussole, profondeur, radar sonar carré, barres O2/santé, inventaire, shader suffocation et écran de mort).
  - `scenes/world/test_abyss.tscn` : bassin greybox de test (brouillard abyssal, lampe, repères radar, `DiveSession`, `OxygenSystem`, `HealthSystem`).
- `scripts/` : logique GDScript strictement typée, découpée par domaine (`player/`, `systems/`, `world/`, `creatures/`, `ui/`, `data/`).
- `shaders/` : shaders GLSL Godot (`suffocation_overlay.gdshader`, `visor_module.gdshader`).
- `resources/` : données métier (`Resource` typées).
- `assets/` : modèles 3D, textures, sons (ne pas indexer par défaut).

## Scripts existants
- `scripts/player/diver_input.gd` (`DiverInput`, `RefCounted`) : lecture isolée de l'Input Map (`move_*`, `swim_up/down`, `sprint`, `interact`, `flashlight`, `pause`).
- `scripts/player/diver_controller.gd` (`DiverController`, `CharacterBody3D`) : contrôleur FPS de nage 3D libre, regard souris, inertie aquatique, lampe torche (`SpotLight3D`), signaux `interact_requested` et `flashlight_toggled`.
- `scripts/systems/oxygen_system.gd` (`OxygenSystem`, `Node`) : réserve d'O2, drainage accéléré au sprint, progression de suffocation et signal `suffocated`.
- `scripts/systems/health_system.gd` (`HealthSystem`, `Node`) : points de vie, dégâts/soin et signal `died`.
- `scripts/ui/visor_frame.gd` (`VisorFrame`, `Control`) : contour discret et télémétrie de bus modulaire de la visière du scaphandre.
- `scripts/ui/module_bezel.gd` (`ModuleBezel`, `Control`) : châssis biseauté réutilisable pour modules plug-in du HUD.
- `scripts/ui/compass_bar.gd` (`CompassBar`, `Control`) : boussole horizontale dynamique (`NAV // GYRO-1`).
- `scripts/ui/radar_display.gd` (`RadarDisplay`, `Control`) : radar sonar orienté joueur avec balayage actif (`SONAR // BATHYS-S1`).
- `scripts/ui/dive_hud.gd` (`DiveHUD`, `CanvasLayer`) : contrôleur d'affichage du HUD, shader de suffocation et écran de mort.
- `scripts/world/dive_session.gd` (`DiveSession`, `Node3D`) : orchestrateur reliant plongeur, oxygène, santé et HUD.

## Configuration clé
- `project.godot` : Godot 4.7, `Forward Plus`, `Jolt Physics`, typage strict (`untyped_declaration=2`, `unsafe_property_access=2`), Input Map 3D ZQSD/WASD/Flèches.
- `.agents/skills/godot-dev-workflow/SKILL.md` : skill de validation CLI, MCP et commit.
