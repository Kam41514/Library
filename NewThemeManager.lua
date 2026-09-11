local ThemeManager = {}

ThemeManager.Library = nil
ThemeManager.CurrentTheme = "Default"
ThemeManager.Themes = {}

ThemeManager.Themes.Default = {
	Background = Color3.fromRGB(8, 8, 8),
	Frame = Color3.fromRGB(9, 9, 9),
	Surface = Color3.fromRGB(11, 11, 11),
	Surface2 = Color3.fromRGB(14, 14, 14),
	Stroke = Color3.fromRGB(18, 18, 18),

	Text = Color3.fromRGB(242, 242, 242),
	SubText = Color3.fromRGB(155, 155, 155),
	Disabled = Color3.fromRGB(78, 78, 78),

	Accent = Color3.fromRGB(128, 92, 255),
	AccentDark = Color3.fromRGB(91, 62, 190),

	White = Color3.fromRGB(255, 255, 255),
	Red = Color3.fromRGB(225, 75, 75),
}

local function IsColor3(value)
	return typeof(value) == "Color3"
end

local function CopyTheme(theme)
	local copy = {}

	for key, value in pairs(theme) do
		copy[key] = value
	end

	return copy
end

local function SetProperty(object, property, value)
	if not object then
		return
	end

	pcall(function()
		object[property] = value
	end)
end

local function ApplyObject(object, theme)
	if not object or not object:IsA("GuiObject") then
		return
	end

	local name = object.Name

	if name == "Window" then
		SetProperty(object, "BackgroundColor3", theme.Background)

	elseif name == "Topbar" then
		SetProperty(object, "BackgroundColor3", theme.Background)

	elseif name == "Sidebar" then
		SetProperty(object, "BackgroundColor3", theme.Frame)

	elseif name == "Content" then
		SetProperty(object, "BackgroundColor3", theme.Background)

	elseif name == "Title" then
		SetProperty(object, "TextColor3", theme.Text)

	elseif name == "Footer" then
		SetProperty(object, "TextColor3", theme.SubText)

	elseif name == "Accent" then
		SetProperty(object, "BackgroundColor3", theme.Accent)

	elseif name == "Separator" then
		SetProperty(object, "BackgroundColor3", theme.Stroke)

	elseif name == "Label" then
		if object:IsA("TextLabel") then
			if object.TextColor3 ~= Color3.fromRGB(255, 255, 255) then
				SetProperty(object, "TextColor3", theme.Text)
			end
		end

	elseif name == "Value" then
		if object:IsA("TextLabel") then
			SetProperty(object, "TextColor3", theme.SubText)
		end

	elseif name == "Text" then
		if object:IsA("TextLabel") then
			SetProperty(object, "TextColor3", theme.SubText)
		end

	elseif name == "Button" then
		if object:IsA("TextButton") then
			SetProperty(object, "BackgroundColor3", theme.Surface2)

			if object.TextColor3 ~= Color3.fromRGB(225, 75, 75) then
				SetProperty(object, "TextColor3", theme.Text)
			end
		elseif object:IsA("TextLabel") then
			SetProperty(object, "TextColor3", theme.Text)
		end

	elseif name == "Holder" then
		SetProperty(object, "BackgroundColor3", theme.Surface)

	elseif name == "Checkbox" then
		SetProperty(object, "BackgroundColor3", theme.Surface2)

	elseif name == "Bar" then
		SetProperty(object, "BackgroundColor3", theme.Surface2)

	elseif name == "Fill" then
		SetProperty(object, "BackgroundColor3", theme.Accent)

	elseif name == "Popup" or name == "DropdownPopup" then
		SetProperty(object, "BackgroundColor3", theme.Background)

	elseif name == "Options" then
		SetProperty(object, "ScrollBarImageColor3", theme.Accent)

	elseif name == "Check" then
		SetProperty(object, "TextColor3", theme.White)

	elseif name == "Tabs" then
		SetProperty(object, "BackgroundColor3", theme.Surface)

	elseif name == "General"
		or name == "Extra"
		or name == "Themes"
		or name == "Actions"
		or name == "Configuration"
		or name == "Controls"
		or name == "Values"
	then
		SetProperty(object, "BackgroundColor3", theme.Background)
	end

	if object:IsA("TextButton") then
		if object.Name ~= "Button" and object.Name ~= "Holder" then
			if object.TextColor3 ~= Color3.fromRGB(225, 75, 75) then
				SetProperty(object, "TextColor3", theme.SubText)
			end
		end
	end

	if object:IsA("TextBox") then
		SetProperty(object, "BackgroundColor3", theme.Surface2)
		SetProperty(object, "TextColor3", theme.Text)
		SetProperty(object, "PlaceholderColor3", theme.Disabled)
	end

	for _, child in ipairs(object:GetChildren()) do
		if child:IsA("UIStroke") then
			child.Color = theme.Stroke
		end
	end
end

function ThemeManager:Init(library)
	self.Library = library

	local defaultTheme = self:GetTheme("Default")

	if defaultTheme then
		self:ApplyTheme("Default")
	end

	return self
end

function ThemeManager:RegisterTheme(name, theme)
	assert(typeof(name) == "string", "Theme name must be a string")
	assert(typeof(theme) == "table", "Theme must be a table")

	local base = self:GetTheme("Default") or {}

	local finalTheme = CopyTheme(base)

	for key, value in pairs(theme) do
		if IsColor3(value) then
			finalTheme[key] = value
		end
	end

	self.Themes[name] = finalTheme

	return finalTheme
end

function ThemeManager:AddTheme(name, theme)
	return self:RegisterTheme(name, theme)
end

function ThemeManager:GetTheme(name)
	return self.Themes[name]
end

function ThemeManager:GetThemes()
	local result = {}

	for name in pairs(self.Themes) do
		table.insert(result, name)
	end

	table.sort(result)

	return result
end

function ThemeManager:GetCurrentTheme()
	return self.CurrentTheme
end

function ThemeManager:GetCurrentThemeData()
	return self.Themes[self.CurrentTheme]
end

function ThemeManager:SetColor(name, color)
	local theme = self:GetTheme(self.CurrentTheme)

	if not theme then
		return false, "Current theme does not exist"
	end

	if not IsColor3(color) then
		return false, "Color must be Color3"
	end

	theme[name] = color

	self:Refresh()

	return true
end

function ThemeManager:GetColor(name)
	local theme = self:GetTheme(self.CurrentTheme)

	if not theme then
		return nil
	end

	return theme[name]
end

function ThemeManager:ApplyTheme(name)
	local theme = self:GetTheme(name)

	if not theme then
		return false, "Theme not found: " .. tostring(name)
	end

	if not self.Library then
		return false, "ThemeManager is not initialized"
	end

	self.CurrentTheme = name

	local library = self.Library

	if library.Window and library.Window.ScreenGui then
		for _, object in ipairs(library.Window.ScreenGui:GetDescendants()) do
			ApplyObject(object, theme)
		end

		ApplyObject(library.Window.ScreenGui, theme)
	end

	if library.Window and library.Window.Main then
		ApplyObject(library.Window.Main, theme)
	end

	if library.Window and library.Window.Topbar then
		ApplyObject(library.Window.Topbar, theme)
	end

	if library.Window and library.Window.Sidebar then
		ApplyObject(library.Window.Sidebar, theme)
	end

	if library.Window and library.Window.Content then
		ApplyObject(library.Window.Content, theme)
	end

	for _, object in pairs(library.Options or {}) do
		if typeof(object) == "table" then
			if object.Button then
				ApplyObject(object.Button, theme)
			end

			if object.Label then
				ApplyObject(object.Label, theme)
			end

			if object.TextBox then
				ApplyObject(object.TextBox, theme)
			end

			if object.Checkbox then
				ApplyObject(object.Checkbox, theme)
			end

			if object.Fill then
				ApplyObject(object.Fill, theme)
			end

			if object.Bar then
				ApplyObject(object.Bar, theme)
			end
		end
	end

	self:RefreshStrokes()

	return true
end

function ThemeManager:Refresh()
	return self:ApplyTheme(self.CurrentTheme)
end

function ThemeManager:RefreshStrokes()
	if not self.Library then
		return
	end

	local theme = self:GetTheme(self.CurrentTheme)

	if not theme then
		return
	end

	local gui

	if self.Library.Window then
		gui = self.Library.Window.ScreenGui
	end

	if not gui then
		return
	end

	for _, object in ipairs(gui:GetDescendants()) do
		if object:IsA("UIStroke") then
			object.Color = theme.Stroke
			object.Thickness = 1
			object.Transparency = 0
		end
	end
end

function ThemeManager:SaveTheme(name)
	local theme = self:GetTheme(name or self.CurrentTheme)

	if not theme then
		return nil
	end

	return CopyTheme(theme)
end

function ThemeManager:LoadTheme(name, data)
	if typeof(data) ~= "table" then
		return false, "Theme data must be a table"
	end

	self:RegisterTheme(name, data)

	return self:ApplyTheme(name)
end

function ThemeManager:DeleteTheme(name)
	if name == "Default" then
		return false, "Default theme cannot be deleted"
	end

	if not self.Themes[name] then
		return false, "Theme not found"
	end

	self.Themes[name] = nil

	if self.CurrentTheme == name then
		self:ApplyTheme("Default")
	end

	return true
end

function ThemeManager:BuildThemeSection(groupbox)
	if not groupbox then
		return false, "Groupbox is required"
	end

	groupbox:AddLabel({
		Text = "Theme",
		DoesWrap = false,
	})

	local values = self:GetThemes()

	groupbox:AddDropdown("ThemeManager_CurrentTheme", {
		Text = "Current Theme",
		Values = values,
		Default = self.CurrentTheme,

		Callback = function(value)
			self:ApplyTheme(value)
		end,
	})

	groupbox:AddButton({
		Text = "Refresh Theme",

		Func = function()
			self:Refresh()
		end,
	})

	groupbox:AddButton({
		Text = "Refresh Strokes",

		Func = function()
			self:RefreshStrokes()
		end,
	})

	return true
end

function ThemeManager:BuildSection(groupbox)
	return self:BuildThemeSection(groupbox)
end

function ThemeManager:Reset()
	return self:ApplyTheme("Default")
end

return ThemeManager
