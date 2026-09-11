local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Library = {}
Library.__index = Library

Library.Registry = {}
Library.Options = {}
Library.Toggles = {}
Library.Flags = {}

local COLORS = {
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
	Red = Color3.fromRGB(220, 70, 70),
}

local function Create(className, properties, parent)
	local object = Instance.new(className)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	if parent then
		object.Parent = parent
	end

	return object
end

local function Corner(parent, radius)
	return Create("UICorner", {
		CornerRadius = UDim.new(0, radius or 5)
	}, parent)
end

local function Stroke(parent, color, thickness, transparency)
	return Create("UIStroke", {
		Color = color or COLORS.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0
	}, parent)
end

local function Padding(parent, left, right, top, bottom)
	return Create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0)
	}, parent)
end

local function GetPlayerGui()
	local player = Players.LocalPlayer

	if not player then
		return nil
	end

	local gui = player:FindFirstChildOfClass("PlayerGui")

	if not gui then
		gui = player:WaitForChild("PlayerGui")
	end

	return gui
end

local function RoundNumber(value, decimals)
	local power = 10 ^ (decimals or 0)
	return math.floor(value * power + 0.5) / power
end

local function SafeCallback(callback, ...)
	if typeof(callback) ~= "function" then
		return
	end

	task.spawn(function(...)
		pcall(callback, ...)
	end, ...)
end

local BaseGroupbox = {}
BaseGroupbox.__index = BaseGroupbox

function BaseGroupbox:_Register(idx, object)
	if idx then
		Library.Options[idx] = object
		Library.Registry[idx] = object
	end

	table.insert(self.Elements, object)
	return object
end

function BaseGroupbox:SetVisible(visible)
	self.Visible = visible

	if self.Holder then
		self.Holder.Visible = visible
	end

	self:Resize()
end

function BaseGroupbox:Show()
	self:SetVisible(true)
end

function BaseGroupbox:Hide()
	self:SetVisible(false)
end

function BaseGroupbox:Resize()
	if not self.Container then
		return
	end

	local layout = self.Container:FindFirstChildOfClass("UIListLayout")

	if layout then
		self.Container.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
	end

	if self.BoxHolder then
		local height = 30

		if layout then
			height = layout.AbsoluteContentSize.Y + 36
		end

		if self.DescriptionLabel and self.DescriptionLabel.Visible then
			height += self.DescriptionLabel.AbsoluteSize.Y + 5
		end

		self.BoxHolder.Size = UDim2.new(1, 0, 0, math.max(height, 42))
	end
end

function BaseGroupbox:AddDivider(info)
	local holder = Create("Frame", {
		Name = "Divider",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 9)
	}, self.Container)

	local line = Create("Frame", {
		BackgroundColor3 = COLORS.Stroke,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 1)
	}, holder)

	self:Resize()

	return holder
end

function BaseGroupbox:AddLabel(info, doesWrap, idx)
	local data

	if typeof(info) == "string" then
		data = {
			Text = info,
			DoesWrap = doesWrap
		}
	else
		data = info or {}
	end

	local holder = Create("Frame", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, data.Size or 20),
		AutomaticSize = data.DoesWrap and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
	}, self.Container)

	local label = Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.Gotham,
		Text = tostring(data.Text or ""),
		TextColor3 = COLORS.SubText,
		TextSize = 12,
		TextWrapped = data.DoesWrap == true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center
	}, holder)

	local object = {
		Text = tostring(data.Text or ""),
		DoesWrap = data.DoesWrap == true,
		Visible = data.Visible ~= false,
		Type = "Label",
		Holder = holder,
		TextLabel = label,
		Container = holder,
		Parent = self
	}

	function object:SetVisible(value)
		self.Visible = value
		self.Holder.Visible = value
		self.Parent:Resize()
	end

	function object:SetText(text)
		self.Text = tostring(text)
		self.TextLabel.Text = self.Text
		self.Parent:Resize()
	end

	function object:Destroy()
		self.Holder:Destroy()
	end

	holder.Visible = object.Visible

	self:_Register(idx, object)
	self:Resize()

	return object
end

function BaseGroupbox:AddButton(info, func, idx)
	local data

	if typeof(info) == "string" then
		data = {
			Text = info,
			Func = func
		}
	else
		data = info or {}
	end

	local holder = Create("Frame", {
		Name = "Button",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 30)
	}, self.Container)

	local button = Create("TextButton", {
		Name = "Button",
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = tostring(data.Text or "Button"),
		TextColor3 = COLORS.Text,
		TextSize = 12
	}, holder)

	Corner(button, 5)
	local buttonStroke = Stroke(button, COLORS.Stroke2, 1)

	local object = {
		Text = tostring(data.Text or "Button"),
		Func = data.Func or function() end,
		Disabled = data.Disabled == true,
		Visible = data.Visible ~= false,
		Risky = data.Risky == true,
		Type = "Button",
		Base = button,
		Holder = holder,
		Stroke = buttonStroke,
		Parent = self
	}

	function object:UpdateColors()
		if self.Disabled then
			button.BackgroundColor3 = COLORS.Surface
			button.TextColor3 = Color3.fromRGB(80, 80, 80)
		else
			button.BackgroundColor3 = COLORS.Surface2
			button.TextColor3 = self.Risky and COLORS.Red or COLORS.Text
		end
	end

	function object:SetDisabled(value)
		self.Disabled = value == true
		self:UpdateColors()
	end

	function object:SetVisible(value)
		self.Visible = value
		holder.Visible = value
		self.Parent:Resize()
	end

	function object:SetText(text)
		self.Text = tostring(text)
		button.Text = self.Text
	end

	function object:Destroy()
		holder:Destroy()
	end

	button.MouseEnter:Connect(function()
		if object.Disabled then
			return
		end

		TweenService:Create(button, TweenInfo.new(0.12), {
			BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		object:UpdateColors()
	end)

	button.MouseButton1Click:Connect(function()
		if object.Disabled then
			return
		end

		SafeCallback(object.Func, false)
	end)

	holder.Visible = object.Visible
	object:UpdateColors()

	return self:_Register(idx, object)
end

function BaseGroupbox:AddToggle(idx, info)
	info = info or {}

	local holder = Create("Frame", {
		Name = "Toggle",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 27)
	}, self.Container)

	local button = Create("TextButton", {
		Name = "Holder",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = ""
	}, holder)

	local box = Create("Frame", {
		Name = "Checkbox",
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, -8),
		Size = UDim2.fromOffset(16, 16)
	}, button)

	Corner(box, 4)
	local boxStroke = Stroke(box, COLORS.Stroke2, 1)

	local check = Create("TextLabel", {
		Name = "Check",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamBold,
		Text = "✓",
		TextColor3 = COLORS.White,
		TextSize = 11,
		Visible = false
	}, box)

	local label = Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 24, 0, 0),
		Size = UDim2.new(1, -24, 1, 0),
		Font = Enum.Font.Gotham,
		Text = tostring(info.Text or idx),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	}, button)

	local object = {
		Text = tostring(info.Text or idx),
		Value = info.Default == true,
		Callback = info.Callback or function() end,
		Changed = info.Changed or function() end,
		Disabled = info.Disabled == true,
		Visible = info.Visible ~= false,
		Risky = info.Risky == true,
		Type = "Toggle",
		Holder = button,
		Container = holder,
		TextLabel = label,
		Parent = self
	}

	function object:Display()
		check.Visible = self.Value

		if self.Value then
			box.BackgroundColor3 = COLORS.Accent
			boxStroke.Color = COLORS.Accent
		else
			box.BackgroundColor3 = COLORS.Surface2
			boxStroke.Color = COLORS.Stroke2
		end

		if self.Disabled then
			label.TextColor3 = Color3.fromRGB(75, 75, 75)
		else
			label.TextColor3 = self.Risky and COLORS.Red or COLORS.Text
		end
	end

	function object:SetValue(value)
		value = value == true

		if self.Value == value then
			self:Display()
			return
		end

		self.Value = value
		Library.Toggles[idx] = self.Value
		Library.Flags[idx] = self.Value

		self:Display()

		SafeCallback(self.Callback, self.Value)
		SafeCallback(self.Changed, self.Value)
	end

	function object:OnChanged(callback)
		self.Changed = callback
		return self
	end

	function object:SetDisabled(value)
		self.Disabled = value == true
		self:Display()
	end

	function object:SetVisible(value)
		self.Visible = value
		holder.Visible = value
		self.Parent:Resize()
	end

	function object:SetText(text)
		self.Text = tostring(text)
		label.Text = self.Text
	end

	function object:AddKeyPicker(keyIdx, keyInfo)
		local picker = {
			Type = "KeyPicker",
			Text = keyInfo.Text or keyIdx,
			Value = keyInfo.Default or "None",
			Mode = keyInfo.Mode or "Toggle",
			Toggled = false,
			Callback = keyInfo.Callback or function() end,
			ChangedCallback = keyInfo.ChangedCallback or function() end,
			Changed = keyInfo.Changed or function() end,
			Clicked = keyInfo.Clicked or function() end
		}

		function picker:GetState()
			return self.Toggled
		end

		function picker:SetValue(data)
			if typeof(data) == "table" then
				if data[1] then
					self.Value = data[1]
				end

				if data[2] then
					self.Mode = data[2]
				end
			elseif typeof(data) == "string" then
				self.Value = data
			end
		end

		function picker:OnChanged(callback)
			self.Changed = callback
			return self
		end

		function picker:OnClick(callback)
			self.Clicked = callback
			return self
		end

		function picker:DoClick()
			SafeCallback(self.Clicked)
		end

		Library.Options[keyIdx] = picker
		Library.Registry[keyIdx] = picker

		return object
	end

	function object:AddColorPicker(colorIdx, colorInfo)
		local picker = {
			Type = "ColorPicker",
			Value = colorInfo.Default or Color3.fromRGB(255, 255, 255),
			Transparency = colorInfo.Transparency or 0,
			Title = colorInfo.Title or colorIdx,
			Callback = colorInfo.Callback or function() end,
			Changed = colorInfo.Changed or function() end
		}

		function picker:SetValueRGB(color, transparency)
			self.Value = color
			if transparency ~= nil then
				self.Transparency = transparency
			end

			SafeCallback(self.Callback, self.Value)
			SafeCallback(self.Changed, self.Value)
		end

		function picker:SetValue(_, transparency)
			if transparency ~= nil then
				self.Transparency = transparency
			end
		end

		function picker:OnChanged(callback)
			self.Changed = callback
			return self
		end

		Library.Options[colorIdx] = picker
		Library.Registry[colorIdx] = picker

		return object
	end

	function object:Destroy()
		holder:Destroy()
	end

	button.MouseButton1Click:Connect(function()
		if not object.Disabled then
			object:SetValue(not object.Value)
		end
	end)

	holder.Visible = object.Visible

	Library.Toggles[idx] = object.Value
	Library.Flags[idx] = object.Value

	object:Display()

	return self:_Register(idx, object)
end

function BaseGroupbox:AddCheckbox(idx, info)
	return self:AddToggle(idx, info)
end

function BaseGroupbox:AddInput(idx, info)
	info = info or {}

	local holder = Create("Frame", {
		Name = "Input",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 52)
	}, self.Container)

	local label = Create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = Enum.Font.Gotham,
		Text = tostring(info.Text or idx),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	local box = Create("TextBox", {
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 24),
		Size = UDim2.new(1, 0, 0, 28),
		ClearTextOnFocus = info.ClearTextOnFocus ~= false,
		Font = Enum.Font.Gotham,
		PlaceholderText = tostring(info.Placeholder or ""),
		PlaceholderColor3 = Color3.fromRGB(85, 85, 85),
		Text = tostring(info.Default or ""),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	Corner(box, 5)
	Stroke(box, COLORS.Stroke2, 1)
	Padding(box, 9, 9, 0, 0)

	local object = {
		Text = tostring(info.Text or idx),
		Value = tostring(info.Default or ""),
		Finished = info.Finished == true,
		Numeric = info.Numeric == true,
		ClearTextOnFocus = info.ClearTextOnFocus ~= false,
		Placeholder = tostring(info.Placeholder or ""),
		AllowEmpty = info.AllowEmpty ~= false,
		EmptyReset = tostring(info.EmptyReset or ""),
		Callback = info.Callback or function() end,
		Changed = info.Changed or function() end,
		Disabled = info.Disabled == true,
		Visible = info.Visible ~= false,
		Type = "Input",
		Holder = holder,
		Parent = self
	}

	function object:SetValue(value)
		value = tostring(value)

		if self.Numeric then
			local number = tonumber(value)

			if number then
				value = tostring(number)
			end
		end

		if value == "" and not self.AllowEmpty then
			value = self.EmptyReset
		end

		self.Value = value
		box.Text = value

		SafeCallback(self.Callback, value)
		SafeCallback(self.Changed, value)
	end

	function object:OnChanged(callback)
		self.Changed = callback
		return self
	end

	function object:SetDisabled(value)
		self.Disabled = value == true
		box.TextEditable = not self.Disabled
		box.TextColor3 = self.Disabled and Color3.fromRGB(70, 70, 70) or COLORS.Text
	end

	function object:SetVisible(value)
		self.Visible = value
		holder.Visible = value
		self.Parent:Resize()
	end

	function object:SetText(text)
		self.Text = tostring(text)
		label.Text = self.Text
	end

	function object:Destroy()
		holder:Destroy()
	end

	box.FocusLost:Connect(function()
		if object.Disabled then
			return
		end

		local value = box.Text

		if object.Numeric then
			local number = tonumber(value)

			if not number then
				box.Text = object.Value
				return
			end
		end

		if value == "" and not object.AllowEmpty then
			box.Text = object.EmptyReset
			object.Value = object.EmptyReset
		else
			object.Value = value
		end

		SafeCallback(object.Callback, object.Value)
	end)

	box:GetPropertyChangedSignal("Text"):Connect(function()
		if object.Disabled then
			return
		end

		if object.Finished then
			return
		end

		object.Value = box.Text
		SafeCallback(object.Changed, object.Value)
	end)

	box.Visible = object.Visible
	object:SetDisabled(object.Disabled)

	return self:_Register(idx, object)
end

function BaseGroupbox:AddSlider(idx, info)
	info = info or {}

	local min = tonumber(info.Min) or 0
	local max = tonumber(info.Max) or 100
	local rounding = tonumber(info.Rounding) or 0
	local default = tonumber(info.Default) or min

	if max < min then
		min, max = max, min
	end

	default = math.clamp(default, min, max)

	local holder = Create("Frame", {
		Name = "Slider",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48)
	}, self.Container)

	local label = Create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.7, 0, 0, 20),
		Font = Enum.Font.Gotham,
		Text = tostring(info.Text or idx),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	local valueLabel = Create("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0.3, 0, 0, 20),
		Font = Enum.Font.GothamMedium,
		TextColor3 = COLORS.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right
	}, holder)

	local bar = Create("Frame", {
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 27),
		Size = UDim2.new(1, 0, 0, 8)
	}, holder)

	Corner(bar, 4)
	Stroke(bar, COLORS.Stroke2, 1)

	local fill = Create("Frame", {
		BackgroundColor3 = COLORS.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0)
	}, bar)

	Corner(fill, 4)

	local object = {
		Text = tostring(info.Text or idx),
		Value = default,
		Min = min,
		Max = max,
		Prefix = tostring(info.Prefix or ""),
		Suffix = tostring(info.Suffix or ""),
		Rounding = rounding,
		Callback = info.Callback or function() end,
		Changed = info.Changed or function() end,
		Disabled = info.Disabled == true,
		Visible = info.Visible ~= false,
		AllowRightClickInput = info.AllowRightClickInput == true,
		Type = "Slider",
		Holder = holder,
		Parent = self
	}

	function object:Display()
		local alpha = (self.Value - self.Min) / (self.Max - self.Min)

		if self.Max == self.Min then
			alpha = 0
		end

		alpha = math.clamp(alpha, 0, 1)

		fill.Size = UDim2.new(alpha, 0, 1, 0)

		local display = self.Prefix .. tostring(self.Value) .. self.Suffix

		valueLabel.Text = display

		if self.Disabled then
			fill.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
			label.TextColor3 = Color3.fromRGB(75, 75, 75)
		else
			fill.BackgroundColor3 = COLORS.Accent
			label.TextColor3 = COLORS.Text
		end
	end

	function object:SetValue(value)
		value = tonumber(value)

		if not value then
			return
		end

		value = math.clamp(value, self.Min, self.Max)
		value = RoundNumber(value, self.Rounding)

		if self.Value == value then
			self:Display()
			return
		end

		self.Value = value
		Library.Flags[idx] = value

		self:Display()

		SafeCallback(self.Callback, value)
		SafeCallback(self.Changed, value)
	end

	function object:OnChanged(callback)
		self.Changed = callback
		return self
	end

	function object:SetMin(value)
		self.Min = tonumber(value) or self.Min
		self:SetValue(self.Value)
	end

	function object:SetMax(value)
		self.Max = tonumber(value) or self.Max
		self:SetValue(self.Value)
	end

	function object:SetDisabled(value)
		self.Disabled = value == true
		self:Display()
	end

	function object:SetVisible(value)
		self.Visible = value
		holder.Visible = value
		self.Parent:Resize()
	end

	function object:SetText(text)
		self.Text = tostring(text)
		label.Text = self.Text
	end

	function object:SetPrefix(prefix)
		self.Prefix = tostring(prefix)
		self:Display()
	end

	function object:SetSuffix(suffix)
		self.Suffix = tostring(suffix)
		self:Display()
	end

	function object:Destroy()
		holder:Destroy()
	end

	local dragging = false

	local function updateFromMouse()
		if object.Disabled then
			return
		end

		local mousePosition = UserInputService:GetMouseLocation()
		local absolutePosition = bar.AbsolutePosition
		local absoluteSize = bar.AbsoluteSize

		local alpha = (mousePosition.X - absolutePosition.X) / absoluteSize.X
		alpha = math.clamp(alpha, 0, 1)

		local value = object.Min + (object.Max - object.Min) * alpha

		object:SetValue(value)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateFromMouse()
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromMouse()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	object:Display()

	return self:_Register(idx, object)
end

function BaseGroupbox:AddDropdown(idx, info)
	info = info or {}

	local values = info.Values or {}
	local multi = info.Multi == true

	local holder = Create("Frame", {
		Name = "Dropdown",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 52)
	}, self.Container)

	local label = Create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = Enum.Font.Gotham,
		Text = tostring(info.Text or idx),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	local button = Create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 24),
		Size = UDim2.new(1, 0, 0, 28),
		Font = Enum.Font.Gotham,
		Text = "",
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	}, holder)

	Corner(button, 5)
	Stroke(button, COLORS.Stroke2, 1)
	Padding(button, 9, 9, 0, 0)

	local arrow = Create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Font = Enum.Font.GothamBold,
		Text = "⌄",
		TextColor3 = COLORS.SubText,
		TextSize = 14
	}, button)

	local list = Create("ScrollingFrame", {
		Name = "List",
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = COLORS.Surface,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		Position = UDim2.new(0, 0, 1, 4),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = COLORS.Accent,
		Size = UDim2.new(1, 0, 0, 0),
		Visible = false,
		ZIndex = 20
	}, button)

	Corner(list, 5)
	Stroke(list, COLORS.Stroke, 1)
	Padding(list, 4, 4, 4, 4)

	Create("UIListLayout", {
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, list)

	local object = {
		Text = tostring(info.Text or idx),
		Values = values,
		Multi = multi,
		Value = nil,
		DisabledValues = info.DisabledValues or {},
		ValueImages = info.ValueImages or {},
		Callback = info.Callback or function() end,
		Changed = info.Changed or function() end,
		Disabled = info.Disabled == true,
		Visible = info.Visible ~= false,
		Type = "Dropdown",
		Holder = holder,
		Parent = self,
		Open = false
	}

	local function isDisabled(value)
		for _, disabledValue in pairs(object.DisabledValues) do
			if disabledValue == value then
				return true
			end
		end

		return false
	end

	local function displayValue()
		if object.Multi then
			local selected = {}

			if typeof(object.Value) == "table" then
				for value, state in pairs(object.Value) do
					if state then
						table.insert(selected, tostring(value))
					end
				end
			end

			button.Text = #selected > 0 and table.concat(selected, ", ") or "None"
		else
			button.Text = object.Value ~= nil and tostring(object.Value) or "None"
		end
	end

	local function rebuild()
		for _, child in ipairs(list:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for key, value in pairs(object.Values) do
			local actualValue = value

			if typeof(key) == "number" then
				actualValue = value
			else
				actualValue = key
			end

			local option = Create("TextButton", {
				AutoButtonColor = false,
				BackgroundColor3 = COLORS.Surface2,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 26),
				Font = Enum.Font.Gotham,
				Text = tostring(actualValue),
				TextColor3 = COLORS.Text,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 21
			}, list)

			Corner(option, 4)
			Padding(option, 8, 8, 0, 0)

			if isDisabled(actualValue) then
				option.TextColor3 = Color3.fromRGB(70, 70, 70)
			end

			option.MouseEnter:Connect(function()
				if not isDisabled(actualValue) then
					option.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				end
			end)

			option.MouseLeave:Connect(function()
				option.BackgroundColor3 = COLORS.Surface2
			end)

			option.MouseButton1Click:Connect(function()
				if isDisabled(actualValue) then
					return
				end

				if object.Multi then
					if typeof(object.Value) ~= "table" then
						object.Value = {}
					end

					object.Value[actualValue] = not object.Value[actualValue]
				else
					object.Value = actualValue
					object:SetOpen(false)
				end

				displayValue()

				SafeCallback(object.Callback, object.Value)
				SafeCallback(object.Changed, object.Value)
			end)
		end
	end

	function object:SetOpen(state)
		self.Open = state == true
		list.Visible = self.Open

		if self.Open then
			list.Size = UDim2.new(1, 0, 0, math.min(#self.Values * 28 + 8, 180))
			arrow.Text = "⌃"
		else
			arrow.Text = "⌄"
		end
	end

	function object:SetValue(value)
		if self.Multi then
			if typeof(value) ~= "table" then
				value = {}
			end

			self.Value = value
		else
			self.Value = value
		end

		displayValue()

		SafeCallback(self.Callback, self.Value)
		SafeCallback(self.Changed, self.Value)
	end

	function object:GetActiveValues(returnCount)
		if not self.Multi then
			if returnCount then
				return self.Value and 1 or 0
			end

			return { self.Value }
		end

		local result = {}

		for value, state in pairs(self.Value or {}) do
			if state then
				table.insert(result, value)
			end
		end

		if returnCount then
			return #result
		end

		return result
	end

	function object:SetValues(newValues)
		self.Values = newValues or {}
		rebuild()
	end

	function object:AddValues(newValues)
		if typeof(newValues) == "string" then
			newValues = { newValues }
		end

		if typeof(newValues) == "table" then
			for key, value in pairs(newValues) do
				self.Values[key] = value
			end
		end

		rebuild()
	end

	function object:SetDisabledValues(disabledValues)
		self.DisabledValues = disabledValues or {}
		rebuild()
	end

	function object:AddDisabledValues(disabledValues)
		if typeof(disabledValues) == "string" then
			disabledValues = { disabledValues }
		end

		for _, value in pairs(disabledValues or {}) do
			table.insert(self.DisabledValues, value)
		end

		rebuild()
	end

	function object:SetValueImages(images)
		self.ValueImages = images or {}
		rebuild()
	end

	function object:SetDisabled(value)
		self.Disabled = value == true
		button.TextColor3 = self.Disabled and Color3.fromRGB(70, 70, 70) or COLORS.Text
	end

	function object:SetVisible(value)
		self.Visible = value
		holder.Visible = value
		self.Parent:Resize()
	end

	function object:SetText(text)
		self.Text = tostring(text)
		label.Text = self.Text
	end

	function object:OnChanged(callback)
		self.Changed = callback
		return self
	end

	function object:Destroy()
		holder:Destroy()
	end

	button.MouseButton1Click:Connect(function()
		if not object.Disabled then
			object:SetOpen(not object.Open)
		end
	end)

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and object.Open then
			local mousePosition = UserInputService:GetMouseLocation()
			local position = button.AbsolutePosition
			local size = button.AbsoluteSize

			local insideButton =
				mousePosition.X >= position.X and
				mousePosition.X <= position.X + size.X and
				mousePosition.Y >= position.Y and
				mousePosition.Y <= position.Y + size.Y

			if not insideButton then
				object:SetOpen(false)
			end
		end
	end)

	rebuild()

	if info.Default ~= nil then
		object:SetValue(info.Default)
	elseif multi then
		object.Value = {}
		displayValue()
	end

	return self:_Register(idx, object)
end

function BaseGroupbox:AddTabbox(info)
	local name

	if typeof(info) == "string" then
		name = info
	else
		info = info or {}
		name = info.Name or "Tabbox"
	end

	local holder = Create("Frame", {
		Name = name,
		BackgroundColor3 = COLORS.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 150)
	}, self.Container)

	Corner(holder, 5)
	Stroke(holder, COLORS.Stroke, 1)

	local tabs = Create("Frame", {
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30)
	}, holder)

	Corner(tabs, 5)

	local tabLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder
	}, tabs)

	local content = Create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 6, 0, 36),
		Size = UDim2.new(1, -12, 1, -42)
	}, holder)

	local tabbox = {
		Type = "Tabbox",
		Holder = holder,
		BoxHolder = holder,
		Tabs = {},
		ActiveTab = nil,
		ParentBox = self
	}

	function tabbox:AddTab(tabName, iconName)
		local button = Create("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 100, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = tostring(tabName),
			TextColor3 = COLORS.SubText,
			TextSize = 11
		}, tabs)

		local tabContainer = Create("ScrollingFrame", {
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = COLORS.Accent,
			Size = UDim2.fromScale(1, 1),
			Visible = false
		}, content)

		Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder
		}, tabContainer)

		local subtab = setmetatable({
			Name = tostring(tabName),
			ButtonHolder = button,
			Container = tabContainer,
			Tabbox = tabbox,
			Elements = {},
			DependencyBoxes = {}
		}, BaseGroupbox)

		function subtab:Show()
			tabContainer.Visible = true
			button.TextColor3 = COLORS.Text
			tabbox.ActiveTab = self
			self:Resize()
		end

		function subtab:Hide()
			tabContainer.Visible = false
			button.TextColor3 = COLORS.SubText
		end

		button.MouseButton1Click:Connect(function()
			for _, tab in pairs(tabbox.Tabs) do
				tab:Hide()
			end

			subtab:Show()
		end)

		tabbox.Tabs[tabName] = subtab

		if not tabbox.ActiveTab then
			subtab:Show()
		end

		return subtab
	end

	return tabbox
end

local Groupbox = {}
Groupbox.__index = Groupbox
setmetatable(Groupbox, { __index = BaseGroupbox })

function Groupbox:SetDescription(description)
	self.Description = description

	if self.DescriptionLabel then
		self.DescriptionLabel.Text = description or ""
		self.DescriptionLabel.Visible = description ~= nil
	end

	self:Resize()
end

function Groupbox:SetCollapsed(collapsed)
	self.Collapsed = collapsed == true

	if self.Container then
		self.Container.Visible = not self.Collapsed
	end
end

function Groupbox:ToggleCollapsed()
	self:SetCollapsed(not self.Collapsed)
end

local Tab = {}
Tab.__index = Tab

function Tab:AddLeftGroupbox(name)
	return self:_CreateGroupbox(name, "Left")
end

function Tab:AddRightGroupbox(name)
	return self:_CreateGroupbox(name, "Right")
end

function Tab:AddLeftTabbox(info)
	local groupbox = self:_CreateGroupbox(
		typeof(info) == "string" and info or (info and info.Name or "Tabbox"),
		"Left"
	)

	return groupbox:AddTabbox(info)
end

function Tab:AddRightTabbox(info)
	local groupbox = self:_CreateGroupbox(
		typeof(info) == "string" and info or (info and info.Name or "Tabbox"),
		"Right"
	)

	return groupbox:AddTabbox(info)
end

function Tab:_CreateGroupbox(name, side)
	local column = side == "Left" and self.LeftColumn or self.RightColumn

	local boxHolder = Create("Frame", {
		Name = tostring(name),
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 50)
	}, column)

	Corner(boxHolder, 6)
	Stroke(boxHolder, COLORS.Stroke, 1)

	local title = Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -24, 0, 20),
		Font = Enum.Font.GothamSemibold,
		Text = tostring(name),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	}, boxHolder)

	local container = Create("Frame", {
		Name = "Container",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 33),
		Size = UDim2.new(1, -24, 0, 20)
	}, boxHolder)

	local layout = Create("UIListLayout", {
		Padding = UDim.new(0, 7),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, container)

	local object = setmetatable({
		Name = tostring(name),
		Visible = true,
		Collapsed = false,
		PoppedOut = false,
		PopOutEnabled = false,
		BoxHolder = boxHolder,
		Holder = boxHolder,
		Container = container,
		Tab = self,
		Elements = {},
		DependencyBoxes = {}
	}, Groupbox)

	function object:Resize()
		local contentHeight = layout.AbsoluteContentSize.Y
		local height = 43 + contentHeight + 10

		if self.Collapsed then
			height = 36
		end

		boxHolder.Size = UDim2.new(1, 0, 0, math.max(height, 43))
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		object:Resize()
	end)

	self.Groupboxes[side][#self.Groupboxes[side] + 1] = object

	object:Resize()

	return object
end

function Tab:SetVisible(visible)
	self.Visible = visible

	if self.Page then
		self.Page.Visible = visible
	end
end

local Window = {}
Window.__index = Window

function Window:AddTab(name, icon)
	local page = Create("ScrollingFrame", {
		Name = tostring(name),
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarImageColor3 = COLORS.Accent,
		ScrollBarThickness = 3,
		Size = UDim2.fromScale(1, 1),
		Visible = false
	}, self.Content)

	local columns = Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -2, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y
	}, page)

	local layout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, columns)

	local left = Create("ScrollingFrame", {
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 0,
		Size = UDim2.new(0.5, -4, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y
	}, columns)

	local right = Create("ScrollingFrame", {
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 0,
		Size = UDim2.new(0.5, -4, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y
	}, columns)

	Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, left)

	Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, right)

	local tabButton = Create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 38),
		Font = Enum.Font.GothamMedium,
		Text = tostring(name),
		TextColor3 = COLORS.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	}, self.SidebarTabs)

	Corner(tabButton, 5)
	Padding(tabButton, 12, 8, 0, 0)

	local tab = setmetatable({
		Name = tostring(name),
		Icon = icon,
		Page = page,
		Button = tabButton,
		Content = columns,
		LeftColumn = left,
		RightColumn = right,
		Groupboxes = {
			Left = {},
			Right = {}
		},
		Window = self
	}, Tab)

	local function select()
		for _, other in pairs(self.Tabs) do
			other.Page.Visible = false
			other.Button.BackgroundColor3 = COLORS.Surface
			other.Button.TextColor3 = COLORS.SubText
		end

		page.Visible = true
		tabButton.BackgroundColor3 = COLORS.Surface2
		tabButton.TextColor3 = COLORS.Text
		self.SelectedTab = tab
	end

	tabButton.MouseButton1Click:Connect(select)

	self.Tabs[name] = tab

	if not self.SelectedTab then
		select()
	end

	return tab
end

function Window:SetVisible(visible)
	self.Visible = visible
	self.ScreenGui.Enabled = visible
end

function Window:Show()
	self:SetVisible(true)
end

function Window:Hide()
	self:SetVisible(false)
end

function Window:Toggle()
	self:SetVisible(not self.Visible)
end

function Window:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

function Library:CreateWindow(settings)
	settings = settings or {}

	local playerGui = GetPlayerGui()

	if not playerGui then
		error("LocalPlayer PlayerGui bulunamadı.")
	end

	local existing = playerGui:FindFirstChild("CustomObsidianUI")

	if existing then
		existing:Destroy()
	end

	local screenGui = Create("ScreenGui", {
		Name = "CustomObsidianUI",
		DisplayOrder = settings.DisplayOrder or 999,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, playerGui)

	local main = Create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = settings.Size or UDim2.fromOffset(720, 500)
	}, screenGui)

	Corner(main, 8)
	Stroke(main, COLORS.Stroke, 1)

	local topbar = Create("Frame", {
		Name = "Topbar",
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 46)
	}, main)

	local title = Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 0),
		Size = UDim2.new(1, -32, 0, 46),
		Font = Enum.Font.GothamBold,
		Text = tostring(settings.Title or "Obsidian"),
		TextColor3 = COLORS.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left
	}, topbar)

	local footer = Create("TextLabel", {
		Name = "Footer",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -16, 0, 0),
		Size = UDim2.new(0, 150, 0, 46),
		Font = Enum.Font.Gotham,
		Text = tostring(settings.Footer or ""),
		TextColor3 = COLORS.SubText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right
	}, topbar)

	local divider = Create("Frame", {
		Name = "Divider",
		BackgroundColor3 = COLORS.Stroke,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 45),
		Size = UDim2.new(1, 0, 0, 1)
	}, topbar)

	local sidebar = Create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = Color3.fromRGB(9, 9, 9),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(0, 155, 1, -46)
	}, main)

	local sidebarTitle = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 13),
		Size = UDim2.new(1, -24, 0, 18),
		Font = Enum.Font.GothamSemibold,
		Text = "TABS",
		TextColor3 = COLORS.SubText,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left
	}, sidebar)

	local sidebarTabs = Create("ScrollingFrame", {
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		Position = UDim2.new(0, 8, 0, 40),
		ScrollBarThickness = 0,
		Size = UDim2.new(1, -16, 1, -48)
	}, sidebar)

	Create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, sidebarTabs)

	local content = Create("Frame", {
		Name = "Content",
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 155, 0, 46),
		Size = UDim2.new(1, -155, 1, -46)
	}, main)

	local window = setmetatable({
		ScreenGui = screenGui,
		Main = main,
		Topbar = topbar,
		Sidebar = sidebar,
		Content = content,
		SidebarTabs = sidebarTabs,
		Tabs = {},
		SelectedTab = nil,
		Visible = true
	}, Window)

	local dragging = false
	local dragStart
	local startPosition

	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPosition = main.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart

			main.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)

	if settings.AutoShow == false then
		window:SetVisible(false)
	end

	return window
end

function Library:Notify(data)
	data = data or {}

	local playerGui = GetPlayerGui()

	if not playerGui then
		return
	end

	local holder = playerGui:FindFirstChild("CustomObsidianNotifications")

	if not holder then
		holder = Create("ScreenGui", {
			Name = "CustomObsidianNotifications",
			DisplayOrder = 10000,
			IgnoreGuiInset = true,
			ResetOnSpawn = false
		}, playerGui)
	end

	local container = holder:FindFirstChild("Container")

	if not container then
		container = Create("Frame", {
			Name = "Container",
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -18, 1, -18),
			Size = UDim2.fromOffset(320, 500)
		}, holder)

		Create("UIListLayout", {
			Padding = UDim.new(0, 7),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder
		}, container)
	end

	local notification = Create("Frame", {
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 65)
	}, container)

	Corner(notification, 6)
	Stroke(notification, COLORS.Stroke, 1)

	local notificationTitle = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -24, 0, 18),
		Font = Enum.Font.GothamSemibold,
		Text = tostring(data.Title or "Notification"),
		TextColor3 = data.TitleColor or COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	}, notification)

	local description = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 28),
		Size = UDim2.new(1, -24, 0, 28),
		Font = Enum.Font.Gotham,
		Text = tostring(data.Description or ""),
		TextColor3 = data.DescriptionColor or COLORS.SubText,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left
	}, notification)

	task.delay(tonumber(data.Time) or 5, function()
		if notification and notification.Parent then
			TweenService:Create(notification, TweenInfo.new(0.2), {
				BackgroundTransparency = 1
			}):Play()

			task.wait(0.2)

			if notification then
				notification:Destroy()
			end
		end
	end)

	return notification
end

function Library:Unload()
	local playerGui = GetPlayerGui()

	if not playerGui then
		return
	end

	local gui = playerGui:FindFirstChild("CustomObsidianUI")

	if gui then
		gui:Destroy()
	end

	local notifications = playerGui:FindFirstChild("CustomObsidianNotifications")

	if notifications then
		notifications:Destroy()
	end

	table.clear(self.Registry)
	table.clear(self.Options)
	table.clear(self.Toggles)
	table.clear(self.Flags)
end

function Library:SetWatermark(text)
	if self.Window and self.Window.Topbar then
		local watermark = self.Window.Topbar:FindFirstChild("Watermark")

		if not watermark then
			watermark = Create("TextLabel", {
				Name = "Watermark",
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -165, 0, 0),
				Size = UDim2.fromOffset(150, 46),
				Font = Enum.Font.Gotham,
				TextColor3 = COLORS.SubText,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Right
			}, self.Window.Topbar)
		end

		watermark.Text = tostring(text or "")
	end
end

Library.SetKeybind = function(self, key, callback)
	if typeof(key) ~= "EnumItem" then
		return
	end

	return UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end

		if input.KeyCode == key then
			SafeCallback(callback)
		end
	end)
end

return Library
