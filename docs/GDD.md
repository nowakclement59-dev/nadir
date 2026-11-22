# Game Design Document (GDD) — Projet Abyssal (Nom de code à définir)

> Document vivant de référence pour le développement du jeu sous **Godot 4.7** (3D / Forward+ / Jolt Physics), à destination d'une sortie **Steam (Windows)**.

---

## 1. Pitch & Vision
Dans un futur lointain, une méga-corporation interplanétaire exploite une **planète océanique gigantesque** aux fonds marins titanesques pour en extraire de nouvelles ressources et connaissances scientifiques.

À la suite d'une **catastrophe majeure**, une aile entière de la station sous-marine est détruite. Seul survivant, le joueur incarne un **scientifique** contraint de plonger dans des abysses obscurs et extrêmement hostiles pour récupérer débris, ressources rares, données et moyens de survie afin de **reconstruire progressivement la base** — et découvrir l'origine de la catastrophe.

- **Genre** : Extraction solo PvE / Survie abyssale à la 1re personne (FPS 3D).
- **Inspirations clés** : *Subnautica* (exploration abyssale, vulnérabilité, progression technologique), *Escape from Tarkov / Pacific Drive / Dredge* (boucle d'extraction risque/récompense et hub à améliorer).
- **Horizon** : Projet ambitieux au long cours (1 an et plus), découpé en jalons jouables (**Greybox → Vertical Slice → Démo Steam → Accès Anticipé → 1.0**).

---

## 2. Piliers de Design

1. **Tension abyssale & Extraction à enjeux**
   - Expéditions courtes et rejouables depuis une capsule/sas d'extraction.
   - Gestion critique de l'oxygène, de la pression/profondeur, de la visibilité et de l'inventaire.
   - En cas d'échec (mort), le butin de la plongée est perdu : savoir quand faire demi-tour est au cœur du gameplay.

2. **Prédateurs redoutables & courbe de puissance méritée**
   - Les prédateurs abyssaux sont **très difficiles à tuer, mais pas impossibles**.
   - En début de partie, le joueur est vulnérable : **furtivité, ruse, gestion du bruit/lumière et stratagèmes** (leurres, sonar, répulsifs) sont essentiels.
   - En progressant (résistances de combinaison, armes et gadgets avancés), affronter et abattre un prédateur devient un **défi risqué mais atteignable**, récompensé par des matériaux rares (ex. trophées de léviathan mutant).

3. **Reconstruction de la Base = Méta-progression concrète**
   - Chaque ressource ramenée sert à réparer et améliorer les ailes/systèmes de la base (énergie, atelier, labo, sonar, armurerie, sas).
   - Chaque amélioration renforce concrètement la qualité et la portée des plongées suivantes, tout en faisant avancer le fil narratif.
   - **Double accès au Hub** :
     - **Interface rapide (1 touche)** pour enchaîner les runs sans friction (équipement, craft, réparations, lancement de plongée).
     - **Accès à la base 3D explorable** pour se déplacer librement, observer la reconstruction visuelle, découvrir des détails d'histoire, journaux, indices et easter eggs.

4. **Secteurs reconnaissables + Variabilité dynamique**
   - Les secteurs abyssaux sont **façonnés à la main** (identifiables, mémorables, lisibles à grande échelle).
   - D'une plongée à l'autre, **débris, brèches et tables de loot varient** — tout en restant thématiquement liés aux biomes et repaires (ex. repaire de léviathan → matériaux rares spécifiques).
   - **Obstacles vivants dynamiques** : des créatures colossales (parfois pacifiques/neutres) peuvent bloquer certains passages selon les runs, et être contournées ou déplacées grâce à des objets/gadgets rares craftés.

---

## 3. Boucle de Gameplay

```
[BASE / HUB]
  ├─ Interface rapide OU exploration 3D de la base
  ├─ Reconstruire un module / Crafter combinaison, gadgets, armes
  ├─ Sélectionner un secteur abyssal & préparer son chargement
  ▼
[PLONGÉE D'EXTRACTION]
  ├─ Nage 3D libre (1re personne) depuis le sas/capsule
  ├─ Gérer oxygène, profondeur, lumière, bruit et orientation
  ├─ Observer les obstacles dynamiques, éviter ou piéger les prédateurs
  ├─ Fouiller débris / épaves / repaires (risque vs récompense)
  ▼
[EXTRACTION]
  ├─ Retour vivant au sas → Butin sécurisé, progrès narratif & base améliorée
  └─ Mort dans les abysses → Perte du butin de la run, retour à la base
```

---

## 4. Direction Artistique & Pipeline Solo
- **Style visuel** : **Semi-réaliste stylisé** (façon *Subnautica* revisité avec une identité propre), fortement appuyé par l'atmosphère abyssale (brouillard volumétrique, obscurité, bioluminescence, particules, faisceau de lampe torche, silhouettes monumentales).
- **Identité matérielle in-universe** : **SCUPEA** (`SCUPEA // MK-IV`), néo-marque professionnelle d'équipements abyssaux (ordinateur de plongée/HUD, combinaisons, capteurs, terminaux de station).
- **HUD de visière modulaire (plug-in)** : l'interface est projetée sur la visière du scaphandre sous forme de modules indépendants identifiés par leur modèle/version (`NAV // GYRO-1`, `SONAR // BATHYS-S1`, `SCUPEA // MK-IV [MOD-01]`) ; améliorer un composant en base fera évoluer visuellement son interface et ses capacités en jeu.
- **Méthode pragmatique en solo** :
  1. **Phase Greybox** : prototyper 100 % des mécaniques avec des formes simples (`CSG` / primitives) pour valider le *game feel* avant toute production lourde d'assets.
  2. **Test d'étalonnage DA** : produire 1 petit diorama (1 fragment d'épave + 1 créature + éclairage/fog) pour calibrer le niveau de détail réaliste soutenable en solo.

---

## 5. Cibles Techniques & Architecture
- **Moteur** : Godot 4.7+ (GDScript à typage statique strict, `Forward Plus`, `Jolt Physics`).
- **Plateforme v1** : **Windows uniquement**, **Clavier / Souris** (support manette et multi-OS éventuellement post-v1).
- **Mode de jeu v1** : **Solo pur (PvE)** afin de sécuriser l'architecture et la livraison. La séparation stricte **Entrées / Logique métier / Données (`Resource`)** est maintenue dès le début pour garder le code propre et évolutif.
- **Steam (prévu en aval)** : sauvegardes propres dans `user://`, gestion des résolutions/fenêtrage, succès et intégration `GodotSteam` au stade démo/pré-sortie.

### Contrôles Clavier/Souris (v1)
| Action Input Map | Touches | Rôle |
| --- | --- | --- |
| `move_forward` / `move_backward` | `Z`/`W`/`Haut`, `S`/`Bas` | Avancer / Reculer (selon le regard en nage) |
| `move_left` / `move_right` | `Q`/`A`/`Gauche`, `D`/`Droite` | Déplacement latéral |
| `swim_up` / `swim_down` | `Espace`, `Ctrl`/`C` | Monter / Plonger verticalement (ou sauter en base) |
| `sprint` | `Shift` | Nage rapide (coût accru en oxygène/énergie) |
| `interact` | `E` | Ramasser / Interagir / Activer le sas |
| `flashlight` | `F` | Allumer / Éteindre la lampe torche |
| `hub_menu` | `Tab` | Interface rapide de la base |
| `pause` | `Échap` | Pause / Libération du curseur |

---

## 6. Feuille de Route par Jalons

- **Jalon 0 — Socle technique (en cours)**
  - Arborescence, typage strict, Input Map 3D, contrôleur de plongeur 3D (`CharacterBody3D`), GDD et conventions Git/AGENTS.
- **Jalon 1 — Prototype Greybox de la boucle minimale**
  - Bassin de test 3D (brouillard abyssal, lampe torche), nage 3D fluide, jauge d'oxygène & pression, 2–3 débris ramassables, sas d'extraction et écran de bilan de run.
- **Jalon 2 — Hub & Reconstruction (v0)**
  - Inventaire persistant (`Resource` + sauvegarde `user://`), interface rapide de craft/reconstruction (3 améliorations concrètes : oxygène, palmes/vitesse, lampe/profondeur) + première salle de base 3D visitable.
- **Jalon 3 — Danger, Furtivité & Stratagèmes**
  - 1er prédateur abyssal (IA à états : patrouille, détection bruit/lumière, poursuite), 1 stratagème (ex. leurre lumineux/sonore), 1 arme/outil de défense de fin de palier, 1 obstacle colossal déplaçable.
- **Jalon 4 — Vertical Slice (1 secteur complet + test DA)**
  - Un premier secteur abyssal travaillé (épave de l'aile détruite), direction artistique étalonnée, ambiance sonore, premiers éléments narratifs (boîtes noires / journaux).
- **Jalon 5 — Démo Steam → Accès Anticipé → 1.0**
  - Page Steam, intégration `GodotSteam` (succès, Cloud Saves), démo publique (Steam Next Fest), puis extension par nouveaux secteurs, créatures et ailes de la base.
