# Feuille de Route — Nadir: One Last Dive

> Suivi officiel des jalons et étapes de développement du projet sous **Godot 4.7** (`Forward Plus` / `Jolt Physics`). Voir aussi [GDD.md](GDD.md) et [ARCHITECTURE.md](ARCHITECTURE.md).

## Vue d'ensemble

| Jalon | Intitulé | Statut |
| --- | --- | --- |
| **Jalon 0** | Socle technique & outils | Terminé |
| **Jalon 1** | Prototype Greybox de la boucle minimale | Terminé |
| **Jalon 2** | Hub, Persistance & Reconstruction (v0) | En cours |
| **Jalon 3** | Danger, Furtivité & Stratagèmes | À venir |
| **Jalon 4** | Vertical Slice (1er secteur + DA étalonnée) | À venir |
| **Jalon 5** | Démo Steam → Accès Anticipé → 1.0 | À venir |

---

## Détail des Jalons & Étapes

### Jalon 0 — Socle technique & outils
- [x] Arborescence du dépôt, typage statique strict GDScript (`untyped_declaration=2`, `unsafe_property_access=2`) et Input Map 3D (`ZQSD`/`WASD`/Flèches).
- [x] Configuration Godot 4.7 (`Forward Plus`, `Jolt Physics`), intégration MCP Godot et workflow de validation CLI.
- [x] Rédaction du [GDD.md](GDD.md), [ARCHITECTURE.md](ARCHITECTURE.md) et dépôt GitHub.

### Jalon 1 — Prototype Greybox de la boucle minimale
- [x] **Étape 1** : Contrôleur de plongeur 3D (`DiverController`, nage libre + lampe torche) et bassin de test greybox avec brouillard abyssal.
- [x] **Étape 2** : Systèmes vitaux (`OxygenSystem`, `HealthSystem`), shader de suffocation progressif, et HUD modulaire de visière **SCUPEA** (`NAV // GYRO-1`, `SONAR // BATHYS-S1`, `SCUPEA // MK-IV`).
- [x] **Étape 3** : Loot typé (`LootItemData`), cargo 6 slots (`InventorySystem`), interaction `[E]`, sas d'extraction (`ExtractionPod`), bilan de run et lisibilité HUD.

### Jalon 2 — Hub, Persistance & Reconstruction (v0) *(en cours)*
- [x] **Étape 1 — Persistance & Économie** : Autoload `GameState` (sauvegarde JSON `user://save_nadir.json`), ressources `UpgradeData`, transfert du butin extrait vers le stock de base et application automatique des améliorations au lancement de plongée.
- [ ] **Étape 2 — Interface rapide du Hub & Échange** : Écran Hub accessible via `Tab` et après extraction/mort ; craft des 3 améliorations concrètes (`Réservoir O2`, `Palmes Hydro-Jet`, `Module Sonar BATHYS` avec évolution visuelle du HUD) et réparation du **Terminal d'Échange Orbital** (vente de surplus contre `¤`).
- [ ] **Étape 3 — Première salle de base 3D visitable** : Scène 3D greybox de la station (sas de départ `[E]`, établi d'équipement, terminal d'échange visuellement réparable, accès rapide `Tab` conservé).

### Jalon 3 — Danger, Furtivité & Stratagèmes
- [ ] **Étape 1** : 1er prédateur abyssal avec IA à états (patrouille, détection bruit/lampe, poursuite, dégâts et récupération).
- [ ] **Étape 2** : Furtivité (impact de la lampe et du sprint sur l'aggro) et 1er stratagème craftable (leurre lumineux/sonore).
- [ ] **Étape 3** : 1er outil/arme avancé de fin de palier et 1er obstacle vivant colossal déplaçable par gadget rare.

### Jalon 4 — Vertical Slice (1er secteur complet & test DA)
- [ ] **Étape 1** : Kit d'architecture modulaire et construction du 1er secteur abyssal travaillé (aile détruite + brèches/loot variables).
- [ ] **Étape 2** : Étalonnage de la Direction Artistique (textures PBR, *marine snow*, bioluminescence, *decals*, éclairage volumétrique).
- [ ] **Étape 3** : Audio spatialisé sous-marin et premiers journaux / boîtes noires narratifs.

### Jalon 5 — Démo Steam → Accès Anticipé → 1.0
- [ ] **Étape 1** : Menus complets (paramètres graphiques/audio/contrôles), intégration `GodotSteam` (succès, Steam Cloud).
- [ ] **Étape 2** : Démo publique (cible Steam Next Fest) et équilibrage sur retours joueurs.
- [ ] **Étape 3** : Extension par nouveaux secteurs abyssaux, créatures, gadgets et ailes de la base.
