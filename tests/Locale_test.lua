local REQUIRED_KEYS = {
    "RESET_MSG", "DEBUG_ON", "DEBUG_OFF", "UNKNOWN_TEMPLATE",
    "QUEST_CAMPAIGN", "QUEST_IMPORTANT", "QUEST_LEGENDARY",
    "QUEST_META", "QUEST_REPEATABLE", "QUEST_LOCAL_STORY",
    "SHOW_ALL", "HIDE_ALL", "SHOW_ALL_MSG",
    "TOOLTIP_LEFT_CLICK", "TOOLTIP_RIGHT_CLICK", "SCAN_ACTIVE_MSG",
    "COLUMN_HEADER_SHOW", "COLUMN_HEADER_HIDE_DONE",
    "TOOLTIP_SHOW_TYPE", "TOOLTIP_HIDE_DONE_TYPE",
    "PRESET_NONE", "PRESET_SAVE", "PRESET_DELETE",
    "PRESET_SAVE_PROMPT", "PRESET_OVERWRITE_CONFIRM", "PRESET_DELETE_CONFIRM",
    "PANEL_SUBTITLE", "TOOLTIP_PRESET_DROPDOWN",
    "TOOLTIP_PRESET_SAVE", "TOOLTIP_PRESET_DELETE", "TOOLTIP_SHOW_ALL",
    "TOOLTIP_HIDE_ALL", "STATUS_HINT",
    "ACTION_ROW_LABEL", "PRESET_ROW_LABEL", "PRESET_LOAD", "TOOLTIP_PRESET_LOAD",
}

describe("Locale enUS", function()
    before_each(function()
        _G.GetLocale = function() return "enUS" end
        _G.MapTidy_L = nil
        dofile("Locales/enUS.lua")
    end)

    for _, key in ipairs(REQUIRED_KEYS) do
        it("a la cle " .. key, function()
            assert.is_not_nil(MapTidy_L[key], "Cle manquante : " .. key)
            assert.is_string(MapTidy_L[key])
            assert.is_true(#MapTidy_L[key] > 0)
        end)
    end
end)

describe("Locale frFR", function()
    before_each(function()
        _G.GetLocale = function() return "frFR" end
        _G.MapTidy_L = nil
        dofile("Locales/enUS.lua")
        dofile("Locales/frFR.lua")
    end)

    for _, key in ipairs(REQUIRED_KEYS) do
        it("a la cle " .. key, function()
            assert.is_not_nil(MapTidy_L[key], "Cle manquante : " .. key)
            assert.is_string(MapTidy_L[key])
            assert.is_true(#MapTidy_L[key] > 0)
        end)
    end

    it("QUEST_CAMPAIGN est en francais", function()
        assert.equals("Campagne", MapTidy_L.QUEST_CAMPAIGN)
    end)

    it("SHOW_ALL est en francais", function()
        assert.equals("Tout", MapTidy_L.SHOW_ALL)
    end)
end)

describe("Locale fallback (deDE)", function()
    before_each(function()
        _G.GetLocale = function() return "deDE" end
        _G.MapTidy_L = nil
        dofile("Locales/enUS.lua")
        dofile("Locales/frFR.lua")
    end)

    it("utilise l'anglais pour une locale inconnue", function()
        assert.equals("Campaign", MapTidy_L.QUEST_CAMPAIGN)
        assert.equals("All", MapTidy_L.SHOW_ALL)
    end)
end)
