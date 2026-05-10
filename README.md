# MapTidy

![Version](https://img.shields.io/badge/version-1.0.1-blue)
![WoW Interface](https://img.shields.io/badge/WoW-12.0.5%20Midnight-orange)
![Lua](https://img.shields.io/badge/Lua-5.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> 🇫🇷 [Français](#français) · 🇬🇧 [English](#english)

---

## Français

### Présentation

MapTidy est un addon World of Warcraft (Midnight, 12.0.5) qui filtre les marqueurs de quêtes sur la carte du monde et la minicarte par **type de quête**. Chaque filtre est persisté par personnage via `SavedVariablesPerCharacter`.

Tous les types de quêtes sont visibles par défaut — MapTidy ne cache jamais un marqueur par erreur.

### Installation

1. Télécharger la dernière release (fichier ZIP)
2. Extraire le dossier `MapTidy` dans :
   ```
   World of Warcraft/_retail_/Interface/AddOns/
   ```
3. Lancer le jeu et activer **MapTidy** dans le gestionnaire d'addons

### Utilisation

#### Bouton minimap

Un bouton circulaire apparaît autour de la minimap :

| Action | Résultat |
|--------|----------|
| Clic gauche | Ouvre le panel de filtres |
| Clic droit | Réinitialise tous les filtres (tout afficher) |

Le bouton est repositionnable par glisser-déposer autour de la minimap. Un second bouton est également disponible sur la carte du monde.

#### Panel de filtres

Le panel affiche une case à cocher par type de quête, avec l'icône atlas correspondante. Les modifications sont appliquées immédiatement sur la carte du monde et la minimap. La position du panel est mémorisée.

#### Commandes slash

```
/maptidy reset   — Réinitialise tous les filtres (tout afficher)
/maptidy debug   — Active ou désactive les logs de débogage
/maptidy scan    — Mode scan : identifie les templates de pin inconnus
```

### Types de quêtes filtrés

| Type | Description |
|------|-------------|
| Campagne | Quêtes de la campagne principale |
| Importante | Quêtes marquées comme importantes |
| Légendaire | Quêtes légendaires |
| Méta | Quêtes méta (succès de zone, etc.) |
| Répétable | Quêtes répétables et journalières |
| Histoire locale | Quêtes de lore secondaires et triviales |

> Les World Quests, objectifs bonus, et événements de scénario ne sont jamais filtrés.

### Développement

Prérequis : **Docker** (aucun runtime local requis).

**Lancer les tests :**
```bash
docker build -f Dockerfile.test -t maptidy-test . && docker run --rm maptidy-test
```

**Lancer un seul fichier de test :**
```bash
docker run --rm -v $(pwd):/addon maptidy-test busted --pattern "_test" tests/Filter_test.lua
```

**Packager l'addon :**
```bash
make zip   # nécessite un tag git pour déterminer la version
```

### Contribuer

Les contributions sont les bienvenues.

1. **Forker** le dépôt
2. **Créer une branche** depuis `master` :
   ```bash
   git checkout -b feature/ma-fonctionnalite
   ```
3. **Écrire les tests d'abord** (TDD — framework Busted dans `tests/`)
4. **Vérifier que les tests passent** :
   ```bash
   docker build -f Dockerfile.test -t maptidy-test . && docker run --rm maptidy-test
   ```
5. **Ouvrir une Pull Request** avec une description claire du problème résolu ou de la fonctionnalité ajoutée

Quelques règles :
- Les variables, fonctions et fichiers sont nommés en **anglais**
- Les commentaires (quand vraiment nécessaires) sont en **français**
- Pas de CI automatisée — la review est manuelle

---

## English

### Overview

MapTidy is a World of Warcraft addon (Midnight, 12.0.5) that filters quest markers on the world map and minimap by **quest type**. Each filter is stored per character via `SavedVariablesPerCharacter`.

All quest types are visible by default — MapTidy never hides a marker by mistake.

### Installation

1. Download the latest release (ZIP file)
2. Extract the `MapTidy` folder into:
   ```
   World of Warcraft/_retail_/Interface/AddOns/
   ```
3. Launch the game and enable **MapTidy** in the AddOn manager

### Usage

#### Minimap button

A circular button appears around the minimap:

| Action | Result |
|--------|--------|
| Left-click | Opens the filter panel |
| Right-click | Resets all filters (show everything) |

The button can be repositioned by dragging it around the minimap edge. A second button is also available on the world map.

#### Filter panel

The panel displays one checkbox per quest type, with its corresponding atlas icon. Changes are applied immediately to both the world map and minimap. Panel position is saved.

#### Slash commands

```
/maptidy reset   — Reset all filters (show everything)
/maptidy debug   — Toggle debug logging
/maptidy scan    — Scan mode: identify unknown pin templates
```

### Filtered quest types

| Type | Description |
|------|-------------|
| Campaign | Main campaign quests |
| Important | Quests flagged as important |
| Legendary | Legendary quests |
| Meta | Meta quests (zone achievements, etc.) |
| Repeatable | Repeatable and daily quests |
| Local Story | Secondary lore and trivial quests |

> World Quests, bonus objectives, and scenario events are never filtered.

### Development

Requirements: **Docker** (no local runtime needed).

**Run the test suite:**
```bash
docker build -f Dockerfile.test -t maptidy-test . && docker run --rm maptidy-test
```

**Run a single test file:**
```bash
docker run --rm -v $(pwd):/addon maptidy-test busted --pattern "_test" tests/Filter_test.lua
```

**Package the addon:**
```bash
make zip   # requires a git tag to determine the version
```

### Contributing

Contributions are welcome.

1. **Fork** the repository
2. **Create a branch** from `master`:
   ```bash
   git checkout -b feature/my-feature
   ```
3. **Write tests first** (TDD — Busted framework in `tests/`)
4. **Verify the tests pass**:
   ```bash
   docker build -f Dockerfile.test -t maptidy-test . && docker run --rm maptidy-test
   ```
5. **Open a Pull Request** with a clear description of the problem solved or feature added

A few rules:
- Variables, functions, and files are named in **English**
- Comments (when truly necessary) are written in **French**
- No automated CI — review is manual

---

## License

[MIT](LICENSE) © 2026 TheDevOpser
