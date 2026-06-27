dofile("tests/mock_wow_api.lua")
dofile("Core/Settings.lua")
dofile("Core/Filter.lua")

local function pin(template, questID)
    return { pinTemplate = template, questID = questID }
end

local function offerPin(classification)
    return { pinTemplate = "QuestOfferPinTemplate", questClassification = classification }
end

local function offerPinNested(classification)
    return { pinTemplate = "QuestOfferPinTemplate", questInfo = { questClassification = classification } }
end

describe("Filter.ShouldShowPin — template connu (anciens templates)", function()
    before_each(function()
        _G.MapTidyCharDB = nil
        MapTidy.Settings.Initialize()
    end)

    it("affiche Campaign quand Campaign=true", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin(pin("CampaignQuestPinTemplate")))
    end)

    it("masque Campaign quand Campaign=false", function()
        MapTidy.Settings.Set("Campaign", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("CampaignQuestPinTemplate")))
    end)

    it("affiche LocalStory quand LocalStory=true", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin(pin("QuestNormalPinTemplate")))
    end)

    it("masque LocalStory quand LocalStory=false", function()
        MapTidy.Settings.Set("LocalStory", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("QuestNormalPinTemplate")))
    end)

    it("masque Repeatable quand Repeatable=false", function()
        MapTidy.Settings.Set("Repeatable", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("RepeatableQuestPinTemplate")))
    end)

    it("masque Meta quand Meta=false", function()
        MapTidy.Settings.Set("Meta", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("MetaQuestPinTemplate")))
    end)

    it("affiche QuestTrivial quand LocalStory=true", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin(pin("QuestTrivialPinTemplate")))
    end)

    it("masque QuestTrivial quand LocalStory=false", function()
        MapTidy.Settings.Set("LocalStory", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("QuestTrivialPinTemplate")))
    end)

    it("affiche Important quand Important=true", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin(pin("ImportantQuestPinTemplate")))
    end)

    it("masque Important quand Important=false", function()
        MapTidy.Settings.Set("Important", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("ImportantQuestPinTemplate")))
    end)

    it("affiche Legendary quand Legendary=true", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin(pin("LegendaryQuestPinTemplate")))
    end)

    it("masque Legendary quand Legendary=false", function()
        MapTidy.Settings.Set("Legendary", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("LegendaryQuestPinTemplate")))
    end)
end)

describe("Filter.ShouldShowPin — QuestOfferPinTemplate (Midnight)", function()
    before_each(function()
        _G.MapTidyCharDB = nil
        MapTidy.Settings.Initialize()
    end)

    it("affiche Campaign via classification directe", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin(offerPin(Enum.QuestClassification.Campaign)))
    end)

    it("masque Campaign via classification directe quand Campaign=false", function()
        MapTidy.Settings.Set("Campaign", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(offerPin(Enum.QuestClassification.Campaign)))
    end)

    it("affiche Important via classification directe", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin(offerPin(Enum.QuestClassification.Important)))
    end)

    it("masque Important via classification directe quand Important=false", function()
        MapTidy.Settings.Set("Important", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(offerPin(Enum.QuestClassification.Important)))
    end)

    it("masque quête normale (LocalStory) quand LocalStory=false", function()
        MapTidy.Settings.Set("LocalStory", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(offerPin(Enum.QuestClassification.Normal)))
    end)

    it("masque Repeatable via classification Recurring quand Repeatable=false", function()
        MapTidy.Settings.Set("Repeatable", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(offerPin(Enum.QuestClassification.Recurring)))
    end)

    it("lit la classification dans questInfo imbriqué", function()
        MapTidy.Settings.Set("Campaign", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(offerPinNested(Enum.QuestClassification.Campaign)))
    end)

    it("Important a la valeur 0 : masque correctement (0 n'est pas nil)", function()
        MapTidy.Settings.Set("Important", false)
        -- Enum.QuestClassification.Important == 0, cas limite
        assert.is_false(MapTidy.Filter.ShouldShowPin(offerPin(0)))
    end)
end)

describe("Filter.ShouldShowPin — pass-through (WQL, quêtes mondiales)", function()
    before_each(function()
        _G.MapTidyCharDB = nil
        MapTidy.Settings.Initialize()
        -- tout masqué
        for _, k in ipairs({"Campaign","Important","Legendary","Meta","Repeatable","LocalStory"}) do
            MapTidy.Settings.Set(k, false)
        end
    end)

    it("ne masque jamais WorldMap_WorldQuestPinTemplate", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin({ pinTemplate = "WorldMap_WorldQuestPinTemplate", questID = 1 }))
    end)

    it("ne masque jamais WQL_WorldQuestPinTemplate", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin({ pinTemplate = "WQL_WorldQuestPinTemplate", questID = 2 }))
    end)

    it("ne masque jamais ScenarioBlobPinTemplate", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin({ pinTemplate = "ScenarioBlobPinTemplate" }))
    end)
end)

describe("Filter.ShouldShowPin — fail-safe", function()
    before_each(function()
        _G.MapTidyCharDB = nil
        MapTidy.Settings.Initialize()
    end)

    it("affiche si pin est nil", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin(nil))
    end)

    it("affiche si template inconnu et pas de questID (fail-safe)", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin(pin("TemplateInconnue")))
    end)
end)

describe("Filter.ShouldShowPin — fallback questID", function()
    before_each(function()
        _G.MapTidyCharDB = nil
        MapTidy.Settings.Initialize()
        _G.C_CampaignInfo.GetCampaignID    = function() return nil end
        _G.C_QuestLog.GetQuestTagInfo      = function() return nil end
        _G.C_QuestLog.IsRepeatableQuest    = function() return false end
    end)

    it("masque une quête légendaire via tagID", function()
        _G.C_QuestLog.GetQuestTagInfo = function() return { tagID = Enum.QuestTag.Legendary } end
        MapTidy.Settings.Set("Legendary", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("TemplateInconnue", 123)))
    end)

    it("masque une quête répétable via IsRepeatableQuest", function()
        _G.C_QuestLog.IsRepeatableQuest = function() return true end
        MapTidy.Settings.Set("Repeatable", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("TemplateInconnue", 456)))
    end)

    it("masque une quête Campaign via GetCampaignID", function()
        _G.C_CampaignInfo.GetCampaignID = function() return 99 end
        MapTidy.Settings.Set("Campaign", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("TemplateInconnue", 789)))
    end)
end)

describe("Filter.ShouldShowPin — Expédition (event de zone à durée limitée)", function()
    before_each(function()
        _G.MapTidyCharDB = nil
        MapTidy.Settings.Initialize()
        _G.C_CampaignInfo.GetCampaignID       = function() return nil end
        _G.C_QuestLog.GetQuestTagInfo         = function() return nil end
        _G.C_QuestLog.IsRepeatableQuest       = function() return false end
        _G.C_TaskQuest.GetQuestTimeLeftSeconds = function() return nil end
    end)

    it("classe en Expedition un pin AreaPOIEventPinTemplate (losange doré natif)", function()
        MapTidy.Settings.Set("Expedition", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("AreaPOIEventPinTemplate")))
    end)

    it("affiche l'event AreaPOIEventPinTemplate quand Expedition=true", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin(pin("AreaPOIEventPinTemplate")))
    end)

    it("classe en Expedition (pas Campaign) un pin questID-only à durée limitée", function()
        -- pin d'addon : questID rattaché à une campagne MAIS event à durée limitée
        _G.C_TaskQuest.GetQuestTimeLeftSeconds = function() return 90000 end
        _G.C_CampaignInfo.GetCampaignID       = function() return 99 end
        MapTidy.Settings.Set("Campaign", false)
        -- Campagne décochée ne doit PAS masquer l'expédition
        assert.is_true(MapTidy.Filter.ShouldShowPin(pin("TemplateInconnue", 248583)))
    end)

    it("masque l'expédition questID-only quand Expedition=false", function()
        _G.C_TaskQuest.GetQuestTimeLeftSeconds = function() return 90000 end
        MapTidy.Settings.Set("Expedition", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("TemplateInconnue", 248583)))
    end)

    it("IsExpeditionQuest : true si temps restant > 0, false sinon", function()
        _G.C_TaskQuest.GetQuestTimeLeftSeconds = function() return 5 end
        assert.is_true(MapTidy.Filter.IsExpeditionQuest(1))
        _G.C_TaskQuest.GetQuestTimeLeftSeconds = function() return 0 end
        assert.is_false(MapTidy.Filter.IsExpeditionQuest(1))
        _G.C_TaskQuest.GetQuestTimeLeftSeconds = function() return nil end
        assert.is_false(MapTidy.Filter.IsExpeditionQuest(1))
        assert.is_false(MapTidy.Filter.IsExpeditionQuest(nil))
    end)

    it("expédition rendue en WorldQuest (pass-through) suit Expedition, pas le pass-through", function()
        _G.C_TaskQuest.GetQuestTimeLeftSeconds = function() return 103904 end
        local worldQuestExpedition = { pinTemplate = "WorldMap_WorldQuestPinTemplate", questID = 91803 }
        assert.is_true(MapTidy.Filter.ShouldShowPin(worldQuestExpedition))
        MapTidy.Settings.Set("Expedition", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(worldQuestExpedition))
    end)

    it("WorldQuest SANS durée limitée reste pass-through (toujours visible)", function()
        MapTidy.Settings.Set("Expedition", false)
        assert.is_true(MapTidy.Filter.ShouldShowPin({ pinTemplate = "WorldMap_WorldQuestPinTemplate", questID = 1 }))
    end)

    it("lit le questID via la méthode GetQuestID (pins AreaPOI)", function()
        _G.C_TaskQuest.GetQuestTimeLeftSeconds = function() return 255104 end
        local areaPoiPin = {
            pinTemplate = "AreaPOIPinTemplate",
            GetQuestID  = function() return 91808 end,
        }
        MapTidy.Settings.Set("Expedition", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(areaPoiPin))
    end)

    it("ne classe PAS Campaign quand campaignID = 0 (0 est truthy en Lua)", function()
        _G.C_CampaignInfo.GetCampaignID = function() return 0 end
        MapTidy.Settings.Set("Campaign", false)
        -- questID sans temps restant, campaignID 0 → ne doit pas tomber dans Campaign
        assert.is_true(MapTidy.Filter.ShouldShowPin(pin("TemplateInconnue", 248583)))
    end)
end)

describe("Filter.ShouldShowPin — masquage déjà-fait par le bataillon", function()
    before_each(function()
        _G.MapTidyCharDB = nil
        MapTidy.Settings.Initialize()
        C_QuestLog.IsQuestFlaggedCompletedOnAccount = function(questID) return false end
    end)

    it("masque une quête déjà faite quand HideWarbandCompleted=true et type activé", function()
        C_QuestLog.IsQuestFlaggedCompletedOnAccount = function() return true end
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("CampaignQuestPinTemplate", 555)))
    end)

    it("affiche une quête déjà faite quand HideWarbandCompleted=false", function()
        MapTidy.Settings.Set("HideWarbandCompleted", false)
        C_QuestLog.IsQuestFlaggedCompletedOnAccount = function() return true end
        assert.is_true(MapTidy.Filter.ShouldShowPin(pin("CampaignQuestPinTemplate", 555)))
    end)

    it("affiche une quête non faite quand type activé (inchangé)", function()
        assert.is_true(MapTidy.Filter.ShouldShowPin(pin("CampaignQuestPinTemplate", 555)))
    end)

    it("masque quand le type est désactivé même si non faite", function()
        MapTidy.Settings.Set("Campaign", false)
        assert.is_false(MapTidy.Filter.ShouldShowPin(pin("CampaignQuestPinTemplate", 555)))
    end)

    it("ne masque pas les pass-through même si déjà faits", function()
        C_QuestLog.IsQuestFlaggedCompletedOnAccount = function() return true end
        assert.is_true(MapTidy.Filter.ShouldShowPin(pin("WorldMap_WorldQuestPinTemplate", 555)))
    end)

    it("IsCompletedByWarband renvoie false si questID nil (fail-safe)", function()
        C_QuestLog.IsQuestFlaggedCompletedOnAccount = function() return true end
        assert.is_false(MapTidy.Filter.IsCompletedByWarband(nil))
    end)
end)
