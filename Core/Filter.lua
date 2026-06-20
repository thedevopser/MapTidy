MapTidy.Filter = {}

-- Templates à ne jamais filtrer (quêtes mondiales, addons tiers, objectifs bonus)
local PASS_THROUGH_TEMPLATES = {
    ["WorldMap_WorldQuestPinTemplate"] = true,
    ["WQL_WorldQuestPinTemplate"]      = true,
    ["BonusObjectivePinTemplate"]      = true,
    ["ThreatObjectivePinTemplate"]     = true,
    ["ScenarioBlobPinTemplate"]        = true,
    ["QuestBlobPinTemplate"]           = true,
}

-- Templates spécifiques qui subsistent hors QuestOfferPinTemplate
local TEMPLATE_TYPE = {
    ["CampaignQuestPinTemplate"]   = "Campaign",
    ["ImportantQuestPinTemplate"]  = "Important",
    ["LegendaryQuestPinTemplate"]  = "Legendary",
    ["MetaQuestPinTemplate"]       = "Meta",
    ["RepeatableQuestPinTemplate"] = "Repeatable",
    ["QuestNormalPinTemplate"]     = "LocalStory",
    ["QuestTrivialPinTemplate"]    = "LocalStory",
}

-- Templates qui sont toujours une expédition, même sans questID exposé
local EXPEDITION_TEMPLATE = {
    ["AreaPOIEventPinTemplate"] = true,
}

local function debugLog(msg)
    if MapTidy.Settings.Get("debug") then
        print("|cff00ff00MapTidy Debug:|r " .. tostring(msg))
    end
end

-- Mapping Enum.QuestClassification → clé Settings (résolu à l'exécution)
local function getTypeFromClassification(classification)
    if not Enum or not Enum.QuestClassification then return nil end
    local E = Enum.QuestClassification
    if classification == E.Campaign   then return "Campaign"   end
    if classification == E.Important  then return "Important"  end
    if classification == E.Legendary  then return "Legendary"  end
    if classification == E.Meta       then return "Meta"       end
    if classification == E.Recurring  then return "Repeatable" end
    -- Normal, BonusObjective, Questline, etc. → LocalStory
    return "LocalStory"
end

-- Extraction robuste du questID : champ direct, imbriqué, ou méthode GetQuestID.
-- questID == 0 = absence de quête réelle (pins blob) → nil.
function MapTidy.Filter.GetQuestID(pin)
    if not pin then return nil end
    local questID = pin.questID or pin.questId
    if questID == nil and pin.questInfo then
        questID = pin.questInfo.questID or pin.questInfo.questId
    end
    if questID == nil and type(pin.GetQuestID) == "function" then
        local ok, value = pcall(pin.GetQuestID, pin)
        if ok then questID = value end
    end
    if questID == 0 then return nil end
    return questID
end

-- Les expéditions sont des events de zone à durée limitée (réput de bataillon, etc.).
-- Détection par questID, indépendante du pin/addon qui les affiche.
function MapTidy.Filter.IsExpeditionQuest(questID)
    if not questID then return false end
    if C_TaskQuest and C_TaskQuest.GetQuestTimeLeftSeconds then
        local timeLeft = C_TaskQuest.GetQuestTimeLeftSeconds(questID)
        if timeLeft and timeLeft > 0 then return true end
    end
    return false
end

-- Une expédition peut être rendue par plusieurs pins (AreaPOIEvent, AreaPOI,
-- WorldQuest). On la reconnaît par son template dédié ou son questID à durée limitée.
function MapTidy.Filter.IsExpeditionPin(pin)
    if not pin then return false end
    if pin.pinTemplate and EXPEDITION_TEMPLATE[pin.pinTemplate] then return true end
    return MapTidy.Filter.IsExpeditionQuest(MapTidy.Filter.GetQuestID(pin))
end

-- Fallback questID pour les pins sans classification exposée
local function getTypeFromQuestID(questID)
    -- campaignID renvoie 0 (et non nil) pour les quêtes hors campagne ; 0 est truthy
    -- en Lua → on exige explicitement > 0.
    local campaignID = C_CampaignInfo and C_CampaignInfo.GetCampaignID and C_CampaignInfo.GetCampaignID(questID)
    if campaignID and campaignID > 0 then
        return "Campaign"
    end
    local tagInfo = C_QuestLog.GetQuestTagInfo and C_QuestLog.GetQuestTagInfo(questID)
    if tagInfo then
        if tagInfo.tagID == Enum.QuestTag.Legendary then return "Legendary" end
        if tagInfo.tagID == Enum.QuestTag.Meta      then return "Meta"      end
    end
    if C_QuestLog.IsRepeatableQuest and C_QuestLog.IsRepeatableQuest(questID) then
        return "Repeatable"
    end
    -- "Important" n'a pas d'équivalent dans C_QuestLog ; les quêtes importantes
    -- sans template connu sont classées LocalStory par défaut
    return "LocalStory"
end

function MapTidy.Filter.ShouldShowPin(pin)
    if not pin then return true end

    -- Expédition AVANT le pass-through : ces events peuvent être rendus par des pins
    -- de quête mondiale (WorldQuest/WQL) normalement en pass-through. Pilotés par leur
    -- propre case, indépendamment de Campagne.
    if MapTidy.Filter.IsExpeditionPin(pin) then
        return MapTidy.Settings.Get("Expedition") == true
    end

    -- Ne jamais filtrer les quêtes mondiales, scénarios ou pins d'addons tiers
    if pin.pinTemplate and PASS_THROUGH_TEMPLATES[pin.pinTemplate] then return true end

    -- Priorité 1 : classification directe (QuestOfferPinTemplate dans Midnight)
    local classification = pin.questClassification
    if classification == nil and pin.questInfo then
        classification = pin.questInfo.questClassification
    end
    if classification ~= nil then
        local questType = getTypeFromClassification(classification)
        return MapTidy.Settings.Get(questType) == true
    end

    -- Priorité 2 : nom de template (anciens templates)
    local template = pin.pinTemplate
    if template then
        local questType = TEMPLATE_TYPE[template]
        if questType then
            return MapTidy.Settings.Get(questType) == true
        end
        debugLog(MapTidy_L.UNKNOWN_TEMPLATE .. template)
    end

    -- Priorité 3 : détection via questID
    local questID = MapTidy.Filter.GetQuestID(pin)
    if questID then
        local questType = getTypeFromQuestID(questID)
        return MapTidy.Settings.Get(questType) == true
    end

    return true
end
