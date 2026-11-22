# Nadir: One Last Dive

Jeu d'extraction et de survie abyssale solo (PvE) à la première personne, développé sous **Godot 4.7** (`Forward Plus` + `Jolt Physics`) pour Windows (Clavier/Souris).

## Documentation
- [Feuille de route & jalons](docs/ROADMAP.md)
- [Game Design Document (GDD)](docs/GDD.md)
- [Architecture du projet](docs/ARCHITECTURE.md)

## Validation & Lancement (CLI)
```powershell
# Recharger le cache des classes globales après ajout de script
godot_console --headless --path . --import

# Validation projet complète
godot --headless --path . --quit
```
