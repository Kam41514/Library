local ThemeManager = {}
ThemeManager.__index = ThemeManager

ThemeManager.Folder = "CustomObsidianUI"
ThemeManager.Theme = "Default"

ThemeManager.Themes = {
	Default = {
		Background = Color3.fromRGB(8, 8, 8),
		Surface = Color3.fromRGB(10, 10, 10),
		Surface2 = Color3.fromRGB(12, 12, 12),
		Stroke = Color3.fromRGB(18, 18, 18),
		Stroke2 = Color3.fromRGB(28, 28, 28),
		Text = Color3.fromRGB(235, 235, 235),
		SubText = Color3.fromRGB(145, 145, 145),
		Accent = Color3.fromRGB(125, 85, 255),
		AccentDark = Color3.fromRGB(80, 50, 180),
		White = Color3.fromRGB(255, 255, 255),
		Red = Color3.fromRGB(220, 70, 70)
	}
}

function ThemeManager:SetLibrary(library)
	self.Library = library
	return self
end

function ThemeManager:SetFolder(folder)
	if folder and tostring(folder) ~= "" then
		self.Folder = tostring(folder)
	end

	return self
end

function ThemeManager:AddTheme(name, theme)
	if typeof(name) ~= "string" or name == "" or typeof(theme) ~= "table" then
		return false
	end

	self.Themes[name] = theme

	return true
end

function ThemeManager:GetTheme(name)
	return self.Themes[name or self.Theme]
end

function ThemeManager:GetThemes()
	local themes = {}

	for name in pairs(self.Themes) do
		table.insert(themes, name)
	end

	table.sort(themes)

	return themes
end

function ThemeManager:_ApplyRecursive(object, theme)
	if not object then
		return
	end

	if object:IsA("Frame")
		or object:IsA("ScrollingFrame")
		or object:IsA("TextButton")
		or object:IsA("TextBox") then

		if object.Name == "Window"
			or object.Name == "Content"
			or object.Name == "Sidebar"
			or object.Name == "Topbar" then

			object.BackgroundColor3 = theme.Background

		elseif object.Name == "Button"
			or object.Name == "Holder"
			or object.Name == "Checkbox"
			or object.Name == "List" then

			object.BackgroundColor3 = theme.Surface2
		end
	end

	if object:IsA("TextLabel")
		or object:IsA("TextButton")
		or object:IsA("TextBox") then

		local name = object.Name

		if name == "Title"
			or name == "Label"
			or name == "Text"
			or name == "Button" then

			object.TextColor3 = theme.Text
		end
	end

	if object:IsA("UIStroke") then
		object.Color = theme.Stroke
	end

	for _, child in ipairs(object:GetChildren()) do
		self:_ApplyRecursive(child, theme)
	end
end

function ThemeManager:ApplyTheme(name)
	local theme = self.Themes[name]

	if not theme then
		return false, "Theme does not exist"
	end

	self.Theme = name

	if self.Library then
		self.Library.Theme = theme

		local window = self.Library.Window

		if window and window.ScreenGui then
			self:_ApplyRecursive(window.ScreenGui, theme)
		end
	end

	return true
end

function ThemeManager:ApplyToWindow(window)
	local theme = self.Themes[self.Theme]

	if not theme or not window then
		return false
	end

	if window.ScreenGui then
		self:_ApplyRecursive(window.ScreenGui, theme)
	end

	return true
end

function ThemeManager:BuildThemeSection(groupbox)
	if not groupbox then
		return nil
	end

	local manager = self

	groupbox:AddDropdown("Theme", {
		Text = "Theme",
		Values = self:GetThemes(),
		Default = self.Theme,
		Callback = function(value)
			manager:ApplyTheme(value)
		end
	})

	groupbox:AddButton({
		Text = "Reset Theme",
		Func = function()
			manager:ApplyTheme("Default")
		end
	})

	return self
end

function ThemeManager:Init(library)
	self.Library = library

	if library then
		library.ThemeManager = self
	end

	return self
end

return setmetatable({}, ThemeManager)
