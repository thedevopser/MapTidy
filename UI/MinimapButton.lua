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

local function positionWorldMapButton(btn)
    local mapLeft   = WorldMapFrame:GetLeft()
    local mapTop    = WorldMapFrame:GetTop()
    local mapWidth  = WorldMapFrame:GetWidth()
    local mapHeight = WorldMapFrame:GetHeight()
    if not mapLeft or mapWidth == 0 then
        btn:ClearAllPoints()
        btn:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -5, -150)
        return
    end

    -- Zone cible : bande droite (> 85 % de la largeur), dans le tiers supérieur uniquement
    -- Exclut les boutons de coin inférieurs (?, close, etc.)
    local xThreshold = mapLeft + mapWidth * 0.85
    local yMinimum   = mapTop - mapHeight * 0.40

    local lowestFrame  = nil
    local lowestBottom = math.huge

    for _, child in ipairs({ WorldMapFrame:GetChildren() }) do
        if child ~= btn and child:IsShown() then
            local w, h = child:GetSize()
            if w > 0 and w <= 50 and h > 0 and h <= 50 then
                local cx, cy = child:GetCenter()
                if cx and cy and cx > xThreshold and cy > yMinimum then
                    local bottom = child:GetBottom()
                    if bottom and bottom < lowestBottom then
                        lowestBottom = bottom
                        lowestFrame  = child
                    end
                end
            end
        end
    end

    btn:ClearAllPoints()
    if lowestFrame then
        btn:SetPoint("TOP", lowestFrame, "BOTTOM", 0, -5)
    else
        btn:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -5, -150)
    end
end

local function createWorldMapButton()
    if not WorldMapFrame then return nil end
    local btn = CreateFrame("Button", "MapTidyWorldMapButton", WorldMapFrame)
    btn:SetSize(22, 22)
    btn:SetFrameStrata("DIALOG")
    btn:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 100)
    btn:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -5, -150)

    WorldMapFrame:HookScript("OnShow", function()
        positionWorldMapButton(btn)
    end)

    if WorldMapFrame:IsShown() then
        positionWorldMapButton(btn)
    end

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture(ADDON_PATH .. "Textures\\icon")
    icon:SetAllPoints()

    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetAllPoints()
    highlight:SetBlendMode("ADD")

    btn:SetScript("OnClick", function()
        MapTidy.Panel.Toggle()
    end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("MapTidy")
        GameTooltip:AddLine(MapTidy_L.TOOLTIP_LEFT_CLICK, 1, 1, 1)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return btn
end

function MapTidy.WorldMapButton.Initialize()
    if not WorldMapFrame then return end
    MapTidy.WorldMapButton.frame = createWorldMapButton()
end
