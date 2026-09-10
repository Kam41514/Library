--[[
    MoonHubGUI
    Modern Roblox UI Library
    Version: 1.0.0

    Inspired by the API philosophy of popular Roblox UI libraries.
    Original implementation / styling.

    Features:
        Window
        Tabs
        Groupboxes
        Buttons
        Toggles
        Sliders
        Dropdowns
        MultiDropdowns
        Inputs
        Keybinds
        Labels
        Dividers
        Notifications
        Themes
        Options registry
        Toggle registry
        Dependencies
        Dragging
        UI scaling
        Unload
]]

local MoonHubGUI = {}

MoonHubGUI.__VERSION = "1.0.0"
MoonHubGUI.Options = {}
MoonHubGUI.Toggles = {}
MoonHubGUI.Flags = {}

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------------
-- CONFIG
---------------------------------------------------------------------

MoonHubGUI.Settings = {
    ToggleKey = Enum.KeyCode.RightShift,

    AnimationSpeed = 0.18,

    Font = Enum.Font.Gotham,

    Theme = {
        Background = Color3.fromRGB(15, 15, 19),
        Secondary = Color3.fromRGB(20, 20, 25),
        Tertiary = Color3.fromRGB(25, 25, 31),

        Element = Color3.fromRGB(29, 29, 36),
        ElementHover = Color3.fromRGB(36, 36, 44),

        Accent = Color3.fromRGB(142, 92, 246),
        AccentDark = Color3.fromRGB(105, 65, 190),

        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(155, 155, 165),

        Border = Color3.fromRGB(45, 45, 55),

        Success = Color3.fromRGB(70, 190, 120),
        Warning = Color3.fromRGB(240, 180, 70),
        Error = Color3.fromRGB(230, 80, 90),
    }
}

---------------------------------------------------------------------
-- INTERNAL
---------------------------------------------------------------------

local Connections = {}
local Windows = {}

local function TrackConnection(connection)
    table.insert(Connections, connection)
    return connection
end

local function DisconnectAll()
    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(Connections)
end

local function Tween(instance, properties, duration)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or MoonHubGUI.Settings.AnimationSpeed,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        properties
    )

    tween:Play()

    return tween
end

local function Create(className, properties)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    return object
end

local function Corner(parent, radius)
    return Create("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius or 6)
    })
end

local function Stroke(parent, color, transparency)
    return Create("UIStroke", {
        Parent = parent,
        Color = color or MoonHubGUI.Settings.Theme.Border,
        Transparency = transparency or 0,
        Thickness = 1
    })
end

local function Padding(parent, amount)
    return Create("UIPadding", {
        Parent = parent,

        PaddingTop = UDim.new(0, amount),
        PaddingBottom = UDim.new(0, amount),
        PaddingLeft = UDim.new(0, amount),
        PaddingRight = UDim.new(0, amount)
    })
end

local function GetGuiParent()
    local success, result = pcall(function()
        return CoreGui
    end)

    if success and result then
        return result
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

---------------------------------------------------------------------
-- DRAGGING
---------------------------------------------------------------------

local function MakeDraggable(frame, handle)
    handle = handle or frame

    local dragging = false
    local dragStart
    local startPosition

    TrackConnection(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = frame.Position

            TrackConnection(input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end))
        end
    end))

    TrackConnection(UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)
end

---------------------------------------------------------------------
-- ELEMENT BASE
---------------------------------------------------------------------

local Element = {}
Element.__index = Element

function Element:SetVisible(value)
    self.Instance.Visible = value
end

function Element:SetDisabled(value)
    self.Disabled = value

    if self.Instance:IsA("GuiButton") then
        self.Instance.AutoButtonColor = not value
    end

    if self.Label then
        self.Label.TextTransparency = value and 0.55 or 0
    end
end

function Element:SetText(text)
    self.Text = text

    if self.Label then
        self.Label.Text = text
    end
end

---------------------------------------------------------------------
-- TOGGLE
---------------------------------------------------------------------

local Toggle = setmetatable({}, Element)
Toggle.__index = Toggle

function Toggle:SetValue(value, silent)
    value = value == true

    if self.Disabled then
        return
    end

    self.Value = value

    if value then
        Tween(self.Box, {
            BackgroundColor3 = MoonHubGUI.Settings.Theme.Accent
        })

        Tween(self.Check, {
            BackgroundTransparency = 0
        })
    else
        Tween(self.Box, {
            BackgroundColor3 = MoonHubGUI.Settings.Theme.Element
        })

        Tween(self.Check, {
            BackgroundTransparency = 1
        })
    end

    if not silent and self.Callback then
        task.spawn(self.Callback, value)
    end

    if self.Flag then
        MoonHubGUI.Flags[self.Flag] = value
    end
end

function Toggle:OnChanged(callback)
    self.Callback = callback
    return self
end

function Toggle:SetValueSilent(value)
    self:SetValue(value, true)
end

---------------------------------------------------------------------
-- BUTTON
---------------------------------------------------------------------

local Button = setmetatable({}, Element)
Button.__index = Button

function Button:Press()
    if self.Disabled then
        return
    end

    if self.Callback then
        task.spawn(self.Callback)
    end
end

---------------------------------------------------------------------
-- SLIDER
---------------------------------------------------------------------

local Slider = setmetatable({}, Element)
Slider.__index = Slider

function Slider:SetValue(value, silent)
    if self.Disabled then
        return
    end

    value = tonumber(value) or self.Min
    value = math.clamp(value, self.Min, self.Max)

    if self.Rounding then
        local mult = 10 ^ self.Rounding
        value = math.floor(value * mult + 0.5) / mult
    end

    self.Value = value

    local alpha = (value - self.Min) / (self.Max - self.Min)

    Tween(self.Fill, {
        Size = UDim2.new(alpha, 0, 1, 0)
    })

    self.ValueLabel.Text = tostring(value)

    if self.Flag then
        MoonHubGUI.Flags[self.Flag] = value
    end

    if not silent and self.Callback then
        task.spawn(self.Callback, value)
    end
end

function Slider:OnChanged(callback)
    self.Callback = callback
    return self
end

---------------------------------------------------------------------
-- DROPDOWN
---------------------------------------------------------------------

local Dropdown = setmetatable({}, Element)
Dropdown.__index = Dropdown

function Dropdown:SetValue(value, silent)
    if self.Disabled then
        return
    end

    if self.Multi then
        if type(value) ~= "table" then
            return
        end

        self.Value = value
    else
        self.Value = value
    end

    if self.Multi then
        local values = {}

        for option, enabled in pairs(self.Value) do
            if enabled then
                table.insert(values, option)
            end
        end

        self.ValueLabel.Text =
            #values > 0 and table.concat(values, ", ") or "None"
    else
        self.ValueLabel.Text = tostring(self.Value or "None")
    end

    if self.Flag then
        MoonHubGUI.Flags[self.Flag] = self.Value
    end

    if not silent and self.Callback then
        task.spawn(self.Callback, self.Value)
    end
end

function Dropdown:OnChanged(callback)
    self.Callback = callback
    return self
end

---------------------------------------------------------------------
-- INPUT
---------------------------------------------------------------------

local Input = setmetatable({}, Element)
Input.__index = Input

function Input:SetValue(value, silent)
    if self.Disabled then
        return
    end

    value = tostring(value or "")

    self.Value = value
    self.TextBox.Text = value

    if self.Flag then
        MoonHubGUI.Flags[self.Flag] = value
    end

    if not silent and self.Callback then
        task.spawn(self.Callback, value)
    end
end

function Input:OnChanged(callback)
    self.Callback = callback
    return self
end

---------------------------------------------------------------------
-- GROUPBOX
---------------------------------------------------------------------

local Groupbox = {}
Groupbox.__index = Groupbox

function Groupbox:_CreateElement(height)
    local object = Create("Frame", {
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 32)
    })

    return object
end

function Groupbox:AddLabel(text)
    local frame = self:_CreateElement(25)

    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 1, 0),

        Font = MoonHubGUI.Settings.Font,
        Text = text or "Label",

        TextColor3 = MoonHubGUI.Settings.Theme.SubText,
        TextSize = 13,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    return setmetatable({
        Instance = frame,
        Label = label,
        Text = text
    }, Element)
end

function Groupbox:AddDivider()
    local frame = self:_CreateElement(13)

    Create("Frame", {
        Parent = frame,

        Position = UDim2.new(0, 0, 0.5, 0),

        Size = UDim2.new(1, 0, 0, 1),

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Border,

        BorderSizePixel = 0
    })

    return frame
end

function Groupbox:AddButton(options)
    options = options or {}

    local text = options.Text or "Button"
    local callback = options.Func or options.Callback

    local frame = self:_CreateElement(34)

    local button = Create("TextButton", {
        Parent = frame,

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Element,

        Size = UDim2.new(1, 0, 1, 0),

        Text = text,
        TextColor3 = MoonHubGUI.Settings.Theme.Text,
        TextSize = 13,

        Font = MoonHubGUI.Settings.Font,

        AutoButtonColor = false
    })

    Corner(button, 6)
    Stroke(button)

    local object = setmetatable({
        Instance = button,
        Label = button,

        Text = text,
        Callback = callback,

        Disabled = false
    }, Button)

    button.MouseEnter:Connect(function()
        if object.Disabled then
            return
        end

        Tween(button, {
            BackgroundColor3 = MoonHubGUI.Settings.Theme.ElementHover
        })
    end)

    button.MouseLeave:Connect(function()
        Tween(button, {
            BackgroundColor3 = MoonHubGUI.Settings.Theme.Element
        })
    end)

    button.MouseButton1Click:Connect(function()
        object:Press()
    end)

    return object
end

function Groupbox:AddToggle(flag, options)
    options = options or {}

    local text = options.Text or flag
    local default = options.Default or false

    local frame = self:_CreateElement(32)

    local button = Create("TextButton", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 1, 0),

        Text = "",
        AutoButtonColor = false
    })

    local box = Create("Frame", {
        Parent = button,

        Position = UDim2.new(0, 0, 0.5, -9),

        Size = UDim2.fromOffset(18, 18),

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Element
    })

    Corner(box, 5)
    Stroke(box)

    local check = Create("TextLabel", {
        Parent = box,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 1, 0),

        Text = "✓",

        TextColor3 = Color3.new(1, 1, 1),

        Font = Enum.Font.GothamBold,
        TextSize = 12,

        TextTransparency = 1
    })

    local label = Create("TextLabel", {
        Parent = button,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(28, 0),

        Size = UDim2.new(1, -28, 1, 0),

        Text = text,

        TextColor3 = MoonHubGUI.Settings.Theme.Text,

        TextSize = 13,

        Font = MoonHubGUI.Settings.Font,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    local object = setmetatable({
        Instance = frame,
        Label = label,

        Box = box,
        Check = check,

        Text = text,
        Value = default,

        Flag = flag,

        Callback = options.Callback,

        Disabled = false
    }, Toggle)

    MoonHubGUI.Options[flag] = object
    MoonHubGUI.Toggles[flag] = object

    button.MouseButton1Click:Connect(function()
        object:SetValue(not object.Value)
    end)

    object:SetValue(default, true)

    return object
end

Groupbox.AddCheckbox = Groupbox.AddToggle

function Groupbox:AddSlider(flag, options)
    options = options or {}

    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min

    local frame = self:_CreateElement(50)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, -70, 0, 20),

        Text = options.Text or flag,

        TextColor3 = MoonHubGUI.Settings.Theme.Text,

        TextSize = 13,

        Font = MoonHubGUI.Settings.Font,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    local valueLabel = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        AnchorPoint = Vector2.new(1, 0),

        Position = UDim2.new(1, 0, 0, 0),

        Size = UDim2.fromOffset(65, 20),

        Text = tostring(default),

        TextColor3 = MoonHubGUI.Settings.Theme.SubText,

        TextSize = 12,

        Font = MoonHubGUI.Settings.Font,

        TextXAlignment = Enum.TextXAlignment.Right
    })

    local slider = Create("TextButton", {
        Parent = frame,

        Position = UDim2.new(0, 0, 0, 27),

        Size = UDim2.new(1, 0, 0, 6),

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Element,

        Text = "",
        AutoButtonColor = false
    })

    Corner(slider, 4)

    local fill = Create("Frame", {
        Parent = slider,

        Size = UDim2.new(0, 0, 1, 0),

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Accent,

        BorderSizePixel = 0
    })

    Corner(fill, 4)

    local object = setmetatable({
        Instance = frame,
        Label = label,

        Slider = slider,
        Fill = fill,
        ValueLabel = valueLabel,

        Min = min,
        Max = max,
        Value = default,

        Rounding = options.Rounding or 0,
        Flag = flag,

        Callback = options.Callback
    }, Slider)

    MoonHubGUI.Options[flag] = object

    local function UpdateFromInput(input)
        local x = input.Position.X
        local start = slider.AbsolutePosition.X
        local width = slider.AbsoluteSize.X

        local alpha = math.clamp(
            (x - start) / width,
            0,
            1
        )

        local value = min + ((max - min) * alpha)

        object:SetValue(value)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            UpdateFromInput(input)
        end
    end)

    slider.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                UpdateFromInput(input)
            end
        end
    end)

    object:SetValue(default, true)

    return object
end

function Groupbox:AddInput(flag, options)
    options = options or {}

    local frame = self:_CreateElement(58)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 0, 20),

        Text = options.Text or flag,

        TextColor3 = MoonHubGUI.Settings.Theme.Text,

        TextSize = 13,

        Font = MoonHubGUI.Settings.Font,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    local textbox = Create("TextBox", {
        Parent = frame,

        Position = UDim2.fromOffset(0, 25),

        Size = UDim2.new(1, 0, 0, 30),

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Element,

        TextColor3 = MoonHubGUI.Settings.Theme.Text,

        PlaceholderColor3 = MoonHubGUI.Settings.Theme.SubText,

        PlaceholderText = options.Placeholder or "",

        Text = options.Default or "",

        TextSize = 12,

        Font = MoonHubGUI.Settings.Font,

        ClearTextOnFocus = false,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    Corner(textbox, 6)
    Stroke(textbox)
    Padding(textbox, 8)

    local object = setmetatable({
        Instance = frame,
        Label = label,

        TextBox = textbox,

        Value = options.Default or "",

        Flag = flag,

        Callback = options.Callback,

        Disabled = false
    }, Input)

    MoonHubGUI.Options[flag] = object

    textbox.FocusLost:Connect(function()
        object:SetValue(textbox.Text)
    end)

    return object
end

function Groupbox:AddDropdown(flag, options)
    options = options or {}

    local frame = self:_CreateElement(55)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 0, 20),

        Text = options.Text or flag,

        TextColor3 = MoonHubGUI.Settings.Theme.Text,

        TextSize = 13,

        Font = MoonHubGUI.Settings.Font,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    local dropdown = Create("TextButton", {
        Parent = frame,

        Position = UDim2.fromOffset(0, 25),

        Size = UDim2.new(1, 0, 0, 30),

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Element,

        Text = "",

        AutoButtonColor = false
    })

    Corner(dropdown, 6)
    Stroke(dropdown)

    local valueLabel = Create("TextLabel", {
        Parent = dropdown,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(9, 0),

        Size = UDim2.new(1, -30, 1, 0),

        Text = "None",

        TextColor3 = MoonHubGUI.Settings.Theme.Text,

        TextSize = 12,

        Font = MoonHubGUI.Settings.Font,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    local arrow = Create("TextLabel", {
        Parent = dropdown,

        BackgroundTransparency = 1,

        AnchorPoint = Vector2.new(1, 0.5),

        Position = UDim2.new(1, -8, 0.5, 0),

        Size = UDim2.fromOffset(18, 18),

        Text = "⌄",

        TextColor3 = MoonHubGUI.Settings.Theme.SubText,

        TextSize = 14,

        Font = MoonHubGUI.Settings.Font
    })

    local list = Create("Frame", {
        Parent = frame,

        Position = UDim2.fromOffset(0, 58),

        Size = UDim2.new(1, 0, 0, 0),

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Secondary,

        Visible = false,

        ZIndex = 20
    })

    Corner(list, 6)
    Stroke(list)

    local layout = Create("UIListLayout", {
        Parent = list,

        Padding = UDim.new(0, 2),

        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Padding(list, 4)

    local values = options.Values or {}

    local object = setmetatable({
        Instance = frame,
        Label = label,

        Dropdown = dropdown,
        ValueLabel = valueLabel,
        List = list,

        Values = values,

        Value = options.Default,

        Flag = flag,

        Callback = options.Callback,

        Multi = options.Multi == true,

        Open = false
    }, Dropdown)

    MoonHubGUI.Options[flag] = object

    local function Rebuild()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, value in ipairs(values) do
            local optionButton = Create("TextButton", {
                Parent = list,

                BackgroundColor3 = MoonHubGUI.Settings.Theme.Element,

                Size = UDim2.new(1, 0, 0, 28),

                Text = tostring(value),

                TextColor3 = MoonHubGUI.Settings.Theme.Text,

                TextSize = 12,

                Font = MoonHubGUI.Settings.Font,

                AutoButtonColor = false,

                ZIndex = 21
            })

            Corner(optionButton, 5)

            optionButton.MouseEnter:Connect(function()
                Tween(optionButton, {
                    BackgroundColor3 = MoonHubGUI.Settings.Theme.ElementHover
                })
            end)

            optionButton.MouseLeave:Connect(function()
                Tween(optionButton, {
                    BackgroundColor3 = MoonHubGUI.Settings.Theme.Element
                })
            end)

            optionButton.MouseButton1Click:Connect(function()
                if object.Multi then
                    object.Value = object.Value or {}

                    object.Value[value] = not object.Value[value]

                    object:SetValue(object.Value)
                else
                    object:SetValue(value)

                    object.Open = false
                    list.Visible = false
                end
            end)
        end

        local height = math.min(
            (#values * 30) + 8,
            160
        )

        list.Size = UDim2.new(1, 0, 0, height)
    end

    Rebuild()

    dropdown.MouseButton1Click:Connect(function()
        object.Open = not object.Open

        list.Visible = object.Open

        if object.Open then
            Tween(arrow, {
                Rotation = 180
            })
        else
            Tween(arrow, {
                Rotation = 0
            })
        end
    end)

    if options.Default ~= nil then
        if object.Multi and type(options.Default) ~= "table" then
            object.Value = {
                [options.Default] = true
            }
        end

        object:SetValue(object.Value, true)
    end

    return object
end

function Groupbox:AddMultiDropdown(flag, options)
    options = options or {}
    options.Multi = true

    return self:AddDropdown(flag, options)
end

---------------------------------------------------------------------
-- DEPENDENCY BOX
---------------------------------------------------------------------

function Groupbox:AddDependencyBox()
    local frame = Create("Frame", {
        Parent = self.Container,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y
    })

    local layout = Create("UIListLayout", {
        Parent = frame,

        Padding = UDim.new(0, 5),

        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local object = {
        Instance = frame,
        Container = frame
    }

    function object:SetupDependencies(...)
        self.Dependencies = {...}
    end

    function object:Update()
        if not self.Dependencies then
            return
        end

        local visible = true

        for _, dependency in ipairs(self.Dependencies) do
            if dependency.Value ~= true then
                visible = false
                break
            end
        end

        self.Instance.Visible = visible
    end

    return object
end

---------------------------------------------------------------------
-- TAB
---------------------------------------------------------------------

local Tab = {}
Tab.__index = Tab

function Tab:AddLeftGroupbox(name)
    return self:_AddGroupbox(name, "Left")
end

function Tab:AddRightGroupbox(name)
    return self:_AddGroupbox(name, "Right")
end

function Tab:_AddGroupbox(name, side)
    local parent = side == "Left"
        and self.Left
        or self.Right

    local box = Create("Frame", {
        Parent = parent,

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Secondary,

        Size = UDim2.new(1, 0, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y
    })

    Corner(box, 8)
    Stroke(box)

    local title = Create("TextLabel", {
        Parent = box,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(12, 8),

        Size = UDim2.new(1, -24, 0, 22),

        Text = name or "Groupbox",

        TextColor3 = MoonHubGUI.Settings.Theme.Text,

        TextSize = 14,

        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    local container = Create("Frame", {
        Parent = box,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(12, 36),

        Size = UDim2.new(1, -24, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y
    })

    local layout = Create("UIListLayout", {
        Parent = container,

        Padding = UDim.new(0, 6),

        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Padding(container, 0)

    local object = setmetatable({
        Instance = box,
        Title = title,

        Container = container,

        Name = name,

        Tab = self
    }, Groupbox)

    return object
end

function Tab:AddTabbox()
    local container = Create("Frame", {
        Parent = self.Container,

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Secondary,

        Size = UDim2.new(1, 0, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y
    })

    Corner(container, 8)
    Stroke(container)

    local object = {
        Instance = container,
        Tabs = {}
    }

    function object:AddTab(name)
        local tabFrame = Create("Frame", {
            Parent = container,

            BackgroundTransparency = 1,

            Size = UDim2.new(1, 0, 0, 0),

            AutomaticSize = Enum.AutomaticSize.Y,

            Visible = #self.Tabs == 0
        })

        local button = Create("TextButton", {
            Parent = container,

            BackgroundTransparency = 1,

            Size = UDim2.new(1 / math.max(1, #self.Tabs + 1), 0, 0, 28),

            Text = name,

            TextColor3 = MoonHubGUI.Settings.Theme.SubText,

            TextSize = 12,

            Font = MoonHubGUI.Settings.Font
        })

        local tab = {
            Instance = tabFrame,
            Button = button,
            Container = tabFrame
        }

        table.insert(self.Tabs, tab)

        button.MouseButton1Click:Connect(function()
            for _, other in ipairs(self.Tabs) do
                other.Instance.Visible = false
                other.Button.TextColor3 = MoonHubGUI.Settings.Theme.SubText
            end

            tab.Instance.Visible = true
            tab.Button.TextColor3 = MoonHubGUI.Settings.Theme.Text
        end)

        setmetatable(tab, Tab)

        return tab
    end

    return object
end

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------

local Window = {}
Window.__index = Window

function Window:AddTab(name, icon)
    local tabButton = Create("TextButton", {
        Parent = self.TabBar,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 0, 38),

        Text = icon and (icon .. "  " .. name) or name,

        TextColor3 = MoonHubGUI.Settings.Theme.SubText,

        TextSize = 13,

        Font = MoonHubGUI.Settings.Font,

        TextXAlignment = Enum.TextXAlignment.Left,

        AutoButtonColor = false
    })

    Padding(tabButton, 10)

    local page = Create("ScrollingFrame", {
        Parent = self.Pages,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 1, 0),

        CanvasSize = UDim2.new(0, 0, 0, 0),

        AutomaticCanvasSize = Enum.AutomaticSize.Y,

        ScrollBarThickness = 2,

        ScrollBarImageColor3 = MoonHubGUI.Settings.Theme.Accent,

        Visible = #self.Tabs == 0
    })

    local content = Create("Frame", {
        Parent = page,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, -12, 0, 0),

        Position = UDim2.fromOffset(6, 6),

        AutomaticSize = Enum.AutomaticSize.Y
    })

    local columns = Create("Frame", {
        Parent = content,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y
    })

    local left = Create("Frame", {
        Parent = columns,

        BackgroundTransparency = 1,

        Size = UDim2.new(0.5, -4, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y
    })

    local right = Create("Frame", {
        Parent = columns,

        BackgroundTransparency = 1,

        AnchorPoint = Vector2.new(1, 0),

        Position = UDim2.new(1, 0, 0, 0),

        Size = UDim2.new(0.5, -4, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y
    })

    local leftLayout = Create("UIListLayout", {
        Parent = left,

        Padding = UDim.new(0, 8),

        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local rightLayout = Create("UIListLayout", {
        Parent = right,

        Padding = UDim.new(0, 8),

        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local tab = setmetatable({
        Window = self,

        Button = tabButton,

        Page = page,

        Container = content,

        Columns = columns,

        Left = left,
        Right = right,

        Name = name,
        Icon = icon
    }, Tab)

    table.insert(self.Tabs, tab)

    tabButton.MouseButton1Click:Connect(function()
        for _, other in ipairs(self.Tabs) do
            other.Page.Visible = false
            other.Button.TextColor3 = MoonHubGUI.Settings.Theme.SubText
        end

        page.Visible = true
        tabButton.TextColor3 = MoonHubGUI.Settings.Theme.Text
    end)

    if #self.Tabs == 1 then
        tabButton.TextColor3 = MoonHubGUI.Settings.Theme.Text
    end

    return tab
end

function Window:Notify(options)
    options = options or {}

    local title = options.Title or "MoonHubGUI"
    local description = options.Description or ""
    local duration = options.Duration or 3

    local notification = Create("Frame", {
        Parent = self.NotificationHolder,

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Secondary,

        Size = UDim2.fromOffset(300, 75),

        BackgroundTransparency = 1
    })

    Corner(notification, 8)
    Stroke(notification)

    local titleLabel = Create("TextLabel", {
        Parent = notification,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(14, 10),

        Size = UDim2.new(1, -28, 0, 20),

        Text = title,

        TextColor3 = MoonHubGUI.Settings.Theme.Text,

        TextSize = 14,

        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Left,

        TextTransparency = 1
    })

    local descriptionLabel = Create("TextLabel", {
        Parent = notification,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(14, 32),

        Size = UDim2.new(1, -28, 0, 30),

        Text = description,

        TextColor3 = MoonHubGUI.Settings.Theme.SubText,

        TextSize = 12,

        Font = MoonHubGUI.Settings.Font,

        TextWrapped = true,

        TextXAlignment = Enum.TextXAlignment.Left,

        TextTransparency = 1
    })

    Tween(notification, {
        BackgroundTransparency = 0
    })

    Tween(titleLabel, {
        TextTransparency = 0
    })

    Tween(descriptionLabel, {
        TextTransparency = 0
    })

    task.delay(duration, function()
        if not notification.Parent then
            return
        end

        Tween(notification, {
            BackgroundTransparency = 1
        })

        Tween(titleLabel, {
            TextTransparency = 1
        })

        Tween(descriptionLabel, {
            TextTransparency = 1
        })

        task.wait(MoonHubGUI.Settings.AnimationSpeed)

        notification:Destroy()
    end)

    return notification
end

function Window:Toggle()
    self.Visible = not self.Visible

    if self.Visible then
        self.ScreenGui.Enabled = true

        self.Main.Size = UDim2.fromOffset(0, 0)

        Tween(self.Main, {
            Size = self.Size
        })
    else
        Tween(self.Main, {
            Size = UDim2.fromOffset(0, 0)
        })

        task.delay(
            MoonHubGUI.Settings.AnimationSpeed,
            function()
                if not self.Visible then
                    self.ScreenGui.Enabled = false
                end
            end
        )
    end
end

function Window:SetTitle(title)
    self.Title.Text = title
end

function Window:SetTheme(theme)
    for key, value in pairs(theme or {}) do
        if self.Theme[key] ~= nil then
            self.Theme[key] = value
        end
    end
end

function Window:Unload()
    self.Destroyed = true

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end

    for flag in pairs(MoonHubGUI.Options) do
        MoonHubGUI.Options[flag] = nil
    end

    for flag in pairs(MoonHubGUI.Toggles) do
        MoonHubGUI.Toggles[flag] = nil
    end

    for flag in pairs(MoonHubGUI.Flags) do
        MoonHubGUI.Flags[flag] = nil
    end

    for i = #Windows, 1, -1 do
        if Windows[i] == self then
            table.remove(Windows, i)
        end
    end
end

---------------------------------------------------------------------
-- CREATE WINDOW
---------------------------------------------------------------------

function MoonHubGUI:CreateWindow(options)
    options = options or {}

    local gui = Create("ScreenGui", {
        Name = "MoonHubGUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })

    gui.Parent = GetGuiParent()

    local main = Create("Frame", {
        Parent = gui,

        AnchorPoint = Vector2.new(0.5, 0.5),

        Position = UDim2.fromScale(0.5, 0.5),

        Size = options.Size or UDim2.fromOffset(720, 500),

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Background,

        BorderSizePixel = 0,

        ClipsDescendants = true
    })

    Corner(main, 10)
    Stroke(main)

    local top = Create("Frame", {
        Parent = main,

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Secondary,

        Size = UDim2.new(1, 0, 0, 55),

        BorderSizePixel = 0
    })

    local title = Create("TextLabel", {
        Parent = top,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(18, 7),

        Size = UDim2.new(1, -36, 0, 24),

        Text = options.Title or "MoonHubGUI",

        TextColor3 = MoonHubGUI.Settings.Theme.Text,

        TextSize = 17,

        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    local subtitle = Create("TextLabel", {
        Parent = top,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(19, 31),

        Size = UDim2.new(1, -38, 0, 16),

        Text = options.Subtitle or "MoonHub Interface",

        TextColor3 = MoonHubGUI.Settings.Theme.SubText,

        TextSize = 10,

        Font = MoonHubGUI.Settings.Font,

        TextXAlignment = Enum.TextXAlignment.Left
    })

    local sidebar = Create("Frame", {
        Parent = main,

        Position = UDim2.fromOffset(0, 55),

        Size = UDim2.new(0, 155, 1, -55),

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Secondary,

        BorderSizePixel = 0
    })

    local tabBar = Create("ScrollingFrame", {
        Parent = sidebar,

        Position = UDim2.fromOffset(8, 12),

        Size = UDim2.new(1, -16, 1, -24),

        BackgroundTransparency = 1,

        ScrollBarThickness = 0,

        AutomaticCanvasSize = Enum.AutomaticSize.Y,

        CanvasSize = UDim2.new()
    })

    Create("UIListLayout", {
        Parent = tabBar,

        Padding = UDim.new(0, 4),

        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local pages = Create("Frame", {
        Parent = main,

        Position = UDim2.fromOffset(155, 55),

        Size = UDim2.new(1, -155, 1, -55),

        BackgroundColor3 = MoonHubGUI.Settings.Theme.Background
    })

    local notificationHolder = Create("Frame", {
        Parent = gui,

        AnchorPoint = Vector2.new(1, 1),

        Position = UDim2.new(1, -15, 1, -15),

        Size = UDim2.fromOffset(310, 400),

        BackgroundTransparency = 1
    })

    local notificationLayout = Create("UIListLayout", {
        Parent = notificationHolder,

        Padding = UDim.new(0, 8),

        VerticalAlignment = Enum.VerticalAlignment.Bottom,

        HorizontalAlignment = Enum.HorizontalAlignment.Right
    })

    local window = setmetatable({
        ScreenGui = gui,

        Main = main,

        Topbar = top,

        Title = title,

        Subtitle = subtitle,

        Sidebar = sidebar,

        TabBar = tabBar,

        Pages = pages,

        NotificationHolder = notificationHolder,

        Tabs = {},

        Visible = true,

        Destroyed = false,

        Size = options.Size or UDim2.fromOffset(720, 500),

        Theme = MoonHubGUI.Settings.Theme
    }, Window)

    MakeDraggable(main, top)

    table.insert(Windows, window)

    if options.ToggleKey then
        MoonHubGUI.Settings.ToggleKey = options.ToggleKey
    end

    if options.AutoShow == false then
        window.Visible = false
        gui.Enabled = false
    end

    return window
end

---------------------------------------------------------------------
-- GLOBAL TOGGLE
---------------------------------------------------------------------

TrackConnection(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == MoonHubGUI.Settings.ToggleKey then
        for _, window in ipairs(Windows) do
            if not window.Destroyed then
                window:Toggle()
            end
        end
    end
end))

---------------------------------------------------------------------
-- GLOBAL METHODS
---------------------------------------------------------------------

function MoonHubGUI:SetTheme(theme)
    for key, value in pairs(theme or {}) do
        if self.Settings.Theme[key] ~= nil then
            self.Settings.Theme[key] = value
        end
    end
end

function MoonHubGUI:SetToggleKey(key)
    self.Settings.ToggleKey = key
end

function MoonHubGUI:Unload()
    DisconnectAll()

    for _, window in ipairs(Windows) do
        pcall(function()
            window:Unload()
        end)
    end

    table.clear(Windows)
end

---------------------------------------------------------------------
-- RETURN
---------------------------------------------------------------------

return MoonHubGUI
