MapTidy.Settings = {}

-- Types filtrables soumis à l'axe "déjà fait par le bataillon" (tous sauf Expedition,
-- qui est un event à durée limitée court-circuité avant cet axe dans Filter.lua).
local WARBAND_TYPE_KEYS = { "Campaign", "Important", "Legendary", "Meta", "Repeatable", "LocalStory" }

local DEFAULTS = {
    Campaign     = true,
    Important    = true,
    Legendary    = true,
    Meta         = true,
    Repeatable   = true,
    LocalStory   = true,
    Expedition   = true,
    HideWarbandCompleted_Campaign   = true,
    HideWarbandCompleted_Important  = true,
    HideWarbandCompleted_Legendary  = true,
    HideWarbandCompleted_Meta       = true,
    HideWarbandCompleted_Repeatable = true,
    HideWarbandCompleted_LocalStory = true,
    minimapAngle = 225,
    debug        = false,
}

local FILTER_KEYS = { "Campaign", "Important", "Legendary", "Meta", "Repeatable", "LocalStory", "Expedition" }

function MapTidy.Settings.Initialize()
    if not MapTidyCharDB then
        MapTidyCharDB = {}
    end
    -- Migration : l'ancienne clé globale HideWarbandCompleted (pré-1.5.0) se propage
    -- vers les 6 clés par type pour préserver le comportement des joueurs existants.
    if MapTidyCharDB.HideWarbandCompleted ~= nil then
        for _, t in ipairs(WARBAND_TYPE_KEYS) do
            if MapTidyCharDB["HideWarbandCompleted_" .. t] == nil then
                MapTidyCharDB["HideWarbandCompleted_" .. t] = MapTidyCharDB.HideWarbandCompleted
            end
        end
        MapTidyCharDB.HideWarbandCompleted = nil
    end
    for k, v in pairs(DEFAULTS) do
        if MapTidyCharDB[k] == nil then
            MapTidyCharDB[k] = v
        end
    end
end

function MapTidy.Settings.Get(key)
    return MapTidyCharDB[key]
end

function MapTidy.Settings.Set(key, value)
    MapTidyCharDB[key] = value
end

function MapTidy.Settings.Reset()
    for _, k in ipairs(FILTER_KEYS) do
        MapTidyCharDB[k] = true
    end
    -- "Tout afficher" implique aussi de remontrer le déjà-fait, pour chaque type
    for _, t in ipairs(WARBAND_TYPE_KEYS) do
        MapTidyCharDB["HideWarbandCompleted_" .. t] = false
    end
end

function MapTidy.Settings.ToggleDebug()
    MapTidyCharDB.debug = not MapTidyCharDB.debug
    local state = MapTidyCharDB.debug and MapTidy_L.DEBUG_ON or MapTidy_L.DEBUG_OFF
    print("|cff00ff00MapTidy:|r Debug " .. state)
end

-- Presets nommés : configurations de filtrage sauvegardées au niveau du compte
-- (MapTidyDB), pour être rappelées sur n'importe quel personnage.

local function normalizePresetName(name)
    if type(name) ~= "string" then return nil end
    local trimmed = name:match("^%s*(.-)%s*$")
    if trimmed == "" then return nil end
    return trimmed
end
MapTidy.Settings.NormalizePresetName = normalizePresetName

local function ensurePresetsTable()
    if not MapTidyDB then
        MapTidyDB = {}
    end
    if not MapTidyDB.presets then
        MapTidyDB.presets = {}
    end
end

-- Capture uniquement les 13 clés de filtrage (jamais panelX/panelY/minimapAngle/debug).
function MapTidy.Settings.SavePreset(name)
    name = normalizePresetName(name)
    if not name then return end
    ensurePresetsTable()
    local snapshot = {}
    for _, k in ipairs(FILTER_KEYS) do
        snapshot[k] = MapTidyCharDB[k]
    end
    for _, t in ipairs(WARBAND_TYPE_KEYS) do
        local key = "HideWarbandCompleted_" .. t
        snapshot[key] = MapTidyCharDB[key]
    end
    MapTidyDB.presets[name] = snapshot
end

function MapTidy.Settings.LoadPreset(name)
    if not (MapTidyDB and MapTidyDB.presets and MapTidyDB.presets[name]) then return end
    for k, v in pairs(MapTidyDB.presets[name]) do
        MapTidyCharDB[k] = v
    end
    MapTidyCharDB.activePreset = name
end

function MapTidy.Settings.DeletePreset(name)
    if not (MapTidyDB and MapTidyDB.presets) then return end
    MapTidyDB.presets[name] = nil
end

function MapTidy.Settings.ListPresetNames()
    local names = {}
    if MapTidyDB and MapTidyDB.presets then
        for presetName in pairs(MapTidyDB.presets) do
            table.insert(names, presetName)
        end
    end
    table.sort(names)
    return names
end

-- Ne renvoie le preset actif que s'il existe encore (peut avoir été supprimé
-- depuis un autre personnage) : centralise ici la vérification pour que l'UI
-- (non testée) n'ait pas à la dupliquer.
function MapTidy.Settings.GetActivePresetName()
    local name = MapTidyCharDB and MapTidyCharDB.activePreset
    if not name then return nil end
    if MapTidyDB and MapTidyDB.presets and MapTidyDB.presets[name] then
        return name
    end
    return nil
end
