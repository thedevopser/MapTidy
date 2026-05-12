MapTidy.WorldMap = {}

local QUEST_TEMPLATES = {
    "CampaignQuestPinTemplate",
    "ImportantQuestPinTemplate",
    "LegendaryQuestPinTemplate",
    "MetaQuestPinTemplate",
    "RepeatableQuestPinTemplate",
    "QuestNormalPinTemplate",
    "QuestTrivialPinTemplate",
    "QuestOfferPinTemplate",
}

local function applyFilterToPin(pin)
    if MapTidy.Filter.ShouldShowPin(pin) then
        pin:Show()
    else
        pin:Hide()
    end
end

local PASS_THROUGH_TEMPLATES = {
    ["WorldMap_WorldQuestPinTemplate"] = true,
    ["WQL_WorldQuestPinTemplate"]      = true,
    ["BonusObjectivePinTemplate"]      = true,
    ["ThreatObjectivePinTemplate"]     = true,
    ["ScenarioBlobPinTemplate"]        = true,
}

-- Détecte si un enfant du canvas est un pin de quête filtrable
local function isQuestPin(child)
    if child.pinTemplate and PASS_THROUGH_TEMPLATES[child.pinTemplate] then return false end
    if child.questClassification ~= nil then return true end
    if child.questID ~= nil or child.questId ~= nil then return true end
    if child.questInfo then return true end
    return false
end

local function refreshAllPins()
    if not WorldMapFrame then return end
    -- Enumération par template (compatibilité tous clients)
    for _, template in ipairs(QUEST_TEMPLATES) do
        for pin in WorldMapFrame:EnumeratePinsByTemplate(template) do
            applyFilterToPin(pin)
        end
    end
    -- Scan direct du canvas : couvre QuestOfferPinTemplate et variantes Midnight
    local canvas = WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child
    if canvas then
        for _, child in pairs({canvas:GetChildren()}) do
            if isQuestPin(child) then
                applyFilterToPin(child)
            end
        end
    end
end

function MapTidy.WorldMap.Initialize()
    pcall(function()
        hooksecurefunc(QuestPinMixin, "OnAcquired", function(self)
            applyFilterToPin(self)
        end)
    end)

    pcall(function()
        hooksecurefunc(WorldMapFrame, "AcquirePin", function(self, templateName)
            C_Timer.After(0, refreshAllPins)
        end)
    end)

    pcall(function()
        hooksecurefunc(QuestDataProviderMixin, "RefreshAllData", function()
            C_Timer.After(0, refreshAllPins)
        end)
    end)

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("QUEST_LOG_UPDATE")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:SetScript("OnEvent", function()
        C_Timer.After(0.1, refreshAllPins)
    end)
end

function MapTidy.WorldMap.Refresh()
    refreshAllPins()
end

function MapTidy.WorldMap.StartScan()
    local seen = {}
    pcall(function()
        hooksecurefunc(WorldMapFrame, "AcquirePin", function(self, templateName)
            if templateName and not seen[templateName] then
                seen[templateName] = true
                print("|cff00ff00MapTidy Scan:|r template = " .. templateName)
            end
        end)
    end)
    print(MapTidy_L.SCAN_ACTIVE_MSG)
end
