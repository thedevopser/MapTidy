dofile("tests/mock_wow_api.lua")
dofile("Core/Settings.lua")

describe("Settings.Initialize", function()
    before_each(function()
        _G.MapTidyCharDB = nil
    end)

    it("crée MapTidyCharDB avec les 6 filtres à true si nil", function()
        MapTidy.Settings.Initialize()
        assert.is_not_nil(MapTidyCharDB)
        assert.is_true(MapTidyCharDB.Campaign)
        assert.is_true(MapTidyCharDB.Important)
        assert.is_true(MapTidyCharDB.Legendary)
        assert.is_true(MapTidyCharDB.Meta)
        assert.is_true(MapTidyCharDB.Repeatable)
        assert.is_true(MapTidyCharDB.LocalStory)
        assert.is_true(MapTidyCharDB.Expedition)
    end)

    it("ne remplace pas les valeurs existantes", function()
        _G.MapTidyCharDB = { Campaign = false }
        MapTidy.Settings.Initialize()
        assert.is_false(MapTidyCharDB.Campaign)
        assert.is_true(MapTidyCharDB.Important)
    end)

    it("initialise minimapAngle à 225", function()
        MapTidy.Settings.Initialize()
        assert.equals(225, MapTidyCharDB.minimapAngle)
    end)
end)

describe("Settings.Get / Set", function()
    before_each(function()
        _G.MapTidyCharDB = nil
        MapTidy.Settings.Initialize()
    end)

    it("Get retourne la valeur stockée", function()
        assert.is_true(MapTidy.Settings.Get("Campaign"))
    end)

    it("Set met à jour la valeur", function()
        MapTidy.Settings.Set("Campaign", false)
        assert.is_false(MapTidy.Settings.Get("Campaign"))
    end)
end)

describe("Settings.Reset", function()
    before_each(function()
        _G.MapTidyCharDB = nil
        MapTidy.Settings.Initialize()
    end)

    it("remet les filtres à true", function()
        MapTidy.Settings.Set("Campaign", false)
        MapTidy.Settings.Set("Repeatable", false)
        MapTidy.Settings.Set("Expedition", false)
        MapTidy.Settings.Reset()
        assert.is_true(MapTidy.Settings.Get("Campaign"))
        assert.is_true(MapTidy.Settings.Get("Repeatable"))
        assert.is_true(MapTidy.Settings.Get("Expedition"))
    end)

    it("ne touche pas à la position UI", function()
        MapTidy.Settings.Set("panelX", 100)
        MapTidy.Settings.Reset()
        assert.equals(100, MapTidy.Settings.Get("panelX"))
    end)
end)

describe("Settings — HideWarbandCompleted", function()
    before_each(function()
        _G.MapTidyCharDB = nil
        MapTidy.Settings.Initialize()
    end)

    it("vaut true par défaut", function()
        assert.is_true(MapTidy.Settings.Get("HideWarbandCompleted"))
    end)

    it("Reset() met les types à true et HideWarbandCompleted à false", function()
        MapTidy.Settings.Set("Campaign", false)
        MapTidy.Settings.Set("HideWarbandCompleted", true)
        MapTidy.Settings.Reset()
        assert.is_true(MapTidyCharDB.Campaign)
        assert.is_false(MapTidyCharDB.HideWarbandCompleted)
    end)
end)
