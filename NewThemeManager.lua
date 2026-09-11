local ThemeManager = {}

ThemeManager.Library = nil
ThemeManager.Themes = {}
ThemeManager.CurrentTheme = "Default"

ThemeManager.DefaultTheme = {
	Name = "Default",

	Background = Color3.fromRGB(8, 8, 8),
	Frame = Color3.fromRGB(9, 9, 9),
	Surface = Color3.fromRGB(11, 11, 11),
	Surface2 = Color3.fromRGB(13, 13, 13),

	Stroke = Color3.fromRGB(18, 18, 18),

	Text = Color3.fromRGB(238, 238, 238),
	SubText = Color3.fromRGB(158, 158, 158),
	Disabled = Color3.fromRGB(85, 85, 85),

	Accent = Color3.fromRGB(125, 85, 255),
	AccentDark = Color3.fromRGB(85, 55, 185),

	White = Color3.fromRGB(255, 255, 255),
	Red = Color3.fromRGB(225, 75, 75),
}

local function CopyTable(source)
	local result = {}

	for key, value in pairs(source) do
		result[key] = value
	end

	return result
end

local function IsGuiObject(object)
	return object
		and object:IsA("GuiObject")
end

local function SetColor(object, property, color)
	if not object or not object.Parent then
		return
	end

	pcall(function()
		object[property] = color
	end)
end

local function GetRole(object)
	if not object or not object.Name then
		return nil
	end

	local name = string.lower(object.Name)

	if name == "window" then
		return "Background"
	end

	if name == "content" then
		return "Background"
	end

	if name == "sidebar" then
		return "Frame"
	end

	if name == "topbar" then
		return "Background"
	end

	if name == "sidebartitle" then
		return "SubText"
	end

	if name == "title" then
		return "Text"
	end

	if name == "footer" then
		return "SubText"
	end

	if name == "label" then
		return "Text"
	end

	if name == "text" then
		return "Text"
	end

	if name == "value" then
		return "SubText"
	end

	if name == "checkbox" then
		return "Surface2"
	end

	if name == "check" then
		return "White"
	end

	if name == "fill" then
		return "Accent"
	end

	if name == "line" then
		return "Stroke"
	end

	if name == "arrow" then
		return "SubText"
	end

	if name == "options" then
		return "Background"
	end

	if name == "dropdownpopup" then
		return "Background"
	end

	if name == "button" then
		return "Surface2"
	end

	if name == "holder" then
		return "Surface"
	end

	return nil
end

local function ApplyToStroke(stroke, theme)
	if not stroke:IsA("UIStroke") then
		return
	end

	stroke.Color = theme.Stroke
	stroke.Transparency = 0
	stroke.Thickness = 1
end

local function ApplyToText(object, theme)
	if not (
		object:IsA("TextLabel")
		or object:IsA("TextButton")
		or object:IsA("TextBox")
	) then
		return
	end

	local role = GetRole(object)

	if role == "Text" then
		object.TextColor3 = theme.Text
	elseif role == "SubText" then
		object.TextColor3 = theme.SubText
	elseif role == "Disabled" then
		object.TextColor3 = theme.Disabled
	elseif role == "White" then
		object.TextColor3 = theme.White
	end
end

local function ApplyToFrame(object, theme)
	if not IsGuiObject(object) then
		return
	end

	if object:IsA("TextLabel")
		or object:IsA("TextButton")
		or object:IsA("TextBox") then
		return
	end

	local role = GetRole(object)

	if role == "Background" then
		object.BackgroundColor3 = theme.Background
	elseif role == "Frame" then
		object.BackgroundColor3 = theme.Frame
	elseif role == "Surface" then
		object.BackgroundColor3 = theme.Surface
	elseif role == "Surface2" then
		object.BackgroundColor3 = theme.Surface2
	elseif role == "Accent" then
		object.BackgroundColor3 = theme.Accent
	elseif role == "Stroke" then
		object.BackgroundColor3 = theme.Stroke
	elseif role == "White" then
		object.BackgroundColor3 = theme.White
	end
end

local function ApplyObject(object, theme)
	if not object or not object.Parent then
		return
	end

	if object:IsA("UIStroke") then
		ApplyToStroke(object, theme)
		return
	end

	if object:IsA("TextLabel")
		or object:IsA("TextButton")
		or object:IsA("TextBox") then

		ApplyToText(object, theme)
		return
	end

	ApplyToFrame(object, theme)
end

local function ApplyAccentObjects(root, theme)
	for _, object in ipairs(root:GetDescendants()) do
		if not object.Parent then
			continue
		end

		local name = string.lower(object.Name)

		if name == "fill" then
			SetColor(object, "BackgroundColor3", theme.Accent)
		elseif name == "checkbox" then
			if object:IsA("Frame") then
				local checked = object:FindFirstChild("Check")

				if checked and checked.Visible then
					object.BackgroundColor3 = theme.Accent
				else
					object.BackgroundColor3 = theme.Surface2
				end
			end
		end
	end
end

function ThemeManager:Init(library)
	self.Library = library

	if not self.Themes.Default then
		self.Themes.Default = CopyTable(self.DefaultTheme)
	end

	self.CurrentTheme = "Default"

	return self
end

function ThemeManager:Register(name, theme)
	if not name or typeof(theme) ~= "table" then
		return false, "Invalid theme"
	end

	local newTheme = CopyTable(self.DefaultTheme)

	for key, value in pairs(theme) do
		newTheme[key] = value
	end

	newTheme.Name = tostring(name)

	self.Themes[tostring(name)] = newTheme

	return true
end

function ThemeManager:GetTheme(name)
	name = name or self.CurrentTheme

	local theme = self.Themes[name]

	if not theme then
		return nil
	end

	return CopyTable(theme)
end

function ThemeManager:GetThemes()
	local result = {}

	for name in pairs(self.Themes) do
		table.insert(result, name)
	end

	table.sort(result)

	return result
end

function ThemeManager:ApplyTheme(name)
	if not self.Library then
		return false, "ThemeManager has not been initialized"
	end

	name = tostring(name or "Default")

	local theme = self.Themes[name]

	if not theme then
		return false, "Theme not found: " .. name
	end

	local window = self.Library.Window

	if not window then
		return false, "Library.Window not found"
	end

	local screenGui = window.ScreenGui

	if not screenGui then
		return false, "ScreenGui not found"
	end

	for _, object in ipairs(screenGui:GetDescendants()) do
		ApplyObject(object, theme)
	end

	ApplyAccentObjects(screenGui, theme)

	self.CurrentTheme = name

	self.Library.Theme = theme

	return true
end

function ThemeManager:Reset()
	return self:ApplyTheme("Default")
end

function ThemeManager:BuildThemeSection(groupbox)
	if not groupbox then
		return nil
	end

	groupbox:AddLabel({
		Text = "Theme",
		DoesWrap = false,
	})

	local themes = self:GetThemes()

	local defaultValue = self.CurrentTheme

	if #themes == 0 then
		themes = {
			"Default"
		}
	end

	groupbox:AddDropdown("ThemeManager_Theme", {
		Text = "Theme",
		Values = themes,
		Default = defaultValue,

		Callback = function(value)
			if value then
				self:ApplyTheme(value)
			end
		end,
	})

	groupbox:AddButton({
		Text = "Reset Theme",

		Func = function()
			self:Reset()
		end,
	})

	return groupbox
end

function ThemeManager:CreateTheme(name, theme)
	return self:Register(name, theme)
end

function ThemeManager:RemoveTheme(name)
	name = tostring(name)

	if name == "Default" then
		return false, "Default theme cannot be removed"
	end

	if not self.Themes[name] then
		return false, "Theme not found"
	end

	self.Themes[name] = nil

	if self.CurrentTheme == name then
		self:Reset()
	end

	return true
end

function ThemeManager:SetThemeColor(name, property, value)
	local theme = self.Themes[name]

	if not theme then
		return false, "Theme not found"
	end

	if theme[property] == nil then
		return false, "Theme color not found: " .. tostring(property)
	end

	if typeof(value) ~= "Color3" then
		return false, "Value must be Color3"
	end

	theme[property] = value

	if self.CurrentTheme == name then
		self:ApplyTheme(name)
	end

	return true
end

function ThemeManager:GetCurrentTheme()
	return self.CurrentTheme
end

ThemeManager:Register("Default", ThemeManager.DefaultTheme)

return ThemeManager
