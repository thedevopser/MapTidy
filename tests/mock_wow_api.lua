-- Stubs WoW API globaux pour busted
_G.MapTidy        = {}
_G.MapTidyCharDB  = nil
_G.print          = function() end

_G.C_CampaignInfo = {
    GetCampaignID = function(questID) return nil end,
}

_G.C_QuestLog = {
    GetQuestTagInfo    = function(questID) return nil end,
    IsRepeatableQuest  = function(questID) return false end,
}

_G.Enum = {
    QuestTag = {
        Legendary = 11,
        Meta      = 266,
    },
    QuestClassification = {
        Important      = 0,
        Legendary      = 1,
        Campaign       = 2,
        Calling        = 3,
        Meta           = 4,
        Recurring      = 5,
        Questline      = 6,
        Normal         = 7,
        BonusObjective = 8,
        Threat         = 9,
        WorldQuest     = 10,
    },
}
