local HttpService = game:GetService("HttpService")

local PathManager = {}

local Paths = {}

local function SerializePoint(Point)
    return {
        Position = {
            X = Point.Position.X,
            Y = Point.Position.Y,
            Z = Point.Position.Z
        },

        Reset = Point.Reset == true,

        WaitTime = tonumber(Point.WaitTime) or 0
    }
end

local function DeserializePoint(Point)
    return {
        Position = Vector3.new(
            tonumber(Point.Position.X) or 0,
            tonumber(Point.Position.Y) or 0,
            tonumber(Point.Position.Z) or 0
        ),

        Reset = Point.Reset == true,

        WaitTime = tonumber(Point.WaitTime) or 0
    }
end

function PathManager.SavePath(Name, Points)
    assert(type(Name) == "string", "Path name must be a string")
    assert(type(Points) == "table", "Points must be a table")

    local Data = {
        Name = Name,
        Points = {}
    }

    for _, Point in ipairs(Points) do
        table.insert(
            Data.Points,
            SerializePoint(Point)
        )
    end

    Paths[Name] = Data

    return true, Data
end

function PathManager.LoadPath(Name)
    local Data = Paths[Name]

    if not Data then
        return nil
    end

    local Result = {
        Name = Data.Name,
        Points = {}
    }

    for _, Point in ipairs(Data.Points) do
        table.insert(
            Result.Points,
            DeserializePoint(Point)
        )
    end

    return Result
end

function PathManager.DeletePath(Name)
    if not Paths[Name] then
        return false
    end

    Paths[Name] = nil

    return true
end

function PathManager.GetPaths()
    local Names = {}

    for Name in pairs(Paths) do
        table.insert(
            Names,
            Name
        )
    end

    table.sort(Names)

    return Names
end

function PathManager.Exists(Name)
    return Paths[Name] ~= nil
end

function PathManager.ExportJSON(Name)
    local Data = Paths[Name]

    if not Data then
        return nil
    end

    return HttpService:JSONEncode(Data)
end

function PathManager.ImportJSON(JSON)
    local Success, Data = pcall(function()
        return HttpService:JSONDecode(JSON)
    end)

    if not Success or type(Data) ~= "table" then
        return false
    end

    if type(Data.Name) ~= "string"
        or type(Data.Points) ~= "table"
    then
        return false
    end

    Paths[Data.Name] = Data

    return true
end

function PathManager.Clear()
    table.clear(Paths)
end

return PathManager
