--[[
    KamUI Library
    Modern / Clean UI
    Obsidian-style API
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {
    Version = "5.0.0",

    Options = {},
    Toggles = {},
    Tabs = {},

    Theme = {
        Background = Color3.fromRGB(15, 16, 19),
        Sidebar = Color3.fromRGB(19, 20, 24),
        Groupbox = Color3.fromRGB(20, 21, 25),
        Element = Color3.fromRGB(25, 26, 31),
        ElementHover = Color3.fromRGB(31, 32, 38),

        Border = Color3.fromRGB(43, 44, 51),

        Accent = Color3.fromRGB(139, 92, 246),

        Text = Color3.fromRGB(245, 245, 248),
        SubText = Color3.fromRGB(178, 180, 190),
        Muted = Color3.fromRGB(125, 127, 138),

        White = Color3.fromRGB(255, 255, 255),
        Off = Color3.fromRGB(55, 56, 64)
    },

    Colors = nil,

    Tween = TweenInfo.new(
        0.15,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    ScreenGui = nil,
    Window = nil,

    ActiveTab = nil,
    Toggled = true,
    Unloaded = false
}

Library.Colors = Library.Theme

------------------------------------------------------------
-- Utilities
------------------------------------------------------------

local function New(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        pcall(function()
            object[property] = value
        end)
    end

    object.Parent = parent

    return object
end

local function Tween(object, properties)
    if not object or not object.Parent then
        return
    end

    local tween = TweenService:Create(
        object,
        Library.Tween,
        properties
    )

    tween:Play()

    return tween
end

local function Corner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object

    return corner
end

local function AddStroke(object, color, transparency)
    local stroke = Instance.new("UIStroke")

    stroke.Color = color or Library.Theme.Border
    stroke.Transparency = transparency or 0
    stroke.Thickness = 1

    stroke.Parent = object

    return stroke
end

local function AddPadding(object, left, right, top, bottom)
    local padding = Instance.new("UIPadding")

    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)

    padding.Parent = object

    return padding
end

local function GetParent()
    local success, result = pcall(function()
        return gethui()
    end)

    if success and result then
        return result
    end

    return game:GetService("CoreGui")
end

------------------------------------------------------------
-- Window
------------------------------------------------------------

function Library:CreateWindow(config)
    config = config or {}

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end

    self.Options = {}
    self.Toggles = {}
    self.Tabs = {}
    self.ActiveTab = nil
    self.Unloaded = false
    self.Toggled = true

    local ScreenGui = New("ScreenGui", {
        Name = "KamUI",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, GetParent())

    self.ScreenGui = ScreenGui

    --------------------------------------------------------
    -- Main Window
    --------------------------------------------------------

    local Window = New("Frame", {
        Name = "Window",

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),

        Size = config.Size or UDim2.fromOffset(960, 580),

        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0
    }, ScreenGui)

    Corner(Window, 12)
    AddStroke(Window, self.Theme.Border, 0.2)

    self.Window = Window

    --------------------------------------------------------
    -- Header
    --------------------------------------------------------

    local Header = New("Frame", {
        Size = UDim2.new(1, 0, 0, 52),

        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, Window)

    local Logo = New("Frame", {
        Position = UDim2.fromOffset(17, 16),
        Size = UDim2.fromOffset(20, 20),

        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0
    }, Header)

    Corner(Logo, 6)

    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),

        Position = UDim2.fromScale(0.5, 0.5),

        Size = UDim2.fromOffset(6, 6),

        BackgroundColor3 = self.Theme.White,
        BorderSizePixel = 0
    }, Logo)

    New("TextLabel", {
        Position = UDim2.fromOffset(46, 9),

        Size = UDim2.new(0, 500, 0, 20),

        BackgroundTransparency = 1,

        Text = config.Title or "KamUI",

        TextColor3 = self.Theme.Text,

        Font = Enum.Font.GothamBold,
        TextSize = 14,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Header)

    New("TextLabel", {
        Position = UDim2.fromOffset(46, 28),

        Size = UDim2.new(0, 500, 0, 14),

        BackgroundTransparency = 1,

        Text = config.Subtitle or "Modern Interface",

        TextColor3 = self.Theme.Muted,

        Font = Enum.Font.Gotham,
        TextSize = 9,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Header)

    --------------------------------------------------------
    -- Close
    --------------------------------------------------------

    local Close = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),

        Position = UDim2.new(1, -13, 0.5, 0),

        Size = UDim2.fromOffset(30, 30),

        BackgroundColor3 = self.Theme.Element,

        BorderSizePixel = 0,

        Text = "×",

        TextColor3 = self.Theme.SubText,

        Font = Enum.Font.GothamMedium,
        TextSize = 17,

        AutoButtonColor = false
    }, Header)

    Corner(Close, 8)

    Close.MouseEnter:Connect(function()
        Tween(Close, {
            BackgroundColor3 = Color3.fromRGB(65, 36, 44),
            TextColor3 = Color3.fromRGB(255, 105, 120)
        })
    end)

    Close.MouseLeave:Connect(function()
        Tween(Close, {
            BackgroundColor3 = self.Theme.Element,
            TextColor3 = self.Theme.SubText
        })
    end)

    Close.MouseButton1Click:Connect(function()
        self:Unload()
    end)

    --------------------------------------------------------
    -- Drag
    --------------------------------------------------------

    do
        local dragging = false
        local dragStart
        local startPosition

        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPosition = Window.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not dragging then
                return
            end

            if input.UserInputType ~= Enum.UserInputType.MouseMovement then
                return
            end

            local delta = input.Position - dragStart

            Window.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,

                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    --------------------------------------------------------
    -- Body
    --------------------------------------------------------

    local Body = New("Frame", {
        Position = UDim2.fromOffset(10, 52),

        Size = UDim2.new(1, -20, 1, -62),

        BackgroundTransparency = 1
    }, Window)

    --------------------------------------------------------
    -- Sidebar
    --------------------------------------------------------

    local Sidebar = New("Frame", {
        Size = UDim2.new(0, 145, 1, 0),

        BackgroundColor3 = self.Theme.Sidebar,

        BorderSizePixel = 0
    }, Body)

    Corner(Sidebar, 10)
    AddStroke(Sidebar, self.Theme.Border, 0.5)
    AddPadding(Sidebar, 6, 6, 7, 7)

    New("UIListLayout", {
        Padding = UDim.new(0, 3),

        SortOrder = Enum.SortOrder.LayoutOrder
    }, Sidebar)

    self.Navigation = Sidebar

    --------------------------------------------------------
    -- Content
    --------------------------------------------------------

    local Content = New("Frame", {
        Position = UDim2.fromOffset(153, 0),

        Size = UDim2.new(1, -153, 1, 0),

        BackgroundTransparency = 1
    }, Body)

    self.Content = Content

    return self
end

------------------------------------------------------------
-- Tab
------------------------------------------------------------

local Tab = {}
Tab.__index = Tab

function Library:AddTab(name, icon)
    local tab = setmetatable({
        Name = name,

        Icon = icon,

        Groupboxes = {},
        LeftGroupboxes = {},
        RightGroupboxes = {}
    }, Tab)

    local Button = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        LayoutOrder = #self.Tabs + 1
    }, self.Navigation)

    Corner(Button, 8)

    local Selected = New("Frame", {
        Position = UDim2.fromOffset(4, 4),

        Size = UDim2.new(1, -8, 1, -8),

        BackgroundColor3 = self.Theme.Accent,

        BackgroundTransparency = 1,

        BorderSizePixel = 0
    }, Button)

    Corner(Selected, 7)

    if icon then
        tab.IconObject = New("TextLabel", {
            Position = UDim2.fromOffset(10, 0),

            Size = UDim2.fromOffset(22, 34),

            BackgroundTransparency = 1,

            Text = tostring(icon),

            TextColor3 = self.Theme.Muted,

            Font = Enum.Font.GothamMedium,
            TextSize = 12,

            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        }, Button)
    end

    local Text = New("TextLabel", {
        Position = UDim2.fromOffset(
            icon and 39 or 12,
            0
        ),

        Size = UDim2.new(
            1,
            icon and -45 or -18,
            1,
            0
        ),

        BackgroundTransparency = 1,

        Text = name,

        TextColor3 = self.Theme.SubText,

        Font = Enum.Font.GothamMedium,
        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, Button)

    local Page = New("ScrollingFrame", {
        Name = name .. "_Page",

        Size = UDim2.fromScale(1, 1),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness = 2,

        ScrollBarImageColor3 = self.Theme.Accent,

        CanvasSize = UDim2.new(),

        AutomaticCanvasSize = Enum.AutomaticSize.Y,

        Visible = false
    }, self.Content)

    AddPadding(Page, 6, 6, 5, 10)

    local Columns = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, Page)

    local Left = New("Frame", {
        Size = UDim2.new(0.5, -5, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, Columns)

    New("UIListLayout", {
        Padding = UDim.new(0, 8),

        SortOrder = Enum.SortOrder.LayoutOrder
    }, Left)

    local Right = New("Frame", {
        Position = UDim2.new(0.5, 5, 0, 0),

        Size = UDim2.new(0.5, -5, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, Columns)

    New("UIListLayout", {
        Padding = UDim.new(0, 8),

        SortOrder = Enum.SortOrder.LayoutOrder
    }, Right)

    tab.Button = Button
    tab.Selected = Selected
    tab.TextObject = Text

    tab.Page = Page
    tab.Left = Left
    tab.Right = Right

    self.Tabs[name] = tab

    Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(Button, {
                BackgroundColor3 = self.Theme.Element,
                BackgroundTransparency = 0.5
            })

            Tween(Text, {
                TextColor3 = self.Theme.Text
            })
        end
    end)

    Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(Button, {
                BackgroundTransparency = 1
            })

            Tween(Text, {
                TextColor3 = self.Theme.SubText
            })
        end
    end)

    Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    if not self.ActiveTab then
        self:SelectTab(tab)
    end

    return tab
end

function Library:SelectTab(tab)
    if type(tab) == "string" then
        tab = self.Tabs[tab]
    end

    if not tab then
        return
    end

    self.ActiveTab = tab

    for _, current in pairs(self.Tabs) do
        local active = current == tab

        current.Page.Visible = active

        if active then
            Tween(current.Selected, {
                BackgroundTransparency = 0.78
            })

            Tween(current.TextObject, {
                TextColor3 = self.Theme.Text
            })

            if current.IconObject then
                Tween(current.IconObject, {
                    TextColor3 = self.Theme.Text
                })
            end
        else
            Tween(current.Selected, {
                BackgroundTransparency = 1
            })

            Tween(current.TextObject, {
                TextColor3 = self.Theme.SubText
            })

            if current.IconObject then
                Tween(current.IconObject, {
                    TextColor3 = self.Theme.Muted
                })
            end
        end
    end
end

------------------------------------------------------------
-- Groupbox
------------------------------------------------------------

local Groupbox = {}
Groupbox.__index = Groupbox

function Tab:AddLeftGroupbox(name, icon)
    return self:_CreateGroupbox(
        name,
        self.Left,
        self.LeftGroupboxes
    )
end

function Tab:AddRightGroupbox(name, icon)
    return self:_CreateGroupbox(
        name,
        self.Right,
        self.RightGroupboxes
    )
end

function Tab:_CreateGroupbox(name, parent, collection)
    local groupbox = setmetatable({
        Name = name,

        Elements = {}
    }, Groupbox)

    local Frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundColor3 = Library.Theme.Groupbox,

        BorderSizePixel = 0
    }, parent)

    Corner(Frame, 10)
    AddStroke(Frame, Library.Theme.Border, 0.55)

    local Header = New("Frame", {
        Size = UDim2.new(1, 0, 0, 39),

        BackgroundTransparency = 1
    }, Frame)

    New("TextLabel", {
        Position = UDim2.fromOffset(12, 0),

        Size = UDim2.new(1, -24, 1, 0),

        BackgroundTransparency = 1,

        Text = name,

        TextColor3 = Library.Theme.Text,

        Font = Enum.Font.GothamSemibold,
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, Header)

    local Container = New("Frame", {
        Position = UDim2.fromOffset(11, 38),

        Size = UDim2.new(1, -22, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, Frame)

    AddPadding(Container, 0, 0, 0, 11)

    New("UIListLayout", {
        Padding = UDim.new(0, 5),

        SortOrder = Enum.SortOrder.LayoutOrder
    }, Container)

    groupbox.Frame = Frame
    groupbox.Container = Container

    table.insert(collection, groupbox)

    return groupbox
end

------------------------------------------------------------
-- Label
------------------------------------------------------------

function Groupbox:AddLabel(text, wrap)
    local Label = New("TextLabel", {
        Size = UDim2.new(
            1,
            0,
            0,
            wrap and 38 or 21
        ),

        BackgroundTransparency = 1,

        Text = tostring(text),

        TextColor3 = Library.Theme.SubText,

        Font = Enum.Font.Gotham,
        TextSize = 10,

        TextWrapped = wrap == true,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, self.Container)

    table.insert(self.Elements, Label)

    return Label
end

------------------------------------------------------------
-- Divider
------------------------------------------------------------

function Groupbox:AddDivider()
    local Divider = New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),

        BackgroundColor3 = Library.Theme.Border,

        BackgroundTransparency = 0.35,

        BorderSizePixel = 0
    }, self.Container)

    table.insert(self.Elements, Divider)

    return Divider
end

------------------------------------------------------------
-- Button
------------------------------------------------------------

function Groupbox:AddButton(info)
    if type(info) == "string" then
        info = {
            Text = info
        }
    end

    info = info or {}

    local Button = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),

        BackgroundColor3 = Library.Theme.Element,

        BorderSizePixel = 0,

        Text = info.Text or "Button",

        TextColor3 = Library.Theme.Text,

        Font = Enum.Font.GothamMedium,
        TextSize = 10,

        AutoButtonColor = false
    }, self.Container)

    Corner(Button, 8)

    Button.MouseEnter:Connect(function()
        Tween(Button, {
            BackgroundColor3 = Library.Theme.ElementHover
        })
    end)

    Button.MouseLeave:Connect(function()
        Tween(Button, {
            BackgroundColor3 = Library.Theme.Element
        })
    end)

    Button.MouseButton1Click:Connect(function()
        local callback = info.Callback or info.Func

        if callback then
            callback()
        end
    end)

    return Button
end

------------------------------------------------------------
-- Toggle
------------------------------------------------------------

local Toggle = {}
Toggle.__index = Toggle

function Groupbox:AddToggle(name, info)
    info = info or {}

    local toggle = setmetatable({
        Name = name,

        Value = info.Default == true,

        Callback = info.Callback or function() end,

        Changed = info.Changed or function() end
    }, Toggle)

    local Holder = New("Frame", {
        Size = UDim2.new(1, 0, 0, 34),

        BackgroundTransparency = 1
    }, self.Container)

    New("TextLabel", {
        Size = UDim2.new(1, -54, 1, 0),

        BackgroundTransparency = 1,

        Text = info.Text or name,

        TextColor3 = Library.Theme.Text,

        Font = Enum.Font.Gotham,
        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, Holder)

    local Switch = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),

        Position = UDim2.new(1, 0, 0.5, 0),

        Size = UDim2.fromOffset(38, 20),

        BackgroundColor3 = Library.Theme.Off,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false
    }, Holder)

    Corner(Switch, 10)

    local Knob = New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),

        Position = UDim2.new(0, 3, 0.5, 0),

        Size = UDim2.fromOffset(14, 14),

        BackgroundColor3 = Color3.fromRGB(190, 191, 198),

        BorderSizePixel = 0
    }, Switch)

    Corner(Knob, 7)

    toggle.Toggle = Switch
    toggle.Knob = Knob

    local function update(value, silent)
        toggle.Value = value == true

        if toggle.Value then
            Tween(Switch, {
                BackgroundColor3 = Library.Theme.Accent
            })

            Tween(Knob, {
                Position = UDim2.new(1, -17, 0.5, 0),
                BackgroundColor3 = Library.Theme.White
            })
        else
            Tween(Switch, {
                BackgroundColor3 = Library.Theme.Off
            })

            Tween(Knob, {
                Position = UDim2.new(0, 3, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(190, 191, 198)
            })
        end

        if not silent then
            toggle.Callback(toggle.Value)
            toggle.Changed(toggle.Value)
        end
    end

    function toggle:SetValue(value)
        update(value)
    end

    function toggle:GetValue()
        return toggle.Value
    end

    function toggle:OnChanged(callback)
        toggle.Changed = callback
        return toggle
    end

    Switch.MouseButton1Click:Connect(function()
        update(not toggle.Value)
    end)

    update(toggle.Value, true)

    Library.Toggles[name] = toggle
    Library.Options[name] = toggle

    return toggle
end

------------------------------------------------------------
-- Slider
------------------------------------------------------------

local Slider = {}
Slider.__index = Slider

function Groupbox:AddSlider(name, info)
    info = info or {}

    local Min = tonumber(info.Min) or 0
    local Max = tonumber(info.Max) or 100
    local Default = tonumber(info.Default) or Min

    -- Varsayılan: integer.
    -- Örn: 186.5353 -> 187
    local Decimals = tonumber(info.Decimals)

    if Decimals == nil then
        Decimals = 0
    end

    local Step = tonumber(info.Rounding)

    if not Step then
        if Decimals <= 0 then
            Step = 1
        else
            Step = 10 ^ (-Decimals)
        end
    end

    local slider = setmetatable({
        Name = name,

        Min = Min,
        Max = Max,

        Value = Default,

        Callback = info.Callback or function() end,

        Changed = info.Changed or function() end
    }, Slider)

    local Holder = New("Frame", {
        Size = UDim2.new(1, 0, 0, 49),

        BackgroundTransparency = 1
    }, self.Container)

    New("TextLabel", {
        Size = UDim2.new(1, -75, 0, 18),

        BackgroundTransparency = 1,

        Text = info.Text or name,

        TextColor3 = Library.Theme.Text,

        Font = Enum.Font.Gotham,
        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Holder)

    local ValueLabel = New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),

        Position = UDim2.new(1, 0, 0, 0),

        Size = UDim2.fromOffset(75, 18),

        BackgroundTransparency = 1,

        TextColor3 = Library.Theme.SubText,

        Font = Enum.Font.GothamMedium,
        TextSize = 9,

        TextXAlignment = Enum.TextXAlignment.Right
    }, Holder)

    local Bar = New("Frame", {
        Position = UDim2.fromOffset(0, 29),

        Size = UDim2.new(1, 0, 0, 4),

        BackgroundColor3 = Library.Theme.Off,

        BorderSizePixel = 0
    }, Holder)

    Corner(Bar, 2)

    local Fill = New("Frame", {
        Size = UDim2.fromScale(0, 1),

        BackgroundColor3 = Library.Theme.Accent,

        BorderSizePixel = 0
    }, Bar)

    Corner(Fill, 2)

    local Knob = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),

        Position = UDim2.fromScale(0, 0.5),

        Size = UDim2.fromOffset(12, 12),

        BackgroundColor3 = Library.Theme.White,

        BorderSizePixel = 0
    }, Bar)

    Corner(Knob, 6)

    local function roundToStep(value)
        local rounded = math.floor(
            (value / Step) + 0.5
        ) * Step

        if Decimals <= 0 then
            return math.floor(rounded + 0.5)
        end

        local multiplier = 10 ^ Decimals

        return math.floor(
            rounded * multiplier + 0.5
        ) / multiplier
    end

    local function formatValue(value)
        if Decimals <= 0 then
            return tostring(math.floor(value + 0.5))
        end

        return string.format(
            "%." .. tostring(Decimals) .. "f",
            value
        )
    end

    local function Set(value, silent)
        value = tonumber(value) or Min

        value = math.clamp(
            value,
            Min,
            Max
        )

        value = roundToStep(value)

        value = math.clamp(
            value,
            Min,
            Max
        )

        slider.Value = value

        local alpha = 0

        if Max ~= Min then
            alpha = (value - Min) / (Max - Min)
        end

        Fill.Size = UDim2.fromScale(
            alpha,
            1
        )

        Knob.Position = UDim2.fromScale(
            alpha,
            0.5
        )

        ValueLabel.Text =
            tostring(info.Prefix or "")
            .. formatValue(value)
            .. tostring(info.Suffix or "")

        if not silent then
            slider.Callback(value)
            slider.Changed(value)
        end
    end

    local dragging = false

    local function UpdateFromMouse(input)
        local mouseX = input.Position.X

        local startX =
            Bar.AbsolutePosition.X

        local width =
            Bar.AbsoluteSize.X

        if width <= 0 then
            return
        end

        local alpha = math.clamp(
            (mouseX - startX) / width,
            0,
            1
        )

        local value =
            Min + ((Max - Min) * alpha)

        Set(value)
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            dragging = true

            UpdateFromMouse(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and
            input.UserInputType ==
            Enum.UserInputType.MouseMovement then

            UpdateFromMouse(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            dragging = false
        end
    end)

    function slider:SetValue(value)
        Set(value)
    end

    function slider:GetValue()
        return slider.Value
    end

    function slider:OnChanged(callback)
        slider.Changed = callback
        return slider
    end

    Set(Default, true)

    Library.Options[name] = slider

    return slider
end

------------------------------------------------------------
-- Input
------------------------------------------------------------

function Groupbox:AddInput(name, info)
    info = info or {}

    local Holder = New("Frame", {
        Size = UDim2.new(1, 0, 0, 59),

        BackgroundTransparency = 1
    }, self.Container)

    New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),

        BackgroundTransparency = 1,

        Text = info.Text or name,

        TextColor3 = Library.Theme.Text,

        Font = Enum.Font.Gotham,
        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Holder)

    local Input = New("TextBox", {
        Position = UDim2.fromOffset(0, 23),

        Size = UDim2.new(1, 0, 0, 32),

        BackgroundColor3 = Library.Theme.Element,

        BorderSizePixel = 0,

        Text = tostring(info.Default or ""),

        PlaceholderText = info.Placeholder or "",

        PlaceholderColor3 = Library.Theme.Muted,

        TextColor3 = Library.Theme.Text,

        Font = Enum.Font.Gotham,
        TextSize = 10,

        ClearTextOnFocus =
            info.ClearTextOnFocus ~= false,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Holder)

    Corner(Input, 8)

    AddPadding(Input, 8, 8, 0, 0)

    local object = {
        Name = name,

        Input = Input,

        Value = Input.Text,

        Callback = info.Callback or function() end,

        Changed = info.Changed or function() end
    }

    function object:SetValue(value)
        Input.Text = tostring(value)

        object.Value = Input.Text

        object.Callback(object.Value)
        object.Changed(object.Value)
    end

    function object:GetValue()
        return Input.Text
    end

    function object:OnChanged(callback)
        object.Changed = callback

        return object
    end

    Input.FocusLost:Connect(function()
        object.Value = Input.Text

        object.Callback(object.Value)
        object.Changed(object.Value)
    end)

    Library.Options[name] = object

    return object
end

------------------------------------------------------------
-- Dropdown
------------------------------------------------------------

local Dropdown = {}
Dropdown.__index = Dropdown

function Groupbox:AddDropdown(name, info)
    info = info or {}

    local Values = info.Values or {}

    local dropdown = setmetatable({
        Name = name,

        Values = Values,

        Value = info.Default or Values[1],

        Callback = info.Callback or function() end,

        Changed = info.Changed or function() end
    }, Dropdown)

    local Holder = New("Frame", {
        Size = UDim2.new(1, 0, 0, 36),

        BackgroundTransparency = 1,

        ZIndex = 5
    }, self.Container)

    New("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),

        BackgroundTransparency = 1,

        Text = info.Text or name,

        TextColor3 = Library.Theme.Text,

        Font = Enum.Font.Gotham,
        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Holder)

    local Button = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),

        Position = UDim2.new(1, 0, 0.5, 0),

        Size = UDim2.new(0.6, 0, 0, 31),

        BackgroundColor3 = Library.Theme.Element,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        ZIndex = 10
    }, Holder)

    Corner(Button, 8)

    local Selected = New("TextLabel", {
        Position = UDim2.fromOffset(9, 0),

        Size = UDim2.new(1, -25, 1, 0),

        BackgroundTransparency = 1,

        Text = tostring(
            dropdown.Value or "Select"
        ),

        TextColor3 = Library.Theme.SubText,

        Font = Enum.Font.Gotham,
        TextSize = 9,

        TextXAlignment = Enum.TextXAlignment.Left,

        ZIndex = 11
    }, Button)

    New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),

        Position = UDim2.new(1, -8, 0.5, 0),

        Size = UDim2.fromOffset(10, 15),

        BackgroundTransparency = 1,

        Text = "⌄",

        TextColor3 = Library.Theme.Muted,

        Font = Enum.Font.GothamBold,
        TextSize = 11,

        ZIndex = 11
    }, Button)

    local List = New("Frame", {
        Position = UDim2.new(0, 0, 1, 4),

        Size = UDim2.new(1, 0, 0, 0),

        BackgroundColor3 = Library.Theme.Groupbox,

        BorderSizePixel = 0,

        Visible = false,

        ZIndex = 100
    }, Button)

    Corner(List, 8)
    AddStroke(List, Library.Theme.Border, 0.2)
    AddPadding(List, 4, 4, 4, 4)

    New("UIListLayout", {
        Padding = UDim.new(0, 2)
    }, List)

    local Open = false

    local function Build()
        for _, child in ipairs(List:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for index, value in ipairs(Values) do
            local Option = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 27),

                BackgroundTransparency = 1,

                Text = tostring(value),

                TextColor3 = Library.Theme.Text,

                Font = Enum.Font.Gotham,
                TextSize = 9,

                AutoButtonColor = false,

                ZIndex = 101,

                LayoutOrder = index
            }, List)

            Corner(Option, 6)

            Option.MouseEnter:Connect(function()
                Tween(Option, {
                    BackgroundColor3 =
                        Library.Theme.ElementHover,

                    BackgroundTransparency = 0
                })
            end)

            Option.MouseLeave:Connect(function()
                Tween(Option, {
                    BackgroundTransparency = 1
                })
            end)

            Option.MouseButton1Click:Connect(function()
                dropdown:SetValue(value)

                Open = false
                List.Visible = false
            end)
        end

        List.Size = UDim2.new(
            1,
            0,
            0,
            math.min(
                (#Values * 29) + 8,
                180
            )
        )
    end

    function dropdown:SetValue(value)
        dropdown.Value = value

        Selected.Text = tostring(value)

        dropdown.Callback(value)
        dropdown.Changed(value)
    end

    function dropdown:GetValue()
        return dropdown.Value
    end

    function dropdown:SetValues(values)
        Values = values or {}

        dropdown.Values = Values

        Build()
    end

    function dropdown:OnChanged(callback)
        dropdown.Changed = callback

        return dropdown
    end

    Button.MouseButton1Click:Connect(function()
        Open = not Open

        List.Visible = Open

        if Open then
            Build()
        end
    end)

    Library.Options[name] = dropdown

    return dropdown
end

------------------------------------------------------------
-- Notification
------------------------------------------------------------

function Library:Notify(info)
    if type(info) == "string" then
        info = {
            Title = "Notification",
            Description = info,
            Time = 3
        }
    end

    info = info or {}

    local Notification = New("Frame", {
        AnchorPoint = Vector2.new(1, 1),

        Position = UDim2.new(1, 320, 1, -18),

        Size = UDim2.fromOffset(290, 68),

        BackgroundColor3 = self.Theme.Groupbox,

        BorderSizePixel = 0
    }, self.ScreenGui)

    Corner(Notification, 9)
    AddStroke(Notification, self.Theme.Border, 0.2)

    New("Frame", {
        Position = UDim2.fromOffset(0, 12),

        Size = UDim2.fromOffset(3, 44),

        BackgroundColor3 = self.Theme.Accent,

        BorderSizePixel = 0
    }, Notification)

    New("TextLabel", {
        Position = UDim2.fromOffset(13, 8),

        Size = UDim2.new(1, -20, 0, 18),

        BackgroundTransparency = 1,

        Text = info.Title or "Notification",

        TextColor3 = self.Theme.Text,

        Font = Enum.Font.GothamSemibold,
        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Notification)

    New("TextLabel", {
        Position = UDim2.fromOffset(13, 28),

        Size = UDim2.new(1, -20, 0, 28),

        BackgroundTransparency = 1,

        Text = info.Description or "",

        TextColor3 = self.Theme.SubText,

        Font = Enum.Font.Gotham,
        TextSize = 9,

        TextWrapped = true,

        TextXAlignment = Enum.TextXAlignment.Left,

        TextYAlignment = Enum.TextYAlignment.Top
    }, Notification)

    Tween(Notification, {
        Position = UDim2.new(1, -18, 1, -18)
    })

    task.delay(info.Time or 3, function()
        if Notification and Notification.Parent then
            Tween(Notification, {
                Position = UDim2.new(1, 320, 1, -18)
            })

            task.wait(0.18)

            if Notification then
                Notification:Destroy()
            end
        end
    end)

    return Notification
end

------------------------------------------------------------
-- UI Toggle
------------------------------------------------------------

function Library:Toggle()
    if not self.Window then
        return
    end

    self.Toggled = not self.Toggled

    self.Window.Visible = self.Toggled
end

function Library:ToggleUI()
    self:Toggle()
end

------------------------------------------------------------
-- Theme Compatibility
------------------------------------------------------------

function Library:ApplyTheme(theme)
    if not theme then
        return
    end

    for key, value in pairs(theme) do
        if self.Theme[key] ~= nil then
            self.Theme[key] = value
        end
    end

    self.Colors = self.Theme
end

function Library:UpdateColorsUsingRegistry()
    return true
end

------------------------------------------------------------
-- Unload
------------------------------------------------------------

function Library:Unload()
    if self.Unloaded then
        return
    end

    self.Unloaded = true

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end

    self.ScreenGui = nil
    self.Window = nil
    self.ActiveTab = nil

    self.Options = {}
    self.Toggles = {}
    self.Tabs = {}
end

return Library
