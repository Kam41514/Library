--[[
    KamUI Library
    Clean / Modern UI
    Obsidian-style API, custom renderer
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}

------------------------------------------------------------
-- CORE
------------------------------------------------------------

Library.Version = "3.0.0"
Library.Options = {}
Library.Toggles = {}
Library.Tabs = {}
Library.TabButtons = {}

Library.ScreenGui = nil
Library.Window = nil
Library.ActiveTab = nil
Library.Toggled = true
Library.Unloaded = false

------------------------------------------------------------
-- THEME
------------------------------------------------------------

Library.Scheme = {
    BackgroundColor = Color3.fromRGB(18, 19, 23),
    MainColor = Color3.fromRGB(22, 23, 28),

    SidebarColor = Color3.fromRGB(19, 20, 25),

    CardColor = Color3.fromRGB(28, 29, 35),
    ElementColor = Color3.fromRGB(34, 35, 42),
    ElementHoverColor = Color3.fromRGB(41, 42, 50),

    BorderColor = Color3.fromRGB(54, 55, 64),

    AccentColor = Color3.fromRGB(116, 92, 255),

    TextColor = Color3.fromRGB(242, 243, 247),
    SubTextColor = Color3.fromRGB(174, 176, 186),

    SuccessColor = Color3.fromRGB(91, 211, 143),
    DangerColor = Color3.fromRGB(238, 91, 105),

    WhiteColor = Color3.fromRGB(255, 255, 255),
}

Library.Colors = Library.Scheme

Library.Tween = TweenInfo.new(
    0.16,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

------------------------------------------------------------
-- UTILITIES
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
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object

    return corner
end

local function AddStroke(object, color, transparency)
    local stroke = Instance.new("UIStroke")

    stroke.Color =
        color or Library.Scheme.BorderColor

    stroke.Transparency =
        transparency or 0

    stroke.Thickness = 1
    stroke.Parent = object

    return stroke
end

local function AddPadding(
    object,
    left,
    right,
    top,
    bottom
)

    local padding = Instance.new("UIPadding")

    padding.PaddingLeft =
        UDim.new(0, left or 0)

    padding.PaddingRight =
        UDim.new(0, right or 0)

    padding.PaddingTop =
        UDim.new(0, top or 0)

    padding.PaddingBottom =
        UDim.new(0, bottom or 0)

    padding.Parent = object

    return padding
end

------------------------------------------------------------
-- CREATE WINDOW
------------------------------------------------------------

function Library:CreateWindow(settings)

    settings = settings or {}

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end

    self.Options = {}
    self.Toggles = {}
    self.Tabs = {}
    self.TabButtons = {}

    self.Unloaded = false
    self.Toggled = true

    --------------------------------------------------------
    -- SCREEN GUI
    --------------------------------------------------------

    local gui = Create("ScreenGui", {
        Name = "KamUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local parentSuccess = pcall(function()
        gui.Parent = gethui()
    end)

    if not parentSuccess or not gui.Parent then
        gui.Parent = game:GetService("CoreGui")
    end

    self.ScreenGui = gui

    --------------------------------------------------------
    -- MAIN WINDOW
    --------------------------------------------------------

    local window = Create("Frame", {
        Name = "MainWindow",

        AnchorPoint =
            Vector2.new(0.5, 0.5),

        Position =
            UDim2.fromScale(0.5, 0.5),

        Size =
            settings.Size
            or UDim2.fromOffset(1040, 640),

        BackgroundColor3 =
            self.Scheme.MainColor,

        BorderSizePixel = 0
    }, gui)

    Corner(window, 12)

    AddStroke(
        window,
        self.Scheme.BorderColor,
        0.15
    )

    self.Window = window

    --------------------------------------------------------
    -- HEADER
    --------------------------------------------------------

    local header = Create("Frame", {
        Size =
            UDim2.new(1, 0, 0, 58),

        BackgroundTransparency = 1,

        BorderSizePixel = 0
    }, window)

    --------------------------------------------------------
    -- BRAND
    --------------------------------------------------------

    local brand = Create("Frame", {
        Position =
            UDim2.fromOffset(18, 19),

        Size =
            UDim2.fromOffset(20, 20),

        BackgroundColor3 =
            self.Scheme.AccentColor,

        BorderSizePixel = 0
    }, header)

    Corner(brand, 6)

    local brandInner = Create("Frame", {
        AnchorPoint =
            Vector2.new(0.5, 0.5),

        Position =
            UDim2.fromScale(0.5, 0.5),

        Size =
            UDim2.fromOffset(7, 7),

        BackgroundColor3 =
            Color3.fromRGB(255,255,255),

        BorderSizePixel = 0
    }, brand)

    Corner(brandInner, 3)

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    Create("TextLabel", {
        Position =
            UDim2.fromOffset(49, 10),

        Size =
            UDim2.new(0, 450, 0, 23),

        BackgroundTransparency = 1,

        Text =
            settings.Title
            or "KamUI",

        TextColor3 =
            self.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamBold),

        TextSize = 15,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, header)

    Create("TextLabel", {
        Position =
            UDim2.fromOffset(49, 31),

        Size =
            UDim2.new(0, 450, 0, 16),

        BackgroundTransparency = 1,

        Text =
            settings.Subtitle
            or "Modern interface",

        TextColor3 =
            self.Scheme.SubTextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 10,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, header)

    --------------------------------------------------------
    -- CLOSE
    --------------------------------------------------------

    local close = Create("TextButton", {
        AnchorPoint =
            Vector2.new(1, 0.5),

        Position =
            UDim2.new(1, -15, 0.5, 0),

        Size =
            UDim2.fromOffset(32, 32),

        BackgroundColor3 =
            self.Scheme.ElementColor,

        BorderSizePixel = 0,

        Text = "×",

        TextColor3 =
            self.Scheme.SubTextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamMedium),

        TextSize = 18,

        AutoButtonColor = false
    }, header)

    Corner(close, 8)

    close.MouseEnter:Connect(function()

        Tween(close, {
            BackgroundColor3 =
                Color3.fromRGB(65, 35, 42),

            TextColor3 =
                self.Scheme.DangerColor
        })

    end)

    close.MouseLeave:Connect(function()

        Tween(close, {
            BackgroundColor3 =
                self.Scheme.ElementColor,

            TextColor3 =
                self.Scheme.SubTextColor
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

        header.InputBegan:Connect(function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                dragging = true

                dragStart =
                    input.Position

                startPosition =
                    window.Position
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
                input.Position -
                dragStart

            window.Position =
                UDim2.new(
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
        Position =
            UDim2.fromOffset(10, 58),

        Size =
            UDim2.new(1, -20, 1, -68),

        BackgroundTransparency = 1
    }, window)

    --------------------------------------------------------
    -- SIDEBAR
    --------------------------------------------------------

    local sidebar = Create("Frame", {
        Size =
            UDim2.new(0, 160, 1, 0),

        BackgroundColor3 =
            self.Scheme.SidebarColor,

        BorderSizePixel = 0
    }, body)

    Corner(sidebar, 10)

    AddPadding(
        sidebar,
        7,
        7,
        9,
        9
    )

    self.Navigation = sidebar

    Create("UIListLayout", {
        Padding =
            UDim.new(0, 4),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    }, sidebar)

    --------------------------------------------------------
    -- CONTENT
    --------------------------------------------------------

    local content = Create("Frame", {
        Position =
            UDim2.fromOffset(170, 0),

        Size =
            UDim2.new(1, -170, 1, 0),

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
        "Library:CreateWindow must be called first"
    )

    local tab = setmetatable({

        Name = name,
        Icon = icon,

        Groupboxes = {},
        LeftGroupboxes = {},
        RightGroupboxes = {}

    }, Tab)

    --------------------------------------------------------
    -- BUTTON
    --------------------------------------------------------

    local button = Create("TextButton", {
        Name = name,

        Size =
            UDim2.new(1, 0, 0, 37),

        BackgroundTransparency = 1,

        Text = "",

        AutoButtonColor = false,

        LayoutOrder =
            #self.TabButtons + 1
    }, self.Navigation)

    Corner(button, 8)

    --------------------------------------------------------
    -- SELECTED INDICATOR
    --------------------------------------------------------

    local indicator = Create("Frame", {
        Position =
            UDim2.fromOffset(0, 8),

        Size =
            UDim2.fromOffset(3, 21),

        BackgroundColor3 =
            self.Scheme.AccentColor,

        BackgroundTransparency = 1,

        BorderSizePixel = 0
    }, button)

    Corner(indicator, 2)

    --------------------------------------------------------
    -- ICON
    --------------------------------------------------------

    local iconObject

    if icon then

        iconObject = Create("TextLabel", {
            Position =
                UDim2.fromOffset(13, 0),

            Size =
                UDim2.fromOffset(22, 37),

            BackgroundTransparency = 1,

            Text =
                tostring(icon),

            TextColor3 =
                self.Scheme.SubTextColor,

            FontFace =
                Font.fromEnum(Enum.Font.GothamMedium),

            TextSize = 13,

            TextXAlignment =
                Enum.TextXAlignment.Center,

            TextYAlignment =
                Enum.TextYAlignment.Center
        }, button)

    end

    --------------------------------------------------------
    -- NAME
    --------------------------------------------------------

    local text = Create("TextLabel", {
        Position =
            UDim2.fromOffset(
                icon and 42 or 14,
                0
            ),

        Size =
            UDim2.new(
                1,
                icon and -48 or -20,
                1,
                0
            ),

        BackgroundTransparency = 1,

        Text =
            name,

        TextColor3 =
            self.Scheme.SubTextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamMedium),

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextYAlignment =
            Enum.TextYAlignment.Center
    }, button)

    --------------------------------------------------------
    -- PAGE
    --------------------------------------------------------

    local page = Create("ScrollingFrame", {
        Name =
            name .. "_Page",

        Size =
            UDim2.fromScale(1, 1),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness = 2,

        ScrollBarImageColor3 =
            self.Scheme.AccentColor,

        AutomaticCanvasSize =
            Enum.AutomaticSize.Y,

        CanvasSize =
            UDim2.new(),

        Visible = false
    }, self.Content)

    AddPadding(
        page,
        7,
        7,
        5,
        10
    )

    local columns = Create("Frame", {
        Size =
            UDim2.new(1, 0, 0, 0),

        AutomaticSize =
            Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, page)

    --------------------------------------------------------
    -- LEFT
    --------------------------------------------------------

    local left = Create("Frame", {
        Size =
            UDim2.new(0.5, -5, 0, 0),

        AutomaticSize =
            Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, columns)

    Create("UIListLayout", {
        Padding =
            UDim.new(0, 8),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    }, left)

    --------------------------------------------------------
    -- RIGHT
    --------------------------------------------------------

    local right = Create("Frame", {
        Position =
            UDim2.new(0.5, 5, 0, 0),

        Size =
            UDim2.new(0.5, -5, 0, 0),

        AutomaticSize =
            Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, columns)

    Create("UIListLayout", {
        Padding =
            UDim.new(0, 8),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    }, right)

    --------------------------------------------------------
    -- STORE
    --------------------------------------------------------

    tab.Button = button
    tab.Page = page
    tab.Left = left
    tab.Right = right
    tab.TextObject = text
    tab.IconObject = iconObject
    tab.Indicator = indicator

    self.Tabs[name] = tab

    table.insert(
        self.TabButtons,
        tab
    )

    --------------------------------------------------------
    -- HOVER
    --------------------------------------------------------

    button.MouseEnter:Connect(function()

        if self.ActiveTab ~= tab then

            Tween(button, {
                BackgroundColor3 =
                    self.Scheme.ElementColor,

                BackgroundTransparency = 0.45
            })

            Tween(text, {
                TextColor3 =
                    self.Scheme.TextColor
            })

        end

    end)

    button.MouseLeave:Connect(function()

        if self.ActiveTab ~= tab then

            Tween(button, {
                BackgroundTransparency = 1
            })

            Tween(text, {
                TextColor3 =
                    self.Scheme.SubTextColor
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

    for _, current in ipairs(
        self.TabButtons
    ) do

        local selected =
            current == tab

        current.Page.Visible =
            selected

        if selected then

            Tween(current.Button, {
                BackgroundColor3 =
                    self.Scheme.AccentColor,

                BackgroundTransparency =
                    0.82
            })

            Tween(current.TextObject, {
                TextColor3 =
                    self.Scheme.TextColor
            })

            Tween(current.Indicator, {
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

            Tween(current.TextObject, {
                TextColor3 =
                    self.Scheme.SubTextColor
            })

            Tween(current.Indicator, {
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

    local frame = Create("Frame", {
        Name =
            name,

        Size =
            UDim2.new(1, 0, 0, 0),

        AutomaticSize =
            Enum.AutomaticSize.Y,

        BackgroundColor3 =
            Library.Scheme.CardColor,

        BorderSizePixel = 0
    }, parent)

    Corner(frame, 10)

    AddStroke(
        frame,
        Library.Scheme.BorderColor,
        0.35
    )

    --------------------------------------------------------
    -- HEADER
    --------------------------------------------------------

    local header = Create("Frame", {
        Size =
            UDim2.new(1, 0, 0, 43),

        BackgroundTransparency = 1
    }, frame)

    local title = Create("TextLabel", {
        Position =
            UDim2.fromOffset(13, 0),

        Size =
            UDim2.new(1, -26, 1, 0),

        BackgroundTransparency = 1,

        Text =
            name,

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamSemibold),

        TextSize = 12,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextYAlignment =
            Enum.TextYAlignment.Center
    }, header)

    --------------------------------------------------------
    -- ELEMENT CONTAINER
    --------------------------------------------------------

    local container = Create("Frame", {
        Position =
            UDim2.fromOffset(12, 40),

        Size =
            UDim2.new(1, -24, 0, 0),

        AutomaticSize =
            Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    }, frame)

    AddPadding(
        container,
        0,
        0,
        0,
        12
    )

    Create("UIListLayout", {
        Padding =
            UDim.new(0, 6),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    }, container)

    box.Frame = frame
    box.Container = container
    box.Title = title

    table.insert(
        collection,
        box
    )

    table.insert(
        self.Groupboxes,
        box
    )

    return box
end

------------------------------------------------------------
-- LABEL
------------------------------------------------------------

function Groupbox:AddLabel(text, wrap)

    local label = Create("TextLabel", {
        Size =
            UDim2.new(
                1,
                0,
                0,
                wrap and 38 or 22
            ),

        BackgroundTransparency = 1,

        Text =
            tostring(text),

        TextColor3 =
            Library.Scheme.SubTextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 11,

        TextWrapped =
            wrap or false,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextYAlignment =
            Enum.TextYAlignment.Center
    }, self.Container)

    table.insert(
        self.Elements,
        label
    )

    return label
end

------------------------------------------------------------
-- DIVIDER
------------------------------------------------------------

function Groupbox:AddDivider()

    local divider = Create("Frame", {
        Size =
            UDim2.new(1, 0, 0, 1),

        BackgroundColor3 =
            Library.Scheme.BorderColor,

        BackgroundTransparency = 0.4,

        BorderSizePixel = 0
    }, self.Container)

    table.insert(
        self.Elements,
        divider
    )

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
        Size =
            UDim2.new(1, 0, 0, 34),

        BackgroundColor3 =
            Library.Scheme.ElementColor,

        BorderSizePixel = 0,

        Text =
            info.Text or "Button",

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamMedium),

        TextSize = 11,

        AutoButtonColor = false
    }, self.Container)

    Corner(button, 8)

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
            info.Callback
            or info.Func

        if callback then
            callback()
        end

    end)

    table.insert(
        self.Elements,
        button
    )

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

        Value =
            info.Default == true,

        Callback =
            info.Callback
            or function() end,

        Changed =
            info.Changed
            or function() end

    }, Toggle)

    local holder = Create("Frame", {
        Size =
            UDim2.new(1, 0, 0, 34),

        BackgroundTransparency = 1
    }, self.Container)

    local label = Create("TextLabel", {
        Size =
            UDim2.new(1, -55, 1, 0),

        BackgroundTransparency = 1,

        Text =
            info.Text or name,

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, holder)

    local switch = Create("TextButton", {
        AnchorPoint =
            Vector2.new(1, 0.5),

        Position =
            UDim2.new(1, 0, 0.5, 0),

        Size =
            UDim2.fromOffset(38, 20),

        BackgroundColor3 =
            Color3.fromRGB(48, 49, 57),

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false
    }, holder)

    Corner(switch, 10)

    local knob = Create("Frame", {
        AnchorPoint =
            Vector2.new(0, 0.5),

        Position =
            UDim2.new(0, 3, 0.5, 0),

        Size =
            UDim2.fromOffset(14, 14),

        BackgroundColor3 =
            Color3.fromRGB(185, 186, 193),

        BorderSizePixel = 0
    }, switch)

    Corner(knob, 7)

    object.Toggle = switch
    object.Knob = knob
    object.Label = label

    local function update(value, silent)

        object.Value =
            value == true

        if object.Value then

            Tween(switch, {
                BackgroundColor3 =
                    Library.Scheme.AccentColor
            })

            Tween(knob, {
                Position =
                    UDim2.new(1, -17, 0.5, 0),

                BackgroundColor3 =
                    Color3.fromRGB(
                        255,255,255
                    )
            })

        else

            Tween(switch, {
                BackgroundColor3 =
                    Color3.fromRGB(48,49,57)
            })

            Tween(knob, {
                Position =
                    UDim2.new(0, 3, 0.5, 0),

                BackgroundColor3 =
                    Color3.fromRGB(
                        185,186,193
                    )
            })

        end

        if not silent then

            object.Callback(
                object.Value
            )

            object.Changed(
                object.Value
            )

        end
    end

    function object:SetValue(value)
        update(value)
    end

    function object:GetValue()
        return object.Value
    end

    function object:OnChanged(callback)

        object.Changed =
            callback

        return object
    end

    switch.MouseButton1Click:Connect(function()

        update(
            not object.Value
        )

    end)

    update(
        object.Value,
        true
    )

    Library.Toggles[name] = object
    Library.Options[name] = object

    table.insert(
        self.Elements,
        object
    )

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
        Size =
            UDim2.new(1, 0, 0, 48),

        BackgroundTransparency = 1
    }, self.Container)

    local title = Create("TextLabel", {
        Size =
            UDim2.new(1, -65, 0, 19),

        BackgroundTransparency = 1,

        Text =
            info.Text or name,

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, holder)

    local valueText = Create("TextLabel", {
        AnchorPoint =
            Vector2.new(1, 0),

        Position =
            UDim2.new(1, 0, 0, 0),

        Size =
            UDim2.fromOffset(65, 19),

        BackgroundTransparency = 1,

        TextColor3 =
            Library.Scheme.SubTextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamMedium),

        TextSize = 10,

        TextXAlignment =
            Enum.TextXAlignment.Right
    }, holder)

    local bar = Create("Frame", {
        Position =
            UDim2.fromOffset(0, 30),

        Size =
            UDim2.new(1, 0, 0, 5),

        BackgroundColor3 =
            Color3.fromRGB(48,49,57),

        BorderSizePixel = 0
    }, holder)

    Corner(bar, 3)

    local fill = Create("Frame", {
        Size =
            UDim2.fromScale(0, 1),

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

    local function setValue(
        value,
        silent
    )

        value =
            math.clamp(
                tonumber(value) or min,
                min,
                max
            )

        object.Value = value

        local alpha

        if max == min then
            alpha = 0
        else
            alpha =
                (value - min) /
                (max - min)
        end

        fill.Size =
            UDim2.fromScale(
                alpha,
                1
            )

        knob.Position =
            UDim2.fromScale(
                alpha,
                0.5
            )

        valueText.Text =
            tostring(
                info.Prefix or ""
            )
            ..
            tostring(value)
            ..
            tostring(
                info.Suffix or ""
            )

        if not silent then

            object.Callback(value)
            object.Changed(value)

        end
    end

    local dragging = false

    local function updateFromInput(input)

        local position =
            input.Position.X -
            bar.AbsolutePosition.X

        local percent =
            math.clamp(
                position /
                    bar.AbsoluteSize.X,
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

            updateFromInput(input)

        end
    end)

    UserInputService.InputChanged:Connect(function(input)

        if dragging and
            input.UserInputType ==
            Enum.UserInputType.MouseMovement then

            updateFromInput(input)

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

        object.Changed =
            callback

        return object
    end

    setValue(
        default,
        true
    )

    Library.Options[name] = object

    table.insert(
        self.Elements,
        object
    )

    return object
end

------------------------------------------------------------
-- INPUT
------------------------------------------------------------

function Groupbox:AddInput(name, info)

    info = info or {}

    local holder = Create("Frame", {
        Size =
            UDim2.new(1, 0, 0, 62),

        BackgroundTransparency = 1
    }, self.Container)

    Create("TextLabel", {
        Size =
            UDim2.new(1, 0, 0, 19),

        BackgroundTransparency = 1,

        Text =
            info.Text or name,

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, holder)

    local input = Create("TextBox", {
        Position =
            UDim2.fromOffset(0, 25),

        Size =
            UDim2.new(1, 0, 0, 32),

        BackgroundColor3 =
            Library.Scheme.ElementColor,

        BorderSizePixel = 0,

        Text =
            tostring(
                info.Default or ""
            ),

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
            info.ClearTextOnFocus ~= false,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, holder)

    Corner(input, 8)

    AddPadding(
        input,
        9,
        9,
        0,
        0
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

        object.Changed =
            callback

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

    table.insert(
        self.Elements,
        object
    )

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
        Size =
            UDim2.new(1, 0, 0, 38),

        BackgroundTransparency = 1
    }, self.Container)

    local label = Create("TextLabel", {
        Size =
            UDim2.new(0.37, 0, 1, 0),

        BackgroundTransparency = 1,

        Text =
            info.Text or name,

        TextColor3 =
            Library.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, holder)

    local select = Create("TextButton", {
        AnchorPoint =
            Vector2.new(1, 0.5),

        Position =
            UDim2.new(1, 0, 0.5, 0),

        Size =
            UDim2.new(0.63, 0, 0, 32),

        BackgroundColor3 =
            Library.Scheme.ElementColor,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        ZIndex = 10
    }, holder)

    Corner(select, 8)

    local selected = Create("TextLabel", {
        Position =
            UDim2.fromOffset(9, 0),

        Size =
            UDim2.new(1, -30, 1, 0),

        BackgroundTransparency = 1,

        Text =
            tostring(
                object.Value
                or "Select"
            ),

        TextColor3 =
            Library.Scheme.SubTextColor,

        FontFace =
            Font.fromEnum(Enum.Font.Gotham),

        TextSize = 10,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        ZIndex = 11
    }, select)

    Create("TextLabel", {
        AnchorPoint =
            Vector2.new(1, 0.5),

        Position =
            UDim2.new(1, -8, 0.5, 0),

        Size =
            UDim2.fromOffset(12, 14),

        BackgroundTransparency = 1,

        Text = "⌄",

        TextColor3 =
            Library.Scheme.SubTextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamBold),

        TextSize = 12,

        ZIndex = 11
    }, select)

    local list = Create("Frame", {
        Position =
            UDim2.new(0, 0, 1, 4),

        Size =
            UDim2.new(1, 0, 0, 0),

        BackgroundColor3 =
            Library.Scheme.CardColor,

        BorderSizePixel = 0,

        Visible = false,

        ZIndex = 100
    }, select)

    Corner(list, 8)

    AddStroke(
        list,
        Library.Scheme.BorderColor,
        0.15
    )

    AddPadding(
        list,
        4,
        4,
        4,
        4
    )

    Create("UIListLayout", {
        Padding =
            UDim.new(0, 2),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    }, list)

    local opened = false

    local function refresh()

        for _, child in ipairs(
            list:GetChildren()
        ) do

            if child:IsA("TextButton") then
                child:Destroy()
            end

        end

        for index, value in ipairs(values) do

            local option = Create("TextButton", {
                Size =
                    UDim2.new(1, 0, 0, 28),

                BackgroundTransparency = 1,

                Text =
                    tostring(value),

                TextColor3 =
                    Library.Scheme.TextColor,

                FontFace =
                    Font.fromEnum(Enum.Font.Gotham),

                TextSize = 10,

                AutoButtonColor = false,

                ZIndex = 101,

                LayoutOrder = index
            }, list)

            Corner(option, 6)

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
                    #values * 30 + 8,
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

        object.Values =
            values

        refresh()
    end

    function object:OnChanged(callback)

        object.Changed =
            callback

        return object
    end

    select.MouseButton1Click:Connect(function()

        opened =
            not opened

        list.Visible =
            opened

        if opened then
            refresh()
        end

    end)

    Library.Options[name] = object

    table.insert(
        self.Elements,
        object
    )

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

    local notification = Create("Frame", {
        AnchorPoint =
            Vector2.new(1, 1),

        Position =
            UDim2.new(1, 320, 1, -20),

        Size =
            UDim2.fromOffset(300, 72),

        BackgroundColor3 =
            self.Scheme.CardColor,

        BorderSizePixel = 0
    }, self.ScreenGui)

    Corner(notification, 10)

    AddStroke(
        notification,
        self.Scheme.BorderColor,
        0.2
    )

    local accent = Create("Frame", {
        Position =
            UDim2.fromOffset(0, 13),

        Size =
            UDim2.fromOffset(3, 46),

        BackgroundColor3 =
            self.Scheme.AccentColor,

        BorderSizePixel = 0
    }, notification)

    Corner(accent, 2)

    Create("TextLabel", {
        Position =
            UDim2.fromOffset(14, 9),

        Size =
            UDim2.new(1, -25, 0, 19),

        BackgroundTransparency = 1,

        Text =
            info.Title
            or "Notification",

        TextColor3 =
            self.Scheme.TextColor,

        FontFace =
            Font.fromEnum(Enum.Font.GothamSemibold),

        TextSize = 11,

        TextXAlignment =
            Enum.TextXAlignment.Left
    }, notification)

    Create("TextLabel", {
        Position =
            UDim2.fromOffset(14, 30),

        Size =
            UDim2.new(1, -25, 0, 30),

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
    }, notification)

    Tween(notification, {
        Position =
            UDim2.new(1, -20, 1, -20)
    })

    task.delay(
        info.Time or 3,
        function()

            if notification.Parent then

                Tween(notification, {
                    Position =
                        UDim2.new(
                            1,
                            320,
                            1,
                            -20
                        )
                })

                task.wait(0.18)

                if notification then
                    notification:Destroy()
                end

            end
        end
    )

    return notification
end

------------------------------------------------------------
-- UI TOGGLE
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
-- THEME
------------------------------------------------------------

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
    self.ActiveTab = nil

    self.Options = {}
    self.Toggles = {}
    self.Tabs = {}
    self.TabButtons = {}
end

return Library
