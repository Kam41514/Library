--[[
    MoonHubGUI
    ConfigManager.lua
    Version: 1.0.0

    Works with MoonHubGUI Library.lua

    Features:
        - Save config
        - Load config
        - Delete config
        - Get config list
        - Auto config folder
        - JSON serialization
        - Library.Flags integration
]]

local ConfigManager = {}

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------

local HttpService = game:GetService("HttpService")

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------

ConfigManager.Folder =
    "MoonHubGUI"

ConfigManager.ConfigFolder =
    "Configs"

ConfigManager.AutoSave =
    false

ConfigManager.AutoSaveInterval =
    60

---------------------------------------------------------------------
-- INTERNAL
---------------------------------------------------------------------

local AutoSaveThread
local Started = false

local function GetFileSystem()
    return {
        isfolder = isfolder,
        makefolder = makefolder,
        isfile = isfile,
        writefile = writefile,
        readfile = readfile,
        delfile = delfile
    }
end

local FS = GetFileSystem()

---------------------------------------------------------------------
-- SAFETY
---------------------------------------------------------------------

local function HasFunction(name)
    return typeof(FS[name]) == "function"
end

local function CanUseFileSystem()
    return HasFunction("isfolder")
        and HasFunction("makefolder")
        and HasFunction("isfile")
        and HasFunction("writefile")
        and HasFunction("readfile")
        and HasFunction("delfile")
end

---------------------------------------------------------------------
-- PATH
---------------------------------------------------------------------

function ConfigManager:GetFolder()
    return self.Folder
end

function ConfigManager:GetConfigFolder()
    return self.Folder
        .. "/"
        .. self.ConfigFolder
end

function ConfigManager:GetPath(name)
    return self:GetConfigFolder()
        .. "/"
        .. tostring(name)
        .. ".json"
end

---------------------------------------------------------------------
-- FOLDER
---------------------------------------------------------------------

function ConfigManager:CreateFolders()
    if not CanUseFileSystem() then
        return false
    end

    pcall(function()
        if not FS.isfile then
            return
        end
    end)

    if not FS.isfolder(
        self.Folder
    ) then
        FS.makefolder(
            self.Folder
        )
    end

    local configFolder =
        self:GetConfigFolder()

    if not FS.isfolder(
        configFolder
    ) then
        FS.makefolder(
            configFolder
        )
    end

    return true
end

---------------------------------------------------------------------
-- SERIALIZATION
---------------------------------------------------------------------

local function SerializeValue(value)
    local valueType =
        typeof(value)

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

    if valueType == "CFrame" then
        local components = {
            value:GetComponents()
        }

        return {
            __type = "CFrame",

            Components =
                components
        }
    end

    if valueType == "Vector2" then
        return {
            __type = "Vector2",

            X = value.X,

            Y = value.Y
        }
    end

    if valueType == "Vector3" then
        return {
            __type = "Vector3",

            X = value.X,

            Y = value.Y,

            Z = value.Z
        }
    end

    if type(value) == "table" then
        local result = {}

        for key, item in pairs(value) do
            result[tostring(key)] =
                SerializeValue(item)
        end

        return result
    end

    if valueType == "string"
        or valueType == "number"
        or valueType == "boolean"
        or value == nil then

        return value
    end

    return tostring(value)
end

local function DeserializeValue(value)
    if type(value) ~= "table" then
        return value
    end

    if value.__type == "Color3" then
        return Color3.new(
            tonumber(value.R) or 1,
            tonumber(value.G) or 1,
            tonumber(value.B) or 1
        )
    end

    if value.__type == "Vector2" then
        return Vector2.new(
            tonumber(value.X) or 0,
            tonumber(value.Y) or 0
        )
    end

    if value.__type == "Vector3" then
        return Vector3.new(
            tonumber(value.X) or 0,
            tonumber(value.Y) or 0,
            tonumber(value.Z) or 0
        )
    end

    if value.__type == "CFrame" then
        if type(value.Components)
            == "table" then

            return CFrame.new(
                table.unpack(
                    value.Components
                )
            )
        end
    end

    if value.__type == "EnumItem" then
        local enumName =
            tostring(
                value.EnumType
                or ""
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
                    return enumObject[
                        value.Name
                    ]
                end)

            if success then
                return result
            end
        end
    end

    local result = {}

    for key, item in pairs(value) do
        result[key] =
            DeserializeValue(item)
    end

    return result
end

---------------------------------------------------------------------
-- COLLECT
---------------------------------------------------------------------

function ConfigManager:GetData()
    local data = {}

    if not self.Library then
        return data
    end

    local flags =
        self.Library.Flags
        or {}

    for flag, value in pairs(flags) do
        data[flag] =
            SerializeValue(value)
    end

    return data
end

---------------------------------------------------------------------
-- APPLY
---------------------------------------------------------------------

function ConfigManager:ApplyData(data)
    if not self.Library then
        return false
    end

    if type(data) ~= "table" then
        return false
    end

    local options =
        self.Library.Options
        or {}

    for flag, value in pairs(data) do
        local option =
            options[flag]

        local decoded =
            DeserializeValue(value)

        if option then
            pcall(function()
                if option.SetValue then
                    option:SetValue(
                        decoded,
                        true
                    )
                else
                    option.Value =
                        decoded
                end
            end)
        end

        self.Library.Flags[flag] =
            decoded
    end

    return true
end

---------------------------------------------------------------------
-- SAVE
---------------------------------------------------------------------

function ConfigManager:Save(name)
    if not CanUseFileSystem() then
        warn(
            "[MoonHubGUI] FileSystem API is unavailable."
        )

        return false
    end

    name = tostring(name)

    if name == ""
        or name:find("[/\\]") then

        warn(
            "[MoonHubGUI] Invalid config name."
        )

        return false
    end

    self:CreateFolders()

    local data =
        self:GetData()

    local success, encoded =
        pcall(
            HttpService.JSONEncode,
            HttpService,
            data
        )

    if not success then
        warn(
            "[MoonHubGUI] Failed to encode config."
        )

        return false
    end

    local path =
        self:GetPath(name)

    local writeSuccess =
        pcall(
            FS.writefile,
            path,
            encoded
        )

    if not writeSuccess then
        warn(
            "[MoonHubGUI] Failed to save config."
        )

        return false
    end

    self.LastConfig =
        name

    return true
end

---------------------------------------------------------------------
-- LOAD
---------------------------------------------------------------------

function ConfigManager:Load(name)
    if not CanUseFileSystem() then
        warn(
            "[MoonHubGUI] FileSystem API is unavailable."
        )

        return false
    end

    name = tostring(name)

    local path =
        self:GetPath(name)

    if not FS.isfile(path) then
        warn(
            "[MoonHubGUI] Config does not exist: "
            .. name
        )

        return false
    end

    local success, content =
        pcall(
            FS.readfile,
            path
        )

    if not success then
        warn(
            "[MoonHubGUI] Failed to read config."
        )

        return false
    end

    local decodeSuccess, data =
        pcall(
            HttpService.JSONDecode,
            HttpService,
            content
        )

    if not decodeSuccess then
        warn(
            "[MoonHubGUI] Invalid config file."
        )

        return false
    end

    local applied =
        self:ApplyData(data)

    if applied then
        self.LastConfig =
            name
    end

    return applied
end

---------------------------------------------------------------------
-- DELETE
---------------------------------------------------------------------

function ConfigManager:Delete(name)
    if not CanUseFileSystem() then
        warn(
            "[MoonHubGUI] FileSystem API is unavailable."
        )

        return false
    end

    name = tostring(name)

    local path =
        self:GetPath(name)

    if not FS.isfile(path) then
        return false
    end

    local success =
        pcall(
            FS.delfile,
            path
        )

    if success
        and self.LastConfig == name then

        self.LastConfig = nil
    end

    return success
end

---------------------------------------------------------------------
-- EXISTS
---------------------------------------------------------------------

function ConfigManager:Exists(name)
    if not CanUseFileSystem() then
        return false
    end

    return FS.isfile(
        self:GetPath(name)
    )
end

---------------------------------------------------------------------
-- LIST
---------------------------------------------------------------------

function ConfigManager:List()
    local configs = {}

    if not listfiles then
        return configs
    end

    self:CreateFolders()

    local success, files =
        pcall(
            listfiles,
            self:GetConfigFolder()
        )

    if not success
        or type(files) ~= "table" then

        return configs
    end

    for _, file in ipairs(files) do
        local name =
            tostring(file)
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
-- CLEAR
---------------------------------------------------------------------

function ConfigManager:Clear()
    local configs =
        self:List()

    for _, name in ipairs(configs) do
        self:Delete(name)
    end

    self.LastConfig = nil

    return true
end

---------------------------------------------------------------------
-- LIBRARY CONNECTION
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
-- AUTOSAVE
---------------------------------------------------------------------

function ConfigManager:SetAutoSave(enabled, interval)
    self.AutoSave =
        enabled == true

    if interval then
        self.AutoSaveInterval =
            tonumber(interval)
            or self.AutoSaveInterval
    end

    return self
end

function ConfigManager:StartAutoSave()
    if Started then
        return self
    end

    Started = true

    AutoSaveThread =
        task.spawn(function()
            while Started do
                task.wait(
                    self.AutoSaveInterval
                )

                if not Started then
                    break
                end

                if self.AutoSave
                    and self.LastConfig then

                    pcall(function()
                        self:Save(
                            self.LastConfig
                        )
                    end)
                end
            end
        end)

    return self
end

function ConfigManager:StopAutoSave()
    Started = false

    AutoSaveThread = nil

    return self
end

---------------------------------------------------------------------
-- QUICK CONFIG
---------------------------------------------------------------------

function ConfigManager:SaveLast()
    if not self.LastConfig then
        return false
    end

    return self:Save(
        self.LastConfig
    )
end

function ConfigManager:LoadLast()
    if not self.LastConfig then
        return false
    end

    return self:Load(
        self.LastConfig
    )
end

---------------------------------------------------------------------
-- EXPORT
---------------------------------------------------------------------

function ConfigManager:Export()
    local data =
        self:GetData()

    local success, encoded =
        pcall(
            HttpService.JSONEncode,
            HttpService,
            data
        )

    if success then
        return encoded
    end

    return nil
end

---------------------------------------------------------------------
-- IMPORT
---------------------------------------------------------------------

function ConfigManager:Import(json)
    if type(json) ~= "string" then
        return false
    end

    local success, data =
        pcall(
            HttpService.JSONDecode,
            HttpService,
            json
        )

    if not success then
        return false
    end

    return self:ApplyData(data)
end

---------------------------------------------------------------------
-- INITIALIZE
---------------------------------------------------------------------

function ConfigManager:Init(library)
    if library then
        self:SetLibrary(
            library
        )
    end

    self:CreateFolders()

    if self.AutoSave then
        self:StartAutoSave()
    end

    return self
end

---------------------------------------------------------------------
-- DESTROY
---------------------------------------------------------------------

function ConfigManager:Unload()
    self:StopAutoSave()

    self.Library = nil

    self.LastConfig = nil
end

---------------------------------------------------------------------
-- RETURN
---------------------------------------------------------------------

return ConfigManager
