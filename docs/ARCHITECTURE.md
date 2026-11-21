# Architecture du Projet (Carte rapide)

> Index compact pour localiser les fichiers en 1 lecture sans scanner les répertoires. Mettre à jour à chaque ajout majeur.

## Répertoires
- `docs/` : [GDD.md](GDD.md) (vision, mécaniques, jalons) et ce fichier.
- `scenes/` : scènes `.tscn` du jeu (à créer lors du Jalon 1 Greybox).
- `scripts/` : logique GDScript strictement typée, découpée par domaine (`player/`, `systems/`, `world/`, `creatures/`, `ui/`, `data/`).
- `resources/` : données métier (`Resource` typées).
- `assets/` : modèles 3D, textures, sons (ne pas indexer par défaut).

## Scripts existants
- `scripts/player/diver_input.gd` (`DiverInput`, `RefCounted`) : lecture isolée de l'Input Map (`move_*`, `swim_up/down`, `sprint`, `interact`, `flashlight`, `pause`).
- `scripts/player/diver_controller.gd` (`DiverController`, `CharacterBody3D`) : contrôleur FPS de nage 3D libre, regard souris, inertie aquatique, lampe torche (`SpotLight3D`), signaux `interact_requested` et `flashlight_toggled`.

## Configuration clé
- `project.godot` : Godot 4.7, `Forward Plus`, `Jolt Physics`, typage strict (`untyped_declaration=2`, `unsafe_property_access=2`), Input Map 3D ZQSD/WASD/Flèches.
- `.agents/skills/godot-dev-workflow/SKILL.md` : skill de validation CLI, MCP et commit.
