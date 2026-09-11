local Library = {
	Options = {},
	Toggles = {},
	Flags = {},
	Connections = {},
	Windows = {},
	Unloaded = false,
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Theme = {
	Background = Color3.fromRGB(8, 8, 8),
	Surface = Color3.fromRGB(11, 11, 11),
	Surface2 = Color3.fromRGB(14, 14, 14),
	Stroke = Color3.fromRGB(18, 18, 18),
	Text = Color3.fromRGB(238, 238, 238),
	SubText = Color3.fromRGB(150, 150, 150),
	Disabled = Color3.fromRGB(80, 80, 80),
	Accent = Color3.fromRGB(132, 94, 255),
	AccentDark = Color3.fromRGB(94, 67, 185),
	White = Color3.fromRGB(255, 255, 255),
	Red = Color3.fromRGB(225, 75, 75),
}

local Font = Enum.Font.GothamMedium
local FontBold = Enum.Font.GothamBold

local function New(class, properties, parent)
	local object = Instance.new(class)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	object.Parent = parent
	return object
end

local function Stroke(parent, color, thickness, transparency)
	local stroke = New("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)

	return stroke
end

local function Corner(parent, radius)
	return New("UICorner", {
		CornerRadius = UDim.new(0, radius or 6),
	}, parent)
end

local function Tween(object, properties, duration)
	if not object then
		return
	end

	local tween = TweenService:Create(
		object,
		TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		properties
	)

	tween:Play()
	return tween
end

local function Disconnect(connection)
	if connection then
		pcall(function()
			connection:Disconnect()
		end)
	end
end

local function AddConnection(connection)
	if connection then
		table.insert(Library.Connections, connection)
	end

	return connection
end

local function GetMousePosition()
	return UserInputService:GetMouseLocation()
end

local function IsMouseOver(gui)
	local mouse = GetMousePosition()
	local position = gui.AbsolutePosition
	local size = gui.AbsoluteSize

	return mouse.X >= position.X
		and mouse.X <= position.X + size.X
		and mouse.Y >= position.Y
		and mouse.Y <= position.Y + size.Y
end

local function MakeDraggable(handle, object)
	local dragging = false
	local dragStart
	local startPosition

	AddConnection(handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPosition = object.Position

			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					Disconnect(connection)
				end
			end)
		end
	end))

	AddConnection(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - dragStart

		object.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)
end

local function SetFont(object, size, bold)
	if object:IsA("TextLabel")
		or object:IsA("TextButton")
		or object:IsA("TextBox") then

		object.Font = bold and FontBold or Font
		object.TextSize = size or 13
	end
end

local function SafeDestroy(object)
	if object then
		pcall(function()
			object:Destroy()
		end)
	end
end

function Library:GetFlag(name)
	return self.Flags[name]
end

function Library:SetFlag(name, value)
	self.Flags[name] = value

	local option = self.Options[name]

	if option and option.SetValue then
		option:SetValue(value)
	end
end

function Library:Notify(data)
	if self.Unloaded then
		return
	end

	data = data or {}

	local title = data.Title or "Notification"
	local description = data.Description or ""
	local duration = data.Time or 4

	local holder = self.Window and self.Window.NotificationHolder

	if not holder then
		return
	end

	local notification = New("Frame", {
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 66),
		AutomaticSize = Enum.AutomaticSize.None,
	}, holder)

	Corner(notification, 7)
	Stroke(notification)

	local accent = New("Frame", {
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, -16),
		Position = UDim2.new(0, 8, 0, 8),
	}, notification)

	Corner(accent, 2)

	local titleLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 21, 0, 10),
		Size = UDim2.new(1, -32, 0, 18),
		Text = tostring(title),
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, notification)

	SetFont(titleLabel, 13, true)

	local descriptionLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 21, 0, 31),
		Size = UDim2.new(1, -32, 0, 23),
		Text = tostring(description),
		TextColor3 = Theme.SubText,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	}, notification)

	SetFont(descriptionLabel, 11, false)

	notification.Position = UDim2.new(1, 20, 0, 0)

	Tween(notification, {
		Position = UDim2.new(0, 0, 0, 0),
	})

	task.delay(duration, function()
		if notification.Parent then
			Tween(notification, {
				Position = UDim2.new(1, 20, 0, 0),
			}, 0.2)

			task.wait(0.22)
			SafeDestroy(notification)
		end
	end)

	return notification
end

function Library:CreateWindow(config)
	config = config or {}

	if self.Window then
		self.Window:Unload()
	end

	local title = config.Title or "Library"
	local footer = config.Footer or ""
	local size = config.Size or UDim2.fromOffset(760, 540)

	local gui = New("ScreenGui", {
		Name = "Library",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = 999,
		IgnoreGuiInset = true,
	})

	pcall(function()
		gui.Parent = CoreGui
	end)

	if not gui.Parent then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	local window = {
		ScreenGui = gui,
		Tabs = {},
		CurrentTab = nil,
		Destroyed = false,
	}

	self.Window = window
	table.insert(self.Windows, window)

	local main = New("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = size,
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, gui)

	Corner(main, 8)
	Stroke(main)

	window.Main = main

	local topbar = New("Frame", {
		Name = "Topbar",
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 46),
	}, main)

	window.Topbar = topbar

	local titleLabel = New("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 17, 0, 6),
		Size = UDim2.new(0, 300, 0, 19),
		Text = tostring(title),
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, topbar)

	SetFont(titleLabel, 14, true)

	local footerLabel = New("TextLabel", {
		Name = "Footer",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 17, 0, 25),
		Size = UDim2.new(0, 350, 0, 15),
		Text = tostring(footer),
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, topbar)

	SetFont(footerLabel, 10, false)

	local closeButton = New("TextButton", {
		Name = "Close",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = Theme.SubText,
		AutoButtonColor = false,
	}, topbar)

	Corner(closeButton, 6)
	Stroke(closeButton)

	SetFont(closeButton, 18, false)

	AddConnection(closeButton.MouseEnter:Connect(function()
		Tween(closeButton, {
			BackgroundColor3 = Theme.Red,
			TextColor3 = Theme.White,
		})
	end))

	AddConnection(closeButton.MouseLeave:Connect(function()
		Tween(closeButton, {
			BackgroundColor3 = Theme.Surface2,
			TextColor3 = Theme.SubText,
		})
	end))

	AddConnection(closeButton.MouseButton1Click:Connect(function()
		window:Hide()
	end))

	MakeDraggable(topbar, main)

	local separator = New("Frame", {
		Name = "Separator",
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 45),
		Size = UDim2.new(1, 0, 0, 1),
	}, main)

	local sidebar = New("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(0, 142, 1, -46),
	}, main)

	window.Sidebar = sidebar

	Stroke(sidebar)

	local tabList = New("ScrollingFrame", {
		Name = "TabList",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 0, 10),
		Size = UDim2.new(1, -16, 1, -18),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, sidebar)

	New("UIListLayout", {
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, tabList)

	local content = New("Frame", {
		Name = "Content",
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 143, 0, 46),
		Size = UDim2.new(1, -143, 1, -46),
	}, main)

	window.Content = content

	local notificationHolder = New("Frame", {
		Name = "NotificationHolder",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -15, 0, 15),
		Size = UDim2.fromOffset(285, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 1000,
	}, gui)

	New("UIListLayout", {
		Padding = UDim.new(0, 7),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, notificationHolder)

	window.NotificationHolder = notificationHolder
	window.TabList = tabList

	function window:Hide()
		main.Visible = false
	end

	function window:Show()
		main.Visible = true
	end

	function window:Toggle()
		main.Visible = not main.Visible
	end

	function window:IsVisible()
		return main.Visible
	end

	function window:AddTab(name, icon)
		local tab = {
			Name = tostring(name),
			Window = self,
			Groupboxes = {},
		}

		local button = New("TextButton", {
			Name = "Tab",
			BackgroundColor3 = Theme.Surface,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 34),
			Text = "",
			AutoButtonColor = false,
			ClipsDescendants = true,
		}, tabList)

		Corner(button, 6)

		local indicator = New("Frame", {
			Name = "Indicator",
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0.5, -8),
			Size = UDim2.new(0, 2, 0, 16),
			Visible = false,
		}, button)

		Corner(indicator, 2)

		local label = New("TextLabel", {
			Name = "Label",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -18, 1, 0),
			Text = tostring(name),
			TextColor3 = Theme.SubText,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, button)

		SetFont(label, 12, true)

		local page = New("Frame", {
			Name = "Page",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
		}, content)

		local left = New("ScrollingFrame", {
			Name = "Left",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 10, 0, 10),
			Size = UDim2.new(0.5, -15, 1, -20),
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Stroke,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, page)

		local right = New("ScrollingFrame", {
			Name = "Right",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 5, 0, 10),
			Size = UDim2.new(0.5, -15, 1, -20),
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Stroke,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, page)

		New("UIListLayout", {
			Padding = UDim.new(0, 9),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, left)

		New("UIListLayout", {
			Padding = UDim.new(0, 9),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, right)

		tab.Button = button
		tab.Page = page
		tab.Left = left
		tab.Right = right

		function tab:Select()
			for _, other in pairs(self.Window.Tabs) do
				if other ~= self then
					other.Page.Visible = false
					other.Indicator.Visible = false
					Tween(other.Button, {
						BackgroundColor3 = Theme.Surface,
					})

					Tween(other.Label, {
						TextColor3 = Theme.SubText,
					})
				end
			end

			self.Page.Visible = true
			self.Indicator.Visible = true

			Tween(self.Button, {
				BackgroundColor3 = Theme.Surface2,
			})

			Tween(self.Label, {
				TextColor3 = Theme.Text,
			})

			self.Window.CurrentTab = self
		end

		tab.Indicator = indicator
		tab.Label = label

		AddConnection(button.MouseEnter:Connect(function()
			if self.CurrentTab ~= tab then
				Tween(button, {
					BackgroundColor3 = Theme.Surface2,
				})
			end
		end))

		AddConnection(button.MouseLeave:Connect(function()
			if self.CurrentTab ~= tab then
				Tween(button, {
					BackgroundColor3 = Theme.Surface,
				})
			end
		end))

		AddConnection(button.MouseButton1Click:Connect(function()
			tab:Select()
		end))

		function tab:AddLeftGroupbox(name, info)
			return self:_AddGroupbox(self.Left, name, info)
		end

		function tab:AddRightGroupbox(name, info)
			return self:_AddGroupbox(self.Right, name, info)
		end

		function tab:_AddGroupbox(parent, name)
			local groupbox = {
				Name = name,
				Parent = parent,
				Elements = {},
			}

			local frame = New("Frame", {
				Name = tostring(name),
				BackgroundColor3 = Theme.Background,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -3, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, parent)

			Corner(frame, 7)
			Stroke(frame)

			local padding = New("UIPadding", {
				PaddingTop = UDim.new(0, 11),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}, frame)

			local titleLabel = New("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 19),
				Text = tostring(name),
				TextColor3 = Theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, frame)

			SetFont(titleLabel, 12, true)

			local elements = New("Frame", {
				Name = "Elements",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 25),
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, frame)

			New("UIListLayout", {
				Padding = UDim.new(0, 7),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, elements)

			groupbox.Container = elements
			groupbox.Frame = frame

			local function Register(nameKey, object)
				if nameKey then
					Library.Options[nameKey] = object
					groupbox.Elements[nameKey] = object
				end

				return object
			end

			function groupbox:AddLabel(text)
				local value = type(text) == "table" and text.Text or text

				local labelObject = New("TextLabel", {
					Name = "Label",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 18),
					Text = tostring(value or ""),
					TextColor3 = Theme.SubText,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
					AutomaticSize = Enum.AutomaticSize.Y,
				}, elements)

				SetFont(labelObject, 11, false)

				return labelObject
			end

			function groupbox:AddDivider()
				local divider = New("Frame", {
					Name = "Divider",
					BackgroundColor3 = Theme.Stroke,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 1),
				}, elements)

				return divider
			end

			function groupbox:AddButton(config)
				config = config or {}

				local button = New("TextButton", {
					Name = "Button",
					BackgroundColor3 = Theme.Surface2,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 32),
					Text = config.Text or "Button",
					TextColor3 = config.Risky and Theme.Red or Theme.Text,
					AutoButtonColor = false,
				}, elements)

				Corner(button, 6)
				Stroke(button)

				SetFont(button, 11, true)

				AddConnection(button.MouseEnter:Connect(function()
					Tween(button, {
						BackgroundColor3 = config.Risky
							and Color3.fromRGB(45, 17, 17)
							or Theme.AccentDark,
					})
				end))

				AddConnection(button.MouseLeave:Connect(function()
					Tween(button, {
						BackgroundColor3 = Theme.Surface2,
					})
				end))

				AddConnection(button.MouseButton1Click:Connect(function()
					if type(config.Func) == "function" then
						task.spawn(config.Func)
					elseif type(config.Callback) == "function" then
						task.spawn(config.Callback)
					end
				end))

				return button
			end

			function groupbox:AddToggle(flag, config)
				config = config or {}

				local current = config.Default == true
				local callback = config.Callback

				local holder = New("Frame", {
					Name = "Toggle",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
				}, elements)

				local button = New("TextButton", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Text = "",
					AutoButtonColor = false,
				}, holder)

				local label = New("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -46, 1, 0),
					Text = config.Text or flag,
					TextColor3 = Theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, holder)

				SetFont(label, 11, true)

				local switch = New("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(34, 18),
					BackgroundColor3 = Theme.Surface2,
					BorderSizePixel = 0,
				}, holder)

				Corner(switch, 9)
				Stroke(switch)

				local knob = New("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 2, 0.5, 0),
					Size = UDim2.fromOffset(14, 14),
					BackgroundColor3 = Theme.SubText,
					BorderSizePixel = 0,
				}, switch)

				Corner(knob, 7)

				local option = {
					Type = "Toggle",
					Value = current,
					Callback = callback,
					Instance = holder,
					Button = button,
					Toggle = switch,
				}

				function option:SetValue(value, silent)
					current = value == true
					self.Value = current
					Library.Flags[flag] = current

					if current then
						Tween(switch, {
							BackgroundColor3 = Theme.Accent,
						})

						Tween(knob, {
							Position = UDim2.new(1, -16, 0.5, 0),
							BackgroundColor3 = Theme.White,
						})
					else
						Tween(switch, {
							BackgroundColor3 = Theme.Surface2,
						})

						Tween(knob, {
							Position = UDim2.new(0, 2, 0.5, 0),
							BackgroundColor3 = Theme.SubText,
						})
					end

					if not silent and type(self.Callback) == "function" then
						task.spawn(self.Callback, current)
					end
				end

				function option:OnChanged(callbackFunction)
					self.Callback = callbackFunction
					return self
				end

				AddConnection(button.MouseButton1Click:Connect(function()
					option:SetValue(not current)
				end))

				Library.Toggles[flag] = option
				Register(flag, option)

				option:SetValue(current, true)

				return option
			end

			function groupbox:AddInput(flag, config)
				config = config or {}

				local holder = New("Frame", {
					Name = "Input",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, config.Text and 52 or 34),
				}, elements)

				local label

				if config.Text then
					label = New("TextLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 17),
						Text = config.Text,
						TextColor3 = Theme.Text,
						TextXAlignment = Enum.TextXAlignment.Left,
					}, holder)

					SetFont(label, 11, true)
				end

				local box = New("TextBox", {
					Name = "InputBox",
					BackgroundColor3 = Theme.Surface2,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 1, -32),
					Size = UDim2.new(1, 0, 0, 32),
					Text = tostring(config.Default or ""),
					PlaceholderText = config.Placeholder or "",
					PlaceholderColor3 = Theme.Disabled,
					TextColor3 = Theme.Text,
					ClearTextOnFocus = false,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, holder)

				Corner(box, 6)
				Stroke(box)

				New("UIPadding", {
					PaddingLeft = UDim.new(0, 9),
					PaddingRight = UDim.new(0, 9),
				}, box)

				SetFont(box, 11, false)

				local option = {
					Type = "Input",
					Value = box.Text,
					Instance = holder,
					TextBox = box,
				}

				function option:SetValue(value, silent)
					value = tostring(value or "")
					self.Value = value
					box.Text = value
					Library.Flags[flag] = value

					if not silent and type(config.Callback) == "function" then
						task.spawn(config.Callback, value)
					end
				end

				AddConnection(box.FocusLost:Connect(function()
					option:SetValue(box.Text, false)
				end))

				Register(flag, option)

				return option
			end

			function groupbox:AddSlider(flag, config)
				config = config or {}

				local min = config.Min or 0
				local max = config.Max or 100
				local value = math.clamp(config.Default or min, min, max)
				local rounding = config.Rounding or 0
				local dragging = false

				local holder = New("Frame", {
					Name = "Slider",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 47),
				}, elements)

				local label = New("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0.7, 0, 0, 17),
					Text = config.Text or flag,
					TextColor3 = Theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, holder)

				SetFont(label, 11, true)

				local valueLabel = New("TextLabel", {
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, 0, 0, 0),
					Size = UDim2.new(0.3, 0, 0, 17),
					TextColor3 = Theme.SubText,
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Right,
				}, holder)

				SetFont(valueLabel, 10, false)

				local bar = New("Frame", {
					Position = UDim2.new(0, 0, 0, 27),
					Size = UDim2.new(1, 0, 0, 5),
					BackgroundColor3 = Theme.Surface2,
					BorderSizePixel = 0,
				}, holder)

				Corner(bar, 3)

				local fill = New("Frame", {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundColor3 = Theme.Accent,
					BorderSizePixel = 0,
				}, bar)

				Corner(fill, 3)

				local knob = New("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0, 0, 0.5, 0),
					Size = UDim2.fromOffset(11, 11),
					BackgroundColor3 = Theme.White,
					BorderSizePixel = 0,
				}, bar)

				Corner(knob, 6)

				local option = {
					Type = "Slider",
					Value = value,
					Instance = holder,
					Bar = bar,
					Fill = fill,
				}

				local function round(number)
					local multiplier = 10 ^ rounding
					return math.floor(number * multiplier + 0.5) / multiplier
				end

				function option:SetValue(newValue, silent)
					newValue = math.clamp(tonumber(newValue) or min, min, max)
					newValue = round(newValue)

					self.Value = newValue
					Library.Flags[flag] = newValue

					local alpha = (newValue - min) / (max - min)

					if max == min then
						alpha = 0
					end

					Tween(fill, {
						Size = UDim2.new(alpha, 0, 1, 0),
					}, 0.08)

					Tween(knob, {
						Position = UDim2.new(alpha, 0, 0.5, 0),
					}, 0.08)

					valueLabel.Text = tostring(newValue) .. tostring(config.Suffix or "")

					if not silent and type(config.Callback) == "function" then
						task.spawn(config.Callback, newValue)
					end
				end

				local function update(position)
					local alpha = math.clamp(
						(position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
						0,
						1
					)

					option:SetValue(min + (max - min) * alpha)
				end

				AddConnection(bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then

						dragging = true
						update(input.Position)
					end
				end))

				AddConnection(UserInputService.InputChanged:Connect(function(input)
					if dragging and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					) then
						update(input.Position)
					end
				end))

				AddConnection(UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end))

				Register(flag, option)
				option:SetValue(value, true)

				return option
			end

			function groupbox:AddDropdown(flag, config)
				config = config or {}

				local values = config.Values or {}
				local multi = config.Multi == true
				local selected = {}

				local holder = New("Frame", {
					Name = "Dropdown",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 52),
					ZIndex = 20,
				}, elements)

				local label = New("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 17),
					Text = config.Text or flag,
					TextColor3 = Theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, holder)

				SetFont(label, 11, true)

				local button = New("TextButton", {
					Position = UDim2.new(0, 0, 0, 20),
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundColor3 = Theme.Surface2,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
					ZIndex = 21,
				}, holder)

				Corner(button, 6)
				Stroke(button)

				local valueLabel = New("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 9, 0, 0),
					Size = UDim2.new(1, -32, 1, 0),
					Text = "",
					TextColor3 = Theme.SubText,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 22,
				}, button)

				SetFont(valueLabel, 10, false)

				local arrow = New("TextLabel", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -8, 0.5, 0),
					Size = UDim2.fromOffset(14, 14),
					BackgroundTransparency = 1,
					Text = "⌄",
					TextColor3 = Theme.SubText,
					ZIndex = 22,
				}, button)

				SetFont(arrow, 13, true)

				local popup = New("Frame", {
					Name = "DropdownPopup",
					BackgroundColor3 = Theme.Surface,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 0, 1, 5),
					Size = UDim2.new(1, 0, 0, 0),
					Visible = false,
					ClipsDescendants = true,
					ZIndex = 100,
				}, button)

				Corner(popup, 6)
				Stroke(popup)

				local optionList = New("ScrollingFrame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 5, 0, 5),
					Size = UDim2.new(1, -10, 1, -10),
					ScrollBarThickness = 2,
					ScrollBarImageColor3 = Theme.Stroke,
					CanvasSize = UDim2.new(),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ZIndex = 101,
				}, popup)

				New("UIListLayout", {
					Padding = UDim.new(0, 2),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}, optionList)

				local opened = false

				local option = {
					Type = "Dropdown",
					Value = multi and {} or config.Default,
					Instance = holder,
					Button = button,
					Popup = popup,
				}

				local function ArrayContains(array, value)
					for _, item in ipairs(array) do
						if item == value then
							return true
						end
					end

					return false
				end

				local function GetValueText()
					if multi then
						local result = {}

						for value, enabled in pairs(selected) do
							if enabled then
								table.insert(result, tostring(value))
							end
						end

						table.sort(result)

						if #result == 0 then
							return "None"
						end

						return table.concat(result, ", ")
					end

					return tostring(option.Value or "None")
				end

				local function UpdateText()
					valueLabel.Text = GetValueText()
				end

				local function SetPopupState(state)
					opened = state
					popup.Visible = state

					if state then
						local count = #values
						local height = math.clamp(10 + count * 29, 38, 180)

						Tween(popup, {
							Size = UDim2.new(1, 0, 0, height),
						}, 0.12)

						arrow.Text = "⌃"
					else
						Tween(popup, {
							Size = UDim2.new(1, 0, 0, 0),
						}, 0.1)

						task.delay(0.11, function()
							if not opened then
								popup.Visible = false
							end
						end)

						arrow.Text = "⌄"
					end
				end

				function option:SetValue(value, silent)
					if multi then
						selected = {}

						if type(value) == "table" then
							for key, enabled in pairs(value) do
								if enabled then
									selected[key] = true
								end
							end
						end

						local copy = {}

						for key, enabled in pairs(selected) do
							if enabled then
								copy[key] = true
							end
						end

						self.Value = copy
						Library.Flags[flag] = copy
					else
						self.Value = value
						Library.Flags[flag] = value
					end

					UpdateText()

					if not silent and type(config.Callback) == "function" then
						task.spawn(config.Callback, self.Value)
					end
				end

				local function AddOption(value)
					local item = New("TextButton", {
						Name = "Option",
						BackgroundColor3 = Theme.Surface,
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 27),
						Text = "",
						AutoButtonColor = false,
						ZIndex = 102,
					}, optionList)

					Corner(item, 4)

					local text = New("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 8, 0, 0),
						Size = UDim2.new(1, -34, 1, 0),
						Text = tostring(value),
						TextColor3 = Theme.SubText,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 103,
					}, item)

					SetFont(text, 10, false)

					local check = New("TextLabel", {
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -8, 0.5, 0),
						Size = UDim2.fromOffset(15, 15),
						BackgroundTransparency = 1,
						Text = "",
						TextColor3 = Theme.Accent,
						ZIndex = 103,
					}, item)

					SetFont(check, 12, true)

					local function Refresh()
						local active

						if multi then
							active = selected[value] == true
						else
							active = option.Value == value
						end

						check.Text = active and "✓" or ""
						text.TextColor3 = active and Theme.Text or Theme.SubText

						if active then
							item.BackgroundColor3 = Theme.Surface2
						else
							item.BackgroundColor3 = Theme.Surface
						end
					end

					AddConnection(item.MouseEnter:Connect(function()
						Tween(item, {
							BackgroundColor3 = Theme.Surface2,
						})
					end))

					AddConnection(item.MouseLeave:Connect(function()
						Refresh()
					end))

					AddConnection(item.MouseButton1Click:Connect(function()
						if multi then
							selected[value] = not selected[value]

							local copy = {}

							for key, enabled in pairs(selected) do
								if enabled then
									copy[key] = true
								end
							end

							option:SetValue(copy)

							Refresh()
						else
							option:SetValue(value)
							Refresh()
							SetPopupState(false)
						end
					end))

					Refresh()
				end

				for _, value in ipairs(values) do
					AddOption(value)
				end

				if multi then
					if type(config.Default) == "table" then
						for key, enabled in pairs(config.Default) do
							if enabled then
								selected[key] = true
							end
						end
					end

					option:SetValue(selected, true)
				else
					option:SetValue(config.Default or values[1], true)
				end

				AddConnection(button.MouseButton1Click:Connect(function()
					SetPopupState(not opened)
				end))

				AddConnection(UserInputService.InputBegan:Connect(function(input)
					if not opened then
						return
					end

					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if not IsMouseOver(holder) then
							SetPopupState(false)
						end
					end
				end))

				Register(flag, option)

				return option
			end

			function groupbox:AddKeyPicker(flag, config)
				config = config or {}

				local holder = New("Frame", {
					Name = "KeyPicker",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 32),
				}, elements)

				local label = New("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0.55, 0, 1, 0),
					Text = config.Text or flag,
					TextColor3 = Theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, holder)

				SetFont(label, 11, true)

				local button = New("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(105, 28),
					BackgroundColor3 = Theme.Surface2,
					BorderSizePixel = 0,
					Text = tostring(config.Default or "None"),
					TextColor3 = Theme.SubText,
					AutoButtonColor = false,
				}, holder)

				Corner(button, 6)
				Stroke(button)
				SetFont(button, 10, true)

				local listening = false
				local option = {
					Type = "KeyPicker",
					Value = config.Default,
					Button = button,
					Instance = holder,
				}

				function option:SetValue(value, silent)
					self.Value = value
					Library.Flags[flag] = value
					button.Text = tostring(value or "None")

					if not silent and type(config.Callback) == "function" then
						task.spawn(config.Callback, value)
					end
				end

				AddConnection(button.MouseButton1Click:Connect(function()
					listening = true
					button.Text = "Press key..."

					local connection
					connection = UserInputService.InputBegan:Connect(function(input, processed)
						if processed then
							return
						end

						if input.UserInputType == Enum.UserInputType.Keyboard then
							listening = false
							option:SetValue(input.KeyCode.Name)
							Disconnect(connection)
						end
					end)
				end))

				Register(flag, option)
				option:SetValue(config.Default, true)

				return option
			end

			function groupbox:AddColorPicker(flag, config)
				config = config or {}

				local holder = New("Frame", {
					Name = "ColorPicker",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 32),
				}, elements)

				local label = New("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0.65, 0, 1, 0),
					Text = config.Text or flag,
					TextColor3 = Theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, holder)

				SetFont(label, 11, true)

				local colorButton = New("TextButton", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(45, 24),
					BackgroundColor3 = config.Default or Theme.Accent,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false,
				}, holder)

				Corner(colorButton, 6)
				Stroke(colorButton)

				local option = {
					Type = "ColorPicker",
					Value = config.Default or Theme.Accent,
					Instance = holder,
					Button = colorButton,
				}

				function option:SetValue(value, silent)
					if typeof(value) ~= "Color3" then
						return
					end

					self.Value = value
					Library.Flags[flag] = value
					colorButton.BackgroundColor3 = value

					if not silent and type(config.Callback) == "function" then
						task.spawn(config.Callback, value)
					end
				end

				AddConnection(colorButton.MouseButton1Click:Connect(function()
					self:Notify({
						Title = "Color Picker",
						Description = "Use SetValue(Color3) to change this color.",
						Time = 2,
					})
				end))

				Register(flag, option)
				option:SetValue(option.Value, true)

				return option
			end

			function groupbox:AddDependencyBox()
				return self
			end

			function groupbox:AddTabbox(name)
				local outer = New("Frame", {
					Name = tostring(name or "Tabbox"),
					BackgroundColor3 = Theme.Background,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
				}, elements)

				Corner(outer, 7)
				Stroke(outer)

				local tabs = New("Frame", {
					BackgroundColor3 = Theme.Surface,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 34),
				}, outer)

				Corner(tabs, 7)

				local tabButtons = New("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 6, 0, 4),
					Size = UDim2.new(1, -12, 1, -8),
				}, tabs)

				New("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 3),
				}, tabButtons)

				local pages = New("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 34),
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
				}, outer)

				local tabbox = {
					Frame = outer,
					Tabs = {},
				}

				function tabbox:AddTab(tabName)
					local tab = {
						Name = tabName,
						Elements = {},
					}

					local tabButton = New("TextButton", {
						BackgroundColor3 = Theme.Surface,
						BorderSizePixel = 0,
						Size = UDim2.fromOffset(80, 26),
						Text = tabName,
						TextColor3 = Theme.SubText,
						AutoButtonColor = false,
					}, tabButtons)

					Corner(tabButton, 5)
					SetFont(tabButton, 10, true)

					local page = New("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -16, 0, 0),
						Position = UDim2.new(0, 8, 0, 8),
						AutomaticSize = Enum.AutomaticSize.Y,
						Visible = false,
					}, pages)

					New("UIListLayout", {
						Padding = UDim.new(0, 6),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}, page)

					tab.Button = tabButton
					tab.Page = page

					function tab:Select()
						for _, other in pairs(tabbox.Tabs) do
							other.Page.Visible = false
							other.Button.TextColor3 = Theme.SubText
							other.Button.BackgroundColor3 = Theme.Surface
						end

						self.Page.Visible = true
						self.Button.TextColor3 = Theme.Text
						self.Button.BackgroundColor3 = Theme.Surface2
					end

					function tab:AddLabel(text)
						local label = New("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 18),
							Text = tostring(text),
							TextColor3 = Theme.SubText,
							TextXAlignment = Enum.TextXAlignment.Left,
						}, page)

						SetFont(label, 10, false)
						return label
					end

					function tab:AddButton(config)
						local button = New("TextButton", {
							BackgroundColor3 = Theme.Surface2,
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 0, 30),
							Text = config.Text or "Button",
							TextColor3 = Theme.Text,
							AutoButtonColor = false,
						}, page)

						Corner(button, 5)
						Stroke(button)
						SetFont(button, 10, true)

						AddConnection(button.MouseButton1Click:Connect(function()
							if type(config.Func) == "function" then
								task.spawn(config.Func)
							end
						end))

						return button
					end

					function tab:AddToggle(flag, config)
						config = config or {}

						local holder = New("Frame", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 30),
						}, page)

						local button = New("TextButton", {
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(1, 1),
							Text = "",
						}, holder)

						local label = New("TextLabel", {
							BackgroundTransparency = 1,
							Size = UDim2.new(1, -40, 1, 0),
							Text = config.Text or flag,
							TextColor3 = Theme.Text,
							TextXAlignment = Enum.TextXAlignment.Left,
						}, holder)

						SetFont(label, 10, true)

						local switch = New("Frame", {
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, 0, 0.5, 0),
							Size = UDim2.fromOffset(32, 18),
							BackgroundColor3 = Theme.Surface2,
						}, holder)

						Corner(switch, 9)

						local knob = New("Frame", {
							Position = UDim2.new(0, 2, 0.5, -7),
							Size = UDim2.fromOffset(14, 14),
							BackgroundColor3 = Theme.SubText,
						}, switch)

						Corner(knob, 7)

						local value = config.Default == true

						local function set(state)
							value = state
							Library.Flags[flag] = state

							if state then
								switch.BackgroundColor3 = Theme.Accent
								knob.Position = UDim2.new(1, -16, 0.5, -7)
							else
								switch.BackgroundColor3 = Theme.Surface2
								knob.Position = UDim2.new(0, 2, 0.5, -7)
							end

							if type(config.Callback) == "function" then
								task.spawn(config.Callback, state)
							end
						end

						AddConnection(button.MouseButton1Click:Connect(function()
							set(not value)
						end))

						set(value)

						return {
							SetValue = set,
							GetValue = function()
								return value
							end,
						}
					end

					table.insert(tabbox.Tabs, tab)

					if #tabbox.Tabs == 1 then
						tab:Select()
					end

					return tab
				end

				return tabbox
			end

			table.insert(tab.Groupboxes, groupbox)

			return groupbox
		end

		table.insert(self.Tabs, tab)

		if #self.Tabs == 1 then
			tab:Select()
		end

		return tab
	end

	function window:AddLeftGroupbox(name, info)
		if not self.CurrentTab then
			return nil
		end

		return self.CurrentTab:AddLeftGroupbox(name, info)
	end

	function window:AddRightGroupbox(name, info)
		if not self.CurrentTab then
			return nil
		end

		return self.CurrentTab:AddRightGroupbox(name, info)
	end

	function window:Unload()
		if self.Destroyed then
			return
		end

		self.Destroyed = true
		Library.Unloaded = true

		for _, connection in ipairs(Library.Connections) do
			Disconnect(connection)
		end

		table.clear(Library.Connections)
		table.clear(Library.Options)
		table.clear(Library.Toggles)
		table.clear(Library.Flags)

		SafeDestroy(gui)

		if Library.Window == self then
			Library.Window = nil
		end
	end

	if config.AutoShow ~= false then
		window:Show()
	else
		window:Hide()
	end

	return window
end

function Library:Unload()
	if self.Window then
		self.Window:Unload()
	end
end

function Library:Toggle()
	if self.Window then
		self.Window:Toggle()
	end
end

function Library:Show()
	if self.Window then
		self.Window:Show()
	end
end

function Library:Hide()
	if self.Window then
		self.Window:Hide()
	end
end

function Library:SetTheme(theme)
	if type(theme) ~= "table" then
		return
	end

	for key, value in pairs(theme) do
		if Theme[key] ~= nil then
			Theme[key] = value
		end
	end

	if self.Window and self.Window.ScreenGui then
		for _, object in ipairs(self.Window.ScreenGui:GetDescendants()) do
			if object:IsA("UIStroke") then
				object.Color = Theme.Stroke
			elseif object:IsA("TextLabel")
				or object:IsA("TextButton")
				or object:IsA("TextBox") then

				if object.Name == "Title" then
					object.TextColor3 = Theme.Text
				end
			end
		end
	end
end

Library.Theme = Theme

return Library
