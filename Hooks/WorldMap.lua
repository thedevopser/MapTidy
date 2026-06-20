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
    "QuestPinTemplate",
    "AreaPOIEventPinTemplate",
}

-- Set indexé pour lookup O(1) dans IsQuestPin
local FILTERABLE_TEMPLATES = {}
for _, template in ipairs(QUEST_TEMPLATES) do
    FILTERABLE_TEMPLATES[template] = true
end

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

-- Détecte si un enfant du canvas est un pin filtrable (allow-list).
-- On ne touche QU'aux vrais pins de quête (template connu ou questClassification)
-- et aux expéditions (events à durée limitée). Les autres pins questID-only
-- (POI, gouffres, pins d'addons tiers) restent intacts → pas de masquage parasite.
function MapTidy.WorldMap.IsQuestPin(child)
    -- Expédition d'abord : un pin WorldQuest (en pass-through) peut être une expédition.
    if MapTidy.Filter.IsExpeditionPin(child) then return true end
    local template = child.pinTemplate
    if template and PASS_THROUGH_TEMPLATES[template] then return false end
    if template and FILTERABLE_TEMPLATES[template] then return true end
    if child.questClassification ~= nil then return true end
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
            if MapTidy.WorldMap.IsQuestPin(child) then
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

-- Outil de diagnostic (Phase 0) : confirme en jeu quel signal identifie une expédition.
-- Liste TOUS les templates présents sur le canvas + le verdict de détection,
-- et le détail des API pour ceux qui portent un questID.
function MapTidy.WorldMap.InspectPins()
    local canvas = WorldMapFrame and WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child
    if not canvas then return end

    local seen = {}
    for _, child in pairs({canvas:GetChildren()}) do
        local template = tostring(child.pinTemplate)
        local questID  = MapTidy.Filter.GetQuestID(child)
        if not seen[template] then
            seen[template] = true
            local filtered = MapTidy.WorldMap.IsQuestPin(child)
            print(string.format("|cff00ff00MapTidy Inspect:|r template=%s filtré=%s",
                template, tostring(filtered)))
        end
        if questID and questID ~= 0 then
            local timeLeft   = C_TaskQuest and C_TaskQuest.GetQuestTimeLeftSeconds and C_TaskQuest.GetQuestTimeLeftSeconds(questID)
            local campaignID = C_CampaignInfo and C_CampaignInfo.GetCampaignID and C_CampaignInfo.GetCampaignID(questID)
            local tagInfo    = C_QuestLog and C_QuestLog.GetQuestTagInfo and C_QuestLog.GetQuestTagInfo(questID)
            print(string.format(
                "|cffffff00  → questID=%s timeLeft=%s campaignID=%s worldQuestType=%s classification=%s|r",
                tostring(questID),
                tostring(timeLeft),
                tostring(campaignID),
                tostring(tagInfo and tagInfo.worldQuestType),
                tostring(child.questClassification)
            ))
        end
    end
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
