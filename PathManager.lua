local HttpService = game:GetService("HttpService")

local PathManager = {}

local FOLDER_NAME = "PathingPaths"

local Paths = {}

local function HasFileAPI()
    return
        type(isfolder) == "function"
        and type(makefolder) == "function"
        and type(isfile) == "function"
        and type(writefile) == "function"
        and type(readfile) == "function"
        and type(delfile) == "function"
end

local function EnsureFolder()
    if not HasFileAPI() then
        return false, "Executor file API desteklemiyor."
    end

    local Success, Result = pcall(function()
        if not isfolder(FOLDER_NAME) then
            makefolder(FOLDER_NAME)
        end

        return true
    end)

    if not Success then
        return false, tostring(Result)
    end

    return true
end

local function SanitizeName(Name)
    Name = tostring(Name or "")

    Name = Name:gsub("[<>:\"/\\|%?%*]", "_")
    Name = Name:gsub("[%c]", "_")

    Name = Name:gsub("^%s+", "")
    Name = Name:gsub("%s+$", "")

    if Name == "" then
        Name = "Unnamed Path"
    end

    return Name
end

local function GetFileName(Name)
    return FOLDER_NAME ..
        "/" ..
        SanitizeName(Name) ..
        ".json"
end

local function SerializePoint(Point)
    return {
        Position = {
            X = Point.Position.X,
            Y = Point.Position.Y,
            Z = Point.Position.Z
        },

        Reset = Point.Reset == true,

        WaitTime =
            tonumber(Point.WaitTime) or 0
    }
end

local function DeserializePoint(Point)
    if type(Point) ~= "table" then
        return nil
    end

    local Position =
        Point.Position

    if type(Position) ~= "table" then
        return nil
    end

    return {
        Position = Vector3.new(
            tonumber(Position.X) or 0,
            tonumber(Position.Y) or 0,
            tonumber(Position.Z) or 0
        ),

        Reset =
            Point.Reset == true,

        WaitTime =
            tonumber(Point.WaitTime) or 0
    }
end

local function BuildData(Name, Points)
    local Data = {
        Name = tostring(Name),
        Points = {}
    }

    for _, Point in ipairs(Points) do
        if Point.Position then
            table.insert(
                Data.Points,
                SerializePoint(Point)
            )
        end
    end

    return Data
end

local function SaveDataToFile(Data)
    local FolderSuccess,
        FolderError =
        EnsureFolder()

    if not FolderSuccess then
        return false, FolderError
    end

    local FilePath =
        GetFileName(Data.Name)

    local Success, Error =
        pcall(function()

            local JSON =
                HttpService:JSONEncode(Data)

            writefile(
                FilePath,
                JSON
            )

        end)

    if not Success then
        return false, tostring(Error)
    end

    return true, FilePath
end

local function LoadDataFromFile(FilePath)
    if not HasFileAPI() then
        return nil
    end

    if not isfile(FilePath) then
        return nil
    end

    local Success, Result =
        pcall(function()

            local JSON =
                readfile(FilePath)

            return HttpService:JSONDecode(
                JSON
            )

        end)

    if not Success then
        return nil
    end

    if type(Result) ~= "table" then
        return nil
    end

    if type(Result.Name) ~= "string" then
        return nil
    end

    if type(Result.Points) ~= "table" then
        return nil
    end

    return Result
end

local function CacheData(Data)
    if not Data then
        return
    end

    Paths[Data.Name] = Data
end

function PathManager.Refresh()
    table.clear(Paths)

    local FolderSuccess =
        EnsureFolder()

    if not FolderSuccess then
        return false
    end

    local Success, Files =
        pcall(function()
            return listfiles(FOLDER_NAME)
        end)

    if not Success
        or type(Files) ~= "table"
    then
        return false
    end

    for _, FilePath in ipairs(Files) do

        if type(FilePath) == "string"
            and FilePath:lower():sub(-5) == ".json"
        then

            local Data =
                LoadDataFromFile(FilePath)

            if Data then
                CacheData(Data)
            end
        end
    end

    return true
end

function PathManager.SavePath(
    Name,
    Points
)
    assert(
        type(Name) == "string",
        "Path name must be a string"
    )

    assert(
        type(Points) == "table",
        "Points must be a table"
    )

    Name = Name:gsub("^%s+", "")
    Name = Name:gsub("%s+$", "")

    if Name == "" then
        return false,
            "Path name cannot be empty."
    end

    local Data =
        BuildData(
            Name,
            Points
        )

    local Success, Error =
        SaveDataToFile(Data)

    if not Success then
        return false, Error
    end

    Paths[Name] = Data

    return true, Data
end

function PathManager.LoadPath(Name)
    assert(
        type(Name) == "string",
        "Path name must be a string"
    )

    local SafeName =
        SanitizeName(Name)

    local FilePath =
        GetFileName(SafeName)

    local Data =
        LoadDataFromFile(FilePath)

    if not Data then
        Data = Paths[Name]
    end

    if not Data then
        return nil
    end

    local Result = {
        Name = Data.Name,
        Points = {}
    }

    for _, Point in ipairs(Data.Points) do

        local NewPoint =
            DeserializePoint(Point)

        if NewPoint then
            table.insert(
                Result.Points,
                NewPoint
            )
        end

    end

    Paths[Data.Name] = Data

    return Result
end

function PathManager.DeletePath(Name)
    if type(Name) ~= "string" then
        return false
    end

    local SafeName =
        SanitizeName(Name)

    local FilePath =
        GetFileName(SafeName)

    local Deleted = false

    if HasFileAPI() then

        local Success =
            pcall(function()

                if isfile(FilePath) then
                    delfile(FilePath)
                    Deleted = true
                end

            end)

        if not Success then
            return false
        end
    end

    if Paths[Name] then
        Paths[Name] = nil
        Deleted = true
    end

    return Deleted
end

function PathManager.GetPaths()
    PathManager.Refresh()

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
    if type(Name) ~= "string" then
        return false
    end

    local SafeName =
        SanitizeName(Name)

    local FilePath =
        GetFileName(SafeName)

    if HasFileAPI() then
        local Success, Result =
            pcall(function()
                return isfile(FilePath)
            end)

        if Success and Result then
            return true
        end
    end

    return Paths[Name] ~= nil
end

function PathManager.ExportJSON(Name)
    local Data = nil

    local Loaded =
        PathManager.LoadPath(Name)

    if Loaded then
        Data = {
            Name = Loaded.Name,
            Points = {}
        }

        for _, Point in ipairs(
            Loaded.Points
        ) do

            table.insert(
                Data.Points,
                SerializePoint(Point)
            )

        end
    end

    if not Data then
        return nil
    end

    local Success, JSON =
        pcall(function()
            return HttpService:JSONEncode(
                Data
            )
        end)

    if not Success then
        return nil
    end

    return JSON
end

function PathManager.ImportJSON(JSON)
    if type(JSON) ~= "string" then
        return false
    end

    local Success, Data =
        pcall(function()
            return HttpService:JSONDecode(
                JSON
            )
        end)

    if not Success
        or type(Data) ~= "table"
    then
        return false
    end

    if type(Data.Name) ~= "string"
        or type(Data.Points) ~= "table"
    then
        return false
    end

    local Points = {}

    for _, Point in ipairs(
        Data.Points
    ) do

        local NewPoint =
            DeserializePoint(Point)

        if not NewPoint then
            return false
        end

        table.insert(
            Points,
            NewPoint
        )
    end

    local SaveSuccess =
        PathManager.SavePath(
            Data.Name,
            Points
        )

    return SaveSuccess == true
end

function PathManager.Clear()
    table.clear(Paths)
end

function PathManager.GetFolderName()
    return FOLDER_NAME
end

function PathManager.GetFolderPath()
    return FOLDER_NAME
end

local FolderOK =
    EnsureFolder()

if FolderOK then
    PathManager.Refresh()
end

return PathManager
