--[[
    KamUI
    Modern Roblox UI Library

    API STYLE:
        Obsidian inspired

    UI:
        Custom
        Rounded
        Dark
        Modern
        Search
        Left / Right Groupboxes
        Draggable

    Supported:
        CreateWindow
        AddTab
        AddLeftGroupbox
        AddRightGroupbox

        AddToggle
        AddKeyPicker
        AddSlider
        AddDropdown
        AddInput
        AddButton
        AddLabel
        AddDivider

        Options
        Toggles
        Registry
        Scheme
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

------------------------------------------------------------
-- LIBRARY
------------------------------------------------------------

local Library = {
    Version = "1.0.0",

    Options = {},
    Toggles = {},
    Registry = {},

    Tabs = {},

    Theme = {
        Background = Color3.fromRGB(8, 8, 10),
        Sidebar = Color3.fromRGB(11, 11, 14),
        Groupbox = Color3.fromRGB(14, 14, 18),
        Element = Color3.fromRGB(20, 20, 25),
        ElementHover = Color3.fromRGB(27, 27, 33),

        Outline = Color3.fromRGB(38, 38, 45),

        Accent = Color3.fromRGB(135, 95, 255),

        Text = Color3.fromRGB(245, 245, 248),
        SecondaryText = Color3.fromRGB(178, 178, 188),
        MutedText = Color3.fromRGB(125, 125, 136),

        White = Color3.fromRGB(255, 255, 255),

        ToggleOff = Color3.fromRGB(50, 50, 58)
    },

    Scheme = {},

    Tween = TweenInfo.new(
        0.16,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    ScreenGui = nil,
    Window = nil,

    ActiveTab = nil,

    Unloaded = false
}

Library.Scheme = Library.Theme

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

local function Corner(object, radius)

    local corner = Instance.new("UICorner")

    corner.CornerRadius = UDim.new(
        0,
        radius
    )

    corner.Parent = object

    return corner
end

local function Stroke(
    object,
    color,
    transparency
)

    local stroke = Instance.new("UIStroke")

    stroke.Color =
        color or Library.Theme.Outline

    stroke.Transparency =
        transparency or 0

    stroke.Thickness = 1

    stroke.Parent = object

    return stroke
end

local function Tween(
    object,
    properties,
    info
)

    if not object
        or not object.Parent then
        return
    end

    return TweenService:Create(
        object,
        info or Library.Tween,
        properties
    ):Play()
end

local function Padding(
    object,
    left,
    right,
    top,
    bottom
)

    local padding =
        Instance.new("UIPadding")

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

local function GetGuiParent()

    local success, result =
        pcall(function()
            return gethui()
        end)

    if success and result then
        return result
    end

    return game:GetService("CoreGui")
end

------------------------------------------------------------
-- FONT
------------------------------------------------------------

local function Text(
    parent,
    properties
)

    properties = properties or {}

    properties.Font =
        properties.Font
        or Enum.Font.GothamMedium

    properties.TextSize =
        properties.TextSize
        or 12

    properties.TextColor3 =
        properties.TextColor3
        or Library.Theme.Text

    properties.BackgroundTransparency =
        1

    return Create(
        "TextLabel",
        properties,
        parent
    )
end

------------------------------------------------------------
-- CREATE WINDOW
------------------------------------------------------------

function Library:CreateWindow(config)

    config = config or {}

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end

    self.Options = {}
    self.Toggles = {}
    self.Registry = {}
    self.Tabs = {}

    self.Unloaded = false

    --------------------------------------------------------
    -- SCREEN GUI
    --------------------------------------------------------

    local ScreenGui =
        Create(
            "ScreenGui",
            {
                Name = "KamUI",

                ResetOnSpawn = false,

                IgnoreGuiInset = true,

                ZIndexBehavior =
                    Enum.ZIndexBehavior.Sibling
            },
            GetGuiParent()
        )

    self.ScreenGui =
        ScreenGui

    --------------------------------------------------------
    -- MAIN WINDOW
    --------------------------------------------------------

    local Window =
        Create(
            "Frame",
            {
                Name = "Window",

                AnchorPoint =
                    Vector2.new(
                        0.5,
                        0.5
                    ),

                Position =
                    UDim2.fromScale(
                        0.5,
                        0.5
                    ),

                Size =
                    config.Size
                    or UDim2.fromOffset(
                        980,
                        620
                    ),

                BackgroundColor3 =
                    self.Theme.Background,

                BorderSizePixel = 0
            },
            ScreenGui
        )

    Corner(Window, 16)

    Stroke(
        Window,
        self.Theme.Outline,
        0.1
    )

    self.Window = Window

    --------------------------------------------------------
    -- HEADER
    --------------------------------------------------------

    local Header =
        Create(
            "Frame",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        64
                    ),

                BackgroundTransparency = 1
            },
            Window
        )

    --------------------------------------------------------
    -- TITLE
    --------------------------------------------------------

    Text(
        Header,
        {
            Position =
                UDim2.fromOffset(
                    22,
                    12
                ),

            Size =
                UDim2.new(
                    1,
                    -160,
                    0,
                    23
                ),

            Text =
                config.Title
                or "KamUI",

            Font =
                Enum.Font.GothamBold,

            TextSize = 16,

            TextXAlignment =
                Enum.TextXAlignment.Left
        }
    )

    Text(
        Header,
        {
            Position =
                UDim2.fromOffset(
                    23,
                    35
                ),

            Size =
                UDim2.new(
                    1,
                    -160,
                    0,
                    17
                ),

            Text =
                config.Subtitle
                or "Modern Interface",

            TextColor3 =
                self.Theme.MutedText,

            Font =
                Enum.Font.Gotham,

            TextSize = 11,

            TextXAlignment =
                Enum.TextXAlignment.Left
        }
    )

    --------------------------------------------------------
    -- CLOSE
    --------------------------------------------------------

    local Close =
        Create(
            "TextButton",
            {
                AnchorPoint =
                    Vector2.new(
                        1,
                        0.5
                    ),

                Position =
                    UDim2.new(
                        1,
                        -18,
                        0.5,
                        0
                    ),

                Size =
                    UDim2.fromOffset(
                        34,
                        34
                    ),

                BackgroundColor3 =
                    self.Theme.Element,

                BorderSizePixel = 0,

                Text = "×",

                TextColor3 =
                    self.Theme.SecondaryText,

                Font =
                    Enum.Font.GothamMedium,

                TextSize = 20,

                AutoButtonColor = false
            },
            Header
        )

    Corner(Close, 10)

    Close.MouseEnter:Connect(
        function()

            Tween(
                Close,
                {
                    BackgroundColor3 =
                        Color3.fromRGB(
                            60,
                            28,
                            35
                        ),

                    TextColor3 =
                        Color3.fromRGB(
                            255,
                            100,
                            110
                        )
                }
            )

        end
    )

    Close.MouseLeave:Connect(
        function()

            Tween(
                Close,
                {
                    BackgroundColor3 =
                        self.Theme.Element,

                    TextColor3 =
                        self.Theme.SecondaryText
                }
            )

        end
    )

    Close.MouseButton1Click:Connect(
        function()
            self:Unload()
        end
    )

    --------------------------------------------------------
    -- DRAGGING
    --------------------------------------------------------

    local dragging = false
    local dragStart
    local startPosition

    Header.InputBegan:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                dragging = true

                dragStart =
                    input.Position

                startPosition =
                    Window.Position

            end

        end
    )

    UserInputService.InputChanged:Connect(
        function(input)

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

            Window.Position =
                UDim2.new(
                    startPosition.X.Scale,
                    startPosition.X.Offset +
                        delta.X,

                    startPosition.Y.Scale,
                    startPosition.Y.Offset +
                        delta.Y
                )

        end
    )

    UserInputService.InputEnded:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                dragging = false

            end

        end
    )

    --------------------------------------------------------
    -- BODY
    --------------------------------------------------------

    local Body =
        Create(
            "Frame",
            {
                Position =
                    UDim2.fromOffset(
                        12,
                        64
                    ),

                Size =
                    UDim2.new(
                        1,
                        -24,
                        1,
                        -76
                    ),

                BackgroundTransparency = 1
            },
            Window
        )

    --------------------------------------------------------
    -- SIDEBAR
    --------------------------------------------------------

    local Sidebar =
        Create(
            "Frame",
            {
                Size =
                    UDim2.new(
                        0,
                        175,
                        1,
                        0
                    ),

                BackgroundColor3 =
                    self.Theme.Sidebar,

                BorderSizePixel = 0
            },
            Body
        )

    Corner(Sidebar, 12)

    Stroke(
        Sidebar,
        self.Theme.Outline,
        0.35
    )

    Padding(
        Sidebar,
        8,
        8,
        8,
        8
    )

    --------------------------------------------------------
    -- SEARCH
    --------------------------------------------------------

    local Search =
        Create(
            "TextBox",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        38
                    ),

                BackgroundColor3 =
                    self.Theme.Element,

                BorderSizePixel = 0,

                PlaceholderText =
                    "Search...",

                PlaceholderColor3 =
                    self.Theme.MutedText,

                Text = "",

                TextColor3 =
                    self.Theme.Text,

                Font =
                    Enum.Font.Gotham,

                TextSize = 12,

                ClearTextOnFocus = false
            },
            Sidebar
        )

    Corner(Search, 10)

    Stroke(
        Search,
        self.Theme.Outline,
        0.5
    )

    Padding(
        Search,
        12,
        10,
        0,
        0
    )

    --------------------------------------------------------
    -- TAB HOLDER
    --------------------------------------------------------

    local TabHolder =
        Create(
            "ScrollingFrame",
            {
                Position =
                    UDim2.fromOffset(
                        0,
                        47
                    ),

                Size =
                    UDim2.new(
                        1,
                        0,
                        1,
                        -47
                    ),

                BackgroundTransparency = 1,

                BorderSizePixel = 0,

                ScrollBarThickness = 2,

                ScrollBarImageColor3 =
                    self.Theme.Accent,

                CanvasSize =
                    UDim2.new(
                        0,
                        0,
                        0,
                        0
                    ),

                AutomaticCanvasSize =
                    Enum.AutomaticSize.Y
            },
            Sidebar
        )

    Padding(
        TabHolder,
        0,
        0,
        3,
        5
    )

    Create(
        "UIListLayout",
        {
            Padding =
                UDim.new(
                    0,
                    4
                ),

            SortOrder =
                Enum.SortOrder.LayoutOrder
        },
        TabHolder
    )

    self.Navigation = TabHolder

    --------------------------------------------------------
    -- CONTENT
    --------------------------------------------------------

    local Content =
        Create(
            "Frame",
            {
                Position =
                    UDim2.fromOffset(
                        187,
                        0
                    ),

                Size =
                    UDim2.new(
                        1,
                        -187,
                        1,
                        0
                    ),

                BackgroundTransparency = 1
            },
            Body
        )

    self.Content = Content

    --------------------------------------------------------
    -- SEARCH FUNCTION
    --------------------------------------------------------

    Search:GetPropertyChangedSignal(
        "Text"
    ):Connect(
        function()

            local query =
                string.lower(
                    Search.Text
                )

            for _, tab in pairs(
                self.Tabs
            ) do

                local visible =
                    query == ""

                if not visible then

                    visible =
                        string.find(
                            string.lower(
                                tab.Name
                            ),
                            query,
                            1,
                            true
                        ) ~= nil

                    if not visible then

                        for _, group in ipairs(
                            tab.Groupboxes
                        ) do

                            if string.find(
                                string.lower(
                                    group.Name
                                ),
                                query,
                                1,
                                true
                            ) then

                                visible = true

                                break

                            end

                        end

                    end

                end

                tab.Button.Visible =
                    visible

            end

        end
    )

    return self
end

------------------------------------------------------------
-- TAB
------------------------------------------------------------

local Tab = {}
Tab.__index = Tab

function Library:AddTab(name, icon)

    local tab =
        setmetatable(
            {
                Name = name,

                Icon = icon,

                Groupboxes = {},

                LeftGroupboxes = {},

                RightGroupboxes = {}
            },
            Tab
        )

    --------------------------------------------------------
    -- BUTTON
    --------------------------------------------------------

    local Button =
        Create(
            "TextButton",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        40
                    ),

                BackgroundTransparency = 1,

                BorderSizePixel = 0,

                Text = "",

                AutoButtonColor = false
            },
            self.Navigation
        )

    Corner(Button, 9)

    local Indicator =
        Create(
            "Frame",
            {
                Position =
                    UDim2.fromOffset(
                        4,
                        9
                    ),

                Size =
                    UDim2.fromOffset(
                        3,
                        22
                    ),

                BackgroundColor3 =
                    self.Theme.Accent,

                BackgroundTransparency = 1,

                BorderSizePixel = 0
            },
            Button
        )

    Corner(Indicator, 3)

    local Icon =
        Text(
            Button,
            {
                Position =
                    UDim2.fromOffset(
                        14,
                        0
                    ),

                Size =
                    UDim2.fromOffset(
                        22,
                        40
                    ),

                Text =
                    icon or "•",

                TextColor3 =
                    self.Theme.MutedText,

                TextSize = 13,

                Font =
                    Enum.Font.GothamMedium,

                TextXAlignment =
                    Enum.TextXAlignment.Center,

                TextYAlignment =
                    Enum.TextYAlignment.Center
            }
        )

    local Label =
        Text(
            Button,
            {
                Position =
                    UDim2.fromOffset(
                        44,
                        0
                    ),

                Size =
                    UDim2.new(
                        1,
                        -50,
                        1,
                        0
                    ),

                Text = name,

                TextColor3 =
                    self.Theme.SecondaryText,

                TextSize = 12,

                Font =
                    Enum.Font.GothamMedium,

                TextXAlignment =
                    Enum.TextXAlignment.Left,

                TextYAlignment =
                    Enum.TextYAlignment.Center
            }
        )

    --------------------------------------------------------
    -- PAGE
    --------------------------------------------------------

    local Page =
        Create(
            "ScrollingFrame",
            {
                Size =
                    UDim2.fromScale(
                        1,
                        1
                    ),

                BackgroundTransparency = 1,

                BorderSizePixel = 0,

                Visible = false,

                ScrollBarThickness = 3,

                ScrollBarImageColor3 =
                    self.Theme.Accent,

                AutomaticCanvasSize =
                    Enum.AutomaticSize.Y,

                CanvasSize =
                    UDim2.new()
            },
            self.Content
        )

    Padding(
        Page,
        7,
        7,
        5,
        12
    )

    --------------------------------------------------------
    -- TWO COLUMNS
    --------------------------------------------------------

    local Columns =
        Create(
            "Frame",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        0
                    ),

                AutomaticSize =
                    Enum.AutomaticSize.Y,

                BackgroundTransparency = 1
            },
            Page
        )

    local Left =
        Create(
            "Frame",
            {
                Size =
                    UDim2.new(
                        0.5,
                        -6,
                        0,
                        0
                    ),

                AutomaticSize =
                    Enum.AutomaticSize.Y,

                BackgroundTransparency = 1
            },
            Columns
        )

    Create(
        "UIListLayout",
        {
            Padding =
                UDim.new(
                    0,
                    9
                )
        },
        Left
    )

    local Right =
        Create(
            "Frame",
            {
                Position =
                    UDim2.new(
                        0.5,
                        6,
                        0,
                        0
                    ),

                Size =
                    UDim2.new(
                        0.5,
                        -6,
                        0,
                        0
                    ),

                AutomaticSize =
                    Enum.AutomaticSize.Y,

                BackgroundTransparency = 1
            },
            Columns
        )

    Create(
        "UIListLayout",
        {
            Padding =
                UDim.new(
                    0,
                    9
                )
        },
        Right
    )

    tab.Button = Button
    tab.Page = Page

    tab.Left = Left
    tab.Right = Right

    tab.Indicator = Indicator
    tab.Label = Label
    tab.IconObject = Icon

    self.Tabs[name] = tab

    --------------------------------------------------------
    -- HOVER
    --------------------------------------------------------

    Button.MouseEnter:Connect(
        function()

            if self.ActiveTab ~= tab then

                Tween(
                    Button,
                    {
                        BackgroundColor3 =
                            self.Theme.Element,

                        BackgroundTransparency =
                            0.25
                    }
                )

                Tween(
                    Label,
                    {
                        TextColor3 =
                            self.Theme.Text
                    }
                )

            end

        end
    )

    Button.MouseLeave:Connect(
        function()

            if self.ActiveTab ~= tab then

                Tween(
                    Button,
                    {
                        BackgroundTransparency =
                            1
                    }
                )

                Tween(
                    Label,
                    {
                        TextColor3 =
                            self.Theme.SecondaryText
                    }
                )

            end

        end
    )

    Button.MouseButton1Click:Connect(
        function()

            self:SelectTab(tab)

        end
    )

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
        tab =
            self.Tabs[tab]
    end

    if not tab then
        return
    end

    self.ActiveTab = tab

    for _, current in pairs(
        self.Tabs
    ) do

        local active =
            current == tab

        current.Page.Visible =
            active

        if active then

            Tween(
                current.Button,
                {
                    BackgroundColor3 =
                        self.Theme.Element,

                    BackgroundTransparency =
                        0
                }
            )

            Tween(
                current.Indicator,
                {
                    BackgroundTransparency =
                        0
                }
            )

            Tween(
                current.Label,
                {
                    TextColor3 =
                        self.Theme.Text
                }
            )

            Tween(
                current.IconObject,
                {
                    TextColor3 =
                        self.Theme.Accent
                }
            )

        else

            Tween(
                current.Button,
                {
                    BackgroundTransparency =
                        1
                }
            )

            Tween(
                current.Indicator,
                {
                    BackgroundTransparency =
                        1
                }
            )

            Tween(
                current.Label,
                {
                    TextColor3 =
                        self.Theme.SecondaryText
                }
            )

            Tween(
                current.IconObject,
                {
                    TextColor3 =
                        self.Theme.MutedText
                }
            )

        end

    end
end

------------------------------------------------------------
-- GROUPBOX
------------------------------------------------------------

local Groupbox = {}
Groupbox.__index = Groupbox

function Tab:_CreateGroupbox(
    name,
    parent,
    collection
)

    local group =
        setmetatable(
            {
                Name = name,

                Elements = {}
            },
            Groupbox
        )

    local Frame =
        Create(
            "Frame",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        0
                    ),

                AutomaticSize =
                    Enum.AutomaticSize.Y,

                BackgroundColor3 =
                    self.Library.Theme.Groupbox,

                BorderSizePixel = 0
            },
            parent
        )

    Corner(Frame, 12)

    Stroke(
        Frame,
        self.Library.Theme.Outline,
        0.25
    )

    --------------------------------------------------------
    -- HEADER
    --------------------------------------------------------

    local Header =
        Create(
            "Frame",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        44
                    ),

                BackgroundTransparency = 1
            },
            Frame
        )

    Text(
        Header,
        {
            Position =
                UDim2.fromOffset(
                    14,
                    0
                ),

            Size =
                UDim2.new(
                    1,
                    -28,
                    1,
                    0
                ),

            Text = name,

            Font =
                Enum.Font.GothamBold,

            TextSize = 13,

            TextColor3 =
                self.Library.Theme.Text,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            TextYAlignment =
                Enum.TextYAlignment.Center
        }
    )

    --------------------------------------------------------
    -- CONTENT
    --------------------------------------------------------

    local Container =
        Create(
            "Frame",
            {
                Position =
                    UDim2.fromOffset(
                        13,
                        42
                    ),

                Size =
                    UDim2.new(
                        1,
                        -26,
                        0,
                        0
                    ),

                AutomaticSize =
                    Enum.AutomaticSize.Y,

                BackgroundTransparency = 1
            },
            Frame
        )

    Padding(
        Container,
        0,
        0,
        0,
        13
    )

    Create(
        "UIListLayout",
        {
            Padding =
                UDim.new(
                    0,
                    7
                ),

            SortOrder =
                Enum.SortOrder.LayoutOrder
        },
        Container
    )

    group.Frame = Frame
    group.Container = Container
    group.Library = self.Library

    table.insert(
        collection,
        group
    )

    return group
end

function Tab:AddLeftGroupbox(
    name,
    icon
)

    return self:_CreateGroupbox(
        name,
        self.Left,
        self.LeftGroupboxes
    )
end

function Tab:AddRightGroupbox(
    name,
    icon
)

    return self:_CreateGroupbox(
        name,
        self.Right,
        self.RightGroupboxes
    )
end

------------------------------------------------------------
-- LABEL
------------------------------------------------------------

function Groupbox:AddLabel(
    text,
    wrap
)

    local label =
        Text(
            self.Container,
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        wrap
                            and 42
                            or 24
                    ),

                Text =
                    tostring(text),

                TextColor3 =
                    self.Library.Theme.SecondaryText,

                TextSize = 12,

                TextWrapped =
                    wrap == true,

                TextXAlignment =
                    Enum.TextXAlignment.Left,

                TextYAlignment =
                    Enum.TextYAlignment.Center
            }
        )

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

    local divider =
        Create(
            "Frame",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        1
                    ),

                BackgroundColor3 =
                    self.Library.Theme.Outline,

                BackgroundTransparency =
                    0.25,

                BorderSizePixel = 0
            },
            self.Container
        )

    return divider
end

------------------------------------------------------------
-- BUTTON
------------------------------------------------------------

function Groupbox:AddButton(
    data
)

    if type(data) == "string" then

        data = {
            Text = data
        }

    end

    data = data or {}

    local button =
        Create(
            "TextButton",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        38
                    ),

                BackgroundColor3 =
                    self.Library.Theme.Element,

                BorderSizePixel = 0,

                Text =
                    data.Text
                    or "Button",

                TextColor3 =
                    self.Library.Theme.Text,

                Font =
                    Enum.Font.GothamMedium,

                TextSize = 12,

                AutoButtonColor = false
            },
            self.Container
        )

    Corner(button, 9)

    Stroke(
        button,
        self.Library.Theme.Outline,
        0.35
    )

    button.MouseEnter:Connect(
        function()

            Tween(
                button,
                {
                    BackgroundColor3 =
                        self.Library.Theme.ElementHover
                }
            )

        end
    )

    button.MouseLeave:Connect(
        function()

            Tween(
                button,
                {
                    BackgroundColor3 =
                        self.Library.Theme.Element
                }
            )

        end
    )

    button.MouseButton1Click:Connect(
        function()

            local callback =
                data.Callback
                or data.Func

            if callback then
                callback()
            end

        end
    )

    return button
end

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------

local Toggle = {}
Toggle.__index = Toggle

function Groupbox:AddToggle(
    name,
    info
)

    info = info or {}

    local toggle =
        setmetatable(
            {
                Name = name,

                Value =
                    info.Default == true,

                Callback =
                    info.Callback
                    or function()
                    end,

                Changed =
                    info.Changed
                    or function()
                    end
            },
            Toggle
        )

    local Holder =
        Create(
            "Frame",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        38
                    ),

                BackgroundTransparency = 1
            },
            self.Container
        )

    Text(
        Holder,
        {
            Size =
                UDim2.new(
                    1,
                    -65,
                    1,
                    0
                ),

            Text =
                info.Text
                or info.Title
                or name,

            TextSize = 12,

            TextColor3 =
                self.Library.Theme.Text,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            TextYAlignment =
                Enum.TextYAlignment.Center
        }
    )

    local Switch =
        Create(
            "TextButton",
            {
                AnchorPoint =
                    Vector2.new(
                        1,
                        0.5
                    ),

                Position =
                    UDim2.new(
                        1,
                        0,
                        0.5,
                        0
                    ),

                Size =
                    UDim2.fromOffset(
                        42,
                        22
                    ),

                BackgroundColor3 =
                    self.Library.Theme.ToggleOff,

                BorderSizePixel = 0,

                Text = "",

                AutoButtonColor = false
            },
            Holder
        )

    Corner(Switch, 11)

    local Knob =
        Create(
            "Frame",
            {
                AnchorPoint =
                    Vector2.new(
                        0,
                        0.5
                    ),

                Position =
                    UDim2.new(
                        0,
                        3,
                        0.5,
                        0
                    ),

                Size =
                    UDim2.fromOffset(
                        16,
                        16
                    ),

                BackgroundColor3 =
                    Color3.fromRGB(
                        190,
                        190,
                        198
                    ),

                BorderSizePixel = 0
            },
            Switch
        )

    Corner(Knob, 8)

    local function Update(
        value,
        silent
    )

        toggle.Value =
            value == true

        if toggle.Value then

            Tween(
                Switch,
                {
                    BackgroundColor3 =
                        self.Library.Theme.Accent
                }
            )

            Tween(
                Knob,
                {
                    Position =
                        UDim2.new(
                            1,
                            -19,
                            0.5,
                            0
                        ),

                    BackgroundColor3 =
                        self.Library.Theme.White
                }
            )

        else

            Tween(
                Switch,
                {
                    BackgroundColor3 =
                        self.Library.Theme.ToggleOff
                }
            )

            Tween(
                Knob,
                {
                    Position =
                        UDim2.new(
                            0,
                            3,
                            0.5,
                            0
                        ),

                    BackgroundColor3 =
                        Color3.fromRGB(
                            190,
                            190,
                            198
                        )
                }
            )

        end

        if not silent then

            toggle.Callback(
                toggle.Value
            )

            toggle.Changed(
                toggle.Value
            )

        end

    end

    function toggle:SetValue(
        value
    )

        Update(value)

    end

    function toggle:GetValue()

        return toggle.Value

    end

    function toggle:OnChanged(
        callback
    )

        toggle.Changed =
            callback

        return toggle
    end

    Switch.MouseButton1Click:Connect(
        function()

            Update(
                not toggle.Value
            )

        end
    )

    Update(
        toggle.Value,
        true
    )

    Library.Toggles[name] =
        toggle

    Library.Options[name] =
        toggle

    return toggle
end

------------------------------------------------------------
-- KEY PICKER
------------------------------------------------------------

local KeyPicker = {}
KeyPicker.__index = KeyPicker

function Toggle:AddKeyPicker(
    name,
    info
)

    info = info or {}

    local picker =
        setmetatable(
            {
                Name = name,

                Value =
                    info.Default
                    or info.Keybind
                    or Enum.KeyCode.Unknown,

                Mode =
                    info.Mode
                    or "Toggle",

                Callback =
                    info.Callback
                    or function()
                    end,

                Changed =
                    info.Changed
                    or function()
                    end
            },
            KeyPicker
        )

    picker:SetKey =
        function(self, key)
            self.Value = key

            self.Changed(key)
        end

    picker:GetKey =
        function(self)
            return self.Value
        end

    Library.Options[name] =
        picker

    return picker
end

------------------------------------------------------------
-- SLIDER
------------------------------------------------------------

local Slider = {}
Slider.__index = Slider

function Groupbox:AddSlider(
    name,
    info
)

    info = info or {}

    local min =
        tonumber(info.Min)
        or 0

    local max =
        tonumber(info.Max)
        or 100

    local decimals =
        tonumber(info.Rounding)

    if decimals == nil then
        decimals = 0
    end

    local default =
        tonumber(info.Default)
        or min

    local slider =
        setmetatable(
            {
                Name = name,

                Min = min,

                Max = max,

                Value = default,

                Rounding = decimals,

                Callback =
                    info.Callback
                    or function()
                    end,

                Changed =
                    info.Changed
                    or function()
                    end
            },
            Slider
        )

    local Holder =
        Create(
            "Frame",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        62
                    ),

                BackgroundTransparency = 1
            },
            self.Container
        )

    Text(
        Holder,
        {
            Size =
                UDim2.new(
                    1,
                    -90,
                    0,
                    22
                ),

            Text =
                info.Text
                or info.Title
                or name,

            TextSize = 12,

            TextColor3 =
                self.Library.Theme.Text,

            TextXAlignment =
                Enum.TextXAlignment.Left
        }
    )

    local ValueLabel =
        Text(
            Holder,
            {
                AnchorPoint =
                    Vector2.new(
                        1,
                        0
                    ),

                Position =
                    UDim2.new(
                        1,
                        0,
                        0,
                        0
                    ),

                Size =
                    UDim2.fromOffset(
                        90,
                        22
                    ),

                TextColor3 =
                    self.Library.Theme.SecondaryText,

                TextSize = 11,

                Font =
                    Enum.Font.GothamMedium,

                TextXAlignment =
                    Enum.TextXAlignment.Right
            }
        )

    --------------------------------------------------------
    -- SLIDER BAR
    --------------------------------------------------------

    local Bar =
        Create(
            "Frame",
            {
                Position =
                    UDim2.fromOffset(
                        0,
                        35
                    ),

                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        6
                    ),

                BackgroundColor3 =
                    self.Library.Theme.ToggleOff,

                BorderSizePixel = 0
            },
            Holder
        )

    Corner(Bar, 4)

    local Fill =
        Create(
            "Frame",
            {
                Size =
                    UDim2.fromScale(
                        0,
                        1
                    ),

                BackgroundColor3 =
                    self.Library.Theme.Accent,

                BorderSizePixel = 0
            },
            Bar
        )

    Corner(Fill, 4)

    local Knob =
        Create(
            "Frame",
            {
                AnchorPoint =
                    Vector2.new(
                        0.5,
                        0.5
                    ),

                Position =
                    UDim2.fromScale(
                        0,
                        0.5
                    ),

                Size =
                    UDim2.fromOffset(
                        16,
                        16
                    ),

                BackgroundColor3 =
                    self.Library.Theme.White,

                BorderSizePixel = 0
            },
            Bar
        )

    Corner(Knob, 8)

    Stroke(
        Knob,
        self.Library.Theme.Accent,
        0.1
    )

    --------------------------------------------------------
    -- ROUND
    --------------------------------------------------------

    local function RoundValue(
        value
    )

        local power =
            10 ^ decimals

        value =
            math.floor(
                value * power
                + 0.5
            ) / power

        return value
    end

    local function FormatValue(
        value
    )

        if decimals <= 0 then

            return tostring(
                math.floor(
                    value + 0.5
                )
            )

        end

        return string.format(
            "%."
                .. decimals
                .. "f",
            value
        )
    end

    local function Set(
        value,
        silent
    )

        value =
            tonumber(value)
            or min

        value =
            math.clamp(
                value,
                min,
                max
            )

        value =
            RoundValue(value)

        slider.Value =
            value

        local alpha = 0

        if max ~= min then

            alpha =
                (value - min)
                /
                (max - min)

        end

        Tween(
            Fill,
            {
                Size =
                    UDim2.fromScale(
                        alpha,
                        1
                    )
            }
        )

        Tween(
            Knob,
            {
                Position =
                    UDim2.fromScale(
                        alpha,
                        0.5
                    )
            }
        )

        ValueLabel.Text =
            tostring(
                info.Prefix
                or ""
            )
            ..
            FormatValue(value)
            ..
            tostring(
                info.Suffix
                or ""
            )

        if not silent then

            slider.Callback(
                value
            )

            slider.Changed(
                value
            )

        end
    end

    local dragging = false

    local function FromMouse(
        input
    )

        local x =
            input.Position.X

        local start =
            Bar.AbsolutePosition.X

        local width =
            Bar.AbsoluteSize.X

        if width <= 0 then
            return
        end

        local alpha =
            math.clamp(
                (x - start)
                / width,
                0,
                1
            )

        local value =
            min
            +
            (
                max - min
            )
            *
            alpha

        Set(value)

    end

    Bar.InputBegan:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                dragging = true

                FromMouse(input)

            end

        end
    )

    UserInputService.InputChanged:Connect(
        function(input)

            if dragging
                and
                input.UserInputType ==
                    Enum.UserInputType.MouseMovement then

                FromMouse(input)

            end

        end
    )

    UserInputService.InputEnded:Connect(
        function(input)

            if input.UserInputType ==
                Enum.UserInputType.MouseButton1 then

                dragging = false

            end

        end
    )

    function slider:SetValue(
        value
    )

        Set(value)

    end

    function slider:GetValue()

        return slider.Value

    end

    function slider:OnChanged(
        callback
    )

        slider.Changed =
            callback

        return slider
    end

    Set(
        default,
        true
    )

    Library.Options[name] =
        slider

    return slider
end

------------------------------------------------------------
-- INPUT
------------------------------------------------------------

function Groupbox:AddInput(
    name,
    info
)

    info = info or {}

    local Holder =
        Create(
            "Frame",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        64
                    ),

                BackgroundTransparency = 1
            },
            self.Container
        )

    Text(
        Holder,
        {
            Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    20
                ),

            Text =
                info.Text
                or name,

            TextSize = 12,

            TextXAlignment =
                Enum.TextXAlignment.Left
        }
    )

    local Input =
        Create(
            "TextBox",
            {
                Position =
                    UDim2.fromOffset(
                        0,
                        27
                    ),

                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        34
                    ),

                BackgroundColor3 =
                    self.Library.Theme.Element,

                BorderSizePixel = 0,

                Text =
                    tostring(
                        info.Default
                        or ""
                    ),

                PlaceholderText =
                    info.Placeholder
                    or "",

                PlaceholderColor3 =
                    self.Library.Theme.MutedText,

                TextColor3 =
                    self.Library.Theme.Text,

                Font =
                    Enum.Font.Gotham,

                TextSize = 12,

                TextXAlignment =
                    Enum.TextXAlignment.Left
            },
            Holder
        )

    Corner(Input, 9)

    Stroke(
        Input,
        self.Library.Theme.Outline,
        0.35
    )

    Padding(
        Input,
        10,
        10,
        0,
        0
    )

    local object = {

        Name = name,

        Input = Input,

        Value = Input.Text,

        Callback =
            info.Callback
            or function()
            end,

        Changed =
            info.Changed
            or function()
            end
    }

    function object:SetValue(
        value
    )

        Input.Text =
            tostring(value)

        object.Value =
            Input.Text

        object.Callback(
            object.Value
        )

    end

    function object:GetValue()

        return Input.Text

    end

    Input.FocusLost:Connect(
        function()

            object.Value =
                Input.Text

            object.Callback(
                object.Value
            )

            object.Changed(
                object.Value
            )

        end
    )

    Library.Options[name] =
        object

    return object
end

------------------------------------------------------------
-- DROPDOWN
------------------------------------------------------------

function Groupbox:AddDropdown(
    name,
    info
)

    info = info or {}

    local values =
        info.Values
        or {}

    local current =
        info.Default
        or values[1]

    local Holder =
        Create(
            "Frame",
            {
                Size =
                    UDim2.new(
                        1,
                        0,
                        0,
                        42
                    ),

                BackgroundTransparency = 1,

                ZIndex = 5
            },
            self.Container
        )

    Text(
        Holder,
        {
            Size =
                UDim2.new(
                    0.42,
                    0,
                    1,
                    0
                ),

            Text =
                info.Text
                or name,

            TextSize = 12,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            TextYAlignment =
                Enum.TextYAlignment.Center
        }
    )

    local Button =
        Create(
            "TextButton",
            {
                AnchorPoint =
                    Vector2.new(
                        1,
                        0.5
                    ),

                Position =
                    UDim2.new(
                        1,
                        0,
                        0.5,
                        0
                    ),

                Size =
                    UDim2.new(
                        0.58,
                        0,
                        0,
                        34
                    ),

                BackgroundColor3 =
                    self.Library.Theme.Element,

                BorderSizePixel = 0,

                Text = "",

                AutoButtonColor = false,

                ZIndex = 10
            },
            Holder
        )

    Corner(Button, 9)

    Stroke(
        Button,
        self.Library.Theme.Outline,
        0.35
    )

    local Selected =
        Text(
            Button,
            {
                Position =
                    UDim2.fromOffset(
                        10,
                        0
                    ),

                Size =
                    UDim2.new(
                        1,
                        -30,
                        1,
                        0
                    ),

                Text =
                    tostring(
                        current
                        or "Select"
                    ),

                TextSize = 11,

                TextColor3 =
                    self.Library.Theme.SecondaryText,

                TextXAlignment =
                    Enum.TextXAlignment.Left,

                TextYAlignment =
                    Enum.TextYAlignment.Center,

                ZIndex = 11
            }
        )

    local Arrow =
        Text(
            Button,
            {
                AnchorPoint =
                    Vector2.new(
                        1,
                        0.5
                    ),

                Position =
                    UDim2.new(
                        1,
                        -9,
                        0.5,
                        0
                    ),

                Size =
                    UDim2.fromOffset(
                        14,
                        18
                    ),

                Text = "⌄",

                TextSize = 13,

                TextColor3 =
                    self.Library.Theme.MutedText,

                ZIndex = 11
            }
        )

    local object = {

        Name = name,

        Values = values,

        Value = current,

        Callback =
            info.Callback
            or function()
            end,

        Changed =
            info.Changed
            or function()
            end
    }

    function object:SetValue(
        value
    )

        object.Value =
            value

        Selected.Text =
            tostring(
                value
            )

        object.Callback(
            value
        )

        object.Changed(
            value
        )

    end

    function object:GetValue()

        return object.Value

    end

    function object:SetValues(
        newValues
    )

        object.Values =
            newValues
            or {}

    end

    function object:OnChanged(
        callback
    )

        object.Changed =
            callback

        return object
    end

    Button.MouseButton1Click:Connect(
        function()

            object:SetValue(
                object.Values[
                    (
                        table.find(
                            object.Values,
                            object.Value
                        )
                        or 0
                    )
                    % #object.Values
                    + 1
                ]
            )

        end
    )

    Library.Options[name] =
        object

    return object
end

------------------------------------------------------------
-- NOTIFICATION
------------------------------------------------------------

function Library:Notify(
    data
)

    if type(data) == "string" then

        data = {
            Description = data
        }

    end

    data = data or {}

    local notification =
        Create(
            "Frame",
            {
                AnchorPoint =
                    Vector2.new(
                        1,
                        1
                    ),

                Position =
                    UDim2.new(
                        1,
                        320,
                        1,
                        -20
                    ),

                Size =
                    UDim2.fromOffset(
                        310,
                        78
                    ),

                BackgroundColor3 =
                    self.Theme.Groupbox,

                BorderSizePixel = 0,

                ZIndex = 500
            },
            self.ScreenGui
        )

    Corner(notification, 12)

    Stroke(
        notification,
        self.Theme.Outline,
        0.1
    )

    Create(
        "Frame",
        {
            Position =
                UDim2.fromOffset(
                    0,
                    14
                ),

            Size =
                UDim2.fromOffset(
                    3,
                    50
                ),

            BackgroundColor3 =
                self.Theme.Accent,

            BorderSizePixel = 0,

            ZIndex = 501
        },
        notification
    )

    Text(
        notification,
        {
            Position =
                UDim2.fromOffset(
                    15,
                    10
                ),

            Size =
                UDim2.new(
                    1,
                    -25,
                    0,
                    20
                ),

            Text =
                data.Title
                or "Notification",

            Font =
                Enum.Font.GothamBold,

            TextSize = 12,

            ZIndex = 502
        }
    )

    Text(
        notification,
        {
            Position =
                UDim2.fromOffset(
                    15,
                    33
                ),

            Size =
                UDim2.new(
                    1,
                    -25,
                    0,
                    34
                ),

            Text =
                data.Description
                or data.Content
                or "",

            TextColor3 =
                self.Theme.SecondaryText,

            Font =
                Enum.Font.Gotham,

            TextSize = 11,

            TextWrapped = true,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            TextYAlignment =
                Enum.TextYAlignment.Top,

            ZIndex = 502
        }
    )

    Tween(
        notification,
        {
            Position =
                UDim2.new(
                    1,
                    -20,
                    1,
                    -20
                )
        }
    )

    task.delay(
        data.Time
        or data.Duration
        or 3,
        function()

            if notification
                and notification.Parent then

                Tween(
                    notification,
                    {
                        Position =
                            UDim2.new(
                                1,
                                320,
                                1,
                                -20
                            )
                    }
                )

                task.wait(0.18)

                notification:Destroy()

            end

        end
    )

    return notification
end

------------------------------------------------------------
-- THEME
------------------------------------------------------------

function Library:SetAccent(
    color
)

    if typeof(color) ~=
        "Color3" then
        return
    end

    self.Theme.Accent =
        color

    self.Scheme.Accent =
        color

end

------------------------------------------------------------
-- TOGGLE UI
------------------------------------------------------------

function Library:Toggle()

    if self.Window then

        self.Window.Visible =
            not self.Window.Visible

    end

end

function Library:ToggleUI()

    self:Toggle()

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

    self.Options = {}
    self.Toggles = {}
    self.Registry = {}
    self.Tabs = {}

end

return Library
