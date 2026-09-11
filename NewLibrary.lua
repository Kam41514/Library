local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Library = {}
Library.__index = Library

Library.Options = {}
Library.Toggles = {}
Library.Flags = {}
Library.Registry = {}
Library.Theme = nil
Library.Window = nil

local COLORS = {
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

local function Stroke(object, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Name = "UIStroke"
	stroke.Color = COLORS.Stroke
	stroke.Thickness = thickness or 1
	stroke.Transparency = 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = object
	return stroke
end

local function Corner(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 5)
	corner.Parent = object
	return corner
end

local function Padding(object, left, right, top, bottom)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.PaddingRight = UDim.new(0, right or 0)
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingBottom = UDim.new(0, bottom or 0)
	padding.Parent = object
	return padding
end

local function ListLayout(object, padding, direction)
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, padding or 0)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.FillDirection = direction or Enum.FillDirection.Vertical
	layout.Parent = object
	return layout
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

local function GetGuiFont()
	return Enum.Font.GothamMedium
end

local function GetBoldFont()
	return Enum.Font.GothamSemibold
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

	local contentHeight = layout.AbsoluteContentSize.Y
	local titleHeight = 36
	local bottomPadding = 10

	self.Container.Size = UDim2.new(
		1,
		-20,
		0,
		contentHeight
	)

	self.BoxHolder.Size = UDim2.new(
		1,
		0,
		0,
		math.max(46, titleHeight + contentHeight + bottomPadding)
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
		Size = UDim2.new(
			1,
			0,
			0,
			data.DoesWrap and 34 or 20
		),
		AutomaticSize = data.DoesWrap
			and Enum.AutomaticSize.Y
			or Enum.AutomaticSize.None,
	}, self.Container)

	local label = Create("TextLabel", {
		Name = "Text",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = GetGuiFont(),
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
		if self.Holder then
			self.Holder:Destroy()
		end
	end

	self:_Register(nil, object)
	self:Resize()

	return object
end

function Groupbox:AddDivider()
	local holder = Create("Frame", {
		Name = "Divider",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 9),
	}, self.Container)

	local line = Create("Frame", {
		Name = "Line",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = COLORS.Stroke,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 1),
	}, holder)

	Stroke(line)

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
		Name = "ButtonHolder",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 31),
	}, self.Container)

	local button = Create("TextButton", {
		Name = "Button",
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Font = GetBoldFont(),
		Text = tostring(data.Text or "Button"),
		TextColor3 = data.Risky and COLORS.Red or COLORS.Text,
		TextSize = 12,
	}, holder)

	Corner(button, 5)
	local buttonStroke = Stroke(button)

	local object = {
		Type = "Button",
		Text = tostring(data.Text or "Button"),
		Func = data.Func or function() end,
		Disabled = data.Disabled == true,
		Risky = data.Risky == true,
		Holder = holder,
		Button = button,
		Stroke = buttonStroke,
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
			self.Button.TextColor3 =
				self.Risky and COLORS.Red or COLORS.Text

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
				BackgroundColor3 = Color3.fromRGB(19, 19, 19),
			}
		):Play()
	end)

	button.MouseLeave:Connect(function()
		if not object.Disabled then
			TweenService:Create(
				button,
				TweenInfo.new(0.12),
				{
					BackgroundColor3 = COLORS.Surface2,
				}
			):Play()
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

	Corner(checkbox, 4)
	local checkboxStroke = Stroke(checkbox)

	local check = Create("TextLabel", {
		Name = "Check",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Font = Enum.Font.GothamBold,
		Text = "✓",
		TextColor3 = COLORS.White,
		TextSize = 10,
		Visible = false,
	}, checkbox)

	local label = Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 24, 0, 0),
		Size = UDim2.new(1, -24, 1, 0),
		Font = GetBoldFont(),
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
			self.Label.TextColor3 =
				self.Risky and COLORS.Red or COLORS.Text
		end
	end

	function object:SetValue(value)
		self.Value = value == true

		Library.Toggles[index] = self.Value
		Library.Flags[index] = self.Value

		self:Display()

		SafeCallback(self.Callback, self.Value)
		SafeCallback(self.Changed, self.Value)
	end

	function object:SetText(text)
		self.Text = tostring(text)
		self.Label.Text = self.Text
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
		Size = UDim2.new(1, 0, 0, 53),
	}, self.Container)

	local label = Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = GetBoldFont(),
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
		Size = UDim2.new(1, 0, 0, 29),
		ClearTextOnFocus = info.ClearTextOnFocus ~= false,
		Font = GetGuiFont(),
		PlaceholderText = tostring(info.Placeholder or ""),
		PlaceholderColor3 = COLORS.Disabled,
		Text = tostring(info.Default or ""),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, holder)

	Corner(box, 5)
	Stroke(box)
	Padding(box, 9, 9, 0, 0)

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

		if self.Numeric and value ~= "" and not tonumber(value) then
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

	function object:SetText(text)
		self.Text = tostring(text)
		self.Label.Text = self.Text
	end

	function object:OnChanged(callback)
		self.Changed = callback
		return self
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
		Size = UDim2.new(1, 0, 0, 49),
	}, self.Container)

	local label = Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.7, 0, 0, 20),
		Font = GetBoldFont(),
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
		Font = GetBoldFont(),
		TextColor3 = COLORS.SubText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, holder)

	local bar = Create("Frame", {
		Name = "Bar",
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 29),
		Size = UDim2.new(1, 0, 0, 7),
	}, holder)

	Corner(bar, 4)
	Stroke(bar)

	local fill = Create("Frame", {
		Name = "Fill",
		BackgroundColor3 = COLORS.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
	}, bar)

	Corner(fill, 4)

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

	function object:SetText(text)
		self.Text = tostring(text)
		self.Label.Text = self.Text
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
		self.Holder.Visible = value == true
		self.Parent:Resize()
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
		Size = UDim2.new(1, 0, 0, 53),
		ZIndex = 10,
	}, self.Container)

	local label = Create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = GetBoldFont(),
		Text = tostring(info.Text or index),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 10,
	}, holder)

	local button = Create("TextButton", {
		Name = "Button",
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.Surface2,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 24),
		Size = UDim2.new(1, 0, 0, 29),
		Font = GetGuiFont(),
		Text = "",
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 11,
	}, holder)

	Corner(button, 5)
	Stroke(button)
	Padding(button, 9, 32, 0, 0)

	local arrow = Create("TextLabel", {
		Name = "Arrow",
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Font = Enum.Font.GothamBold,
		Text = "⌄",
		TextColor3 = COLORS.SubText,
		TextSize = 12,
		ZIndex = 12,
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

	Corner(popup, 5)
	Stroke(popup)

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

	ListLayout(scroll, 3)

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
		Arrow = arrow,
		Parent = self,
	}

	if object.Multi and typeof(object.Value) ~= "table" then
		object.Value = {}
	end

	local function IsDisabled(value)
		for _, disabled in pairs(object.DisabledValues) do
			if disabled == value then
				return true
			end
		end

		return false
	end

	local function DisplayValue()
		if object.Multi then
			local selected = {}

			for value, enabled in pairs(object.Value or {}) do
				if enabled then
					table.insert(selected, tostring(value))
				end
			end

			table.sort(selected)

			if #selected == 0 then
				return "None"
			end

			local text = table.concat(selected, ", ")

			if #text > 34 then
				text = string.sub(text, 1, 31) .. "..."
			end

			return text
		end

		if object.Value == nil then
			return "None"
		end

		return tostring(object.Value)
	end

	function object:SetOpen(value)
		if self.Disabled then
			return
		end

		self.Open = value == true
		self.Popup.Visible = self.Open

		if self.Open then
			local count = 0

			for _ in pairs(self.Values) do
				count += 1
			end

			self.Popup.Size = UDim2.new(
				1,
				0,
				0,
				math.clamp(count * 29 + 10, 39, 190)
			)

			self.Arrow.Text = "⌃"
			self.Button.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
		else
			self.Popup.Size = UDim2.new(1, 0, 0, 0)
			self.Arrow.Text = "⌄"
			self.Button.BackgroundColor3 = COLORS.Surface2
		end

		self.Button.Text = DisplayValue()
	end

	function object:SetValue(value)
		if self.Multi then
			if typeof(value) ~= "table" then
				return
			end
		end

		self.Value = value
		self.Button.Text = DisplayValue()

		SafeCallback(self.Callback, value)
		SafeCallback(self.Changed, value)
	end

	function object:SetValues(values)
		self.Values = values or {}
		self:Rebuild()
	end

	function object:AddValues(values)
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

		if self.Disabled then
			self:SetOpen(false)
		end
	end

	function object:SetVisible(value)
		self.Holder.Visible = value == true
		self.Parent:Resize()
	end

	function object:OnChanged(callback)
		self.Changed = callback
		return self
	end

	function object:GetActiveValues(returnCount)
		if not self.Multi then
			if returnCount then
				return self.Value ~= nil and 1 or 0
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

	function object:Rebuild()
		for _, child in ipairs(self.OptionsFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		local values = self.Values or {}
		local array = {}

		for key, value in pairs(values) do
			local actual

			if typeof(key) == "number" then
				actual = value
			else
				actual = key
			end

			table.insert(array, actual)
		end

		table.sort(array, function(a, b)
			return tostring(a) < tostring(b)
		end)

		for _, actualValue in ipairs(array) do
			local option = Create("TextButton", {
				Name = tostring(actualValue),
				AutoButtonColor = false,
				BackgroundColor3 = COLORS.Surface2,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 26),
				Font = GetGuiFont(),
				Text = tostring(actualValue),
				TextColor3 = IsDisabled(actualValue)
					and COLORS.Disabled
					or COLORS.Text,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 102,
			}, self.OptionsFrame)

			Corner(option, 4)
			Stroke(option)
			Padding(option, 8, 8, 0, 0)

			option.MouseEnter:Connect(function()
				if not IsDisabled(actualValue) then
					option.BackgroundColor3 =
						Color3.fromRGB(20, 20, 20)
				end
			end)

			option.MouseLeave:Connect(function()
				option.BackgroundColor3 = COLORS.Surface2
			end)

			option.MouseButton1Click:Connect(function()
				if IsDisabled(actualValue) then
					return
				end

				if self.Multi then
					self.Value[actualValue] =
						not self.Value[actualValue]

					self.Button.Text = DisplayValue()

					SafeCallback(
						self.Callback,
						self.Value
					)

					SafeCallback(
						self.Changed,
						self.Value
					)
				else
					self.Value = actualValue
					self.Button.Text = DisplayValue()

					self:SetOpen(false)

					SafeCallback(
						self.Callback,
						self.Value
					)

					SafeCallback(
						self.Changed,
						self.Value
					)
				end
			end)
		end

		self.Button.Text = DisplayValue()
	end

	function object:Destroy()
		self:SetOpen(false)
		self.Holder:Destroy()
	end

	button.MouseButton1Click:Connect(function()
		object:SetOpen(not object.Open)
	end)

	object:Rebuild()

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
		Size = UDim2.new(1, 0, 0, 135),
		ClipsDescendants = false,
	}, self.Container)

	Corner(holder, 6)
	Stroke(holder)

	local tabbar = Create("Frame", {
		Name = "Tabbar",
		BackgroundColor3 = COLORS.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),
	}, holder)

	Corner(tabbar, 6)
	Stroke(tabbar)

	local tabs = Create("Frame", {
		Name = "Buttons",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(4, 0),
		Size = UDim2.new(1, -8, 1, 0),
	}, tabbar)

	ListLayout(
		tabs,
		3,
		Enum.FillDirection.Horizontal
	)

	local content = Create("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Position = UDim2.new(0, 9, 0, 39),
		Size = UDim2.new(1, -18, 1, -46),
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
			BackgroundColor3 = COLORS.Surface,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(82, 28),
			Font = GetBoldFont(),
			Text = tostring(tabName),
			TextColor3 = COLORS.SubText,
			TextSize = 11,
		}, tabs)

		Corner(button, 4)
		Stroke(button)

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

		ListLayout(page, 6)

		local subtab = setmetatable({
			Type = "Tab",
			Name = tostring(tabName),
			Button = button,
			Container = page,
			Elements = {},
			Parent = tabbox,
		}, Groupbox)

		function subtab:Resize()
			local layout = self.Container:FindFirstChildOfClass("UIListLayout")

			if layout then
				self.Container.CanvasSize = UDim2.new(
					0,
					0,
					0,
					layout.AbsoluteContentSize.Y + 5
				)
			end
		end

		function subtab:Show()
			for _, other in pairs(tabbox.Tabs) do
				other.Container.Visible = false
				other.Button.BackgroundColor3 = COLORS.Surface
				other.Button.TextColor3 = COLORS.SubText
			end

			self.Container.Visible = true
			self.Button.BackgroundColor3 = COLORS.Surface2
			self.Button.TextColor3 = COLORS.Text

			tabbox.ActiveTab = self
		end

		function subtab:Hide()
			self.Container.Visible = false
			self.Button.BackgroundColor3 = COLORS.Surface
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
	local column

	if side == "Left" then
		column = self.LeftColumn
	else
		column = self.RightColumn
	end

	local holder = Create("Frame", {
		Name = tostring(name),
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 48),
		ClipsDescendants = false,
	}, column)

	Corner(holder, 6)
	Stroke(holder)

	local title = Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 11, 0, 7),
		Size = UDim2.new(1, -22, 0, 20),
		Font = GetBoldFont(),
		Text = tostring(name),
		TextColor3 = COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, holder)

	local container = Create("Frame", {
		Name = "Container",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 11, 0, 33),
		Size = UDim2.new(1, -22, 0, 0),
		ClipsDescendants = false,
	}, holder)

	local layout = ListLayout(container, 7)

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

		if self.Page then
			self.Page.CanvasSize = UDim2.new(
				0,
				0,
				0,
				math.max(
					self.Page.CanvasSize.Y.Offset,
					self.Content.AbsoluteSize.Y
				)
			)
		end
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
	local name

	if typeof(info) == "string" then
		name = info
	else
		name = info and info.Name or "Tabbox"
	end

	local groupbox = self:_CreateGroupbox(name, "Left")

	return groupbox:AddTabbox(info)
end

function Tab:AddRightTabbox(info)
	local name

	if typeof(info) == "string" then
		name = info
	else
		name = info and info.Name or "Tabbox"
	end

	local groupbox = self:_CreateGroupbox(name, "Right")

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
		Position = UDim2.fromOffset(7, 7),
		Size = UDim2.new(1, -14, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, page)

	local columnLayout = ListLayout(
		columns,
		8,
		Enum.FillDirection.Horizontal
	)

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

	ListLayout(left, 8)
	ListLayout(right, 8)

	local button = Create("TextButton", {
		Name = tostring(name),
		AutoButtonColor = false,
		BackgroundColor3 = COLORS.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 34),
		Font = GetBoldFont(),
		Text = tostring(name),
		TextColor3 = COLORS.SubText,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, self.SidebarTabs)

	Corner(button, 5)
	Stroke(button)
	Padding(button, 10, 7, 0, 0)

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

	local oldGui = playerGui:FindFirstChild("CustomObsidianUI")

	if oldGui then
		oldGui:Destroy()
	end

	local screenGui = Create("ScreenGui", {
		Name = "CustomObsidianUI",
		DisplayOrder = settings.DisplayOrder or 999,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
	}, playerGui)

	local mainSize = settings.Size or UDim2.fromOffset(720, 500)

	local main = Create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = mainSize,
		ClipsDescendants = false,
	}, screenGui)

	Corner(main, 8)
	Stroke(main, 1)

	local topbar = Create("Frame", {
		Name = "Topbar",
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
	}, main)

	Stroke(topbar, 1)

	local titleHolder = Create("Frame", {
		Name = "TitleHolder",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(13, 0),
		Size = UDim2.new(1, -110, 1, 0),
	}, topbar)

	local titleAccent = Create("Frame", {
		Name = "Accent",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = COLORS.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(3, 18),
	}, titleHolder)

	Corner(titleAccent, 2)

	local title = Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -12, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = tostring(settings.Title or "Obsidian"),
		TextColor3 = COLORS.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}, titleHolder)

	local footer = Create("TextLabel", {
		Name = "Footer",
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(120, 20),
		Font = GetGuiFont(),
		Text = tostring(settings.Footer or ""),
		TextColor3 = COLORS.SubText,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Center,
	}, topbar)

	local separator = Create("Frame", {
		Name = "Separator",
		BackgroundColor3 = COLORS.Stroke,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
	}, topbar)

	Stroke(separator)

	local sidebar = Create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = COLORS.Frame,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(0, 146, 1, -40),
	}, main)

	Stroke(sidebar)

	local sidebarTabs = Create("ScrollingFrame", {
		Name = "Tabs",
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		Position = UDim2.fromOffset(8, 9),
		ScrollBarThickness = 0,
		Size = UDim2.new(1, -16, 1, -18),
	}, sidebar)

	ListLayout(sidebarTabs, 5)

	local content = Create("Frame", {
		Name = "Content",
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 146, 0, 40),
		Size = UDim2.new(1, -146, 1, -40),
		ClipsDescendants = false,
	}, main)

	Stroke(content)

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

		ListLayout(
			container,
			7
		).VerticalAlignment = Enum.VerticalAlignment.Bottom
	end

	local notification = Create("Frame", {
		BackgroundColor3 = COLORS.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 64),
	}, container)

	Corner(notification, 6)
	Stroke(notification)

	local accent = Create("Frame", {
		BackgroundColor3 = COLORS.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 7),
		Size = UDim2.new(0, 3, 1, -14),
	}, notification)

	Corner(accent, 2)

	local notificationTitle = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(13, 7),
		Size = UDim2.new(1, -23, 0, 18),
		Font = GetBoldFont(),
		Text = tostring(data.Title or "Notification"),
		TextColor3 = data.TitleColor or COLORS.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, notification)

	local description = Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(13, 27),
		Size = UDim2.new(1, -23, 0, 28),
		Font = GetGuiFont(),
		Text = tostring(data.Description or ""),
		TextColor3 = data.DescriptionColor or COLORS.SubText,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, notification)

	task.delay(tonumber(data.Time) or 5, function()
		if not notification or not notification.Parent then
			return
		end

		local tween = TweenService:Create(
			notification,
			TweenInfo.new(0.2),
			{
				BackgroundTransparency = 1,
			}
		)

		tween:Play()

		task.wait(0.2)

		if notification then
			notification:Destroy()
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

		local notifications =
			playerGui:FindFirstChild("CustomObsidianNotifications")

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
