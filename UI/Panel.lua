MapTidy.Panel = {}

local AceGUI = LibStub("AceGUI-3.0")

-- Noms d'atlas WoW pour les icônes (Midnight 12.0.5)
-- hasWarband = false pour Expedition : l'axe "déjà fait par le bataillon" ne
-- s'applique pas à ce type (event à durée limitée, gate indépendant dans Filter.lua).
local QUEST_TYPES = {
    { key = "Campaign",   label = MapTidy_L.QUEST_CAMPAIGN,    atlas = "questlog-questtypeicon-story",      hasWarband = true },
    { key = "Important",  label = MapTidy_L.QUEST_IMPORTANT,   atlas = "questlog-questtypeicon-important",  hasWarband = true },
    { key = "Legendary",  label = MapTidy_L.QUEST_LEGENDARY,   atlas = "questlog-questtypeicon-legendary",  hasWarband = true },
    { key = "Meta",       label = MapTidy_L.QUEST_META,        atlas = "questlog-questtypeicon-wrapper",    hasWarband = true },
    { key = "Repeatable", label = MapTidy_L.QUEST_REPEATABLE,  atlas = "questlog-questtypeicon-recurring",  hasWarband = true },
    { key = "LocalStory", label = MapTidy_L.QUEST_LOCAL_STORY, atlas = "questnormal",                       hasWarband = true },
    { key = "Expedition", label = MapTidy_L.QUEST_EXPEDITION,  atlas = "worldquest-tracker-questmarker",    hasWarband = false },
}

local ROW_LABEL_WIDTH    = 150
local CHECKBOX_COL_WIDTH = 55

local function showTooltip(anchorFrame, text)
    GameTooltip:SetOwner(anchorFrame, "ANCHOR_TOP")
    GameTooltip:SetText(text, nil, nil, nil, nil, true)
    GameTooltip:Show()
end

local function hideTooltip()
    GameTooltip:Hide()
end

local ICON_COL_WIDTH = 22

-- AceGUI-3.0 prédate les atlas WoW : son widget Label ne sait afficher qu'une
-- texture + texcoords manuels, pas un nom d'atlas — une conversion via
-- C_Texture.GetAtlasInfo donnait un rendu cassé. On réserve la colonne via un
-- Label vide (participe au layout Flow) et on pose une vraie Texture Blizzard
-- par-dessus avec SetAtlas, la même technique fiable qu'avant AceGUI.
local function addIconColumn(row)
    local spacer = AceGUI:Create("Label")
    spacer:SetWidth(ICON_COL_WIDTH)
    spacer:SetText(" ")
    row:AddChild(spacer)
    return spacer
end

local function paintIcon(spacer, atlasName)
    local icon = spacer.frame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(18, 18)
    icon:SetPoint("LEFT", spacer.frame, "LEFT", 0, 0)
    pcall(icon.SetAtlas, icon, atlasName)
end

local function syncCheckboxes(panel)
    for _, questType in ipairs(QUEST_TYPES) do
        local cb = panel.checkboxes[questType.key]
        if cb then
            cb:SetValue(MapTidy.Settings.Get(questType.key) == true)
        end
        if questType.hasWarband then
            local doneCb = panel.doneCheckboxes[questType.key]
            if doneCb then
                doneCb:SetValue(MapTidy.Settings.Get("HideWarbandCompleted_" .. questType.key) == true)
            end
        end
    end
end

local function refreshPresetDropdown(panel)
    local names = MapTidy.Settings.ListPresetNames()
    local items = {}
    for _, name in ipairs(names) do
        items[name] = name
    end
    panel.presetDropdown:SetList(items, names)
    local active = MapTidy.Settings.GetActivePresetName()
    panel.presetDropdown:SetValue(active)
    panel.presetDropdown:SetText(active or MapTidy_L.PRESET_NONE)
    panel.loadPresetBtn:SetDisabled(active == nil)
    panel.deletePresetBtn:SetDisabled(active == nil)
end

local function presetExists(name)
    for _, existing in ipairs(MapTidy.Settings.ListPresetNames()) do
        if existing == name then return true end
    end
    return false
end

local function submitPresetName(panel, rawName)
    local name = MapTidy.Settings.NormalizePresetName(rawName)
    if not name then return end
    if presetExists(name) then
        StaticPopup_Show("MAPTIDY_OVERWRITE_PRESET", name, nil, name)
    else
        MapTidy.Settings.SavePreset(name)
        refreshPresetDropdown(panel)
    end
end

StaticPopupDialogs["MAPTIDY_SAVE_PRESET"] = {
    text = MapTidy_L.PRESET_SAVE_PROMPT,
    button1 = MapTidy_L.PRESET_SAVE,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 32,
    OnAccept = function(self)
        -- Midnight's GameDialog.xml template exposes the edit box as `EditBox`
        -- (PascalCase); keep the classic `editBox` as a fallback for safety.
        local editBox = self.EditBox or self.editBox
        submitPresetName(MapTidy.Panel.frame, editBox and editBox:GetText())
    end,
    EditBoxOnEnterPressed = function(self)
        submitPresetName(MapTidy.Panel.frame, self:GetText())
        self:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["MAPTIDY_OVERWRITE_PRESET"] = {
    text = MapTidy_L.PRESET_OVERWRITE_CONFIRM,
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, name)
        MapTidy.Settings.SavePreset(name)
        refreshPresetDropdown(MapTidy.Panel.frame)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

StaticPopupDialogs["MAPTIDY_DELETE_PRESET"] = {
    text = MapTidy_L.PRESET_DELETE_CONFIRM,
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, name)
        MapTidy.Settings.DeletePreset(name)
        refreshPresetDropdown(MapTidy.Panel.frame)
        MapTidy.WorldMap.Refresh()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

local function buildColumnHeaderRow()
    local row = AceGUI:Create("SimpleGroup")
    row:SetFullWidth(true)
    row:SetLayout("Flow")

    addIconColumn(row)

    local spacer = AceGUI:Create("Label")
    spacer:SetWidth(ROW_LABEL_WIDTH)
    spacer:SetText(" ")
    row:AddChild(spacer)

    local showHeader = AceGUI:Create("Label")
    showHeader:SetWidth(CHECKBOX_COL_WIDTH)
    showHeader:SetText(MapTidy_L.COLUMN_HEADER_SHOW)
    row:AddChild(showHeader)

    -- Plus large que la checkbox elle-même : "Déjà fait sur un reroll" est
    -- long, on le laisse déborder à droite (rien après lui sur la ligne) et
    -- s'enrouler sur 2 lignes plutôt que le tronquer.
    local doneHeader = AceGUI:Create("Label")
    doneHeader:SetWidth(CHECKBOX_COL_WIDTH + 55)
    doneHeader:SetText(MapTidy_L.COLUMN_HEADER_HIDE_DONE)
    row:AddChild(doneHeader)

    return row
end

local function buildTypeRow(panel, questType)
    local row = AceGUI:Create("SimpleGroup")
    row:SetFullWidth(true)
    row:SetLayout("Flow")

    local iconSpacer = addIconColumn(row)
    paintIcon(iconSpacer, questType.atlas)

    local label = AceGUI:Create("Label")
    label:SetWidth(ROW_LABEL_WIDTH)
    label:SetText(questType.label)
    row:AddChild(label)

    local showCb = AceGUI:Create("CheckBox")
    showCb:SetLabel("")
    showCb:SetWidth(CHECKBOX_COL_WIDTH)
    showCb:SetValue(MapTidy.Settings.Get(questType.key) == true)
    showCb:SetCallback("OnValueChanged", function(widget, event, value)
        MapTidy.Settings.Set(questType.key, value and true or false)
        MapTidy.WorldMap.Refresh()
    end)
    showCb:SetCallback("OnEnter", function(widget) showTooltip(widget.frame, MapTidy_L.TOOLTIP_SHOW_TYPE) end)
    showCb:SetCallback("OnLeave", hideTooltip)
    row:AddChild(showCb)
    panel.checkboxes[questType.key] = showCb

    if questType.hasWarband then
        local doneCb = AceGUI:Create("CheckBox")
        doneCb:SetLabel("")
        doneCb:SetWidth(CHECKBOX_COL_WIDTH)
        doneCb:SetValue(MapTidy.Settings.Get("HideWarbandCompleted_" .. questType.key) == true)
        doneCb:SetCallback("OnValueChanged", function(widget, event, value)
            MapTidy.Settings.Set("HideWarbandCompleted_" .. questType.key, value and true or false)
            MapTidy.WorldMap.Refresh()
        end)
        doneCb:SetCallback("OnEnter", function(widget) showTooltip(widget.frame, MapTidy_L.TOOLTIP_HIDE_DONE_TYPE) end)
        doneCb:SetCallback("OnLeave", hideTooltip)
        row:AddChild(doneCb)
        panel.doneCheckboxes[questType.key] = doneCb
    end

    return row
end

-- Ligne "Préréglage : [ dropdown ]" — sélectionner un preset dans le menu ne
-- l'applique plus automatiquement (cf. la ligne Charger/Sauvegarder/Supprimer
-- juste en dessous) : on évite d'écraser les filtres en survolant le menu.
local function buildPresetSelectRow(panel)
    local row = AceGUI:Create("SimpleGroup")
    row:SetFullWidth(true)
    row:SetLayout("Flow")

    local presetLabel = AceGUI:Create("Label")
    presetLabel:SetWidth(80)
    presetLabel:SetText(MapTidy_L.PRESET_ROW_LABEL)
    row:AddChild(presetLabel)

    local presetDropdown = AceGUI:Create("Dropdown")
    presetDropdown:SetWidth(150)
    presetDropdown:SetCallback("OnValueChanged", function(widget, event, key)
        panel.loadPresetBtn:SetDisabled(key == nil)
        panel.deletePresetBtn:SetDisabled(key == nil)
    end)
    presetDropdown:SetCallback("OnEnter", function(widget) showTooltip(widget.frame, MapTidy_L.TOOLTIP_PRESET_DROPDOWN) end)
    presetDropdown:SetCallback("OnLeave", hideTooltip)
    row:AddChild(presetDropdown)
    panel.presetDropdown = presetDropdown

    return row
end

local function buildPresetActionRow(panel)
    local row = AceGUI:Create("SimpleGroup")
    row:SetFullWidth(true)
    row:SetLayout("Flow")

    local loadPresetBtn = AceGUI:Create("Button")
    loadPresetBtn:SetText(MapTidy_L.PRESET_LOAD)
    loadPresetBtn:SetWidth(90)
    loadPresetBtn:SetHeight(24)
    loadPresetBtn:SetCallback("OnClick", function()
        local key = panel.presetDropdown:GetValue()
        if not key then return end
        MapTidy.Settings.LoadPreset(key)
        syncCheckboxes(panel)
        MapTidy.WorldMap.Refresh()
        refreshPresetDropdown(panel)
    end)
    loadPresetBtn:SetCallback("OnEnter", function(widget) showTooltip(widget.frame, MapTidy_L.TOOLTIP_PRESET_LOAD) end)
    loadPresetBtn:SetCallback("OnLeave", hideTooltip)
    row:AddChild(loadPresetBtn)
    panel.loadPresetBtn = loadPresetBtn

    local savePresetBtn = AceGUI:Create("Button")
    savePresetBtn:SetText(MapTidy_L.PRESET_SAVE)
    savePresetBtn:SetWidth(90)
    savePresetBtn:SetHeight(24)
    savePresetBtn:SetCallback("OnClick", function()
        StaticPopup_Show("MAPTIDY_SAVE_PRESET")
    end)
    savePresetBtn:SetCallback("OnEnter", function(widget) showTooltip(widget.frame, MapTidy_L.TOOLTIP_PRESET_SAVE) end)
    savePresetBtn:SetCallback("OnLeave", hideTooltip)
    row:AddChild(savePresetBtn)

    local deletePresetBtn = AceGUI:Create("Button")
    deletePresetBtn:SetText(MapTidy_L.PRESET_DELETE)
    deletePresetBtn:SetWidth(90)
    deletePresetBtn:SetHeight(24)
    deletePresetBtn:SetCallback("OnClick", function()
        local key = panel.presetDropdown:GetValue()
        if key then
            StaticPopup_Show("MAPTIDY_DELETE_PRESET", key, nil, key)
        end
    end)
    deletePresetBtn:SetCallback("OnEnter", function(widget) showTooltip(widget.frame, MapTidy_L.TOOLTIP_PRESET_DELETE) end)
    deletePresetBtn:SetCallback("OnLeave", hideTooltip)
    row:AddChild(deletePresetBtn)
    panel.deletePresetBtn = deletePresetBtn

    return row
end

-- "Afficher : [Tout] [Aucun]" — agit sur la liste de types juste au-dessus.
local function buildActionRow(panel)
    local row = AceGUI:Create("SimpleGroup")
    row:SetFullWidth(true)
    row:SetLayout("Flow")

    local actionLabel = AceGUI:Create("Label")
    actionLabel:SetWidth(80)
    actionLabel:SetText(MapTidy_L.ACTION_ROW_LABEL)
    row:AddChild(actionLabel)

    local showAllBtn = AceGUI:Create("Button")
    showAllBtn:SetText(MapTidy_L.SHOW_ALL)
    showAllBtn:SetWidth(80)
    showAllBtn:SetHeight(24)
    showAllBtn:SetCallback("OnClick", function()
        MapTidy.Settings.Reset()
        syncCheckboxes(panel)
        MapTidy.WorldMap.Refresh()
    end)
    showAllBtn:SetCallback("OnEnter", function(widget) showTooltip(widget.frame, MapTidy_L.TOOLTIP_SHOW_ALL) end)
    showAllBtn:SetCallback("OnLeave", hideTooltip)
    row:AddChild(showAllBtn)

    local hideAllBtn = AceGUI:Create("Button")
    hideAllBtn:SetText(MapTidy_L.HIDE_ALL)
    hideAllBtn:SetWidth(80)
    hideAllBtn:SetHeight(24)
    hideAllBtn:SetCallback("OnClick", function()
        for _, questType in ipairs(QUEST_TYPES) do
            MapTidy.Settings.Set(questType.key, false)
        end
        syncCheckboxes(panel)
        MapTidy.WorldMap.Refresh()
    end)
    hideAllBtn:SetCallback("OnEnter", function(widget) showTooltip(widget.frame, MapTidy_L.TOOLTIP_HIDE_ALL) end)
    hideAllBtn:SetCallback("OnLeave", hideTooltip)
    row:AddChild(hideAllBtn)

    return row
end

local function buildDescriptionLabel(text)
    local label = AceGUI:Create("Label")
    label:SetFullWidth(true)
    label:SetFontObject(GameFontDisableSmall)
    label:SetText(text)
    return label
end

local function createPanel()
    local panel = AceGUI:Create("Frame")
    panel:SetTitle("MapTidy")
    panel:SetStatusText(MapTidy_L.STATUS_HINT)
    panel:SetLayout("List")
    panel:SetWidth(420)
    panel:SetHeight(470)
    panel:SetCallback("OnClose", function(widget) widget.frame:Hide() end)

    -- Persistance de position/taille déléguée à AceGUI (drag + resize déjà
    -- intégrés au widget Frame) via une table stockée dans MapTidyCharDB.
    MapTidyCharDB.panelStatus = MapTidyCharDB.panelStatus or {}
    panel:SetStatusTable(MapTidyCharDB.panelStatus)

    -- Petite croix en haut à droite, en plus du bouton "Fermer" natif d'AceGUI :
    -- convention WoW attendue, absente du widget Frame par défaut.
    local closeBtn = CreateFrame("Button", nil, panel.frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", panel.frame, "TOPRIGHT", -4, -6)
    closeBtn:SetScript("OnClick", function() panel.frame:Hide() end)

    panel.checkboxes = {}
    panel.doneCheckboxes = {}

    panel:AddChild(buildDescriptionLabel(MapTidy_L.PANEL_SUBTITLE))
    panel:AddChild(buildColumnHeaderRow())
    for _, questType in ipairs(QUEST_TYPES) do
        panel:AddChild(buildTypeRow(panel, questType))
    end

    -- Tout afficher/Tout masquer agissent sur la liste de types ci-dessus : ils
    -- restent groupés avec elle, avant la séparation vers la section Presets,
    -- pour ne pas laisser croire qu'ils font partie de la gestion des presets.
    panel:AddChild(buildActionRow(panel))

    local divider = AceGUI:Create("Heading")
    divider:SetFullWidth(true)
    panel:AddChild(divider)

    panel:AddChild(buildPresetSelectRow(panel))
    panel:AddChild(buildPresetActionRow(panel))

    refreshPresetDropdown(panel)
    panel.frame:Hide()

    return panel
end

function MapTidy.Panel.Initialize()
    MapTidy.Panel.frame = createPanel()
end

function MapTidy.Panel.Toggle()
    local panel = MapTidy.Panel.frame
    if panel.frame:IsShown() then
        panel.frame:Hide()
    else
        syncCheckboxes(panel)
        refreshPresetDropdown(panel)
        panel.frame:Show()
    end
end
