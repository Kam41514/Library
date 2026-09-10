--[[
    MoonHubGUI
    ConfigManager.lua
    Version: 1.0.0

    Works with:
        Library.Flags
        Library.Options
        Library.Toggles

    Features:
        Save
        Load
        Delete
        Exists
        GetConfigs
        Export
        Import
        AutoLoad
]]

local ConfigManager = {}

ConfigManager.Version = "1.0.0"

ConfigManager.Library = nil
ConfigManager.Folder = "MoonHubGUI"
ConfigManager.AutoSave = false

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------

local HttpService = game:GetService("HttpService")

---------------------------------------------------------------------
-- FILESYSTEM
---------------------------------------------------------------------

local function HasFileSystem()
    return
        type(isfolder) == "function"
        and type(makefolder) == "function"
        and type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
        and type(delfile) == "function"
end

local function EnsureFolder()
    if not HasFileSystem() then
        return false
    end

    if not isfolder(ConfigManager.Folder) then
        pcall(function()
            makefolder(ConfigManager.Folder)
        end)
    end

    return true
end

local function GetPath(name)
    name = tostring(name or "")

    name = name:gsub("[^%w_%-%s]", "")
    name = name:gsub("%s+", "_")

    if name == "" then
        name = "Default"
    end

    return ConfigManager.Folder
        .. "/"
        .. name
        .. ".json"
end

---------------------------------------------------------------------
-- SERIALIZATION
---------------------------------------------------------------------

local function Serialize(value)
    local valueType = typeof(value)

    if valueType == "Color3" then
        return {
            __type = "Color3",

            R = value.R,
            G = value.G,
            B = value.B
        }
    end

    if valueType == "EnumItem" then
        return {
            __type = "EnumItem",

            EnumType =
                tostring(
                    value.EnumType
                ),

            Name = value.Name
        }
    end

    if valueType == "UDim2" then
        return {
            __type = "UDim2",

            XScale = value.X.Scale,
            XOffset = value.X.Offset,

            YScale = value.Y.Scale,
            YOffset = value.Y.Offset
        }
    end

    if type(value) == "table" then
        local result = {}

        for key, child in pairs(value) do
            result[tostring(key)] =
                Serialize(child)
        end

        return result
    end

    if valueType == "number"
        or valueType == "string"
        or valueType == "boolean" then

        return value
    end

    return nil
end

local function Deserialize(value)
    if type(value) ~= "table" then
        return value
    end

    if value.__type == "Color3" then
        return Color3.new(
            value.R or 1,
            value.G or 1,
            value.B or 1
        )
    end

    if value.__type == "EnumItem" then
        local enumName =
            tostring(
                value.EnumType or ""
            )

        enumName =
            enumName:gsub(
                "^Enum%.",
                ""
            )

        local enumObject =
            Enum[enumName]

        if enumObject then
            local success, result =
                pcall(function()
                    return enumObject[value.Name]
                end)

            if success then
                return result
            end
        end

        return nil
    end

    if value.__type == "UDim2" then
        return UDim2.new(
            value.XScale or 0,
            value.XOffset or 0,

            value.YScale or 0,
            value.YOffset or 0
        )
    end

    local result = {}

    for key, child in pairs(value) do
        result[key] =
            Deserialize(child)
    end

    return result
end

---------------------------------------------------------------------
-- INTERNAL VALUE SETTER
---------------------------------------------------------------------

local function SetOptionValue(
    option,
    value
)
    if not option then
        return false
    end

    if type(option.SetValue)
        ~= "function" then

        return false
    end

    local success = pcall(function()
        option:SetValue(
            value,
            true
        )
    end)

    return success
end

---------------------------------------------------------------------
-- SET LIBRARY
---------------------------------------------------------------------

function ConfigManager:SetLibrary(library)
    assert(
        type(library) == "table",
        "ConfigManager:SetLibrary expected Library table"
    )

    self.Library = library

    return self
end

---------------------------------------------------------------------
-- SET FOLDER
---------------------------------------------------------------------

function ConfigManager:SetFolder(folder)
    assert(
        type(folder) == "string",
        "ConfigManager:SetFolder expected string"
    )

    self.Folder = folder

    EnsureFolder()

    return self
end

---------------------------------------------------------------------
-- GET DATA
---------------------------------------------------------------------

function ConfigManager:GetData()
    assert(
        self.Library,
        "ConfigManager: Library has not been set"
    )

    local data = {}

    for flag, value in pairs(
        self.Library.Flags
    ) do

        local serialized =
            Serialize(value)

        if serialized ~= nil then
            data[flag] = serialized
        end
    end

    return data
end

---------------------------------------------------------------------
-- APPLY DATA
---------------------------------------------------------------------

function ConfigManager:ApplyData(data)
    assert(
        self.Library,
        "ConfigManager: Library has not been set"
    )

    if type(data) ~= "table" then
        return false
    end

    for flag, value in pairs(data) do
        local option =
            self.Library.Options[flag]

        if option then
            local deserialized =
                Deserialize(value)

            SetOptionValue(
                option,
                deserialized
            )
        end
    end

    return true
end

---------------------------------------------------------------------
-- SAVE
---------------------------------------------------------------------

function ConfigManager:Save(name)
    if not HasFileSystem() then
        return false,
            "Filesystem functions are unavailable"
    end

    if not self.Library then
        return false,
            "Library has not been set"
    end

    EnsureFolder()

    local path =
        GetPath(name)

    local data =
        self:GetData()

    local success, encoded =
        pcall(function()
            return HttpService:JSONEncode(
                data
            )
        end)

    if not success then
        return false,
            "Failed to encode config"
    end

    local writeSuccess =
        pcall(function()
            writefile(
                path,
                encoded
            )
        end)

    if not writeSuccess then
        return false,
            "Failed to write config"
    end

    self.CurrentConfig =
        tostring(name)

    return true
end

---------------------------------------------------------------------
-- LOAD
---------------------------------------------------------------------

function ConfigManager:Load(name)
    if not HasFileSystem() then
        return false,
            "Filesystem functions are unavailable"
    end

    if not self.Library then
        return false,
            "Library has not been set"
    end

    EnsureFolder()

    local path =
        GetPath(name)

    if not isfile(path) then
        return false,
            "Config does not exist"
    end

    local success, content =
        pcall(function()
            return readfile(path)
        end)

    if not success then
        return false,
            "Failed to read config"
    end

    local decodeSuccess, data =
        pcall(function()
            return HttpService:JSONDecode(
                content
            )
        end)

    if not decodeSuccess then
        return false,
            "Invalid config"
    end

    local applied =
        self:ApplyData(data)

    if not applied then
        return false,
            "Failed to apply config"
    end

    self.CurrentConfig =
        tostring(name)

    return true
end

---------------------------------------------------------------------
-- DELETE
---------------------------------------------------------------------

function ConfigManager:Delete(name)
    if not HasFileSystem() then
        return false,
            "Filesystem functions are unavailable"
    end

    EnsureFolder()

    local path =
        GetPath(name)

    if not isfile(path) then
        return false,
            "Config does not exist"
    end

    local success =
        pcall(function()
            delfile(path)
        end)

    if not success then
        return false,
            "Failed to delete config"
    end

    if self.CurrentConfig
        == tostring(name) then

        self.CurrentConfig = nil
    end

    return true
end

---------------------------------------------------------------------
-- EXISTS
---------------------------------------------------------------------

function ConfigManager:Exists(name)
    if not HasFileSystem() then
        return false
    end

    EnsureFolder()

    return isfile(
        GetPath(name)
    )
end

---------------------------------------------------------------------
-- LIST CONFIGS
---------------------------------------------------------------------

function ConfigManager:GetConfigs()
    local configs = {}

    if not HasFileSystem() then
        return configs
    end

    EnsureFolder()

    if type(listfiles) ~= "function" then
        return configs
    end

    local success, files =
        pcall(function()
            return listfiles(
                self.Folder
            )
        end)

    if not success
        or type(files) ~= "table" then

        return configs
    end

    for _, path in ipairs(files) do
        local name =
            tostring(path)
                :match(
                    "([^/\\]+)%.json$"
                )

        if name then
            table.insert(
                configs,
                name
            )
        end
    end

    table.sort(configs)

    return configs
end

---------------------------------------------------------------------
-- EXPORT
---------------------------------------------------------------------

function ConfigManager:Export()
    if not self.Library then
        return nil,
            "Library has not been set"
    end

    local data =
        self:GetData()

    local success, encoded =
        pcall(function()
            return HttpService:JSONEncode(
                data
            )
        end)

    if not success then
        return nil,
            "Failed to encode config"
    end

    return encoded
end

---------------------------------------------------------------------
-- IMPORT
---------------------------------------------------------------------

function ConfigManager:Import(encoded)
    if not self.Library then
        return false,
            "Library has not been set"
    end

    if type(encoded) ~= "string" then
        return false,
            "Import data must be a string"
    end

    local success, data =
        pcall(function()
            return HttpService:JSONDecode(
                encoded
            )
        end)

    if not success then
        return false,
            "Invalid import data"
    end

    return self:ApplyData(data)
end

---------------------------------------------------------------------
-- AUTO SAVE
---------------------------------------------------------------------

function ConfigManager:SetAutoSave(enabled)
    self.AutoSave =
        enabled == true

    return self
end

function ConfigManager:SaveCurrent()
    if not self.CurrentConfig then
        return false,
            "No current config"
    end

    return self:Save(
        self.CurrentConfig
    )
end

---------------------------------------------------------------------
-- AUTO SAVE HOOK
---------------------------------------------------------------------

function ConfigManager:HookAutoSave()
    if not self.Library then
        return self
    end

    for _, option in pairs(
        self.Library.Options
    ) do

        if option.OnChanged
            and not option.__ConfigHooked then

            option.__ConfigHooked = true

            local oldCallback =
                option.Callback

            option:OnChanged(
                function(value)

                    if oldCallback then
                        task.spawn(
                            oldCallback,
                            value
                        )
                    end

                    if self.AutoSave
                        and self.CurrentConfig then

                        task.defer(function()
                            self:SaveCurrent()
                        end)
                    end
                end
            )
        end
    end

    return self
end

---------------------------------------------------------------------
-- CURRENT CONFIG
---------------------------------------------------------------------

function ConfigManager:GetCurrentConfig()
    return self.CurrentConfig
end

---------------------------------------------------------------------
-- RESET
---------------------------------------------------------------------

function ConfigManager:Reset()
    if not self.Library then
        return self
    end

    for flag, option in pairs(
        self.Library.Options
    ) do

        if option.Default ~= nil then
            SetOptionValue(
                option,
                option.Default
            )
        end
    end

    return self
end

---------------------------------------------------------------------
-- INITIALIZE
---------------------------------------------------------------------

function ConfigManager:Init(library)
    self:SetLibrary(
        library
    )

    EnsureFolder()

    return self
end

return ConfigManager
