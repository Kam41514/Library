--// KamUI - Fluent Inspired / Obsidian-like API
--// Library.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {
    Version = "4.0.0",

    Options = {},
    Toggles = {},
    Tabs = {},

    Scheme = {
        Background = Color3.fromRGB(17, 18, 21),
        Surface = Color3.fromRGB(21, 22, 26),
        Surface2 = Color3.fromRGB(26, 27, 32),
        SurfaceHover = Color3.fromRGB(32, 33, 39),

        Border = Color3.fromRGB(48, 49, 57),

        Accent = Color3.fromRGB(137, 100, 255),
        AccentDark = Color3.fromRGB(108, 76, 220),

        Text = Color3.fromRGB(242, 242, 246),
        SubText = Color3.fromRGB(164, 166, 176),
        Muted = Color3.fromRGB(118, 120, 130),

        Success = Color3.fromRGB(91, 211, 143),
        Danger = Color3.fromRGB(238, 91, 105)
    },

    Colors = nil,

    TweenInfo = TweenInfo.new(
        0.16,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    ScreenGui = nil,
    Window = nil,
    ActiveTab = nil,
    Toggled = true,
    Unloaded = false
}

Library.Colors = Library.Scheme

--========================================================--
-- Utilities
--========================================================--

local function Create(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        pcall(function()
            object[property] = value
        end)
    end

    object.Parent = parent
    return object
end

local function Tween(object, properties, info)
    if not object or not object.Parent then
        return
    end

    local tween = TweenService:Create(
        object,
        info or Library.TweenInfo,
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

local function Stroke(object, color, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Library.Scheme.Border
    stroke.Transparency = transparency or 0
    stroke.Thickness = 1
    stroke.Parent = object
    return stroke
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

local function GetParent()
    local success, hui = pcall(function()
        return gethui()
    end)

    if success and hui then
        return hui
    end

    return game:GetService("CoreGui")
end

--========================================================--
-- Window
--========================================================--

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

    local gui = Create("ScreenGui", {
        Name = "KamUI",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, GetParent())

    self.ScreenGui = gui

    -- Main
    local window = Create("Frame", {
        Name = "Window",

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),

        Size = config.Size or UDim2.fromOffset(1000, 610),

        BackgroundColor3 = self.Scheme.Background,
        BorderSizePixel = 0
    }, gui)

    Corner(window, 14)
    Stroke(window, self.Scheme.Border, 0.25)

    self.Window = window

    --====================================================--
    -- Header
    --====================================================--

    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, window)

    -- Accent dot
    local logo = Create("Frame", {
        Position = UDim2.fromOffset(18, 19),
        Size = UDim2.fromOffset(20, 20),

        BackgroundColor3 = self.Scheme.Accent,
        BorderSizePixel = 0
    }, header)

    Corner(logo, 7)

    Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(7, 7),

        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    }, logo)

    -- Title
    Create("TextLabel", {
        Position = UDim2.fromOffset(48, 10),
        Size = UDim2.new(0, 450, 0, 22),

        BackgroundTransparency = 1,

        Text = config.Title or "KamUI",

        TextColor3 = self.Scheme.Text,

        FontFace = Font.fromEnum(Enum.Font.GothamBold),
        TextSize = 14,

        TextXAlignment = Enum.TextXAlignment.Left
    }, header)

    -- Subtitle
    Create("TextLabel", {
        Position = UDim2.fromOffset(48, 30),
        Size = UDim2.new(0, 450, 0, 16),

        BackgroundTransparency = 1,

        Text = config.Subtitle or "Modern interface",

        TextColor3 = self.Scheme.Muted,

        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Left
    }, header)

    -- Close
    local close = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -15, 0.5, 0),

        Size = UDim2.fromOffset(31, 31),

        BackgroundColor3 = self.Scheme.Surface2,
        BorderSizePixel = 0,

        Text = "×",

        TextColor3 = self.Scheme.SubText,

        FontFace = Font.fromEnum(Enum.Font.GothamMedium),
        TextSize = 18,

        AutoButtonColor = false
    }, header)

    Corner(close, 9)

    close.MouseEnter:Connect(function()
        Tween(close, {
            BackgroundColor3 = Color3.fromRGB(62, 34, 42),
            TextColor3 = self.Scheme.Danger
        })
    end)

    close.MouseLeave:Connect(function()
        Tween(close, {
            BackgroundColor3 = self.Scheme.Surface2,
            TextColor3 = self.Scheme.SubText
        })
    end)

    close.MouseButton1Click:Connect(function()
        self:Unload()
    end)

    --====================================================--
    -- Drag
    --====================================================--

    do
        local dragging = false
        local dragStart
        local startPosition

        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPosition = window.Position
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

            window.Position = UDim2.new(
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

    --====================================================--
    -- Body
    --====================================================--

    local body = Create("Frame", {
        Position = UDim2.fromOffset(10, 58),
        Size = UDim2.new(1, -20, 1, -68),

        BackgroundTransparency = 1
    }, window)

    --====================================================--
    -- Sidebar
    --====================================================--

    local sidebar = Create("Frame", {
        Size = UDim2.new(0, 154, 1, 0),

        BackgroundColor3 = self.Scheme.Surface,
        BorderSizePixel = 0
    }, body)

    Corner(sidebar, 11)

    Padding(sidebar, 7, 7, 9, 9)

    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, sidebar)

    self.Navigation = sidebar

    --====================================================--
    -- Content
    --====================================================--

    local content = Create("Frame", {
        Position = UDim2.fromOffset(164, 0),
        Size = UDim2.new(1, -164, 1, 0),

        BackgroundTransparency = 1
    }, body)

    self.Content = content

    return self
end

--========================================================--
-- Tabs
--========================================================--

local Tab = {}
Tab.__index = Tab

function Library:AddTab(name, icon)
    assert(
        self.Navigation,
        "CreateWindow must be called before AddTab"
    )

    local tab = setmetatable({
        Name = name,
        Icon = icon,

        Groupboxes = {},
        LeftGroupboxes = {},
        RightGroupboxes = {}
    }, Tab)

    -- Button
    local button = Create("TextButton", {
        Name = name,

        Size = UDim2.new(1, 0, 0, 36),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        LayoutOrder = #self.Tabs + 1
    }, self.Navigation)

    Corner(button, 9)

    -- Selected pill
    local selected = Create("Frame", {
        Position = UDim2.fromOffset(5, 5),
        Size = UDim2.new(1, -10, 1, -10),

        BackgroundColor3 = self.Scheme.Accent,
        BackgroundTransparency = 1,

        BorderSizePixel = 0
    }, button)

    Corner(selected, 8)

    -- Icon
    local iconLabel

    if icon then
        iconLabel = Create("TextLabel", {
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.fromOffset(22, 36),

            BackgroundTransparency = 1,

            Text = tostring(icon),

            TextColor3 = self.Scheme.SubText,

            FontFace = Font.fromEnum(Enum.Font.GothamMedium),
            TextSize = 13,

            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        }, button)
    end

    -- Text
    local text = Create("TextLabel", {
        Position = UDim2.fromOffset(
            icon and 42 or 14,
            0
        ),

        Size = UDim2.new(
            1,
            icon and -49 or -20,
            1,
            0
        ),

        BackgroundTransparency = 1,

        Text = name,

        TextColor3 = self.Scheme.SubText,

        FontFace = Font.fromEnum(Enum.Font.GothamMedium),
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, button)

    -- Page
    local page = Create("ScrollingFrame", {
        Name = name .. "_Page",

        Size = UDim2.fromScale(1, 1),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness = 2,

        ScrollBarImageColor3 = self.Scheme.Accent,

        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,

        Visible = false
    }, self.Content)

    Padding(page, 6, 6, 5, 10)

    local columns = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, page)

    -- Left
    local left = Create("Frame", {
        Size = UDim2.new(0.5, -5, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, columns)

    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, left)

    -- Right
    local right = Create("Frame", {
        Position = UDim2.new(0.5, 5, 0, 0),

        Size = UDim2.new(0.5, -5, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, columns)

    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, right)

    tab.Button = button
    tab.Selected = selected
    tab.TextObject = text
    tab.IconObject = iconLabel

    tab.Page = page
    tab.Left = left
    tab.Right = right

    self.Tabs[name] = tab

    button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(button, {
                BackgroundColor3 = self.Scheme.Surface2,
                BackgroundTransparency = 0.65
            })

            Tween(text, {
                TextColor3 = self.Scheme.Text
            })
        end
    end)

    button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(button, {
                BackgroundTransparency = 1
            })

            Tween(text, {
                TextColor3 = self.Scheme.SubText
            })
        end
    end)

    button.MouseButton1Click:Connect(function()
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
                TextColor3 = self.Scheme.Text
            })

            if current.IconObject then
                Tween(current.IconObject, {
                    TextColor3 = self.Scheme.Text
                })
            end
        else
            Tween(current.Selected, {
                BackgroundTransparency = 1
            })

            Tween(current.TextObject, {
                TextColor3 = self.Scheme.SubText
            })

            if current.IconObject then
                Tween(current.IconObject, {
                    TextColor3 = self.Scheme.SubText
                })
            end
        end
    end
end

--========================================================--
-- Groupbox
--========================================================--

local Groupbox = {}
Groupbox.__index = Groupbox

function Tab:AddLeftGroupbox(name, icon)
    return self:_CreateGroupbox(
        name,
        icon,
        self.Left,
        self.LeftGroupboxes
    )
end

function Tab:AddRightGroupbox(name, icon)
    return self:_CreateGroupbox(
        name,
        icon,
        self.Right,
        self.RightGroupboxes
    )
end

function Tab:_CreateGroupbox(
    name,
    icon,
    parent,
    collection
)
    local groupbox = setmetatable({
        Name = name,
        Icon = icon,
        Elements = {}
    }, Groupbox)

    -- Card
    local card = Create("Frame", {
        Name = name,

        Size = UDim2.new(1, 0, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundColor3 = self == nil
            and Library.Scheme.Surface
            or Library.Scheme.Surface,

        BorderSizePixel = 0
    }, parent)

    Corner(card, 11)
    Stroke(card, Library.Scheme.Border, 0.45)

    -- Header
    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),

        BackgroundTransparency = 1
    }, card)

    local title = Create("TextLabel", {
        Position = UDim2.fromOffset(13, 0),

        Size = UDim2.new(1, -26, 1, 0),

        BackgroundTransparency = 1,

        Text = name,

        TextColor3 = Library.Scheme.Text,

        FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
        TextSize = 12,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, header)

    -- Content
    local content = Create("Frame", {
        Position = UDim2.fromOffset(12, 39),

        Size = UDim2.new(1, -24, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, card)

    Padding(content, 0, 0, 0, 12)

    Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, content)

    groupbox.Frame = card
    groupbox.Container = content
    groupbox.Title = title

    table.insert(collection, groupbox)
    table.insert(self.Groupboxes, groupbox)

    return groupbox
end

--========================================================--
-- Label
--========================================================--

function Groupbox:AddLabel(text, wrap)
    local label = Create("TextLabel", {
        Size = UDim2.new(
            1,
            0,
            0,
            wrap and 40 or 22
        ),

        BackgroundTransparency = 1,

        Text = tostring(text),

        TextColor3 = Library.Scheme.SubText,

        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 11,

        TextWrapped = wrap or false,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, self.Container)

    table.insert(self.Elements, label)

    return label
end

--========================================================--
-- Divider
--========================================================--

function Groupbox:AddDivider()
    local divider = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),

        BackgroundColor3 = Library.Scheme.Border,
        BackgroundTransparency = 0.45,

        BorderSizePixel = 0
    }, self.Container)

    table.insert(self.Elements, divider)

    return divider
end

--========================================================--
-- Button
--========================================================--

function Groupbox:AddButton(info)
    if type(info) == "string" then
        info = {
            Text = info
        }
    end

    info = info or {}

    local button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 35),

        BackgroundColor3 = Library.Scheme.Surface2,

        BorderSizePixel = 0,

        Text = info.Text or "Button",

        TextColor3 = Library.Scheme.Text,

        FontFace = Font.fromEnum(Enum.Font.GothamMedium),
        TextSize = 11,

        AutoButtonColor = false
    }, self.Container)

    Corner(button, 9)

    button.MouseEnter:Connect(function()
        Tween(button, {
            BackgroundColor3 = Library.Scheme.SurfaceHover
        })
    end)

    button.MouseLeave:Connect(function()
        Tween(button, {
            BackgroundColor3 = Library.Scheme.Surface2
        })
    end)

    button.MouseButton1Click:Connect(function()
        local callback = info.Callback or info.Func

        if callback then
            callback()
        end
    end)

    table.insert(self.Elements, button)

    return button
end

--========================================================--
-- Toggle
--========================================================--

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

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 35),

        BackgroundTransparency = 1
    }, self.Container)

    local label = Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),

        BackgroundTransparency = 1,

        Text = info.Text or name,

        TextColor3 = Library.Scheme.Text,

        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, holder)

    local switch = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),

        Position = UDim2.new(1, 0, 0.5, 0),

        Size = UDim2.fromOffset(40, 22),

        BackgroundColor3 = Color3.fromRGB(48, 49, 56),

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false
    }, holder)

    Corner(switch, 11)

    local knob = Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),

        Position = UDim2.new(0, 3, 0.5, 0),

        Size = UDim2.fromOffset(16, 16),

        BackgroundColor3 = Color3.fromRGB(190, 191, 198),

        BorderSizePixel = 0
    }, switch)

    Corner(knob, 8)

    toggle.Toggle = switch
    toggle.Knob = knob
    toggle.Label = label

    local function update(value, silent)
        toggle.Value = value == true

        if toggle.Value then
            Tween(switch, {
                BackgroundColor3 = Library.Scheme.Accent
            })

            Tween(knob, {
                Position = UDim2.new(1, -19, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(255,255,255)
            })
        else
            Tween(switch, {
                BackgroundColor3 = Color3.fromRGB(48,49,56)
            })

            Tween(knob, {
                Position = UDim2.new(0, 3, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(190,191,198)
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

    switch.MouseButton1Click:Connect(function()
        update(not toggle.Value)
    end)

    update(toggle.Value, true)

    Library.Toggles[name] = toggle
    Library.Options[name] = toggle

    table.insert(self.Elements, toggle)

    return toggle
end

--========================================================--
-- Slider
--========================================================--

local Slider = {}
Slider.__index = Slider

function Groupbox:AddSlider(name, info)
    info = info or {}

    local min = info.Min or 0
    local max = info.Max or 100
    local default = info.Default or min

    local slider = setmetatable({
        Name = name,

        Value = default,

        Min = min,
        Max = max,

        Callback = info.Callback or function() end,

        Changed = info.Changed or function() end
    }, Slider)

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 51),

        BackgroundTransparency = 1
    }, self.Container)

    local title = Create("TextLabel", {
        Size = UDim2.new(1, -70, 0, 19),

        BackgroundTransparency = 1,

        Text = info.Text or name,

        TextColor3 = Library.Scheme.Text,

        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left
    }, holder)

    local valueText = Create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),

        Position = UDim2.new(1, 0, 0, 0),

        Size = UDim2.fromOffset(70, 19),

        BackgroundTransparency = 1,

        TextColor3 = Library.Scheme.SubText,

        FontFace = Font.fromEnum(Enum.Font.GothamMedium),
        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Right
    }, holder)

    local bar = Create("Frame", {
        Position = UDim2.fromOffset(0, 29),

        Size = UDim2.new(1, 0, 0, 5),

        BackgroundColor3 = Color3.fromRGB(48,49,56),

        BorderSizePixel = 0
    }, holder)

    Corner(bar, 3)

    local fill = Create("Frame", {
        Size = UDim2.fromScale(0, 1),

        BackgroundColor3 = Library.Scheme.Accent,

        BorderSizePixel = 0
    }, bar)

    Corner(fill, 3)

    local knob = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),

        Position = UDim2.fromScale(0, 0.5),

        Size = UDim2.fromOffset(12, 12),

        BackgroundColor3 = Color3.fromRGB(255,255,255),

        BorderSizePixel = 0
    }, bar)

    Corner(knob, 6)

    local function setValue(value, silent)
        value = math.clamp(
            tonumber(value) or min,
            min,
            max
        )

        slider.Value = value

        local alpha = 0

        if max ~= min then
            alpha = (value - min) / (max - min)
        end

        fill.Size = UDim2.fromScale(alpha, 1)
        knob.Position = UDim2.fromScale(alpha, 0.5)

        valueText.Text =
            tostring(info.Prefix or "")
            .. tostring(value)
            .. tostring(info.Suffix or "")

        if not silent then
            slider.Callback(value)
            slider.Changed(value)
        end
    end

    local dragging = false

    local function inputUpdate(input)
        local x =
            input.Position.X -
            bar.AbsolutePosition.X

        local percent =
            math.clamp(
                x / bar.AbsoluteSize.X,
                0,
                1
            )

        setValue(
            min + ((max - min) * percent)
        )
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            dragging = true
            inputUpdate(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and
            input.UserInputType ==
            Enum.UserInputType.MouseMovement then

            inputUpdate(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            dragging = false
        end
    end)

    function slider:SetValue(value)
        setValue(value)
    end

    function slider:GetValue()
        return slider.Value
    end

    function slider:OnChanged(callback)
        slider.Changed = callback
        return slider
    end

    setValue(default, true)

    Library.Options[name] = slider

    table.insert(self.Elements, slider)

    return slider
end

--========================================================--
-- Input
--========================================================--

function Groupbox:AddInput(name, info)
    info = info or {}

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 61),

        BackgroundTransparency = 1
    }, self.Container)

    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),

        BackgroundTransparency = 1,

        Text = info.Text or name,

        TextColor3 = Library.Scheme.Text,

        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left
    }, holder)

    local input = Create("TextBox", {
        Position = UDim2.fromOffset(0, 24),

        Size = UDim2.new(1, 0, 0, 33),

        BackgroundColor3 = Library.Scheme.Surface2,

        BorderSizePixel = 0,

        Text = tostring(info.Default or ""),

        PlaceholderText = info.Placeholder or "",

        PlaceholderColor3 = Library.Scheme.Muted,

        TextColor3 = Library.Scheme.Text,

        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 10,

        ClearTextOnFocus =
            info.ClearTextOnFocus ~= false,

        TextXAlignment = Enum.TextXAlignment.Left
    }, holder)

    Corner(input, 9)

    Padding(input, 9, 9, 0, 0)

    local object = {
        Name = name,
        Input = input,

        Value = input.Text,

        Callback = info.Callback or function() end,

        Changed = info.Changed or function() end
    }

    function object:SetValue(value)
        input.Text = tostring(value)
        object.Value = input.Text

        object.Callback(object.Value)
        object.Changed(object.Value)
    end

    function object:GetValue()
        return input.Text
    end

    function object:OnChanged(callback)
        object.Changed = callback
        return object
    end

    input.FocusLost:Connect(function()
        object.Value = input.Text

        object.Callback(input.Text)
        object.Changed(input.Text)
    end)

    Library.Options[name] = object

    table.insert(self.Elements, object)

    return object
end

--========================================================--
-- Dropdown
--========================================================--

local Dropdown = {}
Dropdown.__index = Dropdown

function Groupbox:AddDropdown(name, info)
    info = info or {}

    local values = info.Values or {}

    local dropdown = setmetatable({
        Name = name,

        Values = values,

        Value = info.Default or values[1],

        Callback = info.Callback or function() end,

        Changed = info.Changed or function() end
    }, Dropdown)

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),

        BackgroundTransparency = 1,

        ZIndex = 5
    }, self.Container)

    local title = Create("TextLabel", {
        Size = UDim2.new(0.38, 0, 1, 0),

        BackgroundTransparency = 1,

        Text = info.Text or name,

        TextColor3 = Library.Scheme.Text,

        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left
    }, holder)

    local select = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),

        Position = UDim2.new(1, 0, 0.5, 0),

        Size = UDim2.new(0.62, 0, 0, 32),

        BackgroundColor3 = Library.Scheme.Surface2,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        ZIndex = 10
    }, holder)

    Corner(select, 9)

    local selected = Create("TextLabel", {
        Position = UDim2.fromOffset(9, 0),

        Size = UDim2.new(1, -30, 1, 0),

        BackgroundTransparency = 1,

        Text = tostring(
            dropdown.Value or "Select"
        ),

        TextColor3 = Library.Scheme.SubText,

        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Left,

        ZIndex = 11
    }, select)

    Create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),

        Position = UDim2.new(1, -8, 0.5, 0),

        Size = UDim2.fromOffset(12, 15),

        BackgroundTransparency = 1,

        Text = "⌄",

        TextColor3 = Library.Scheme.Muted,

        FontFace = Font.fromEnum(Enum.Font.GothamBold),
        TextSize = 12,

        ZIndex = 11
    }, select)

    local list = Create("Frame", {
        Position = UDim2.new(0, 0, 1, 4),

        Size = UDim2.new(1, 0, 0, 0),

        BackgroundColor3 = Library.Scheme.Surface,

        BorderSizePixel = 0,

        Visible = false,

        ZIndex = 100
    }, select)

    Corner(list, 9)
    Stroke(list, Library.Scheme.Border, 0.2)

    Padding(list, 4, 4, 4, 4)

    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, list)

    local open = false

    local function rebuild()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for index, value in ipairs(values) do
            local option = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 29),

                BackgroundTransparency = 1,

                Text = tostring(value),

                TextColor3 = Library.Scheme.Text,

                FontFace = Font.fromEnum(Enum.Font.Gotham),
                TextSize = 10,

                AutoButtonColor = false,

                ZIndex = 101,

                LayoutOrder = index
            }, list)

            Corner(option, 7)

            option.MouseEnter:Connect(function()
                Tween(option, {
                    BackgroundColor3 =
                        Library.Scheme.SurfaceHover,

                    BackgroundTransparency = 0
                })
            end)

            option.MouseLeave:Connect(function()
                Tween(option, {
                    BackgroundTransparency = 1
                })
            end)

            option.MouseButton1Click:Connect(function()
                dropdown:SetValue(value)

                open = false
                list.Visible = false
            end)
        end

        list.Size = UDim2.new(
            1,
            0,
            0,
            math.min(
                #values * 31 + 8,
                190
            )
        )
    end

    function dropdown:SetValue(value)
        dropdown.Value = value

        selected.Text = tostring(value)

        dropdown.Callback(value)
        dropdown.Changed(value)
    end

    function dropdown:GetValue()
        return dropdown.Value
    end

    function dropdown:SetValues(newValues)
        values = newValues or {}
        dropdown.Values = values

        rebuild()
    end

    function dropdown:OnChanged(callback)
        dropdown.Changed = callback
        return dropdown
    end

    select.MouseButton1Click:Connect(function()
        open = not open
        list.Visible = open

        if open then
            rebuild()
        end
    end)

    Library.Options[name] = dropdown

    table.insert(self.Elements, dropdown)

    return dropdown
end

--========================================================--
-- Notification
--========================================================--

function Library:Notify(info)
    if type(info) == "string" then
        info = {
            Title = "Notification",
            Description = info,
            Time = 3
        }
    end

    info = info or {}

    local notification = Create("Frame", {
        AnchorPoint = Vector2.new(1, 1),

        Position = UDim2.new(1, 330, 1, -20),

        Size = UDim2.fromOffset(305, 74),

        BackgroundColor3 = self.Scheme.Surface,

        BorderSizePixel = 0
    }, self.ScreenGui)

    Corner(notification, 11)
    Stroke(notification, self.Scheme.Border, 0.2)

    local accent = Create("Frame", {
        Position = UDim2.fromOffset(0, 13),

        Size = UDim2.fromOffset(3, 48),

        BackgroundColor3 = self.Scheme.Accent,

        BorderSizePixel = 0
    }, notification)

    Corner(accent, 2)

    Create("TextLabel", {
        Position = UDim2.fromOffset(14, 9),

        Size = UDim2.new(1, -24, 0, 19),

        BackgroundTransparency = 1,

        Text = info.Title or "Notification",

        TextColor3 = self.Scheme.Text,

        FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
        TextSize = 11,

        TextXAlignment = Enum.TextXAlignment.Left
    }, notification)

    Create("TextLabel", {
        Position = UDim2.fromOffset(14, 30),

        Size = UDim2.new(1, -24, 0, 32),

        BackgroundTransparency = 1,

        Text = info.Description or "",

        TextColor3 = self.Scheme.SubText,

        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 10,

        TextWrapped = true,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    }, notification)

    Tween(notification, {
        Position = UDim2.new(1, -20, 1, -20)
    })

    task.delay(info.Time or 3, function()
        if notification and notification.Parent then
            Tween(notification, {
                Position = UDim2.new(1, 330, 1, -20)
            })

            task.wait(0.18)

            if notification then
                notification:Destroy()
            end
        end
    end)

    return notification
end

--========================================================--
-- UI
--========================================================--

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

--========================================================--
-- ThemeManager Compatibility
--========================================================--

function Library:ApplyTheme(theme)
    if not theme then
        return
    end

    for key, value in pairs(theme) do
        if self.Scheme[key] ~= nil then
            self.Scheme[key] = value
        end
    end

    self.Colors = self.Scheme
end

function Library:UpdateColorsUsingRegistry()
    return true
end

--========================================================--
-- Unload
--========================================================--

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
