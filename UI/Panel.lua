MapTidy.Panel = {}

-- Noms d'atlas WoW pour les icônes (Midnight 12.0.5)
local QUEST_TYPES = {
    { key = "Campaign",   label = "Campagne",        atlas = "questlog-questtypeicon-story"      },
    { key = "Important",  label = "Important",       atlas = "questlog-questtypeicon-important"  },
    { key = "Legendary",  label = "Légendaire",      atlas = "questlog-questtypeicon-legendary"  },
    { key = "Meta",       label = "Méta",            atlas = "questlog-questtypeicon-wrapper"    },
    { key = "Repeatable", label = "Répétable",       atlas = "questlog-questtypeicon-recurring"  },
    { key = "LocalStory", label = "Histoire locale", atlas = "questnormal"                     },
}

local PANEL_WIDTH  = 200
local ROW_HEIGHT   = 28
local PADDING      = 10
local HEADER_H     = 24
local BUTTON_H     = 24
local PANEL_HEIGHT = PADDING * 2 + HEADER_H + #QUEST_TYPES * ROW_HEIGHT + BUTTON_H + 8

local function syncCheckboxes(panel)
    for _, questType in ipairs(QUEST_TYPES) do
        local cb = panel.checkboxes[questType.key]
        if cb then
            cb:SetChecked(MapTidy.Settings.Get(questType.key))
        end
    end
end

local function createPanel()
    local panel = CreateFrame("Frame", "MapTidyPanel", UIParent, "BackdropTemplate")
    panel:SetSize(PANEL_WIDTH, PANEL_HEIGHT)
    panel:SetFrameStrata("HIGH")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetCenter()
        MapTidy.Settings.Set("panelX", x)
        MapTidy.Settings.Set("panelY", y)
    end)

    panel:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", panel, "TOP", 0, -PADDING)
    title:SetText("MapTidy")

    local sep = panel:CreateTexture(nil, "ARTWORK")
    sep:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")
    sep:SetSize(PANEL_WIDTH - 20, 8)
    sep:SetPoint("TOP", title, "BOTTOM", 0, -2)

    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 1, -1)
    closeBtn:SetScript("OnClick", function()
        panel:Hide()
    end)

    panel.checkboxes = {}
    for i, questType in ipairs(QUEST_TYPES) do
        local offsetY = -(PADDING + HEADER_H + (i - 1) * ROW_HEIGHT)
        local row = CreateFrame("Frame", nil, panel)
        row:SetSize(PANEL_WIDTH - PADDING * 2, ROW_HEIGHT)
        row:SetPoint("TOPLEFT", panel, "TOPLEFT", PADDING, offsetY)

        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetPoint("LEFT", row, "LEFT", 0, 0)
        icon:SetAtlas(questType.atlas)

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", icon, "RIGHT", 6, 0)
        label:SetText(questType.label)

        local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        cb:SetSize(20, 20)
        cb:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        cb:SetChecked(MapTidy.Settings.Get(questType.key))
        cb:SetScript("OnClick", function(self)
            MapTidy.Settings.Set(questType.key, self:GetChecked() and true or false)
            MapTidy.WorldMap.Refresh()
        end)

        panel.checkboxes[questType.key] = cb
    end

    local btnWidth = math.floor((PANEL_WIDTH - PADDING * 2 - 4) / 2)

    local showAllBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    showAllBtn:SetSize(btnWidth, BUTTON_H)
    showAllBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", PADDING, PADDING)
    showAllBtn:SetText("Tout afficher")
    showAllBtn:SetScript("OnClick", function()
        MapTidy.Settings.Reset()
        syncCheckboxes(panel)
        MapTidy.WorldMap.Refresh()
    end)

    local hideAllBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    hideAllBtn:SetSize(btnWidth, BUTTON_H)
    hideAllBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -PADDING, PADDING)
    hideAllBtn:SetText("Tout masquer")
    hideAllBtn:SetScript("OnClick", function()
        for _, questType in ipairs(QUEST_TYPES) do
            MapTidy.Settings.Set(questType.key, false)
        end
        syncCheckboxes(panel)
        MapTidy.WorldMap.Refresh()
    end)

    local x = MapTidy.Settings.Get("panelX")
    local y = MapTidy.Settings.Get("panelY")
    if x and y then
        panel:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    else
        panel:SetPoint("CENTER", UIParent, "CENTER")
    end

    panel:Hide()
    return panel
end

function MapTidy.Panel.Initialize()
    MapTidy.Panel.frame = createPanel()
end

function MapTidy.Panel.Toggle()
    local panel = MapTidy.Panel.frame
    if panel:IsShown() then
        panel:Hide()
    else
        syncCheckboxes(panel)
        panel:Show()
    end
end
