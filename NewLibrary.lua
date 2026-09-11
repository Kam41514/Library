local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Library = {}
Library.__index = Library

Library.Options = {}
Library.Toggles = {}
Library.Flags = {}
Library.Registry = {}

local COLORS = {
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

local function AddStroke(object)
	return Create("UIStroke", {
		Color = COLORS.Stroke,
		Thickness = 1,
		Transparency = 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, object)
end

local function AddCorner(object, radius)
	return Create("UICorner", {
		CornerRadius = UDim.new(0, radius or 5),
	}, object)
end

local function AddPadding(object, left, right, top, bottom)
	return Create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
	}, object)
end

local function SafeCallback(callback, ...)
	if typeof(callback) ~= "function" then
		return
	end

	task.spawn(function(...)
		pcall(callback, ...)
	end, ...)
end

local function GetPlayerGui()
	local player = Players.LocalPlayer

	if not player then
		return nil
	end

	return player:FindFirstChildOfClass("PlayerGui")
		or player:WaitForChild("PlayerGui")
end

local function Round(value, decimals)
	local multiplier = 10 ^ (decimals or 0)
	return math.floor(value * multiplier + 0.5) / multiplier
end

local Groupbox = {}
Groupbox.__index = Groupbox

function Groupbox:_Register(index, object)
	if index then
		Library.Options[index] = object
		Library.Registry[index] = object
	end

	table.insert(self.Elements, object)

	return object
end

function Groupbox:Resize()
	if not self.Container or not self.BoxHolder then
		return
	end

	local layout = self.Container:FindFirstChildOfClass("UIListLayout")

	if not layout then
		return
	end

	local height = layout.AbsoluteContentSize.Y + 45

	if self.Collapsed then
		height = 36
	end

	self.Container.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)

	self.BoxHolder.Size = UDim2.new(
		1,
		0,
		0,
		math.max(height, 44)
	)
end

function Groupbox:SetVisible(value)
	self.Visible = value == true
	self.BoxHolder.Visible = self.Visible

	self:Resize()
end

function Groupbox:Show()
	self:SetVisible(true)
end

function Groupbox:Hide()
	self:SetVisible(false)
end

function Groupbox:SetCollapsed(value)
	self.Collapsed = value == true
	self.Container.Visible = not self.Collapsed

	self:Resize()
end

function Groupbox:ToggleCollapsed()
	self:SetCollapsed(not self.Collapsed)
end

function Groupbox:AddLabel(info, doesWrap)
	local data

	if typeof(info) == "string" then
		data = {
			Text = info,
			DoesWrap = doesWrap,
		}
	else
		data = info or {}
	end

	local holder = Create("Frame", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, data.DoesWrap and 32 or 20),
		AutomaticSize = data.DoesWrap and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
	}, self.Container)

	local label = Create("TextLabel", {
		Name = "Text",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = tostring(data.Text or ""),
		TextColor3 = COLORS.SubText,
		TextSize = 12,
		TextWrapped = data.DoesWrap == true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}, holder)

	local object = {
		Type = "Label",
		Text = tostring(data.Text or ""),
		Holder = holder,
		TextLabel = label,
		Parent = self,
	}

	function object:SetText(text)
		self.Text = tostring(text)
		self.TextLabel.Text = self.Text
		self.Parent:Resize()
	end

	function object:SetVisible(value)
		self.Holder.Visible = value == true
		self.Parent:Resize()
	end

	function object:Destroy()
		self.Holder:Destroy()
	end

	self:_Register(nil, object)
	self:Resize()

	return object
end

function Groupbox:AddDivider()
	local holder = Create("Frame", {
		Name = "Divider",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 8),
	}, self.Container)

	local line = Create("Frame", {
		Name = "Line",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = COLORS.Stroke,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 1),
	}, holder)

	AddStroke(line)

	self:Resize()

	return holder
end

function Groupbox:AddButton(info, callback)
	local data

	if typeof(info) == "string" then
		data = {
			Text = info,
			Func = callback,
		}
	else
		data = info or {}
	end

	local holder = Create("Frame", {
		Name = "Button",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 30),
	}, self.Container)

	local button = Create("TextButton", {
		Name = "Button",
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamSemibold,
		Text = tostring(data.Text or "Button"),
		TextColor3 = data.Risky and COLORS.Red or COLORS.Text,
		TextSize = 12,
	}, holder)

	AddCorner(button, 5)
	local stroke = AddStroke(button)

	local object = {
		Type = "Button",
		Text = tostring(data.Text or "Button"),
		Func = data.Func or function() end,
		Disabled = data.Disabled == true,
		Risky = data.Risky == true,
		Holder = holder,
		Button = button,
		Stroke = stroke,
		Parent = self,
	}

	function object:SetText(text)
		self.Text = tostring(text)
		self.Button.Text = self.Text
	end

	function object:SetDisabled(value)
		self.Disabled = value == true

		if self.Disabled then
			self.Button.TextColor3 = COLORS.Disabled
			self.Button.BackgroundColor3 = COLORS.Surface
		else
			self.Button.TextColor3 = self.Risky and COLORS.Red or COLORS.Text
			self.Button.BackgroundColor3 = COLORS.Surface2
		end
	end

	function object:SetVisible(value)
		self.Holder.Visible = value == true
		self.Parent:Resize()
	end

	function object:Destroy()
		self.Holder:Destroy()
	end

	button.MouseEnter:Connect(function()
		if object.Disabled then
			return
		end

		TweenService:Create(
			button,
			TweenInfo.new(0.12),
			{
				BackgroundColor3 = Color3.fromRGB(18, 18, 18),
			}
		):Play()
	end)

	button.MouseLeave:Connect(function()
		if not object.Disabled then
			button.BackgroundColor3 = COLORS.Surface2
		end
	end)

	button.MouseButton1Click:Connect(function()
		if object.Disabled then
			return
		end

		SafeCallback(object.Func)
	end)

	object:SetDisabled(object.Disabled)

	self:_Register(nil, object)
	self:Resize()

	return object
end

function Groupbox:AddToggle(index, info)
	info = info or {}

	local holder = Create("Frame", {
		Name = "Toggle",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 27),
	}, self.Container)

	local button = Create("TextButton", {
		Name = "Holder",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
	}, holder)

	local checkbox = Create("Frame", {
		Name = "Checkbox",
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, -8),
		Size = UDim2.fromOffset(16, 16),
	}, button)

	AddCorner(checkbox, 4)
	local checkboxStroke = AddStroke(checkbox)

	local check = Create("TextLabel", {
		Name = "Check",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamBold,
		Text = "✓",
		TextColor3 = COLORS.White,
		TextSize = 11,
		Visible = false,
	}, checkbox)

	local label = Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 24, 0, 0),
		Size = UDim2.new(1, -24, 1, 0),
		Font = Enum.Font.GothamSemibold,
		Text = tostring(info.Text or index),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, button)

	local object = {
		Type = "Toggle",
		Text = tostring(info.Text or index),
		Value = info.Default == true,
		Callback = info.Callback or function() end,
		Changed = info.Changed or function() end,
		Disabled = info.Disabled == true,
		Risky = info.Risky == true,
		Holder = holder,
		Button = button,
		Label = label,
		Checkbox = checkbox,
		Check = check,
		Stroke = checkboxStroke,
		Parent = self,
	}

	function object:Display()
		self.Check.Visible = self.Value

		if self.Value then
			self.Checkbox.BackgroundColor3 = COLORS.Accent
			self.Stroke.Color = COLORS.Accent
		else
			self.Checkbox.BackgroundColor3 = COLORS.Surface2
			self.Stroke.Color = COLORS.Stroke
		end

		if self.Disabled then
			self.Label.TextColor3 = COLORS.Disabled
		else
			self.Label.TextColor3 = self.Risky and COLORS.Red or COLORS.Text
		end
	end

	function object:SetValue(value)
		value = value == true

		self.Value = value

		Library.Toggles[index] = value
		Library.Flags[index] = value

		self:Display()

		SafeCallback(self.Callback, value)
		SafeCallback(self.Changed, value)
	end

	function object:OnChanged(callback)
		self.Changed = callback
		return self
	end

	function object:SetDisabled(value)
		self.Disabled = value == true
		self:Display()
	end

	function object:SetText(text)
		self.Text = tostring(text)
		self.Label.Text = self.Text
	end

	function object:SetVisible(value)
		self.Holder.Visible = value == true
		self.Parent:Resize()
	end

	function object:Destroy()
		self.Holder:Destroy()
	end

	button.MouseButton1Click:Connect(function()
		if not object.Disabled then
			object:SetValue(not object.Value)
		end
	end)

	Library.Toggles[index] = object.Value
	Library.Flags[index] = object.Value

	object:Display()

	return self:_Register(index, object)
end

function Groupbox:AddCheckbox(index, info)
	return self:AddToggle(index, info)
end

function Groupbox:AddInput(index, info)
	info = info or {}

	local holder = Create("Frame", {
		Name = "Input",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 52),
	}, self.Container)

	local label = Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = Enum.Font.GothamSemibold,
		Text = tostring(info.Text or index),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, holder)

	local box = Create("TextBox", {
		Name = "TextBox",
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 24),
		Size = UDim2.new(1, 0, 0, 28),
		ClearTextOnFocus = info.ClearTextOnFocus ~= false,
		Font = Enum.Font.GothamMedium,
		PlaceholderText = tostring(info.Placeholder or ""),
		PlaceholderColor3 = COLORS.Disabled,
		Text = tostring(info.Default or ""),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, holder)

	AddCorner(box, 5)
	AddStroke(box)
	AddPadding(box, 9, 9, 0, 0)

	local object = {
		Type = "Input",
		Text = tostring(info.Text or index),
		Value = tostring(info.Default or ""),
		Callback = info.Callback or function() end,
		Changed = info.Changed or function() end,
		Numeric = info.Numeric == true,
		Finished = info.Finished == true,
		AllowEmpty = info.AllowEmpty ~= false,
		EmptyReset = tostring(info.EmptyReset or ""),
		Holder = holder,
		TextBox = box,
		Label = label,
		Parent = self,
	}

	function object:SetValue(value)
		value = tostring(value)

		if self.Numeric and not tonumber(value) then
			return
		end

		if value == "" and not self.AllowEmpty then
			value = self.EmptyReset
		end

		self.Value = value
		self.TextBox.Text = value

		SafeCallback(self.Callback, value)
		SafeCallback(self.Changed, value)
	end

	function object:OnChanged(callback)
		self.Changed = callback
		return self
	end

	function object:SetText(text)
		self.Text = tostring(text)
		self.Label.Text = self.Text
	end

	function object:SetVisible(value)
		self.Holder.Visible = value == true
		self.Parent:Resize()
	end

	function object:Destroy()
		self.Holder:Destroy()
	end

	box.FocusLost:Connect(function()
		local value = box.Text

		if object.Numeric and value ~= "" and not tonumber(value) then
			box.Text = object.Value
			return
		end

		if value == "" and not object.AllowEmpty then
			value = object.EmptyReset
			box.Text = value
		end

		object.Value = value

		SafeCallback(object.Callback, value)
		SafeCallback(object.Changed, value)
	end)

	return self:_Register(index, object)
end

function Groupbox:AddSlider(index, info)
	info = info or {}

	local min = tonumber(info.Min) or 0
	local max = tonumber(info.Max) or 100
	local default = tonumber(info.Default) or min
	local rounding = tonumber(info.Rounding) or 0

	if max < min then
		min, max = max, min
	end

	default = math.clamp(default, min, max)

	local holder = Create("Frame", {
		Name = "Slider",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48),
	}, self.Container)

	local label = Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.7, 0, 0, 20),
		Font = Enum.Font.GothamSemibold,
		Text = tostring(info.Text or index),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, holder)

	local valueLabel = Create("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0.3, 0, 0, 20),
		Font = Enum.Font.GothamSemibold,
		TextColor3 = COLORS.SubText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, holder)

	local bar = Create("Frame", {
		Name = "Bar",
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 28),
		Size = UDim2.new(1, 0, 0, 8),
	}, holder)

	AddCorner(bar, 4)
	AddStroke(bar)

	local fill = Create("Frame", {
		Name = "Fill",
		BackgroundColor3 = COLORS.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
	}, bar)

	AddCorner(fill, 4)

	local object = {
		Type = "Slider",
		Text = tostring(info.Text or index),
		Value = default,
		Min = min,
		Max = max,
		Rounding = rounding,
		Prefix = tostring(info.Prefix or ""),
		Suffix = tostring(info.Suffix or ""),
		Callback = info.Callback or function() end,
		Changed = info.Changed or function() end,
		Disabled = false,
		Holder = holder,
		Bar = bar,
		Fill = fill,
		Label = label,
		ValueLabel = valueLabel,
		Parent = self,
	}

	function object:Display()
		local alpha = 0

		if self.Max ~= self.Min then
			alpha = (self.Value - self.Min) / (self.Max - self.Min)
		end

		alpha = math.clamp(alpha, 0, 1)

		self.Fill.Size = UDim2.new(alpha, 0, 1, 0)
		self.ValueLabel.Text =
			self.Prefix ..
			tostring(self.Value) ..
			self.Suffix

		self.Fill.BackgroundColor3 =
			self.Disabled and COLORS.Disabled or COLORS.Accent
	end

	function object:SetValue(value)
		value = tonumber(value)

		if not value then
			return
		end

		value = math.clamp(value, self.Min, self.Max)
		value = Round(value, self.Rounding)

		self.Value = value
		Library.Flags[index] = value

		self:Display()

		SafeCallback(self.Callback, value)
		SafeCallback(self.Changed, value)
	end

	function object:OnChanged(callback)
		self.Changed = callback
		return self
	end

	function object:SetVisible(value)
		self.Holder.Visible = value == true
		self.Parent:Resize()
	end

	function object:SetDisabled(value)
		self.Disabled = value == true
		self:Display()
	end

	function object:SetText(text)
		self.Text = tostring(text)
		self.Label.Text = self.Text
	end

	function object:Destroy()
		self.Holder:Destroy()
	end

	local dragging = false

	local function update()
		if object.Disabled then
			return
		end

		local mouse = UserInputService:GetMouseLocation()
		local position = bar.AbsolutePosition
		local size = bar.AbsoluteSize

		local alpha = (mouse.X - position.X) / size.X
		alpha = math.clamp(alpha, 0, 1)

		object:SetValue(
			object.Min +
			(object.Max - object.Min) * alpha
		)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			update()
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	object:Display()

	return self:_Register(index, object)
end

function Groupbox:AddDropdown(index, info)
	info = info or {}

	local holder = Create("Frame", {
		Name = "Dropdown",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 52),
		ZIndex = 5,
	}, self.Container)

	local label = Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = Enum.Font.GothamSemibold,
		Text = tostring(info.Text or index),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 5,
	}, holder)

	local button = Create("TextButton", {
		Name = "Button",
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 24),
		Size = UDim2.new(1, 0, 0, 28),
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
	}, holder)

	AddCorner(button, 5)
	AddStroke(button)
	AddPadding(button, 9, 30, 0, 0)

	local arrow = Create("TextLabel", {
		Name = "Arrow",
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(15, 15),
		Font = Enum.Font.GothamBold,
		Text = "⌄",
		TextColor3 = COLORS.SubText,
		TextSize = 13,
		ZIndex = 7,
	}, button)

	local popup = Create("Frame", {
		Name = "DropdownPopup",
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, 4),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = false,
		ZIndex = 100,
	}, button)

	AddCorner(popup, 5)
	AddStroke(popup)

	local scroll = Create("ScrollingFrame", {
		Name = "Options",
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		Position = UDim2.fromOffset(4, 4),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = COLORS.Accent,
		Size = UDim2.new(1, -8, 1, -8),
		ZIndex = 101,
	}, popup)

	AddStroke(scroll)

	Create("UIListLayout", {
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, scroll)

	local object = {
		Type = "Dropdown",
		Text = tostring(info.Text or index),
		Values = info.Values or {},
		Value = info.Default,
		Multi = info.Multi == true,
		Callback = info.Callback or function() end,
		Changed = info.Changed or function() end,
		DisabledValues = info.DisabledValues or {},
		Disabled = false,
		Open = false,
		Holder = holder,
		Button = button,
		Popup = popup,
		OptionsFrame = scroll,
		Label = label,
		Parent = self,
	}

	local function isDisabled(value)
		for _, disabled in pairs(object.DisabledValues) do
			if disabled == value then
				return true
			end
		end

		return false
	end

	local function getDisplay()
		if object.Multi then
			local selected = {}

			if typeof(object.Value) == "table" then
				for value, enabled in pairs(object.Value) do
					if enabled then
						table.insert(selected, tostring(value))
					end
				end
			end

			return #selected > 0
				and table.concat(selected, ", ")
				or "None"
		end

		return object.Value ~= nil
			and tostring(object.Value)
			or "None"
	end

	function object:SetOpen(value)
		if self.Disabled then
			return
		end

		self.Open = value == true

		self.Popup.Visible = self.Open

		if self.Open then
			local count = 0

			for _, value in pairs(self.Values) do
				count += 1
			end

			self.Popup.Size = UDim2.new(
				1,
				0,
				0,
				math.clamp(count * 29 + 10, 35, 190)
			)

			self.Button.TextColor3 = COLORS.White
			self.Parent:Resize()
		else
			self.Popup.Size = UDim2.new(1, 0, 0, 0)
			self.Button.TextColor3 = COLORS.Text
		end

		self.Button.Text = getDisplay()
		self.Arrow.Text = self.Open and "⌃" or "⌄"
	end

	function object:SetValue(value)
		if self.Multi then
			if typeof(value) ~= "table" then
				value = {}
			end
		end

		self.Value = value

		self.Button.Text = getDisplay()

		SafeCallback(self.Callback, value)
		SafeCallback(self.Changed, value)
	end

	function object:GetActiveValues(returnCount)
		if not self.Multi then
			if returnCount then
				return self.Value and 1 or 0
			end

			return {
				self.Value
			}
		end

		local result = {}

		for value, enabled in pairs(self.Value or {}) do
			if enabled then
				table.insert(result, value)
			end
		end

		if returnCount then
			return #result
		end

		return result
	end

	function object:SetValues(values)
		self.Values = values or {}
		self:Rebuild()
	end

	function object:AddValues(values)
		if typeof(values) == "string" then
			values = {
				values
			}
		end

		for key, value in pairs(values or {}) do
			self.Values[key] = value
		end

		self:Rebuild()
	end

	function object:SetDisabledValues(values)
		self.DisabledValues = values or {}
		self:Rebuild()
	end

	function object:SetDisabled(value)
		self.Disabled = value == true

		self.Button.TextColor3 =
			self.Disabled and COLORS.Disabled or COLORS.Text
	end

	function object:SetVisible(value)
		self.Holder.Visible = value == true
		self.Parent:Resize()
	end

	function object:OnChanged(callback)
		self.Changed = callback
		return self
	end

	function object:Rebuild()
		for _, child in ipairs(self.OptionsFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for key, value in pairs(self.Values) do
			local actualValue

			if typeof(key) == "number" then
				actualValue = value
			else
				actualValue = key
			end

			local option = Create("TextButton", {
				Name = tostring(actualValue),
				AutoButtonColor = false,
				BackgroundColor3 = COLORS.Surface2,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 26),
				Font = Enum.Font.GothamMedium,
				Text = tostring(actualValue),
				TextColor3 = COLORS.Text,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 102,
			}, self.OptionsFrame)

			AddCorner(option, 4)
			AddStroke(option)
			AddPadding(option, 8, 8, 0, 0)

			if isDisabled(actualValue) then
				option.TextColor3 = COLORS.Disabled
			end

			option.MouseEnter:Connect(function()
				if not isDisabled(actualValue) then
					option.BackgroundColor3 = Color3.fromRGB(19, 19, 19)
				end
			end)

			option.MouseLeave:Connect(function()
				option.BackgroundColor3 = COLORS.Surface2
			end)

			option.MouseButton1Click:Connect(function()
				if isDisabled(actualValue) then
					return
				end

				if self.Multi then
					if typeof(self.Value) ~= "table" then
						self.Value = {}
					end

					self.Value[actualValue] =
						not self.Value[actualValue]
				else
					self.Value = actualValue
					self:SetOpen(false)
				end

				self.Button.Text = getDisplay()

				SafeCallback(self.Callback, self.Value)
				SafeCallback(self.Changed, self.Value)
			end)
		end

		self.Button.Text = getDisplay()
	end

	function object:Destroy()
		self:SetOpen(false)
		self.Holder:Destroy()
	end

	button.MouseButton1Click:Connect(function()
		object:SetOpen(not object.Open)
	end)

	object:Rebuild()

	if object.Multi and typeof(object.Value) ~= "table" then
		object.Value = {}
	end

	object.Button.Text = getDisplay()

	return self:_Register(index, object)
end

function Groupbox:AddTabbox(info)
	local name

	if typeof(info) == "string" then
		name = info
	else
		name = info and info.Name or "Tabbox"
	end

	local holder = Create("Frame", {
		Name = tostring(name),
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 130),
	}, self.Container)

	AddCorner(holder, 6)
	AddStroke(holder)

	local tabbar = Create("Frame", {
		Name = "Tabbar",
		BackgroundColor3 = COLORS.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 31),
	}, holder)

	AddCorner(tabbar, 6)
	AddStroke(tabbar)

	local tabs = Create("Frame", {
		Name = "Buttons",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	}, tabbar)

	local tabLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, tabs)

	local content = Create("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 39),
		Size = UDim2.new(1, -16, 1, -47),
	}, holder)

	local tabbox = {
		Type = "Tabbox",
		Holder = holder,
		Tabs = {},
		ActiveTab = nil,
		Parent = self,
	}

	function tabbox:AddTab(tabName)
		local button = Create("TextButton", {
			Name = tostring(tabName),
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(90, 31),
			Font = Enum.Font.GothamSemibold,
			Text = tostring(tabName),
			TextColor3 = COLORS.SubText,
			TextSize = 11,
		}, tabs)

		local page = Create("ScrollingFrame", {
			Name = tostring(tabName),
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = COLORS.Accent,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
		}, content)

		Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, page)

		local subtab = setmetatable({
			Type = "Tab",
			Name = tostring(tabName),
			Button = button,
			Container = page,
			Elements = {},
			DependencyBoxes = {},
			Parent = tabbox,
		}, Groupbox)

		function subtab:Show()
			for _, other in pairs(tabbox.Tabs) do
				other.Container.Visible = false
				other.Button.TextColor3 = COLORS.SubText
			end

			self.Container.Visible = true
			self.Button.TextColor3 = COLORS.Text
			tabbox.ActiveTab = self
		end

		function subtab:Hide()
			self.Container.Visible = false
			self.Button.TextColor3 = COLORS.SubText
		end

		button.MouseButton1Click:Connect(function()
			subtab:Show()
		end)

		tabbox.Tabs[tabName] = subtab

		if not tabbox.ActiveTab then
			subtab:Show()
		end

		return subtab
	end

	self:Resize()

	return tabbox
end

local Tab = {}
Tab.__index = Tab

function Tab:_CreateGroupbox(name, side)
	local column = side == "Left"
		and self.LeftColumn
		or self.RightColumn

	local holder = Create("Frame", {
		Name = tostring(name),
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 45),
	}, column)

	AddCorner(holder, 6)
	AddStroke(holder)

	local title = Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -24, 0, 20),
		Font = Enum.Font.GothamBold,
		Text = tostring(name),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, holder)

	local container = Create("Frame", {
		Name = "Container",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 34),
		Size = UDim2.new(1, -24, 0, 0),
	}, holder)

	local layout = Create("UIListLayout", {
		Padding = UDim.new(0, 7),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, container)

	local object = setmetatable({
		Type = "Groupbox",
		Name = tostring(name),
		Holder = holder,
		BoxHolder = holder,
		Container = container,
		Title = title,
		Elements = {},
		DependencyBoxes = {},
		Collapsed = false,
		Visible = true,
		Tab = self,
	}, Groupbox)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		object:Resize()
	end)

	table.insert(self.Groupboxes[side], object)

	object:Resize()

	return object
end

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
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = COLORS.Accent,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
	}, self.Content)

	local columns = Create("Frame", {
		Name = "Columns",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -12, 0, 0),
		Position = UDim2.new(0, 6, 0, 6),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, page)

	local columnLayout = Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, columns)

	local left = Create("Frame", {
		Name = "Left",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -4, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, columns)

	local right = Create("Frame", {
		Name = "Right",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -4, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, columns)

	Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, left)

	Create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, right)

	local button = Create("TextButton", {
		Name = tostring(name),
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 36),
		Font = Enum.Font.GothamSemibold,
		Text = tostring(name),
		TextColor3 = COLORS.SubText,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, self.SidebarTabs)

	AddCorner(button, 5)
	AddStroke(button)
	AddPadding(button, 11, 8, 0, 0)

	local tab = setmetatable({
		Type = "Tab",
		Name = tostring(name),
		Icon = icon,
		Page = page,
		Button = button,
		Content = columns,
		LeftColumn = left,
		RightColumn = right,
		Groupboxes = {
			Left = {},
			Right = {},
		},
		Window = self,
	}, Tab)

	local function select()
		for _, other in pairs(self.Tabs) do
			other.Page.Visible = false
			other.Button.BackgroundColor3 = COLORS.Surface
			other.Button.TextColor3 = COLORS.SubText
		end

		page.Visible = true
		button.BackgroundColor3 = COLORS.Surface2
		button.TextColor3 = COLORS.Text

		self.SelectedTab = tab
	end

	button.MouseButton1Click:Connect(select)

	self.Tabs[name] = tab

	if not self.SelectedTab then
		select()
	end

	return tab
end

function Window:Show()
	self.Visible = true

	if self.ScreenGui then
		self.ScreenGui.Enabled = true
	end
end

function Window:Hide()
	self.Visible = false

	if self.ScreenGui then
		self.ScreenGui.Enabled = false
	end
end

function Window:Toggle()
	if self.Visible then
		self:Hide()
	else
		self:Show()
	end
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
		error("PlayerGui not found")
	end

	local old = playerGui:FindFirstChild("CustomObsidianUI")

	if old then
		old:Destroy()
	end

	local screenGui = Create("ScreenGui", {
		Name = "CustomObsidianUI",
		DisplayOrder = settings.DisplayOrder or 999,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
	}, playerGui)

	local main = Create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = settings.Size or UDim2.fromOffset(720, 500),
	}, screenGui)

	AddCorner(main, 8)
	AddStroke(main)

	local topbar = Create("Frame", {
		Name = "Topbar",
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 46),
	}, main)

	AddStroke(topbar)

	local title = Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 0),
		Size = UDim2.new(1, -32, 0, 46),
		Font = Enum.Font.GothamBold,
		Text = tostring(settings.Title or "Obsidian"),
		TextColor3 = COLORS.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, topbar)

	local footer = Create("TextLabel", {
		Name = "Footer",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -16, 0, 0),
		Size = UDim2.fromOffset(160, 46),
		Font = Enum.Font.GothamMedium,
		Text = tostring(settings.Footer or ""),
		TextColor3 = COLORS.SubText,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, topbar)

	local sidebar = Create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = COLORS.Frame,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(0, 155, 1, -46),
	}, main)

	AddStroke(sidebar)

	local sidebarTitle = Create("TextLabel", {
		Name = "SidebarTitle",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(1, -24, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = "TABS",
		TextColor3 = COLORS.SubText,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, sidebar)

	local sidebarTabs = Create("ScrollingFrame", {
		Name = "Tabs",
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		Position = UDim2.new(0, 8, 0, 39),
		ScrollBarThickness = 0,
		Size = UDim2.new(1, -16, 1, -47),
	}, sidebar)

	Create("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, sidebarTabs)

	local content = Create("Frame", {
		Name = "Content",
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 155, 0, 46),
		Size = UDim2.new(1, -155, 1, -46),
	}, main)

	AddStroke(content)

	local window = setmetatable({
		Type = "Window",
		ScreenGui = screenGui,
		Main = main,
		Topbar = topbar,
		Sidebar = sidebar,
		Content = content,
		SidebarTabs = sidebarTabs,
		Tabs = {},
		SelectedTab = nil,
		Visible = true,
	}, Window)

	Library.Window = window

	local dragging = false
	local dragStart
	local startPosition

	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPosition = main.Position
		end
	end)

	topbar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
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
		window:Hide()
	end

	return window
end

function Library:Notify(data)
	data = data or {}

	local playerGui = GetPlayerGui()

	if not playerGui then
		return
	end

	local gui = playerGui:FindFirstChild("CustomObsidianNotifications")

	if not gui then
		gui = Create("ScreenGui", {
			Name = "CustomObsidianNotifications",
			DisplayOrder = 10000,
			IgnoreGuiInset = true,
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
		}, playerGui)
	end

	local container = gui:FindFirstChild("Container")

	if not container then
		container = Create("Frame", {
			Name = "Container",
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -18, 1, -18),
			Size = UDim2.fromOffset(320, 500),
		}, gui)

		Create("UIListLayout", {
			Padding = UDim.new(0, 7),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}, container)
	end

	local notification = Create("Frame", {
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 65),
	}, container)

	AddCorner(notification, 6)
	AddStroke(notification)

	local notificationTitle = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 8),
		Size = UDim2.new(1, -24, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = tostring(data.Title or "Notification"),
		TextColor3 = data.TitleColor or COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, notification)

	local description = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 29),
		Size = UDim2.new(1, -24, 0, 28),
		Font = Enum.Font.GothamMedium,
		Text = tostring(data.Description or ""),
		TextColor3 = data.DescriptionColor or COLORS.SubText,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, notification)

	task.delay(tonumber(data.Time) or 5, function()
		if notification and notification.Parent then
			TweenService:Create(
				notification,
				TweenInfo.new(0.2),
				{
					BackgroundTransparency = 1,
				}
			):Play()

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

	if playerGui then
		local gui = playerGui:FindFirstChild("CustomObsidianUI")

		if gui then
			gui:Destroy()
		end

		local notifications = playerGui:FindFirstChild("CustomObsidianNotifications")

		if notifications then
			notifications:Destroy()
		end
	end

	table.clear(Library.Options)
	table.clear(Library.Toggles)
	table.clear(Library.Flags)
	table.clear(Library.Registry)

	Library.Window = nil
end

return Library
