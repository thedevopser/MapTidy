MapTidy.Changelog = {}

function MapTidy.Changelog.ShouldShow(seenVersion, currentVersion)
    return seenVersion ~= currentVersion
end
