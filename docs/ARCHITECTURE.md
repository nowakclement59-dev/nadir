# Architecture du Projet (Carte rapide)

> Index compact pour localiser les fichiers en 1 lecture sans scanner les répertoires. Mettre à jour à chaque ajout majeur.

## Répertoires
- `docs/` : [ROADMAP.md](ROADMAP.md) (suivi des jalons), [GDD.md](GDD.md) (vision & mécaniques) et ce fichier.
- `scenes/` : scènes `.tscn` du jeu :
  - `scenes/player/diver.tscn` : scène autonome du plongeur (`CharacterBody3D`, `DiverController`, `HeadPivot`, `Camera3D`, `SpotLight3D`).
  - `scenes/player/diver_showcase.tscn` : scaphandre 3D interactif sur socle SCUPEA pour l'aperçu en station (`DiverShowcase`).
  - `scenes/ui/dive_hud.tscn` : HUD de plongée (`DiveHUD` : boussole, profondeur, radar sonar carré, barres O2/santé, inventaire, shader suffocation et écran de mort).
  - `scenes/ui/station_ui.tscn` : terminal de station à 3 onglets (`StationUI` : Accueil/Loadout/Skins, Améliorations, Terminal d'Échange Orbital).
  - `scenes/world/station_hub.tscn` : scène principale — baie pressurisée 3D avec vitre abyssale, terminal physique et plongeur en attente (`StationHubController`).
  - `scenes/world/test_abyss.tscn` : bassin greybox de test (brouillard abyssal, lampe, repères radar, débris `LootPickup`, sas `ExtractionPod`, `DiveSession`, `OxygenSystem`, `HealthSystem`, `InventorySystem`).
- `scripts/` : logique GDScript strictement typée, découpée par domaine (`player/`, `systems/`, `world/`, `creatures/`, `ui/`, `data/`).
- `shaders/` : shaders GLSL Godot (`suffocation_overlay.gdshader`, `visor_module.gdshader`).
- `resources/` : données métier (`Resource` typées) :
  - `resources/loot/` : `alloy_scrap.tres`, `data_core.tres`, `bio_sample.tres`.
  - `resources/upgrades/` : `oxygen_tank.tres`, `hydro_fins.tres`, `sonar_module.tres`, `trade_terminal.tres`.
  - `resources/trade/` : `o2_canister_offer.tres`, `alloy_pack_offer.tres`, `data_core_offer.tres`, `stealth_skin_offer.tres`.
- `assets/` : modèles 3D, textures, sons (ne pas indexer par défaut).

## Scripts existants
- `scripts/data/loot_item_data.gd` (`LootItemData`, `Resource`) : définition typée d'un objet/débris (id, nom, valeur `¤`, coût en slots, couleur).
- `scripts/data/upgrade_data.gd` (`UpgradeData`, `Resource`) : définition typée d'une amélioration/réparation (coûts matériaux par niveau et crédits `¤`).
- `scripts/data/trade_offer_data.gd` (`TradeOfferData`, `Resource`) : offre d'achat en `¤` via le Terminal d'Échange Orbital.
- `scripts/data/game_catalog.gd` (`GameCatalog`, `RefCounted`) : chargement centralisé des loots, améliorations, offres et skins.
- `scripts/player/diver_input.gd` (`DiverInput`, `RefCounted`) : lecture isolée de l'Input Map (`move_*`, `swim_up/down`, `sprint`, `interact`, `flashlight`, `hub_menu`, `pause`).
- `scripts/player/diver_controller.gd` (`DiverController`, `CharacterBody3D`) : contrôleur FPS de nage 3D libre, regard souris, `InteractionRay` (`RayCast3D`), lampe torche (`SpotLight3D`), signaux `interact_requested` et `flashlight_toggled`.
- `scripts/systems/save_store.gd` (`SaveStore`, `RefCounted`) : sérialisation/désérialisation JSON sécurisée dans `user://`.
- `scripts/systems/game_state.gd` (`GameStateService`, Autoload `GameState`, `Node`) : stock de base, crédits `¤`, améliorations, skins, loadout et terminal d'échange.
- `scripts/systems/oxygen_system.gd` (`OxygenSystem`, `Node`) : réserve d'O2, drainage accéléré au sprint, progression de suffocation et signal `suffocated`.
- `scripts/systems/health_system.gd` (`HealthSystem`, `Node`) : points de vie, dégâts/soin et signal `died`.
- `scripts/systems/inventory_system.gd` (`InventorySystem`, `Node`) : cargo à capacité limitée en slots, signaux `inventory_changed` et `inventory_full`.
- `scripts/ui/visor_frame.gd` (`VisorFrame`, `Control`) : contour discret et télémétrie de bus modulaire de la visière du scaphandre.
- `scripts/ui/module_bezel.gd` (`ModuleBezel`, `Control`) : châssis biseauté réutilisable pour modules plug-in du HUD.
- `scripts/ui/compass_bar.gd` (`CompassBar`, `Control`) : boussole horizontale dynamique (`NAV // GYRO-1`).
- `scripts/ui/radar_display.gd` (`RadarDisplay`, `Control`) : radar sonar orienté joueur avec balayage actif (`SONAR // BATHYS-S1`).
- `scripts/ui/dive_hud.gd` (`DiveHUD`, `CanvasLayer`) : contrôleur d'affichage du HUD de plongée, shader suffocation et écran de mort.
- `scripts/ui/station_ui_helpers.gd` (`StationUIHelpers`, `RefCounted`) : styles et widgets partagés de l'interface Station SCUPEA.
- `scripts/ui/station_tab_builders.gd` (`StationTabBuilders`, `RefCounted`) : construction des onglets Accueil/Loadout/Skins, Améliorations et Terminal d'Échange.
- `scripts/ui/station_ui.gd` (`StationUI`, `CanvasLayer`) : contrôleur des 3 onglets de la station.
- `scripts/world/diver_showcase.gd` (`DiverShowcase`, `Node3D`) : aperçu 3D rotatif du scaphandre (idle, skins, équipements visuels).
- `scripts/world/station_hub_controller.gd` (`StationHubController`, `Node3D`) : orchestrateur de la baie 3D de station (rotation souris, état terminal, lancement plongée).
- `scripts/world/loot_pickup.gd` (`LootPickup`, `Area3D`) : objet interactif ramassable associé à un `LootItemData`.
- `scripts/world/extraction_pod.gd` (`ExtractionPod`, `Area3D`) : zone d'interaction du sas d'extraction.
- `scripts/world/dive_session.gd` (`DiveSession`, `Node3D`) : orchestrateur de plongée reliant plongeur, systèmes vitaux, loadout, extraction et retour en station.

## Configuration clé
- `project.godot` : Godot 4.7, `Forward Plus`, `Jolt Physics`, typage strict (`untyped_declaration=2`, `unsafe_property_access=2`), `run/main_scene="res://scenes/world/station_hub.tscn"`.
- `.agents/skills/godot-dev-workflow/SKILL.md` : skill de validation CLI, MCP et commit.
