local ThemeManager = {
Library = nil,
Folder = "Library",
ThemeFolder = "Themes",
Themes = {},
Initialized = false,
}

local HttpService = game:GetService("HttpService")

local DEFAULT_THEME = {
BackgroundColor = Color3.fromRGB(8, 8, 8),
StrokeColor = Color3.fromRGB(18, 18, 18),
TextColor = Color3.fromRGB(235, 235, 235),
SubTextColor = Color3.fromRGB(155, 155, 155),
AccentColor = Color3.fromRGB(120, 170, 255),
AccentColorDark = Color3.fromRGB(75, 115, 190),
ControlColor = Color3.fromRGB(14, 14, 14),
HoverColor = Color3.fromRGB(24, 24, 24),
ActiveColor = Color3.fromRGB(30, 30, 30),
BorderColor = Color3.fromRGB(18, 18, 18),
TabColor = Color3.fromRGB(11, 11, 11),
TabActiveColor = Color3.fromRGB(20, 20, 20),
}

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

if type(value) == "table" then
	local result = {}

	for key, item in pairs(value) do
		result[tostring(key)] = Serialize(item)
	end

	return result
end

return value


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

local result = {}

for key, item in pairs(value) do
	result[key] = Deserialize(item)
end

return result


end

local function EnsureFolder(path)
if isfolder and makefolder and not isfolder(path) then
makefolder(path)
end
end

local function GetThemePath(self, name)
return self.Folder .. "/" .. self.ThemeFolder .. "/" .. tostring(name) .. ".json"
end

function ThemeManager:Init(Library, options)
self.Library = Library
options = options or {}

self.Folder = options.Folder or self.Folder
self.ThemeFolder = options.ThemeFolder or self.ThemeFolder

self.Themes = {
	Default = DeepCopy(DEFAULT_THEME),
}

EnsureFolder(self.Folder)
EnsureFolder(self.Folder .. "/" .. self.ThemeFolder)

self.Initialized = true

return self


end

function ThemeManager:GetDefaultTheme()
return DeepCopy(DEFAULT_THEME)
end

function ThemeManager:GetTheme(name)
name = tostring(name or "Default")

if self.Themes[name] then
	return DeepCopy(self.Themes[name])
end

return nil


end

function ThemeManager:Register(name, theme)
if type(name) ~= "string" or name == "" then
return false, "Invalid theme name."
end

if type(theme) ~= "table" then
	return false, "Invalid theme."
end

self.Themes[name] = DeepCopy(theme)

return true


end

function ThemeManager:SaveTheme(name, theme)
if not writefile then
return false, "writefile is not available."
end

name = tostring(name or "Default")

theme = theme or self.Themes[name]

if not theme then
	return false, "Theme does not exist."
end

EnsureFolder(self.Folder)
EnsureFolder(self.Folder .. "/" .. self.ThemeFolder)

local encodedSuccess, encoded = pcall(function()
	return HttpService:JSONEncode(Serialize(theme))
end)

if not encodedSuccess then
	return false, tostring(encoded)
end

local success, errorMessage = pcall(function()
	writefile(GetThemePath(self, name), encoded)
end)

if not success then
	return false, tostring(errorMessage)
end

return true


end

function ThemeManager:LoadTheme(name)
if not isfile or not readfile then
return false, "File APIs are not available."
end

name = tostring(name or "Default")

local path = GetThemePath(self, name)

if not isfile(path) then
	return false, "Theme does not exist."
end

local success, content = pcall(function()
	return readfile(path)
end)

if not success then
	return false, tostring(content)
end

local decodeSuccess, data = pcall(function()
	return HttpService:JSONDecode(content)
end)

if not decodeSuccess or type(data) ~= "table" then
	return false, "Invalid theme file."
end

self.Themes[name] = Deserialize(data)

return true, self.Themes[name]


end

function ThemeManager:DeleteTheme(name)
if not isfile or not delfile then
return false, "File APIs are not available."
end

name = tostring(name or "Default")

if name == "Default" then
	return false, "Default theme cannot be deleted."
end

local path = GetThemePath(self, name)

if not isfile(path) then
	return false, "Theme does not exist."
end

local success, errorMessage = pcall(function()
	delfile(path)
end)

if not success then
	return false, tostring(errorMessage)
end

self.Themes[name] = nil

return true


end

function ThemeManager:GetThemes()
local themes = {}

for name in pairs(self.Themes) do
	table.insert(themes, name)
end

if listfiles then
	local path = self.Folder .. "/" .. self.ThemeFolder

	if isfolder and isfolder(path) then
		for _, file in ipairs(listfiles(path)) do
			local name = file:match("([^/\\]+)%.json$")

			if name and not table.find(themes, name) then
				table.insert(themes, name)
			end
		end
	end
end

table.sort(themes)

return themes


end

function ThemeManager:ApplyTheme(name)
name = tostring(name or "Default")

local theme = self.Themes[name]

if not theme and isfile and isfile(GetThemePath(self, name)) then
	local success = self:LoadTheme(name)

	if not success then
		return false, "Failed to load theme."
	end

	theme = self.Themes[name]
end

if not theme then
	return false, "Theme does not exist."
end

if not self.Library then
	return false, "Library is not initialized."
end

if type(self.Library.SetTheme) == "function" then
	local success, errorMessage = pcall(function()
		self.Library:SetTheme(theme)
	end)

	if not success then
		return false, tostring(errorMessage)
	end
elseif type(self.Library.ApplyTheme) == "function" then
	local success, errorMessage = pcall(function()
		self.Library:ApplyTheme(theme)
	end)

	if not success then
		return false, tostring(errorMessage)
	end
else
	self.Library.Theme = DeepCopy(theme)

	if type(self.Library.RefreshTheme) == "function" then
		pcall(function()
			self.Library:RefreshTheme()
		end)
	end
end

return true


end

function ThemeManager:BuildThemeSection(groupbox)
if not groupbox then
return nil
end

local themeNames = self:GetThemes()
local currentTheme = "Default"

groupbox:AddDropdown("ThemeSelector", {
	Text = "Theme",
	Values = themeNames,
	Default = "Default",
	Callback = function(value)
		currentTheme = tostring(value or "Default")
	end,
})

groupbox:AddButton({
	Text = "Apply Theme",
	Func = function()
		local success, errorMessage = self:ApplyTheme(currentTheme)

		if self.Library and self.Library.Notify then
			self.Library:Notify({
				Title = success and "Theme Applied" or "Theme Error",
				Description = success
					and ("Applied: " .. currentTheme)
					or tostring(errorMessage),
				Time = 3,
			})
		end
	end,
})

groupbox:AddButton({
	Text = "Save Theme",
	Func = function()
		local theme = self.Themes[currentTheme]

		if not theme then
			if self.Library and self.Library.Notify then
				self.Library:Notify({
					Title = "Theme Error",
					Description = "Theme does not exist.",
					Time = 3,
				})
			end

			return
		end

		local success, errorMessage = self:SaveTheme(currentTheme, theme)

		if self.Library and self.Library.Notify then
			self.Library:Notify({
				Title = success and "Theme Saved" or "Theme Error",
				Description = success
					and ("Saved: " .. currentTheme)
					or tostring(errorMessage),
				Time = 3,
			})
		end
	end,
})

groupbox:AddButton({
	Text = "Load Theme",
	Func = function()
		local success, errorMessage = self:LoadTheme(currentTheme)

		if success then
			self:ApplyTheme(currentTheme)
		end

		if self.Library and self.Library.Notify then
			self.Library:Notify({
				Title = success and "Theme Loaded" or "Theme Error",
				Description = success
					and ("Loaded: " .. currentTheme)
					or tostring(errorMessage),
				Time = 3,
			})
		end
	end,
})

groupbox:AddDivider()

groupbox:AddLabel({
	Text = "Background: 8, 8, 8",
})

groupbox:AddLabel({
	Text = "Stroke: 18, 18, 18",
})

return groupbox


end

function ThemeManager:SetFolder(folder, themeFolder)
self.Folder = tostring(folder or "Library")
self.ThemeFolder = tostring(themeFolder or "Themes")

EnsureFolder(self.Folder)
EnsureFolder(self.Folder .. "/" .. self.ThemeFolder)


end

function ThemeManager:GetPath(name)
return GetThemePath(self, name)
end

return ThemeManager
