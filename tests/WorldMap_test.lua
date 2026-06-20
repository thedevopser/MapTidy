dofile("tests/mock_wow_api.lua")
dofile("Core/Settings.lua")
dofile("Core/Filter.lua")
dofile("Hooks/WorldMap.lua")

local IsQuestPin = function(child) return MapTidy.WorldMap.IsQuestPin(child) end

describe("WorldMap.IsQuestPin — allow-list", function()
    before_each(function()
        _G.C_TaskQuest.GetQuestTimeLeftSeconds = function() return nil end
    end)

    it("vrai pour un pin avec questClassification", function()
        assert.is_true(IsQuestPin({ pinTemplate = "QuestOfferPinTemplate", questClassification = 2 }))
    end)

    it("vrai pour un template de quête connu", function()
        assert.is_true(IsQuestPin({ pinTemplate = "QuestPinTemplate" }))
        assert.is_true(IsQuestPin({ pinTemplate = "CampaignQuestPinTemplate" }))
    end)

    it("vrai pour AreaPOIEventPinTemplate (losange doré natif)", function()
        assert.is_true(IsQuestPin({ pinTemplate = "AreaPOIEventPinTemplate" }))
    end)

    it("faux pour un template pass-through", function()
        assert.is_false(IsQuestPin({ pinTemplate = "WorldMap_WorldQuestPinTemplate", questID = 1 }))
    end)

    it("vrai pour un pin addon questID-only à durée limitée (expédition)", function()
        _G.C_TaskQuest.GetQuestTimeLeftSeconds = function() return 90000 end
        assert.is_true(IsQuestPin({ pinTemplate = "HandyNotes_MidnightWorldMapPinTemplate", questID = 248583 }))
    end)

    it("faux pour un pin addon questID-only SANS durée limitée (POI/gouffre)", function()
        assert.is_false(IsQuestPin({ pinTemplate = "DelveEntrancePinTemplate", questID = 12345 }))
        assert.is_false(IsQuestPin({ pinTemplate = "AreaPOIPinTemplate", questID = 6789 }))
    end)

    it("faux pour un pin sans template, sans classification, sans questID", function()
        assert.is_false(IsQuestPin({}))
    end)

    it("vrai pour une expédition rendue en WorldQuest (pass-through mais durée limitée)", function()
        _G.C_TaskQuest.GetQuestTimeLeftSeconds = function() return 103904 end
        assert.is_true(IsQuestPin({ pinTemplate = "WorldMap_WorldQuestPinTemplate", questID = 91803 }))
    end)

    it("vrai pour une expédition AreaPOI dont le questID vient de GetQuestID", function()
        _G.C_TaskQuest.GetQuestTimeLeftSeconds = function() return 255104 end
        assert.is_true(IsQuestPin({ pinTemplate = "AreaPOIPinTemplate", GetQuestID = function() return 91808 end }))
    end)
end)
