MapTidy = {}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "MapTidy" then
            MapTidy.Settings.Initialize()
        end
    elseif event == "PLAYER_LOGIN" then
        MapTidy.WorldMap.Initialize()
        MapTidy.MinimapButton.Initialize()
        MapTidy.WorldMapButton.Initialize()
        MapTidy.Panel.Initialize()
    end
end)

SLASH_MAPTIDY1 = "/maptidy"
SlashCmdList["MAPTIDY"] = function(msg)
    local cmd = strtrim(msg):lower()
    if cmd == "reset" then
        MapTidy.Settings.Reset()
        MapTidy.WorldMap.Refresh()
        print(MapTidy_L.RESET_MSG)
    elseif cmd == "debug" then
        MapTidy.Settings.ToggleDebug()
    elseif cmd == "scan" then
        MapTidy.WorldMap.StartScan()
    end
end
