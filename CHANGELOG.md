# Changelog

All notable changes to MapTidy are documented here.

---

## [1.2.3] — Latest

### Fixed
- WorldMap button positioning on characters with few addons enabled — the custom child-frame scan was unreliable and could anchor to internal Blizzard layout frames

### Changed
- WorldMap button now uses [Krowi_WorldMapButtons](https://github.com/TheKrowi/Krowi_WorldMapButtons) library for positioning (same approach as HandyNotes) — anchors to `GetCanvasContainer()` and stacks automatically with Blizzard and third-party addon buttons
- Button template moved to XML (`UI/WorldMapButton.xml`) with a `MapTidyWorldMapButtonMixin`
- Added `libs/LibStub.lua` and `libs/Krowi_WorldMapButtons/` as embedded dependencies

---

## [1.2.2]

### Fixed
- `Locales/enUS.lua` and `Locales/frFR.lua` missing from zip — omitted from `ADDON_FILES` in Makefile

---

## [1.2.1]

### Added
- Localization system (FR/EN): UI language now follows the WoW client locale
  - English for all non-French clients (default)
  - French when `GetLocale() == "frFR"`
- `Locales/enUS.lua` — base locale table with 16 string keys
- `Locales/frFR.lua` — French overrides loaded conditionally at startup
- `## Notes-frFR` entry in the `.toc` for the French addon list description
- 35 locale tests covering enUS, frFR, and unknown-locale fallback

### Changed
- All hardcoded French strings replaced with `MapTidy_L.*` keys across:
  `MapTidy.lua`, `Core/Settings.lua`, `Core/Filter.lua`, `Hooks/WorldMap.lua`,
  `UI/Panel.lua`, `UI/MinimapButton.lua`
- `.toc` load order updated: locale files are now loaded before all other files

---

## [1.1.0]

### Added
- Close button on the filter panel
- "Hide All" button to disable all quest types at once
- Draggable minimap button with persisted angle

### Removed
- Minimap quest pin filtering (reliability issues with `QuestPOIMixin` hooks)

### Changed
- Minimap button right-click now resets all filters and refreshes the map

---

## [1.0.1]

### Added
- Dynamic positioning of the WorldMap button (stacks below existing corner buttons)
- Bilingual README (FR/EN)
- MIT License

---

## [1.0.0] — Initial release

### Added
- Quest marker filtering on the world map by quest type: Campaign, Important, Legendary, Meta, Repeatable, Local Story
- Draggable filter panel with per-type checkboxes and atlas icons
- Minimap button (left-click: panel, right-click: show all)
- WorldMap button (left-click: panel)
- Per-character settings via `SavedVariablesPerCharacter`
- `/maptidy reset` — reset all filters
- `/maptidy debug` — toggle debug logging
- `/maptidy scan` — log pin templates to chat for troubleshooting
