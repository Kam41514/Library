--[[
    KamUI Library
    Modern / Fluent-inspired renderer
    Obsidian-compatible style API

    Window
    ├── Tabs
    │   ├── Left Groupbox
    │   └── Right Groupbox
    │
    ├── Toggle
    ├── Slider
    ├── Dropdown
    ├── Input
    ├── Button
    ├── Label
    └── Divider
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}

------------------------------------------------------------
-- CORE
------------------------------------------------------------

Library.Version = "2.0.0"
Library.Options = {}
Library.Toggles = {}
Library.Tabs = {}
Library.TabButtons = {}

Library.ScreenGui = nil
Library.Window = nil
Library.ActiveTab = nil
Library.Unloaded = false
Library.Toggled = true

------------------------------------------------------------
-- THEME
------------------------------------------------------------

Library.Scheme = {
    BackgroundColor = Color3.fromRGB(9, 10, 14),
    MainColor = Color3.fromRGB(13, 14, 19),

    AccentColor = Color3.fromRGB(124, 92, 255),

    TextColor = Color3.fromRGB(239, 240, 245),
    SubTextColor = Color3.fromRGB(145, 148, 160),

    CardColor = Color3.fromRGB(17, 18, 24),
    CardHoverColor = Color3.fromRGB(22, 23, 30),

    ElementColor = Color3.fromRGB(25, 26, 33),
    ElementHoverColor = Color3.fromRGB(31, 32, 41),

    BorderColor = Color3.fromRGB(38, 39, 49),

    SuccessColor = Color3.fromRGB(87, 220, 145),
    DangerColor = Color3.fromRGB(245, 91, 105),

    WhiteColor = Color3.fromRGB(255, 255, 255),
}

Library.Colors = Library.Scheme

Library.Tween = TweenInfo.new(
    0.18,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

------------------------------------------------------------
-- UTIL
------------------------------------------------------------

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
    if not object then
        return
    end

    local tween = TweenService:Create(
        object,
        info or Library.Tween,
        properties
    )

    tween:Play()

    return tween
end

local function Corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = object

    return c
end

local function Stroke(object, color, transparency)
    local s = Instance.new("UIStroke")

    s.Color = color or Library.Scheme.BorderColor
    s.Transparency = transparency or 0
    s.Thickness = 1

    s.Parent = object

    return s
end

local function Padding(object, left, right, top, bottom)
    local p = Instance.new("UIPadding")

    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)

    p.Parent = object

    return p
end

------------------------------------------------------------
-- WINDOW
------------------------------------------------------------

function Library:CreateWindow(settings)

    settings = settings or {}

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end

    self.Unloaded = false

    --------------------------------------------------------
    -- GUI
    --------------------------------------------------------

    local gui = Create("ScreenGui", {
        Name = "KamUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local success = pcall(function()
        gui.Parent = gethui()
    end)

    if not success or not gui.Parent then
        gui.Parent = game:GetService("CoreGui")
    end

    self.ScreenGui = gui

    --------------------------------------------------------
    -- WINDOW
    --------------------------------------------------------

    local window = Create("Frame", {
        Name = "Window",

        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),

        -- 10px smaller than the previous version
        Size = settings.Size or UDim2.fromOffset(1040, 640),

        BackgroundColor3 = self.Scheme.MainColor,

        BorderSizePixel = 0
    }, gui)

    Corner(window, 18)

    Stroke(
        window,
        self.Scheme.BorderColor,
        0.25
    )

    self.Window = window

    --------------------------------------------------------
    -- TOP BAR
    --------------------------------------------------------

    local top = Create("Frame", {
        Name = "Top",

        Size = UDim2.new(1, 0, 0, 64),

        BackgroundTransparency = 1,

        BorderSizePixel = 0
    }, window)

    --------------------------------------------------------
    -- BRAND DOT
    --------------------------------------------------------

    local brandDot = Create("Frame", {
        Position = UDim2.fromOffset(20, 22),

        Size = UDim2.fromOffset(20, 20),

        BackgroundColor3 = self.Scheme.AccentColor,

        BorderSizePixel = 0
    }, top)

    Corner(brandDot, 10)

    local brandDotInner = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),

        Position = UDim2.fromScale(0.5, 0.5),

        Size = UDim2.fromOffset(7, 7),

        BackgroundColor3 = Color3.fromRGB(255,255,255),

        BackgroundTransparency = 0.15,

        BorderSizePixel = 0
    }, brandDot)

    Corner(brandDotInner, 4)

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    local title = Create("TextLabel", {
        Position = UDim2.fromOffset(51, 15),

        Size = UDim2.new(0, 400, 0, 22),

        BackgroundTransparency = 1,

        Text = settings.Title or "KamUI",

        TextColor3 = self.Scheme.TextColor,

        FontFace = Font.fromEnum(Enum.Font.GothamBold),

        TextSize = 16,

        TextXAlignment = Enum.TextXAlignment.Left
    }, top)

    local subtitle = Create("TextLabel", {
        Position = UDim2.fromOffset(51, 36),

        Size = UDim2.new(0, 400, 0, 16),

        BackgroundTransparency = 1,

        Text = settings.Subtitle or "Modern interface",

        TextColor3 = self.Scheme.SubTextColor,

        FontFace = Font.fromEnum(Enum.Font.Gotham),

        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Left
    }, top)

    --------------------------------------------------------
    -- CLOSE
    --------------------------------------------------------

    local close = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),

        Position = UDim2.new(1, -16, 0.5, 0),

        Size = UDim2.fromOffset(34, 34),

        BackgroundColor3 = Color3.fromRGB(30, 30, 38),

        BackgroundTransparency = 0.15,

        Text = "×",

        TextColor3 = self.Scheme.SubTextColor,

        FontFace = Font.fromEnum(Enum.Font.GothamMedium),

        TextSize = 19,

        AutoButtonColor = false
    }, top)

    Corner(close, 10)

    close.MouseEnter:Connect(function()
        Tween(close, {
            BackgroundColor3 = Color3.fromRGB(70, 35, 43),
            TextColor3 = self.Scheme.DangerColor
        })
    end)

    close.MouseLeave:Connect(function()
        Tween(close, {
            BackgroundColor3 = Color3.fromRGB(30, 30, 38),
            TextColor3 = self.Scheme.SubTextColor
        })
    end)

    close.MouseButton1Click:Connect(function()
        self:Unload()
    end)

    --------------------------------------------------------
    -- DRAG
    --------------------------------------------------------

    do
        local dragging = false
        local dragStart
        local startPosition

        top.InputBegan:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                dragging = true

                dragStart = input.Position

                startPosition = window.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)

            if not dragging then
                return
            end

            if input.UserInputType ~=
                Enum.UserInputType.MouseMovement then
                return
            end

            local delta =
                input.Position - dragStart

            window.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,

                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end)

        UserInputService.InputEnded:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                dragging = false
            end
        end)
    end

    --------------------------------------------------------
    -- BODY
    --------------------------------------------------------

    local body = Create("Frame", {
        Position = UDim2.fromOffset(10, 64),

        Size = UDim2.new(1, -20, 1, -74),

        BackgroundTransparency = 1
    }, window)

    --------------------------------------------------------
    -- NAVIGATION
    --------------------------------------------------------

    local navigation = Create("Frame", {
        Size = UDim2.new(0, 155, 1, 0),

        BackgroundColor3 = Color3.fromRGB(11, 12, 17),

        BorderSizePixel = 0
    }, body)

    Corner(navigation, 14)

    Padding(
        navigation,
        8,
        8,
        10,
        10
    )

    self.Navigation = navigation

    local navLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 5),

        SortOrder = Enum.SortOrder.LayoutOrder
    }, navigation)

    --------------------------------------------------------
    -- CONTENT
    --------------------------------------------------------

    local content = Create("Frame", {
        Position = UDim2.fromOffset(165, 0),

        Size = UDim2.new(1, -165, 1, 0),

        BackgroundTransparency = 1
    }, body)

    self.Content = content

    return self
end

------------------------------------------------------------
-- TAB
------------------------------------------------------------

local Tab = {}
Tab.__index = Tab

function Library:AddTab(name, icon)

    assert(
        self.Navigation,
        "CreateWindow must be called first"
    )

    local tab = setmetatable({
        Name = name,
        Icon = icon,

        Groupboxes = {},
        LeftGroupboxes = {},
        RightGroupboxes = {}
    }, Tab)

    --------------------------------------------------------
    -- TAB BUTTON
    --------------------------------------------------------

    local button = Create("TextButton", {
        Name = name,

        Size = UDim2.new(1, 0, 0, 38),

        BackgroundTransparency = 1,

        Text = "",

        AutoButtonColor = false,

        LayoutOrder = #self.TabButtons + 1
    }, self.Navigation)

    Corner(button, 10)

    --------------------------------------------------------
    -- ACTIVE BAR
    --------------------------------------------------------

    local active = Create("Frame", {
        Position = UDim2.fromOffset(0, 9),

        Size = UDim2.fromOffset(3, 20),

        BackgroundColor3 = self.Scheme.AccentColor,

        BackgroundTransparency = 1,

        BorderSizePixel = 0
    }, button)

    Corner(active, 2)

    --------------------------------------------------------
    -- ICON
    --------------------------------------------------------

    local iconLabel

    if icon then

        iconLabel = Create("TextLabel", {
            Position = UDim2.fromOffset(14, 0),

            Size = UDim2.fromOffset(20, 38),

            BackgroundTransparency = 1,

            Text = tostring(icon),

            TextColor3 = self.Scheme.SubTextColor,

            FontFace = Font.fromEnum(Enum.Font.GothamMedium),

            TextSize = 13
        }, button)

    end

    --------------------------------------------------------
    -- NAME
    --------------------------------------------------------

    local text = Create("TextLabel", {
        Position = UDim2.fromOffset(
            icon and 40 or 14,
            0
        ),

        Size = UDim2.new(
            1,
            icon and -48 or -22,
            1,
            0
        ),

        BackgroundTransparency = 1,

        Text = name,

        TextColor3 = self.Scheme.SubTextColor,

        FontFace = Font.fromEnum(Enum.Font.GothamMedium),

        TextSize = 12,

        TextXAlignment = Enum.TextXAlignment.Left
    }, button)

    --------------------------------------------------------
    -- PAGE
    --------------------------------------------------------

    local page = Create("ScrollingFrame", {
        Name = name .. "_Page",

        Size = UDim2.fromScale(1, 1),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness = 2,

        ScrollBarImageColor3 = self.Scheme.AccentColor,

        CanvasSize = UDim2.new(),

        AutomaticCanvasSize = Enum.AutomaticSize.Y,

        Visible = false
    }, self.Content)

    Padding(
        page,
        8,
        8,
        5,
        12
    )

    local columns = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, page)

    --------------------------------------------------------
    -- LEFT
    --------------------------------------------------------

    local left = Create("Frame", {
        Size = UDim2.new(0.5, -6, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, columns)

    local leftLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 9),

        SortOrder = Enum.SortOrder.LayoutOrder
    }, left)

    --------------------------------------------------------
    -- RIGHT
    --------------------------------------------------------

    local right = Create("Frame", {
        Position = UDim2.new(0.5, 6, 0, 0),

        Size = UDim2.new(0.5, -6, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, columns)

    local rightLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 9),

        SortOrder = Enum.SortOrder.LayoutOrder
    }, right)

    --------------------------------------------------------
    -- STORE
    --------------------------------------------------------

    tab.Button = button
    tab.Page = page
    tab.Left = left
    tab.Right = right
    tab.ActiveBar = active
    tab.Text = text
    tab.IconObject = iconLabel

    self.Tabs[name] = tab

    table.insert(self.TabButtons, tab)

    --------------------------------------------------------
    -- EVENTS
    --------------------------------------------------------

    button.MouseEnter:Connect(function()

        if self.ActiveTab ~= tab then

            Tween(button, {
                BackgroundColor3 =
                    self.Scheme.ElementHoverColor,

                BackgroundTransparency = 0.5
            })

        end
    end)

    button.MouseLeave:Connect(function()

        if self.ActiveTab ~= tab then

            Tween(button, {
                BackgroundTransparency = 1
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

------------------------------------------------------------
-- SELECT TAB
------------------------------------------------------------

function Library:SelectTab(tab)

    if type(tab) == "string" then
        tab = self.Tabs[tab]
    end

    if not tab then
        return
    end

    self.ActiveTab = tab

    for _, current in ipairs(self.TabButtons) do

        local selected =
            current == tab

        current.Page.Visible = selected

        if selected then

            Tween(current.Button, {
                BackgroundColor3 =
                    self.Scheme.AccentColor,

                BackgroundTransparency = 0.88
            })

            Tween(current.Text, {
                TextColor3 =
                    self.Scheme.TextColor
            })

            Tween(current.ActiveBar, {
                BackgroundTransparency = 0
            })

            if current.IconObject then
                Tween(current.IconObject, {
                    TextColor3 =
                        self.Scheme.TextColor
                })
            end

        else

            Tween(current.Button, {
                BackgroundTransparency = 1
            })

            Tween(current.Text, {
                TextColor3 =
                    self.Scheme.SubTextColor
            })

            Tween(current.ActiveBar, {
                BackgroundTransparency = 1
            })

            if current.IconObject then
                Tween(current.IconObject, {
                    TextColor3 =
                        self.Scheme.SubTextColor
                })
            end
        end
    end
end

------------------------------------------------------------
-- GROUPBOX
------------------------------------------------------------

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

    local box = setmetatable({
        Name = name,
        Icon = icon,
        Elements = {}
    }, Groupbox)

    --------------------------------------------------------
    -- CARD
    --------------------------------------------------------

    local card = Create("Frame", {
        Name = name,

        Size = UDim2.new(1, 0, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundColor3 =
            self.Parent
                and Library.Scheme.CardColor
                or Library.Scheme.CardColor,

        BorderSizePixel = 0
    }, parent)

    Corner(card, 14)

    --------------------------------------------------------
    -- SUBTLE TOP LIGHT
    --------------------------------------------------------

    local topLine = Create("Frame", {
        Position = UDim2.fromOffset(14, 0),

        Size = UDim2.new(0, 35, 0, 2),

        BackgroundColor3 =
            Library.Scheme.AccentColor,

        BackgroundTransparency = 0.45,

        BorderSizePixel = 0
    }, card)

    Corner(topLine, 2)

    --------------------------------------------------------
    -- HEADER
    --------------------------------------------------------

    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),

        BackgroundTransparency = 1
    }, card)

    Padding(
        header,
        14,
        14,
        8,
        4
    )

    local title = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),

        BackgroundTransparency = 1,

        Text = name,

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamSemibold),

        TextSize = 13,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextYAlignment =
            Enum.TextYAlignment.Center
    }, header)

    --------------------------------------------------------
    -- ELEMENT HOLDER
    --------------------------------------------------------

    local holder = Create("Frame", {
        Position = UDim2.fromOffset(13, 42),

        Size = UDim2.new(1, -26, 0, 0),

        AutomaticSize = Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, card)

    Padding(
        holder,
        0,
        0,
        0,
        13
    )

    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 7),

        SortOrder = Enum.SortOrder.LayoutOrder
    }, holder)

    box.Frame = card
    box.Container = holder
    box.Title = title

    table.insert(collection, box)
    table.insert(self.Groupboxes, box)

    return box
end

------------------------------------------------------------
-- LABEL
------------------------------------------------------------

function Groupbox:AddLabel(text, wrap)

    local label = Create("TextLabel", {
        Size = UDim2.new(
            1,
            0,
            0,
            wrap and 38 or 22
        ),

        BackgroundTransparency = 1,

        Text = text,

        TextColor3 =
            Library.Scheme.SubTextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 11,

        TextWrapped = wrap or false,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextYAlignment =
            Enum.TextYAlignment.Center
    }, self.Container)

    table.insert(self.Elements, label)

    return label
end

------------------------------------------------------------
-- DIVIDER
------------------------------------------------------------

function Groupbox:AddDivider()

    local divider = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),

        BackgroundColor3 =
            Library.Scheme.BorderColor,

        BackgroundTransparency = 0.65,

        BorderSizePixel = 0
    }, self.Container)

    table.insert(self.Elements, divider)

    return divider
end

------------------------------------------------------------
-- BUTTON
------------------------------------------------------------

function Groupbox:AddButton(info)

    if type(info) == "string" then
        info = {
            Text = info
        }
    end

    info = info or {}

    local button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),

        BackgroundColor3 =
            Library.Scheme.ElementColor,

        BorderSizePixel = 0,

        Text = info.Text or "Button",

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamMedium),

        TextSize = 11,

        AutoButtonColor = false
    }, self.Container)

    Corner(button, 9)

    button.MouseEnter:Connect(function()

        Tween(button, {
            BackgroundColor3 =
                Library.Scheme.ElementHoverColor
        })

    end)

    button.MouseLeave:Connect(function()

        Tween(button, {
            BackgroundColor3 =
                Library.Scheme.ElementColor
        })

    end)

    button.MouseButton1Click:Connect(function()

        local callback =
            info.Callback or info.Func

        if callback then
            callback()
        end

    end)

    table.insert(self.Elements, button)

    return button
end

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------

local Toggle = {}
Toggle.__index = Toggle

function Groupbox:AddToggle(name, info)

    info = info or {}

    local object = setmetatable({
        Name = name,

        Value = info.Default or false,

        Callback =
            info.Callback
            or function() end,

        Changed =
            info.Changed
            or function() end
    }, Toggle)

    --------------------------------------------------------
    -- HOLDER
    --------------------------------------------------------

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),

        BackgroundTransparency = 1
    }, self.Container)

    --------------------------------------------------------
    -- TEXT
    --------------------------------------------------------

    local label = Create("TextLabel", {
        Size = UDim2.new(1, -55, 1, 0),

        BackgroundTransparency = 1,

        Text = info.Text or name,

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 12,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, holder)

    --------------------------------------------------------
    -- TOGGLE
    --------------------------------------------------------

    local toggle = Create("TextButton", {
        AnchorPoint =
            Vector2.new(1, 0.5),

        Position =
            UDim2.new(1, 0, 0.5, 0),

        Size =
            UDim2.fromOffset(38, 20),

        BackgroundColor3 =
            Color3.fromRGB(40, 41, 49),

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false
    }, holder)

    Corner(toggle, 10)

    local knob = Create("Frame", {
        AnchorPoint =
            Vector2.new(0, 0.5),

        Position =
            UDim2.new(0, 3, 0.5, 0),

        Size =
            UDim2.fromOffset(14, 14),

        BackgroundColor3 =
            Color3.fromRGB(190, 191, 198),

        BorderSizePixel = 0
    }, toggle)

    Corner(knob, 7)

    object.Toggle = toggle
    object.Knob = knob
    object.Label = label

    --------------------------------------------------------
    -- UPDATE
    --------------------------------------------------------

    local function update(value, silent)

        object.Value = value == true

        if object.Value then

            Tween(toggle, {
                BackgroundColor3 =
                    Library.Scheme.AccentColor
            })

            Tween(knob, {
                Position =
                    UDim2.new(1, -17, 0.5, 0),

                BackgroundColor3 =
                    Color3.fromRGB(255,255,255)
            })

        else

            Tween(toggle, {
                BackgroundColor3 =
                    Color3.fromRGB(40,41,49)
            })

            Tween(knob, {
                Position =
                    UDim2.new(0, 3, 0.5, 0),

                BackgroundColor3 =
                    Color3.fromRGB(190,191,198)
            })

        end

        if not silent then
            object.Callback(object.Value)
            object.Changed(object.Value)
        end
    end

    function object:SetValue(value)
        update(value)
    end

    function object:GetValue()
        return object.Value
    end

    function object:OnChanged(callback)
        object.Changed = callback
        return object
    end

    toggle.MouseButton1Click:Connect(function()
        update(not object.Value)
    end)

    update(object.Value, true)

    Library.Toggles[name] = object
    Library.Options[name] = object

    table.insert(self.Elements, object)

    return object
end

------------------------------------------------------------
-- SLIDER
------------------------------------------------------------

local Slider = {}
Slider.__index = Slider

function Groupbox:AddSlider(name, info)

    info = info or {}

    local min =
        info.Min or 0

    local max =
        info.Max or 100

    local default =
        info.Default or min

    local object = setmetatable({

        Name = name,

        Value = default,

        Min = min,

        Max = max,

        Callback =
            info.Callback
            or function() end,

        Changed =
            info.Changed
            or function() end

    }, Slider)

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),

        BackgroundTransparency = 1
    }, self.Container)

    local nameLabel = Create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 19),

        BackgroundTransparency = 1,

        Text = info.Text or name,

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 12,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, holder)

    local valueLabel = Create("TextLabel", {
        AnchorPoint =
            Vector2.new(1, 0),

        Position =
            UDim2.new(1, 0, 0, 0),

        Size =
            UDim2.fromOffset(60, 19),

        BackgroundTransparency = 1,

        TextColor3 =
            Library.Scheme.SubTextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamMedium),

        TextSize = 10,

        TextXAlignment =
            Enum.TextXAlignment.Right
    }, holder)

    --------------------------------------------------------
    -- BAR
    --------------------------------------------------------

    local bar = Create("Frame", {
        Position =
            UDim2.fromOffset(0, 29),

        Size =
            UDim2.new(1, 0, 0, 5),

        BackgroundColor3 =
            Color3.fromRGB(38,39,47),

        BorderSizePixel = 0
    }, holder)

    Corner(bar, 3)

    local fill = Create("Frame", {
        Size = UDim2.fromScale(0,1),

        BackgroundColor3 =
            Library.Scheme.AccentColor,

        BorderSizePixel = 0
    }, bar)

    Corner(fill, 3)

    local knob = Create("Frame", {
        AnchorPoint =
            Vector2.new(0.5,0.5),

        Position =
            UDim2.fromScale(0,0.5),

        Size =
            UDim2.fromOffset(12,12),

        BackgroundColor3 =
            Color3.fromRGB(255,255,255),

        BorderSizePixel = 0
    }, bar)

    Corner(knob, 6)

    --------------------------------------------------------
    -- VALUE
    --------------------------------------------------------

    local function setValue(value, silent)

        value =
            math.clamp(
                tonumber(value) or min,
                min,
                max
            )

        object.Value = value

        local alpha =
            (value - min) /
            (max - min)

        fill.Size =
            UDim2.fromScale(alpha,1)

        knob.Position =
            UDim2.fromScale(alpha,0.5)

        valueLabel.Text =
            tostring(info.Prefix or "")
            .. tostring(value)
            .. tostring(info.Suffix or "")

        if not silent then

            object.Callback(value)

            object.Changed(value)

        end
    end

    local dragging = false

    local function update(input)

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
            min +
            ((max - min) * percent)
        )
    end

    bar.InputBegan:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            dragging = true

            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)

        if dragging and
            input.UserInputType ==
            Enum.UserInputType.MouseMovement then

            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)

        if input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            dragging = false
        end
    end)

    function object:SetValue(value)
        setValue(value)
    end

    function object:GetValue()
        return object.Value
    end

    function object:OnChanged(callback)
        object.Changed = callback
        return object
    end

    setValue(default, true)

    Library.Options[name] = object

    table.insert(self.Elements, object)

    return object
end

------------------------------------------------------------
-- DROPDOWN
------------------------------------------------------------

local Dropdown = {}
Dropdown.__index = Dropdown

function Groupbox:AddDropdown(name, info)

    info = info or {}

    local values =
        info.Values or {}

    local object = setmetatable({

        Name = name,

        Values = values,

        Value =
            info.Default
            or values[1],

        Callback =
            info.Callback
            or function() end,

        Changed =
            info.Changed
            or function() end

    }, Dropdown)

    local holder = Create("Frame", {
        Size = UDim2.new(1,0,0,38),

        BackgroundTransparency = 1
    }, self.Container)

    local label = Create("TextLabel", {
        Size = UDim2.new(0.38,0,1,0),

        BackgroundTransparency = 1,

        Text =
            info.Text
            or name,

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 12,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, holder)

    local select = Create("TextButton", {
        AnchorPoint =
            Vector2.new(1,0.5),

        Position =
            UDim2.new(1,0,0.5,0),

        Size =
            UDim2.new(0.58,0,0,32),

        BackgroundColor3 =
            Library.Scheme.ElementColor,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false
    }, holder)

    Corner(select, 9)

    local selected = Create("TextLabel", {
        Position =
            UDim2.fromOffset(10,0),

        Size =
            UDim2.new(1,-30,1,0),

        BackgroundTransparency = 1,

        Text =
            tostring(object.Value or "Select"),

        TextColor3 =
            Library.Scheme.SubTextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 10,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, select)

    local arrow = Create("TextLabel", {
        AnchorPoint =
            Vector2.new(1,0.5),

        Position =
            UDim2.new(1,-8,0.5,0),

        Size =
            UDim2.fromOffset(14,14),

        BackgroundTransparency = 1,

        Text = "⌄",

        TextColor3 =
            Library.Scheme.SubTextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamBold),

        TextSize = 13
    }, select)

    --------------------------------------------------------
    -- LIST
    --------------------------------------------------------

    local list = Create("Frame", {
        Position =
            UDim2.new(0,0,1,4),

        Size =
            UDim2.new(1,0,0,0),

        BackgroundColor3 =
            Library.Scheme.CardColor,

        BorderSizePixel = 0,

        Visible = false,

        ZIndex = 50,

        ClipsDescendants = true
    }, select)

    Corner(list, 9)

    Stroke(
        list,
        Library.Scheme.BorderColor,
        0.3
    )

    Padding(
        list,
        4,4,4,4
    )

    local listLayout = Create("UIListLayout", {
        Padding = UDim.new(0,2),

        SortOrder = Enum.SortOrder.LayoutOrder
    }, list)

    local opened = false

    local function refresh()

        for _, child in ipairs(list:GetChildren()) do

            if child:IsA("TextButton") then
                child:Destroy()
            end

        end

        for index, value in ipairs(values) do

            local option = Create("TextButton", {
                Size =
                    UDim2.new(1,0,0,28),

                BackgroundTransparency = 1,

                Text =
                    tostring(value),

                TextColor3 =
                    Library.Scheme.TextColor,

                FontFace =
                    Font.fromEnum(Enum.Font.Gotham),

                TextSize = 10,

                AutoButtonColor = false,

                ZIndex = 51,

                LayoutOrder = index
            }, list)

            Corner(option, 7)

            option.MouseEnter:Connect(function()

                Tween(option, {
                    BackgroundColor3 =
                        Library.Scheme.ElementHoverColor,

                    BackgroundTransparency = 0
                })

            end)

            option.MouseLeave:Connect(function()

                Tween(option, {
                    BackgroundTransparency = 1
                })

            end)

            option.MouseButton1Click:Connect(function()

                object:SetValue(value)

                opened = false

                list.Visible = false
            end)
        end

        list.Size =
            UDim2.new(
                1,
                0,
                0,
                math.min(
                    (#values * 30) + 8,
                    190
                )
            )
    end

    function object:SetValue(value)

        object.Value = value

        selected.Text =
            tostring(value)

        object.Callback(value)

        object.Changed(value)
    end

    function object:GetValue()
        return object.Value
    end

    function object:SetValues(newValues)

        values =
            newValues or {}

        object.Values = values

        refresh()
    end

    function object:OnChanged(callback)

        object.Changed = callback

        return object
    end

    select.MouseButton1Click:Connect(function()

        opened = not opened

        list.Visible = opened

        if opened then
            refresh()
        end
    end)

    Library.Options[name] = object

    table.insert(self.Elements, object)

    return object
end

------------------------------------------------------------
-- INPUT
------------------------------------------------------------

function Groupbox:AddInput(name, info)

    info = info or {}

    local holder = Create("Frame", {
        Size =
            UDim2.new(1,0,0,62),

        BackgroundTransparency = 1
    }, self.Container)

    local label = Create("TextLabel", {
        Size =
            UDim2.new(1,0,0,18),

        BackgroundTransparency = 1,

        Text =
            info.Text
            or name,

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 12,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, holder)

    local input = Create("TextBox", {
        Position =
            UDim2.fromOffset(0,24),

        Size =
            UDim2.new(1,0,0,32),

        BackgroundColor3 =
            Library.Scheme.ElementColor,

        BorderSizePixel = 0,

        Text =
            tostring(info.Default or ""),

        PlaceholderText =
            info.Placeholder or "",

        PlaceholderColor3 =
            Library.Scheme.SubTextColor,

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 10,

        ClearTextOnFocus =
            info.ClearTextOnFocus ~= false
    }, holder)

    Corner(input, 9)

    Padding(
        input,
        10,10,0,0
    )

    local object = {
        Name = name,

        Input = input,

        Value = input.Text,

        Callback =
            info.Callback
            or function() end,

        Changed =
            info.Changed
            or function() end
    }

    function object:SetValue(value)

        input.Text =
            tostring(value)

        object.Value =
            input.Text

        object.Callback(
            object.Value
        )

        object.Changed(
            object.Value
        )
    end

    function object:GetValue()
        return input.Text
    end

    function object:OnChanged(callback)

        object.Changed = callback

        return object
    end

    input.FocusLost:Connect(function()

        object.Value =
            input.Text

        object.Callback(
            input.Text
        )

        object.Changed(
            input.Text
        )
    end)

    Library.Options[name] = object

    table.insert(self.Elements, object)

    return object
end

------------------------------------------------------------
-- NOTIFICATION
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

    local holder = Create("Frame", {
        AnchorPoint =
            Vector2.new(1,1),

        Position =
            UDim2.new(1,330,1,-20),

        Size =
            UDim2.fromOffset(310,78),

        BackgroundColor3 =
            self.Scheme.CardColor,

        BorderSizePixel = 0
    }, self.ScreenGui)

    Corner(holder, 14)

    Stroke(
        holder,
        self.Scheme.BorderColor,
        0.25
    )

    local accent = Create("Frame", {
        Position =
            UDim2.fromOffset(0,16),

        Size =
            UDim2.fromOffset(3,46),

        BackgroundColor3 =
            self.Scheme.AccentColor,

        BorderSizePixel = 0
    }, holder)

    Corner(accent,2)

    Create("TextLabel", {
        Position =
            UDim2.fromOffset(15,10),

        Size =
            UDim2.new(1,-30,0,20),

        BackgroundTransparency = 1,

        Text =
            info.Title
            or "Notification",

        TextColor3 =
            self.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamSemibold),

        TextSize = 12,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, holder)

    Create("TextLabel", {
        Position =
            UDim2.fromOffset(15,32),

        Size =
            UDim2.new(1,-30,0,32),

        BackgroundTransparency = 1,

        Text =
            info.Description
            or "",

        TextColor3 =
            self.Scheme.SubTextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 10,

        TextWrapped = true,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextYAlignment =
            Enum.TextYAlignment.Top
    }, holder)

    Tween(holder, {
        Position =
            UDim2.new(1,-20,1,-20)
    })

    task.delay(
        info.Time or 3,
        function()

            if holder.Parent then

                Tween(holder, {
                    Position =
                        UDim2.new(1,330,1,-20)
                })

                task.wait(0.2)

                if holder then
                    holder:Destroy()
                end
            end
        end
    )

    return holder
end

------------------------------------------------------------
-- UI
------------------------------------------------------------

function Library:Toggle()

    if not self.Window then
        return
    end

    self.Toggled =
        not self.Toggled

    self.Window.Visible =
        self.Toggled
end

function Library:ToggleUI()
    self:Toggle()
end

------------------------------------------------------------
-- THEME API
------------------------------------------------------------

function Library:UpdateColorsUsingRegistry()
    return true
end

function Library:ApplyTheme(theme)

    if not theme then
        return
    end

    for key, value in pairs(theme) do

        if self.Scheme[key] ~= nil then

            self.Scheme[key] =
                value
        end
    end
end

------------------------------------------------------------
-- UNLOAD
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

    self.Tabs = {}
    self.TabButtons = {}
    self.Options = {}
    self.Toggles = {}
end

return Library
