# Projet Godot 4 — Nadir: One Last Dive
- Moteur : Godot 4.7+ (GDScript strict, 3D, Forward Plus, Jolt Physics) | Cible v1 : Solo PvE, Windows, Clavier/Souris
- CLI : `godot_console --headless --path . --quit` (ou `godot --headless --path . --quit`)

## Règles impératives
- API Godot 4 uniquement, typage statique strict sur toutes variables, paramètres et retours.
- Scripts courts et modulaires (< 150 lignes) ; séparer lecture d'`Input`, logique métier et données (`Resource` typées).
- Ne pas modifier un `.tscn` si la scène est ouverte dans Godot.
- Après modification de script, valider avec `godot --headless --path . --quit` et corriger toute erreur avant de répondre.

## Économie de tokens & lecture efficace
- Ne jamais lire, lister ni indexer `.godot/`, `addons/`, `assets/`, `exports/`, `*.uid`, `*.import`.
- Lire `docs/ARCHITECTURE.md` en premier pour localiser un fichier sans scanner le dépôt.
- Cibler les lectures (`rg -n`, `StartLine`/`EndLine`) ; ne lire `docs/GDD.md` que pour cadrer un nouveau système ou le scope.
- Signaux typés pour découpler gameplay, UI et audio ; greyboxing avant assets lourds.

## Orchestration d'équipe (Swarm)
- **Mode direct (1 agent)** pour les ajustements ciblés (1–2 fichiers, réglages rapides, bug simple).
- **Lancer automatiquement le Swarm** dès qu'une demande touche plusieurs domaines indépendants, en n'activant que les rôles utiles avec territoires disjoints (`workspace: "share"` pour auteurs, `inherit` pour QA) et en leur demandant de lire leur skill dans `.agents/skills/` :
  - `systems-dev` (`godot-gameplay-systems`) | `ui-dev` (`scupea-ui-design`) | `world-dev` (`abyssal-world-design`) | `qa-verifier` (`godot-dev-workflow`).
