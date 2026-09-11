local ConfigManager = {
Library = nil,
Folder = "Library",
ConfigFolder = "Configs",
Initialized = false,
}

local HttpService = game:GetService("HttpService")

local function EnsureFolder(path)
if not isfolder(path) then
makefolder(path)
end
end

local function DeepCopy(value)
if type(value) ~= "table" then
return value
end

local result = {}

for key, item in pairs(value) do
	result[key] = DeepCopy(item)
end

return result


end

local function Serialize(value)
if typeof(value) == "Color3" then
return {
__type = "Color3",
R = value.R,
G = value.G,
B = value.B,
}
end

if typeof(value) == "EnumItem" then
	return {
		__type = "EnumItem",
		EnumType = tostring(value.EnumType),
		Name = value.Name,
	}
end

if type(value) == "table" then
	local result = {}

	for key, item in pairs(value) do
		result[tostring(key)] = Serialize(item)
	end

	return result
end

if type(value) == "string"
	or type(value) == "number"
	or type(value) == "boolean"
	or value == nil then
	return value
end

return tostring(value)


end

local function Deserialize(value)
if type(value) ~= "table" then
return value
end

if value.__type == "Color3" then
	return Color3.new(
		tonumber(value.R) or 0,
		tonumber(value.G) or 0,
		tonumber(value.B) or 0
	)
end

if value.__type == "EnumItem" then
	local enumName = tostring(value.EnumType):match("Enum%.(.+)")

	if enumName and Enum[enumName] then
		local success, result = pcall(function()
			return Enum[enumName][value.Name]
		end)

		if success then
			return result
		end
	end

	return value.Name
end

local result = {}

for key, item in pairs(value) do
	result[key] = Deserialize(item)
end

return result


end

local function GetConfigPath(self, name)
return self.Folder .. "/" .. self.ConfigFolder .. "/" .. tostring(name) .. ".json"
end

function ConfigManager:Init(Library, options)
self.Library = Library
options = options or {}

self.Folder = options.Folder or self.Folder
self.ConfigFolder = options.ConfigFolder or self.ConfigFolder

if isfolder then
	EnsureFolder(self.Folder)
	EnsureFolder(self.Folder .. "/" .. self.ConfigFolder)
end

self.Initialized = true

return self


end

function ConfigManager:GetConfigs()
local configs = {}

if not listfiles then
	return configs
end

local path = self.Folder .. "/" .. self.ConfigFolder

if not isfolder(path) then
	return configs
end

for _, file in ipairs(listfiles(path)) do
	local name = file:match("([^/\\]+)%.json$")

	if name then
		table.insert(configs, name)
	end
end

table.sort(configs)

return configs


end

function ConfigManager:Save(name)
if not self.Library then
return false, "Library is not initialized."
end

if not writefile then
	return false, "writefile is not available."
end

name = tostring(name or "Default")

if name == "" then
	return false, "Invalid config name."
end

if isfolder then
	EnsureFolder(self.Folder)
	EnsureFolder(self.Folder .. "/" .. self.ConfigFolder)
end

local data = {
	Version = 1,
	Name = name,
	Options = {},
}

for flag, option in pairs(self.Library.Options or {}) do
	if type(option) == "table" then
		local value = option.Value

		if value ~= nil then
			data.Options[flag] = Serialize(DeepCopy(value))
		end
	end
end

local success, encoded = pcall(function()
	return HttpService:JSONEncode(data)
end)

if not success then
	return false, tostring(encoded)
end

local path = GetConfigPath(self, name)

local saved, errorMessage = pcall(function()
	writefile(path, encoded)
end)

if not saved then
	return false, tostring(errorMessage)
end

return true


end

function ConfigManager:Load(name)
if not self.Library then
return false, "Library is not initialized."
end

if not isfile or not readfile then
	return false, "File APIs are not available."
end

name = tostring(name or "Default")

local path = GetConfigPath(self, name)

if not isfile(path) then
	return false, "Config does not exist."
end

local success, content = pcall(function()
	return readfile(path)
end)

if not success then
	return false, tostring(content)
end

local decodedSuccess, data = pcall(function()
	return HttpService:JSONDecode(content)
end)

if not decodedSuccess then
	return false, "Invalid config file."
end

if type(data) ~= "table" or type(data.Options) ~= "table" then
	return false, "Invalid config structure."
end

for flag, value in pairs(data.Options) do
	local option = self.Library.Options[flag]

	if option and type(option.SetValue) == "function" then
		local decodedValue = Deserialize(value)

		pcall(function()
			option:SetValue(decodedValue)
		end)
	end
end

return true


end

function ConfigManager:Delete(name)
name = tostring(name or "Default")

if not isfile or not delfile then
	return false, "File APIs are not available."
end

local path = GetConfigPath(self, name)

if not isfile(path) then
	return false, "Config does not exist."
end

local success, errorMessage = pcall(function()
	delfile(path)
end)

if not success then
	return false, tostring(errorMessage)
end

return true


end

function ConfigManager:HasConfig(name)
if not isfile then
return false
end

return isfile(GetConfigPath(self, tostring(name or "Default")))


end

function ConfigManager:RefreshConfigList()
return self:GetConfigs()
end

function ConfigManager:BuildConfigSection(groupbox)
if not groupbox then
return nil
end

local currentConfig = "Default"

groupbox:AddInput("ConfigName", {
	Text = "Config Name",
	Default = "Default",
	Placeholder = "Config name...",
	Finished = true,
	Callback = function(value)
		if tostring(value or "") ~= "" then
			currentConfig = tostring(value)
		end
	end,
})

groupbox:AddButton({
	Text = "Save Config",
	Func = function()
		local success, errorMessage = self:Save(currentConfig)

		if self.Library and self.Library.Notify then
			self.Library:Notify({
				Title = success and "Config Saved" or "Config Error",
				Description = success
					and ("Saved: " .. currentConfig)
					or tostring(errorMessage),
				Time = 3,
			})
		end
	end,
})

groupbox:AddButton({
	Text = "Load Config",
	Func = function()
		local success, errorMessage = self:Load(currentConfig)

		if self.Library and self.Library.Notify then
			self.Library:Notify({
				Title = success and "Config Loaded" or "Config Error",
				Description = success
					and ("Loaded: " .. currentConfig)
					or tostring(errorMessage),
				Time = 3,
			})
		end
	end,
})

groupbox:AddButton({
	Text = "Delete Config",
	Risky = true,
	Func = function()
		local success, errorMessage = self:Delete(currentConfig)

		if self.Library and self.Library.Notify then
			self.Library:Notify({
				Title = success and "Config Deleted" or "Config Error",
				Description = success
					and ("Deleted: " .. currentConfig)
					or tostring(errorMessage),
				Time = 3,
			})
		end
	end,
})

groupbox:AddDivider()

groupbox:AddLabel({
	Text = "Available configs",
})

groupbox:AddButton({
	Text = "Print Configs",
	Func = function()
		local configs = self:GetConfigs()

		for _, configName in ipairs(configs) do
			print(configName)
		end

		if self.Library and self.Library.Notify then
			self.Library:Notify({
				Title = "Configs",
				Description = #configs > 0
					and table.concat(configs, ", ")
					or "No configs found.",
				Time = 3,
			})
		end
	end,
})

return groupbox


end

function ConfigManager:SetFolder(folder, configFolder)
self.Folder = tostring(folder or "Library")
self.ConfigFolder = tostring(configFolder or "Configs")

if isfolder then
	EnsureFolder(self.Folder)
	EnsureFolder(self.Folder .. "/" .. self.ConfigFolder)
end


end

function ConfigManager:GetPath(name)
return GetConfigPath(self, name)
end

return ConfigManager
