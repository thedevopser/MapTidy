MapTidy.MinimapButton = {}
MapTidy.WorldMapButton = {}

local ADDON_PATH = "Interface\\AddOns\\MapTidy\\"

local function positionButton(button, angle)
    button:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(math.rad(angle)) * 80,
        math.sin(math.rad(angle)) * 80)
end

local function createButton()
    local button = CreateFrame("Button", "MapTidyMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture(ADDON_PATH .. "Textures\\icon")
    icon:SetSize(27, 27)
    icon:SetPoint("CENTER")

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetAllPoints()
    highlight:SetBlendMode("ADD")

    positionButton(button, MapTidy.Settings.Get("minimapAngle"))

    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(self)
        self.dragging = true
    end)
    button:SetScript("OnDragStop", function(self)
        self.dragging = false
    end)
    button:SetScript("OnUpdate", function(self)
        if not self.dragging then return end
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale  = UIParent:GetEffectiveScale()
        local angle  = math.deg(math.atan2(cy / scale - my, cx / scale - mx))
        MapTidy.Settings.Set("minimapAngle", angle)
        positionButton(self, angle)
    end)

    button:SetScript("OnClick", function(self, btn)
        if btn == "LeftButton" then
            MapTidy.Panel.Toggle()
        elseif btn == "RightButton" then
            MapTidy.Settings.Reset()
            MapTidy.WorldMap.Refresh()
            print(MapTidy_L.SHOW_ALL_MSG)
        end
    end)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("MapTidy")
        GameTooltip:AddLine(MapTidy_L.TOOLTIP_LEFT_CLICK, 1, 1, 1)
        GameTooltip:AddLine(MapTidy_L.TOOLTIP_RIGHT_CLICK, 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return button
end

function MapTidy.MinimapButton.Initialize()
    MapTidy.MinimapButton.frame = createButton()
end

MapTidyWorldMapButtonMixin = {}

function MapTidyWorldMapButtonMixin:OnLoad()
    self:SetFrameLevel(self:GetParent():GetFrameLevel() + 100)
end

function MapTidyWorldMapButtonMixin:OnClick()
    MapTidy.Panel.Toggle()
end

function MapTidyWorldMapButtonMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("MapTidy")
    GameTooltip:AddLine(MapTidy_L.TOOLTIP_LEFT_CLICK, 1, 1, 1)
    GameTooltip:Show()
end

function MapTidyWorldMapButtonMixin:Refresh()
end

function MapTidy.WorldMapButton.Initialize()
    if not WorldMapFrame then return end
    MapTidy.WorldMapButton.frame = LibStub("Krowi_WorldMapButtons-1.4"):Add(
        "MapTidyWorldMapButtonTemplate", "Button")
end
