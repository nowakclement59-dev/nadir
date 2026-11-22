---
name: godot-dev-workflow
description: Procédures de validation Godot 4.7, utilisation du MCP Godot, règles de sécurité .tscn et checklist de commit pour ce projet.
---

# Godot Dev Workflow (Nadir)

## 1. Validation CLI Godot 4.7 (Windows)
Toujours utiliser `--headless` et exécuter depuis la racine du projet :

```powershell
# Recharger le cache de classes globales (à faire après ajout/renommage de class_name)
godot_console --headless --path . --import

# Vérifier un script spécifique (syntaxe + typage strict)
godot_console --headless --path . --check-only --script res://scripts/player/diver_controller.gd

# Validation globale du projet avant de répondre
godot --headless --path . --quit
```

- Si un nouveau `class_name` provoque `Could not find type ...`, exécuter `--import` avant `--check-only`.
- Sous Windows, `godot_console` affiche stdout/stderr complet, contrairement à `godot.exe`.

## 2. Utilisation du MCP Godot (`godot`)
- **Quand utiliser le MCP** : lancer l'éditeur, exécuter le projet et capturer les logs runtime/debug, inspecter ou créer des nœuds/scènes de façon structurée.
- **Quand éditer directement** : éditer les fichiers `.gd`, `.md` ou `project.godot` directement via les outils fichiers (plus rapide et économe en tokens).
- **Sécurité `.tscn`** : ne jamais éditer un `.tscn` à la main si la scène est ouverte dans l'éditeur Godot.

## 3. Checklist avant commit Git
1. Valider les scripts modifiés (`godot --headless --path . --quit`).
2. Mettre à jour `docs/ARCHITECTURE.md` si un script/dossier/scène majeur est ajouté ou déplacé.
3. Vérifier `git status -s` pour s'assurer qu'aucun fichier temporaire ou binaire indésirable n'est inclus.

## 4. Validation QA Runtime (`qa-verifier`)
1. Écrire les scripts temporaires `extends SceneTree` dans le dossier scratch (hors dépôt) et exécuter les assertions dans `_process()` à partir de la frame 1 (car `_ready()` des nœuds ajoutés ne s'exécute pas dans `_init()`).
2. Rediriger `GameStateService.save_path` vers un fichier temporaire (`user://save_*_test.json`) et le supprimer via `reset_progress(true)` en fin de test.
3. Vérifier que tous les scripts neufs/modifiés respectent strictement `< 150` lignes.
