# Projet Godot 4
- Moteur : Godot 4.7+ (Standard / GDScript, 3D, Forward Plus, Jolt Physics)
- CLI : `godot` (toujours utiliser `--headless` pour valider ; sous Windows `godot_console --headless` affiche la sortie standard complète)
- Cible v1 : Solo PvE, Windows, Clavier/Souris (voir `docs/GDD.md`)

## Règles impératives
- Utiliser uniquement les API Godot 4 et le typage statique strict sur toutes les variables et fonctions.
- Ne jamais lire, lister ni indexer `.godot/`, `addons/` ou `assets/` sauf demande explicite.
- Garder des scripts courts et modulaires ; séparer les entrées joueur de la logique métier.
- Ne pas modifier un fichier `.tscn` si la scène est ouverte dans Godot.
- Après modification de script, valider avec `godot --headless --path . --quit` et corriger les erreurs avant de répondre.

## Conventions d'architecture du projet
- **Vision & scope** : se référer à `docs/GDD.md` avant d'introduire de nouveaux systèmes.
- **Organisation des scripts** : regrouper par domaine dans `scripts/` (`player/`, `systems/`, `world/`, `creatures/`, `ui/`, `data/`).
- **Données métier** : privilégier des `Resource` typées dans `resources/` (objets, recettes, améliorations de base, tables de loot) plutôt que des dictionnaires non typés.
- **Découplage** : utiliser les signaux Godot typés pour communiquer entre gameplay, UI et audio ; garder la lecture d'`Input` isolée dans des classes dédiées.
- **Prototypage** : privilégier le greyboxing (primitives/CSG) pour valider le gameplay avant l'intégration d'assets lourds.
