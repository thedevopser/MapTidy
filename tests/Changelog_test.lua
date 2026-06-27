dofile("tests/mock_wow_api.lua")
dofile("Core/Changelog.lua")

describe("Changelog.ShouldShow", function()
    it("affiche si aucune version vue", function()
        assert.is_true(MapTidy.Changelog.ShouldShow(nil, "1.4.0"))
    end)

    it("n'affiche pas si version vue = version courante", function()
        assert.is_false(MapTidy.Changelog.ShouldShow("1.4.0", "1.4.0"))
    end)

    it("affiche si version vue différente", function()
        assert.is_true(MapTidy.Changelog.ShouldShow("1.3.0", "1.4.0"))
    end)
end)
