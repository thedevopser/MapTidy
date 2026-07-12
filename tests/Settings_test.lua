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

local WARBAND_TYPES = {"Campaign", "Important", "Legendary", "Meta", "Repeatable", "LocalStory"}

describe("Settings — HideWarbandCompleted par type", function()
    before_each(function()
        _G.MapTidyCharDB = nil
        MapTidy.Settings.Initialize()
    end)

    it("vaut true par défaut pour chaque type filtrable (hors Expedition)", function()
        for _, t in ipairs(WARBAND_TYPES) do
            assert.is_true(MapTidy.Settings.Get("HideWarbandCompleted_" .. t), t)
        end
    end)

    it("n'a pas de clé warband pour Expedition", function()
        assert.is_nil(MapTidy.Settings.Get("HideWarbandCompleted_Expedition"))
    end)

    it("Reset() met les types à true et les 6 clés warband à false", function()
        MapTidy.Settings.Set("Campaign", false)
        MapTidy.Settings.Set("HideWarbandCompleted_Campaign", true)
        MapTidy.Settings.Reset()
        assert.is_true(MapTidyCharDB.Campaign)
        for _, t in ipairs(WARBAND_TYPES) do
            assert.is_false(MapTidyCharDB["HideWarbandCompleted_" .. t], t)
        end
    end)
end)

describe("Settings — migration HideWarbandCompleted (ancienne clé globale)", function()
    it("propage true vers les 6 clés par type et supprime l'ancienne clé", function()
        _G.MapTidyCharDB = { HideWarbandCompleted = true }
        MapTidy.Settings.Initialize()
        for _, t in ipairs(WARBAND_TYPES) do
            assert.is_true(MapTidyCharDB["HideWarbandCompleted_" .. t], t)
        end
        assert.is_nil(MapTidyCharDB.HideWarbandCompleted)
    end)

    it("propage false vers les 6 clés par type et supprime l'ancienne clé", function()
        _G.MapTidyCharDB = { HideWarbandCompleted = false }
        MapTidy.Settings.Initialize()
        for _, t in ipairs(WARBAND_TYPES) do
            assert.is_false(MapTidyCharDB["HideWarbandCompleted_" .. t], t)
        end
        assert.is_nil(MapTidyCharDB.HideWarbandCompleted)
    end)

    it("sans ancienne clé, initialise directement les 6 clés à true", function()
        _G.MapTidyCharDB = nil
        MapTidy.Settings.Initialize()
        for _, t in ipairs(WARBAND_TYPES) do
            assert.is_true(MapTidyCharDB["HideWarbandCompleted_" .. t], t)
        end
    end)
end)

describe("Settings.Presets", function()
    before_each(function()
        _G.MapTidyCharDB = nil
        _G.MapTidyDB = nil
        MapTidy.Settings.Initialize()
    end)

    it("SavePreset capture les 13 clés de filtrage sous le nom donné", function()
        MapTidy.Settings.Set("Campaign", false)
        MapTidy.Settings.Set("HideWarbandCompleted_Campaign", false)
        MapTidy.Settings.SavePreset("Leveling")
        local saved = MapTidyDB.presets["Leveling"]
        assert.is_not_nil(saved)
        assert.is_false(saved.Campaign)
        assert.is_true(saved.Important)
        assert.is_false(saved.HideWarbandCompleted_Campaign)
        assert.is_true(saved.HideWarbandCompleted_Legendary)
        assert.is_true(saved.Expedition)
    end)

    it("SavePreset n'inclut pas les réglages UI", function()
        MapTidy.Settings.Set("panelX", 42)
        MapTidy.Settings.Set("minimapAngle", 99)
        MapTidy.Settings.Set("debug", true)
        MapTidy.Settings.SavePreset("Leveling")
        local saved = MapTidyDB.presets["Leveling"]
        assert.is_nil(saved.panelX)
        assert.is_nil(saved.minimapAngle)
        assert.is_nil(saved.debug)
    end)

    it("SavePreset(nil) ne crée aucune entrée", function()
        MapTidy.Settings.SavePreset(nil)
        assert.is_nil(MapTidyDB)
    end)

    it("SavePreset('') et SavePreset('   ') ne créent aucune entrée", function()
        MapTidy.Settings.SavePreset("")
        MapTidy.Settings.SavePreset("   ")
        assert.is_nil(MapTidyDB)
    end)

    it("SavePreset écrase silencieusement un preset existant du même nom", function()
        MapTidy.Settings.SavePreset("Leveling")
        MapTidy.Settings.Set("Campaign", false)
        MapTidy.Settings.SavePreset("Leveling")
        assert.is_false(MapTidyDB.presets["Leveling"].Campaign)
    end)

    it("SavePreset trim les espaces autour du nom", function()
        MapTidy.Settings.SavePreset("  Leveling  ")
        assert.is_not_nil(MapTidyDB.presets["Leveling"])
        assert.is_nil(MapTidyDB.presets["  Leveling  "])
    end)

    it("LoadPreset applique les 13 clés sur MapTidyCharDB et fixe activePreset", function()
        MapTidy.Settings.Set("Campaign", false)
        MapTidy.Settings.Set("HideWarbandCompleted_Legendary", false)
        MapTidy.Settings.SavePreset("Leveling")
        MapTidy.Settings.Set("Campaign", true)
        MapTidy.Settings.Set("HideWarbandCompleted_Legendary", true)
        MapTidy.Settings.LoadPreset("Leveling")
        assert.is_false(MapTidy.Settings.Get("Campaign"))
        assert.is_false(MapTidy.Settings.Get("HideWarbandCompleted_Legendary"))
        assert.equals("Leveling", MapTidyCharDB.activePreset)
    end)

    it("LoadPreset('inconnu') est un no-op fail-safe", function()
        MapTidy.Settings.Set("Campaign", false)
        MapTidy.Settings.LoadPreset("inconnu")
        assert.is_false(MapTidy.Settings.Get("Campaign"))
        assert.is_nil(MapTidyCharDB.activePreset)
    end)

    it("DeletePreset retire l'entrée", function()
        MapTidy.Settings.SavePreset("Leveling")
        MapTidy.Settings.DeletePreset("Leveling")
        assert.is_nil(MapTidyDB.presets["Leveling"])
    end)

    it("DeletePreset('inconnu') est un no-op", function()
        MapTidy.Settings.SavePreset("Leveling")
        MapTidy.Settings.DeletePreset("inconnu")
        assert.is_not_nil(MapTidyDB.presets["Leveling"])
    end)

    it("ListPresetNames renvoie les noms triés alphabétiquement", function()
        MapTidy.Settings.SavePreset("Zebra")
        MapTidy.Settings.SavePreset("Alpha")
        MapTidy.Settings.SavePreset("Mike")
        assert.same({ "Alpha", "Mike", "Zebra" }, MapTidy.Settings.ListPresetNames())
    end)

    it("ListPresetNames renvoie {} si aucun preset", function()
        assert.same({}, MapTidy.Settings.ListPresetNames())
    end)

    it("GetActivePresetName renvoie le nom si le preset existe encore", function()
        MapTidy.Settings.SavePreset("Leveling")
        MapTidy.Settings.LoadPreset("Leveling")
        assert.equals("Leveling", MapTidy.Settings.GetActivePresetName())
    end)

    it("GetActivePresetName renvoie nil si le preset actif a été supprimé", function()
        MapTidy.Settings.SavePreset("Leveling")
        MapTidy.Settings.LoadPreset("Leveling")
        MapTidy.Settings.DeletePreset("Leveling")
        assert.is_nil(MapTidy.Settings.GetActivePresetName())
    end)

    it("GetActivePresetName renvoie nil si aucun preset n'a jamais été chargé", function()
        assert.is_nil(MapTidy.Settings.GetActivePresetName())
    end)
end)
