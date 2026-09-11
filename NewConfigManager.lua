local HttpService = game:GetService("HttpService")

local ConfigManager = {}
ConfigManager.__index = ConfigManager

ConfigManager.Folder = "MoonHubUI"
ConfigManager.File = "config.json"

local function getOptions()
	local ok, Library = pcall(function()
		return require(script.Parent.Library)
	end)

	if not ok or not Library then
		return {}
	end

	return Library.Options or {}
end

local function serialize(value)
	local valueType = typeof(value)

	if valueType == "Color3" then
		return {
			__type = "Color3",
			R = value.R,
			G = value.G,
			B = value.B
		}
	elseif valueType == "EnumItem" then
		return {
			__type = "EnumItem",
			EnumType = tostring(value.EnumType),
			Name = value.Name
		}
	elseif valueType == "table" then
		local result = {}

		for key, item in pairs(value) do
			if typeof(key) == "string" or typeof(key) == "number" then
				result[key] = serialize(item)
			end
		end

		return result
	elseif valueType == "string"
		or valueType == "number"
		or valueType == "boolean"
		or valueType == "nil" then
		return value
	end

	return nil
end

local function deserialize(value)
	if typeof(value) ~= "table" then
		return value
	end

	if value.__type == "Color3" then
		return Color3.new(
			tonumber(value.R) or 1,
			tonumber(value.G) or 1,
			tonumber(value.B) or 1
		)
	end

	if value.__type == "EnumItem" then
		local enumType = tostring(value.EnumType):match("Enum%.(.+)")

		if enumType and Enum[enumType] and Enum[enumType][value.Name] then
			return Enum[enumType][value.Name]
		end

		return nil
	end

	local result = {}

	for key, item in pairs(value) do
		if key ~= "__type" then
			result[key] = deserialize(item)
		end
	end

	return result
end

local function hasFileSystem()
	return type(isfolder) == "function"
		and type(makefolder) == "function"
		and type(isfile) == "function"
		and type(readfile) == "function"
		and type(writefile) == "function"
end

function ConfigManager:_GetPath(name)
	name = tostring(name or "Default")

	if name == "" then
		name = "Default"
	end

	return self.Folder .. "/" .. name .. ".json"
end

function ConfigManager:_EnsureFolder()
	if not hasFileSystem() then
		return false
	end

	if not isfolder(self.Folder) then
		pcall(makefolder, self.Folder)
	end

	return isfolder(self.Folder)
end

function ConfigManager:_Collect()
	local options = getOptions()
	local data = {}

	for index, option in pairs(options) do
		if type(option) == "table" then
			local value

			if option.Value ~= nil then
				value = option.Value
			elseif option.CurrentValue ~= nil then
				value = option.CurrentValue
			elseif option.State ~= nil then
				value = option.State
			end

			if value ~= nil then
				local serialized = serialize(value)

				if serialized ~= nil then
					data[index] = serialized
				end
			end
		end
	end

	return data
end

function ConfigManager:_Apply(data)
	if type(data) ~= "table" then
		return false
	end

	local options = getOptions()

	for index, savedValue in pairs(data) do
		local option = options[index]

		if option then
			local value = deserialize(savedValue)

			if value ~= nil then
				local applied = false

				if type(option.SetValue) == "function" then
					local ok = pcall(function()
						option:SetValue(value)
					end)

					applied = ok
				end

				if not applied and option.Type == "Toggle" then
					option.Value = value

					if option.Display then
						pcall(function()
							option:Display()
						end)
					end
				elseif not applied and option.Type == "Slider" then
					option.Value = tonumber(value) or option.Value

					if option.Display then
						pcall(function()
							option:Display()
						end)
					end
				elseif not applied and option.Type == "Input" then
					option.Value = tostring(value)
				elseif not applied and option.Type == "Dropdown" then
					option.Value = value
				end
			end
		end
	end

	return true
end

function ConfigManager:Save(name)
	name = tostring(name or "Default")

	if not self:_EnsureFolder() then
		return false, "Filesystem API unavailable"
	end

	local data = self:_Collect()

	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(data)
	end)

	if not ok then
		return false, "Failed to encode configuration"
	end

	local path = self:_GetPath(name)

	local success, err = pcall(function()
		writefile(path, encoded)
	end)

	if not success then
		return false, err or "Failed to write configuration"
	end

	self.CurrentConfig = name

	return true
end

function ConfigManager:Load(name)
	name = tostring(name or "Default")

	if not hasFileSystem() then
		return false, "Filesystem API unavailable"
	end

	local path = self:_GetPath(name)

	if not isfile(path) then
		return false, "Configuration does not exist"
	end

	local success, contents = pcall(function()
		return readfile(path)
	end)

	if not success or type(contents) ~= "string" then
		return false, "Failed to read configuration"
	end

	local decodedSuccess, data = pcall(function()
		return HttpService:JSONDecode(contents)
	end)

	if not decodedSuccess or type(data) ~= "table" then
		return false, "Invalid configuration"
	end

	local applied = self:_Apply(data)

	if not applied then
		return false, "Failed to apply configuration"
	end

	self.CurrentConfig = name

	return true
end

function ConfigManager:Delete(name)
	name = tostring(name or "Default")

	if not hasFileSystem() then
		return false, "Filesystem API unavailable"
	end

	local path = self:_GetPath(name)

	if not isfile(path) then
		return false, "Configuration does not exist"
	end

	local success, err = pcall(function()
		delfile(path)
	end)

	if not success then
		return false, err or "Failed to delete configuration"
	end

	if self.CurrentConfig == name then
		self.CurrentConfig = nil
	end

	return true
end

function ConfigManager:Exists(name)
	name = tostring(name or "Default")

	if not hasFileSystem() then
		return false
	end

	return isfile(self:_GetPath(name))
end

function ConfigManager:GetConfigs()
	local configs = {}

	if not self:_EnsureFolder() then
		return configs
	end

	if type(listfiles) ~= "function" then
		return configs
	end

	local success, files = pcall(function()
		return listfiles(self.Folder)
	end)

	if not success or type(files) ~= "table" then
		return configs
	end

	for _, path in ipairs(files) do
		local name = tostring(path):match("[^/\\]+$")

		if name then
			name = name:gsub("%.json$", "")

			if name ~= "" then
				table.insert(configs, name)
			end
		end
	end

	table.sort(configs)

	return configs
end

function ConfigManager:SetFolder(folder)
	if folder and tostring(folder) ~= "" then
		self.Folder = tostring(folder)
	end

	return self
end

function ConfigManager:SetLibrary(library)
	self.Library = library
	return self
end

function ConfigManager:BuildConfigSection(groupbox)
	if not groupbox then
		return nil
	end

	local manager = self

	groupbox:AddInput("ConfigName", {
		Text = "Config Name",
		Default = "Default",
		Placeholder = "Configuration name",
		Finished = true,
		Callback = function(value)
			manager.SelectedConfig = tostring(value)
		end
	})

	groupbox:AddButton({
		Text = "Save Config",
		Func = function()
			manager:Save(manager.SelectedConfig or "Default")
		end
	})

	groupbox:AddButton({
		Text = "Load Config",
		Func = function()
			manager:Load(manager.SelectedConfig or "Default")
		end
	})

	groupbox:AddButton({
		Text = "Delete Config",
		Risky = true,
		Func = function()
			manager:Delete(manager.SelectedConfig or "Default")
		end
	})

	return self
end

function ConfigManager:Init(library)
	self.Library = library
	self.SelectedConfig = "Default"

	if library then
		library.ConfigManager = self
	end

	return self
end

return setmetatable({}, ConfigManager)
