MapTidy.ChangelogPopup = {}

local CHANGELOG_VERSION = "1.4.0"

local function showPopup()
    StaticPopupDialogs = StaticPopupDialogs or {}
    StaticPopupDialogs["MAPTIDY_CHANGELOG"] = {
        text = MapTidy_L.CHANGELOG_TITLE .. "\n\n" .. MapTidy_L.CHANGELOG_BODY,
        button1 = MapTidy_L.CHANGELOG_CLOSE,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        showAlert = true,
    }
    StaticPopup_Show("MAPTIDY_CHANGELOG")
end

function MapTidy.ChangelogPopup.Initialize()
    pcall(function()
        MapTidyDB = MapTidyDB or {}
        if MapTidy.Changelog.ShouldShow(MapTidyDB.lastSeenVersion, CHANGELOG_VERSION) then
            showPopup()
            MapTidyDB.lastSeenVersion = CHANGELOG_VERSION
        end
    end)
end
