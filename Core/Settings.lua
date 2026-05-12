MapTidy.Settings = {}

local DEFAULTS = {
    Campaign     = true,
    Important    = true,
    Legendary    = true,
    Meta         = true,
    Repeatable   = true,
    LocalStory   = true,
    panelX       = nil,
    panelY       = nil,
    minimapAngle = 225,
    debug        = false,
}

local FILTER_KEYS = { "Campaign", "Important", "Legendary", "Meta", "Repeatable", "LocalStory" }

function MapTidy.Settings.Initialize()
    if not MapTidyCharDB then
        MapTidyCharDB = {}
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
end

function MapTidy.Settings.ToggleDebug()
    MapTidyCharDB.debug = not MapTidyCharDB.debug
    local state = MapTidyCharDB.debug and MapTidy_L.DEBUG_ON or MapTidy_L.DEBUG_OFF
    print("|cff00ff00MapTidy:|r Debug " .. state)
end
