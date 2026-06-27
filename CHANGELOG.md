# Changelog

All notable changes to MapTidy are documented here.

---

## [1.4.1] — Latest

### Fixed
- `Core/Changelog.lua` and `UI/ChangelogPopup.lua` were missing from the packaged zip (absent from `ADDON_FILES` in the Makefile), causing a load failure and a crash at login (`attempt to index field 'ChangelogPopup' (a nil value)`). Added the two files to the package, plus a `make zip` safeguard that fails the build when a `.lua`/`.xml` referenced in the `.toc` is not in `ADDON_FILES` — preventing this recurring packaging bug

## [1.4.0]

### Added
- Hide quests **already completed by your warband** — new per-character setting `HideWarbandCompleted` (enabled by default), driven by `C_QuestLog.IsQuestFlaggedCompletedOnAccount`, with its own toggle in the filter panel (separate from the per-type checkboxes)
- One-time-per-account changelog popup (localized FR/EN) shown on login when the addon version changes, backed by a new account-wide saved variable `MapTidyDB`

### Changed
- Visibility is now a two-axis rule: a quest shows if its **type is enabled** AND (it is **not warband-completed** OR the warband toggle is off). Checking a type means "this content interests me"; the warband toggle independently drops what you have already done
- "Show All" (panel button / minimap right-click / `/maptidy reset`) now also disables warband-completed hiding, so everything reappears in one gesture
- Warband-completed hiding never affects pass-through pins (World Quests, expeditions, bonus objectives, scenarios) and is fail-safe — a nil questID or an unavailable API never hides a pin

## [1.3.0]

### Added
- New **Expedition** quest type (zone events with a time limit — battalion reputation, loot) with its own checkbox in the filter panel, enabled by default
- `/maptidy inspect` — diagnostic command logging each map pin's template, questID, time left, campaign ID, world quest type and classification

### Fixed
- Expeditions no longer disappear or flicker when **Campaign** is unchecked. Their pins carry a `questID` attached to a campaign, so they were wrongly classified as Campaign and hidden — worsened by addons (WorldQuestList / WorldQuestTab) that re-render them. They are now detected as their own type and controlled only by the Expedition checkbox
- `campaignID == 0` (returned for non-campaign quests) was treated as truthy in Lua and misclassified pins as Campaign — now requires `> 0`
- World map canvas scan no longer filters every pin carrying a `questID` (delves, area POIs, third-party pins); it now only touches genuine quest pins and expeditions, ending the parasitic hiding

### Changed
- Expedition detection is template- and addon-independent: a pin is an expedition if its template is `AreaPOIEventPinTemplate` or its quest has a remaining time (`C_TaskQuest.GetQuestTimeLeftSeconds`), so all renderings (native diamond, AreaPOI, world quest) respond to the same checkbox
- questID extraction now also reads the pin's `GetQuestID()` method (used by AreaPOI pins)

## [1.2.5]

### Fixed
- bump wow verfsion to 12.0.7

---

## [1.2.4]

### Fixed
- `libs/LibStub.lua`, `libs/Krowi_WorldMapButtons/` and `UI/WorldMapButton.xml` missing from zip — omitted from `ADDON_FILES` in Makefile, causing a crash cascade on addon load

---

## [1.2.3]

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
