# MapTidy — Design Spec

**Date :** 2026-05-09
**Addon WoW :** MapTidy
**Cible :** World of Warcraft Midnight (12.0.5) — client live retail

---

## Objectif

Permettre d'afficher ou masquer les marqueurs de quêtes disponibles sur la minimap et la grande carte du monde, par type de quête, avec des réglages par personnage. Cas d'usage principal : avoir une carte propre sur les personnages alternatifs.

---

## Scope

### Types de quêtes filtrables (6)

| Type | Identifiant interne |
|------|---------------------|
| Campagne | `Campaign` |
| Important | `Important` |
| Légendaire | `Legendary` |
| Méta | `Meta` |
| Répétable | `Repeatable` |
| Histoire locale | `LocalStory` |

### Toujours visibles (hors scope)

- En cours
- Rendre la quête

---

## Architecture

```
MapTidy/
├── MapTidy.toc
├── MapTidy.lua
├── Core/
│   ├── Settings.lua
│   └── Filter.lua
├── Hooks/
│   ├── WorldMap.lua
│   └── Minimap.lua
├── Textures/
│   └── icon.tga          # Bouton minimap : 64×64 RGBA, fond sombre, bordure or, "!" orange-or
└── UI/
    ├── MinimapButton.lua
    └── Panel.lua
```

Pas de dépendances externes. Lua pur, pas de LibStub ni LibDBIcon.

Le fichier `.toc` déclare `## SavedVariablesPerCharacter: MapTidyCharDB` — WoW gère automatiquement l'isolation par personnage.

---

## Composants

### `MapTidy.lua`
Point d'entrée. Enregistre les events WoW (`ADDON_LOADED`, `PLAYER_LOGIN`), initialise les settings, charge les hooks et l'UI dans le bon ordre.

### `Core/Settings.lua`
Valeurs par défaut : tous les types visibles (`true`). Au `PLAYER_LOGIN`, fusionne avec `MapTidyCharDB` (SavedVariablesPerCharacter). Expose `Settings.Get(type)` et `Settings.Set(type, value)`.

### `Core/Filter.lua`
Expose `Filter.ShouldShowPin(questID)`. Interroge `C_QuestLog.GetQuestTagInfo(questID)` et `C_CampaignInfo` pour déterminer le type de quête, retourne `true/false` selon les settings. Seul fichier contenant les règles de filtrage.

### `Hooks/WorldMap.lua`
- Hook sur `QuestDataProvider:RefreshAllData` : itère les pins existants, applique `Hide()`/`Show()`.
- Hook sur `QuestPinMixin:OnAcquired` : applique le filtre immédiatement à la création du pin (évite le flash).

### `Hooks/Minimap.lua`
Hook sur les frames `QuestPOI` de la minimap via `hooksecurefunc`. Même logique de filtre via `Filter.ShouldShowPin`.

### `UI/MinimapButton.lua`
Bouton rond (31px) ancré sur la minimap. Texture : `Textures/icon.tga` (64×64 RGBA custom). Clic gauche : ouvre/ferme le panel. Clic droit : reset rapide (tout afficher). Draggable autour de la minimap.

### `UI/Panel.lua`
Frame draggable. 6 lignes (icône atlas WoW native + label + checkbox). Les icônes sont récupérées via `SetAtlas(atlasName)` sur un `Texture` frame — même rendu que l'interface Blizzard. Bouton "Tout afficher" en bas. Chaque toggle appelle `Settings.Set` puis force un refresh de la carte et de la minimap. Position mémorisée dans `MapTidyCharDB`.

---

## Data flow

```
PLAYER_LOGIN
    └─> Settings.lua : charge MapTidyCharDB (ou defaults)

Ouverture carte / changement de zone
    └─> QuestDataProvider:RefreshAllData (hook)
            └─> pour chaque pin : Filter.ShouldShowPin(questID)
                    └─> C_QuestLog.GetQuestTagInfo(questID)
                    └─> C_CampaignInfo.GetCampaignID(questID)
                    └─> pin:Show() ou pin:Hide()

Nouveau pin créé (pool)
    └─> QuestPinMixin:OnAcquired (hook)
            └─> Filter.ShouldShowPin(questID) → Hide() si filtré

Joueur coche/décoche dans le panel
    └─> Settings.Set(type, value) → sauvegarde dans MapTidyCharDB
    └─> WorldMap.Refresh() + Minimap.Refresh()
```

L'UI écrit dans Settings. Les hooks lisent Settings. Filter ne connaît ni l'UI ni les hooks.

---

## Interface utilisateur

**Bouton minimap** : cercle 31px, icône marqueur de quête, ancré en bas-droite de la minimap.

**Panel** :
```
┌─────────────────────────┐
│  MapTidy                │
├─────────────────────────┤
│  ☑  ! Campagne          │
│  ☑  ! Important         │
│  ☑  ! Légendaire        │
│  ☑  ❄ Méta              │
│  ☐  ↺ Répétable         │
│  ☑  ! Histoire locale   │
├─────────────────────────┤
│  [Tout afficher]        │
└─────────────────────────┘
```

- Icône colorée reprenant les couleurs WoW par type
- Checkbox décochée = type masqué sur minimap ET grande carte
- Panel draggable, position mémorisée par personnage

---

## Tests et gestion d'erreurs

### Slash commands

```
/maptidy test    → suite de tests in-game
/maptidy debug   → logs de filtrage dans le chat
/maptidy reset   → remet les settings à défaut pour le perso connecté
```

### Ce qui est testé
- `Filter.ShouldShowPin` retourne le bon booléen pour chaque type
- Settings chargés et sauvegardés correctement entre sessions
- Panel reflète fidèlement l'état des settings au chargement

### Fail-safes
- `GetQuestTagInfo` retourne `nil` → pin affiché par défaut (on ne masque jamais par erreur)
- `QuestDataProvider` ou `QuestPinMixin` absent (breaking change Blizzard) → hooks silencieux, addon désactivé proprement sans erreur Lua
