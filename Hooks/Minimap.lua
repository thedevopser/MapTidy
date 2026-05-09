MapTidy.Minimap = {}

local function applyFilterToMinimapPin(pin)
    if MapTidy.Filter.ShouldShowPin(pin) then
        pin:Show()
    else
        pin:Hide()
    end
end

local function refreshMinimapPins()
    if not Minimap then return end
    for _, child in ipairs({ Minimap:GetChildren() }) do
        if child.questID and child:IsObjectType("Button") then
            applyFilterToMinimapPin(child)
        end
    end
end

function MapTidy.Minimap.Initialize()
    pcall(function()
        hooksecurefunc(QuestPOIMixin, "UpdatePOI", function()
            C_Timer.After(0, refreshMinimapPins)
        end)
    end)

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("MINIMAP_UPDATE_TRACKING")
    frame:RegisterEvent("ZONE_CHANGED")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:RegisterEvent("QUEST_LOG_UPDATE")
    frame:SetScript("OnEvent", function()
        C_Timer.After(0.1, refreshMinimapPins)
    end)
end

function MapTidy.Minimap.Refresh()
    refreshMinimapPins()
end
