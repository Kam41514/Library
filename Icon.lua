--// MoonHub Custom Icons

local Icons = {}

Icons.Moon = {
    AssetId = 4512627654,
    Name = "Moon"
}

function Icons:Get(Name)
    local Icon = self[Name]

    if not Icon then
        return nil
    end

    return Icon.AssetId
end

return Icons
