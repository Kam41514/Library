--[[
    KamUI Library
    Modern rounded Roblox UI
    Obsidian-style API
]]

local Library = {}

Library.__VERSION = "2.0.0"

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------------
-- THEME
---------------------------------------------------------------------

Library.Theme = {
    Background = Color3.fromRGB(10, 10, 12),
    Secondary = Color3.fromRGB(14, 14, 17),
    Element = Color3.fromRGB(19, 19, 23),
    ElementHover = Color3.fromRGB(25, 25, 30),

    Sidebar = Color3.fromRGB(13, 13, 16),

    Accent = Color3.fromRGB(132, 92, 255),
    AccentDark = Color3.fromRGB(100, 65, 210),

    Text = Color3.fromRGB(245, 245, 248),
    SubText = Color3.fromRGB(175, 175, 184),
    MutedText = Color3.fromRGB(120, 120, 130),

    Outline = Color3.fromRGB(55, 55, 63),

    SliderBackground = Color3.fromRGB(31, 31, 37),

    Success = Color3.fromRGB(80, 210, 130),
    Warning = Color3.fromRGB(240, 180, 70),
    Error = Color3.fromRGB(235, 80, 90)
}

Library.Flags = {}
Library.Tabs = {}

Library._searchElements = {}

---------------------------------------------------------------------
-- UTILITIES
---------------------------------------------------------------------

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

local function Corner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = object
    return corner
end

local function Stroke(object, color, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Library.Theme.Outline
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

local function Tween(object, properties, duration)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.2,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        properties
    )

    tween:Play()

    return tween
end

local function Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function RoundNumber(value, decimals)
    decimals = decimals or 0

    local multiplier = 10 ^ decimals

    return math.floor(value * multiplier + 0.5)
        / multiplier
end

local function FormatValue(value, decimals)
    value = RoundNumber(value, decimals)

    if decimals == 0 then
        return tostring(math.floor(value))
    end

    return string.format("%." .. decimals .. "f", value)
end

---------------------------------------------------------------------
-- NOTIFICATION CONTAINER
---------------------------------------------------------------------

local NotificationGui = Create("ScreenGui", {
    Name = "KamUI_Notifications",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

pcall(function()
    NotificationGui.Parent = CoreGui
end)

if not NotificationGui.Parent then
    NotificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local NotificationContainer = Create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -20, 1, -20),
    Size = UDim2.fromOffset(330, 0),
    AutomaticSize = Enum.AutomaticSize.Y,

    BackgroundTransparency = 1
}, NotificationGui)

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationLayout.Padding = UDim.new(0, 8)
NotificationLayout.Parent = NotificationContainer

---------------------------------------------------------------------
-- NOTIFY
---------------------------------------------------------------------

function Library:Notify(data)
    data = data or {}

    local title = data.Title or "Notification"
    local description = data.Description or ""
    local duration = data.Time or 3

    local notification = Create("Frame", {
        Size = UDim2.fromOffset(320, 72),

        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,

        BackgroundTransparency = 0.02
    }, NotificationContainer)

    Corner(notification, 14)
    Stroke(notification, self.Theme.Outline, 0.15)

    local accent = Create("Frame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 4, 1, 0),

        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0
    }, notification)

    Corner(accent, 4)

    local titleLabel = Create("TextLabel", {
        Position = UDim2.fromOffset(18, 12),
        Size = UDim2.new(1, -30, 0, 22),

        BackgroundTransparency = 1,

        Text = title,
        TextColor3 = self.Theme.Text,

        Font = Enum.Font.GothamBold,
        TextSize = 14,

        TextXAlignment = Enum.TextXAlignment.Left
    }, notification)

    local descLabel = Create("TextLabel", {
        Position = UDim2.fromOffset(18, 35),
        Size = UDim2.new(1, -30, 0, 25),

        BackgroundTransparency = 1,

        Text = description,
        TextColor3 = self.Theme.SubText,

        Font = Enum.Font.GothamMedium,
        TextSize = 12,

        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left
    }, notification)

    notification.BackgroundTransparency = 1

    Tween(notification, {
        BackgroundTransparency = 0.02
    }, 0.2)

    task.delay(duration, function()
        if notification and notification.Parent then
            Tween(notification, {
                BackgroundTransparency = 1
            }, 0.2)

            task.wait(0.22)

            if notification then
                notification:Destroy()
            end
        end
    end)
end

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------

function Library:CreateWindow(options)
    options = options or {}

    local Window = {}

    Window.Library = self
    Window.Tabs = {}
    Window.CurrentTab = nil

    local title = options.Title or "KamUI"
    local subtitle = options.Subtitle or "Modern Interface"

    local size = options.Size or UDim2.fromOffset(920, 580)

    -----------------------------------------------------------------
    -- GUI
    -----------------------------------------------------------------

    local Gui = Create("ScreenGui", {
        Name = "KamUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    pcall(function()
        Gui.Parent = CoreGui
    end)

    if not Gui.Parent then
        Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    Window.Gui = Gui

    -----------------------------------------------------------------
    -- MAIN
    -----------------------------------------------------------------

    local Main = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),

        Size = size,

        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0
    }, Gui)

    Window.Main = Main

    Corner(Main, 18)
    Stroke(Main, self.Theme.Outline, 0.1)

    -----------------------------------------------------------------
    -- SHADOW
    -----------------------------------------------------------------

    local Shadow = Create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 5),

        Size = UDim2.new(1, 45, 1, 45),

        BackgroundTransparency = 1,

        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.45,

        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),

        ZIndex = -1
    }, Gui)

    -----------------------------------------------------------------
    -- SIDEBAR
    -----------------------------------------------------------------

    local Sidebar = Create("Frame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 158, 1, 0),

        BackgroundColor3 = self.Theme.Sidebar,
        BorderSizePixel = 0
    }, Main)

    Corner(Sidebar, 18)

    -----------------------------------------------------------------
    -- SIDEBAR MASK
    -----------------------------------------------------------------

    local SidebarMask = Create("Frame", {
        Position = UDim2.new(0, 145, 0, 0),
        Size = UDim2.new(0, 20, 1, 0),

        BackgroundColor3 = self.Theme.Sidebar,
        BorderSizePixel = 0
    }, Sidebar)

    -----------------------------------------------------------------
    -- TITLE
    -----------------------------------------------------------------

    local TitleLabel = Create("TextLabel", {
        Position = UDim2.fromOffset(18, 18),
        Size = UDim2.new(1, -36, 0, 26),

        BackgroundTransparency = 1,

        Text = title,
        TextColor3 = self.Theme.Text,

        Font = Enum.Font.GothamBold,
        TextSize = 18,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Sidebar)

    local SubtitleLabel = Create("TextLabel", {
        Position = UDim2.fromOffset(18, 44),
        Size = UDim2.new(1, -36, 0, 20),

        BackgroundTransparency = 1,

        Text = subtitle,
        TextColor3 = self.Theme.MutedText,

        Font = Enum.Font.GothamMedium,
        TextSize = 10,

        TextXAlignment = Enum.TextXAlignment.Left
    }, Sidebar)

    -----------------------------------------------------------------
    -- TAB HOLDER
    -----------------------------------------------------------------

    local TabHolder = Create("ScrollingFrame", {
        Position = UDim2.fromOffset(10, 80),
        Size = UDim2.new(1, -20, 1, -90),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness = 0,

        CanvasSize = UDim2.new()
    }, Sidebar)

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabHolder

    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabHolder.CanvasSize = UDim2.fromOffset(
            0,
            TabLayout.AbsoluteContentSize.Y + 10
        )
    end)

    -----------------------------------------------------------------
    -- CONTENT
    -----------------------------------------------------------------

    local Content = Create("Frame", {
        Position = UDim2.fromOffset(158, 0),
        Size = UDim2.new(1, -158, 1, 0),

        BackgroundTransparency = 1
    }, Main)

    -----------------------------------------------------------------
    -- HEADER
    -----------------------------------------------------------------

    local Header = Create("Frame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 64),

        BackgroundTransparency = 1
    }, Content)

    -----------------------------------------------------------------
    -- SEARCH
    -----------------------------------------------------------------

    local Search = Create("TextBox", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 13),

        Size = UDim2.fromOffset(310, 38),

        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,

        Text = "",
        PlaceholderText = "Search modules...",

        PlaceholderColor3 = self.Theme.MutedText,
        TextColor3 = self.Theme.Text,

        Font = Enum.Font.GothamMedium,
        TextSize = 12,

        ClearTextOnFocus = false
    }, Header)

    Corner(Search, 12)
    Stroke(Search, self.Theme.Outline, 0.25)

    Padding(Search, 14, 14, 0, 0)

    -----------------------------------------------------------------
    -- SEARCH ICON
    -----------------------------------------------------------------

    local SearchIcon = Create("TextLabel", {
        Position = UDim2.new(1, -35, 0, 0),
        Size = UDim2.fromOffset(28, 38),

        BackgroundTransparency = 1,

        Text = "⌕",
        TextColor3 = self.Theme.MutedText,

        Font = Enum.Font.GothamBold,
        TextSize = 17
    }, Search)

    -----------------------------------------------------------------
    -- PAGE HOLDER
    -----------------------------------------------------------------

    local PageHolder = Create("Frame", {
        Position = UDim2.fromOffset(10, 64),
        Size = UDim2.new(1, -20, 1, -74),

        BackgroundTransparency = 1
    }, Content)

    -----------------------------------------------------------------
    -- DRAGGING
    -----------------------------------------------------------------

    local dragging = false
    local dragStart
    local startPosition

    local function UpdateDrag(input)
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,

            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = Main.Position
        end
    end)

    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            UpdateDrag(input)
        end
    end)

    -----------------------------------------------------------------
    -- TAB
    -----------------------------------------------------------------

    function Window:AddTab(tabName, icon)
        local Tab = {}

        Tab.Name = tabName
        Tab.Elements = {}
        Tab.Groupboxes = {}

        -----------------------------------------------------------------
        -- TAB BUTTON
        -----------------------------------------------------------------

        local TabButton = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),

            BackgroundColor3 = self.Theme.Sidebar,
            BackgroundTransparency = 1,

            BorderSizePixel = 0,

            Text = ""
        }, TabHolder)

        Corner(TabButton, 10)

        local Icon = Create("TextLabel", {
            Position = UDim2.fromOffset(11, 0),
            Size = UDim2.fromOffset(24, 38),

            BackgroundTransparency = 1,

            Text = icon or "•",

            TextColor3 = self.Theme.MutedText,

            Font = Enum.Font.GothamBold,
            TextSize = 14
        }, TabButton)

        local TabText = Create("TextLabel", {
            Position = UDim2.fromOffset(40, 0),
            Size = UDim2.new(1, -45, 1, 0),

            BackgroundTransparency = 1,

            Text = tabName,

            TextColor3 = self.Theme.SubText,

            Font = Enum.Font.GothamMedium,
            TextSize = 12,

            TextXAlignment = Enum.TextXAlignment.Left
        }, TabButton)

        -----------------------------------------------------------------
        -- PAGE
        -----------------------------------------------------------------

        local Page = Create("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),

            BackgroundTransparency = 1,

            BorderSizePixel = 0,

            ScrollBarThickness = 3,
            ScrollBarImageColor3 = self.Theme.Accent,

            CanvasSize = UDim2.new(),

            Visible = false
        }, PageHolder)

        local Columns = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),

            AutomaticSize = Enum.AutomaticSize.Y,

            BackgroundTransparency = 1
        }, Page)

        local LeftColumn = Create("Frame", {
            Position = UDim2.fromOffset(0, 0),

            Size = UDim2.new(0.5, -7, 0, 0),

            AutomaticSize = Enum.AutomaticSize.Y,

            BackgroundTransparency = 1
        }, Columns)

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Padding = UDim.new(0, 10)
        LeftLayout.Parent = LeftColumn

        local RightColumn = Create("Frame", {
            Position = UDim2.new(0.5, 7, 0, 0),

            Size = UDim2.new(0.5, -19, 0, 0),

            AutomaticSize = Enum.AutomaticSize.Y,

            BackgroundTransparency = 1
        }, Columns)

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Padding = UDim.new(0, 10)
        RightLayout.Parent = RightColumn

        local function UpdateCanvas()
            Page.CanvasSize = UDim2.fromOffset(
                0,
                Columns.AbsoluteSize.Y + 10
            )
        end

        Columns:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateCanvas)

        -----------------------------------------------------------------
        -- SELECT TAB
        -----------------------------------------------------------------

        local function Select()
            for _, other in pairs(Window.Tabs) do
                other.Page.Visible = false

                Tween(
                    other.Button,
                    {
                        BackgroundTransparency = 1
                    },
                    0.15
                )

                Tween(
                    other.Text,
                    {
                        TextColor3 = self.Theme.SubText
                    },
                    0.15
                )

                Tween(
                    other.Icon,
                    {
                        TextColor3 = self.Theme.MutedText
                    },
                    0.15
                )
            end

            Page.Visible = true

            Tween(
                TabButton,
                {
                    BackgroundColor3 = self.Theme.Accent,
                    BackgroundTransparency = 0.82
                },
                0.15
            )

            Tween(
                TabText,
                {
                    TextColor3 = self.Theme.Text
                },
                0.15
            )

            Tween(
                Icon,
                {
                    TextColor3 = self.Theme.Accent
                },
                0.15
            )

            Window.CurrentTab = Tab
        end

        TabButton.MouseButton1Click:Connect(Select)

        Tab.Button = TabButton
        Tab.Text = TabText
        Tab.Icon = Icon
        Tab.Page = Page
        Tab.LeftColumn = LeftColumn
        Tab.RightColumn = RightColumn
        Tab.Select = Select

        table.insert(Window.Tabs, Tab)
        table.insert(self.Tabs, Tab)

        -----------------------------------------------------------------
        -- GROUPBOX
        -----------------------------------------------------------------

        function Tab:AddGroupbox(name, side)
            local Groupbox = {}

            Groupbox.Name = name
            Groupbox.Elements = {}

            local parent =
                side == "Right"
                and RightColumn
                or LeftColumn

            local Frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),

                AutomaticSize = Enum.AutomaticSize.Y,

                BackgroundColor3 = self.Theme.Element,

                BorderSizePixel = 0
            }, parent)

            Corner(Frame, 13)
            Stroke(Frame, self.Theme.Outline, 0.3)

            local Header = Create("TextLabel", {
                Position = UDim2.fromOffset(14, 12),

                Size = UDim2.new(1, -28, 0, 23),

                BackgroundTransparency = 1,

                Text = name,

                TextColor3 = self.Theme.Text,

                Font = Enum.Font.GothamBold,
                TextSize = 14,

                TextXAlignment = Enum.TextXAlignment.Left
            }, Frame)

            local ElementsHolder = Create("Frame", {
                Position = UDim2.fromOffset(13, 43),

                Size = UDim2.new(1, -26, 0, 0),

                AutomaticSize = Enum.AutomaticSize.Y,

                BackgroundTransparency = 1
            }, Frame)

            local Layout = Instance.new("UIListLayout")
            Layout.Padding = UDim.new(0, 9)
            Layout.Parent = ElementsHolder

            Padding(Frame, 0, 0, 0, 13)

            Groupbox.Frame = Frame
            Groupbox.Container = ElementsHolder
            Groupbox.Layout = Layout

            table.insert(Tab.Groupboxes, Groupbox)

            -----------------------------------------------------------------
            -- ELEMENT REGISTER
            -----------------------------------------------------------------

            local function RegisterElement(element, name)
                element._SearchName = string.lower(name or "")
                element._Frame = element.Frame or element

                table.insert(Groupbox.Elements, element)

                table.insert(
                    Library._searchElements,
                    element
                )

                return element
            end

            -----------------------------------------------------------------
            -- TOGGLE
            -----------------------------------------------------------------

            function Groupbox:AddToggle(flag, options)
                options = options or {}

                local Toggle = {}

                local default =
                    options.Default == true

                Toggle.Value = default
                Toggle.Flag = flag

                Library.Flags[flag] = default

                local Holder = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 42),

                    BackgroundTransparency = 1
                }, ElementsHolder)

                local Label = Create("TextLabel", {
                    Position = UDim2.fromOffset(0, 0),

                    Size = UDim2.new(1, -54, 1, 0),

                    BackgroundTransparency = 1,

                    Text = options.Text or flag,

                    TextColor3 = self.Theme.Text,

                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,

                    TextXAlignment = Enum.TextXAlignment.Left
                }, Holder)

                local ToggleButton = Create("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),

                    Position = UDim2.new(1, 0, 0.5, 0),

                    Size = UDim2.fromOffset(42, 23),

                    BackgroundColor3 =
                        default
                        and self.Theme.Accent
                        or self.Theme.SliderBackground,

                    BorderSizePixel = 0,

                    Text = ""
                }, Holder)

                Corner(ToggleButton, 12)

                Stroke(
                    ToggleButton,
                    self.Theme.Outline,
                    0.35
                )

                local Knob = Create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),

                    Position =
                        default
                        and UDim2.new(1, -20, 0.5, 0)
                        or UDim2.fromOffset(3, 11.5),

                    Size = UDim2.fromOffset(17, 17),

                    BackgroundColor3 =
                        Color3.fromRGB(245, 245, 248),

                    BorderSizePixel = 0
                }, ToggleButton)

                Corner(Knob, 10)

                local function Set(value)
                    Toggle.Value = value
                    Library.Flags[flag] = value

                    Tween(
                        ToggleButton,
                        {
                            BackgroundColor3 =
                                value
                                and self.Theme.Accent
                                or self.Theme.SliderBackground
                        },
                        0.18
                    )

                    Tween(
                        Knob,
                        {
                            Position =
                                value
                                and UDim2.new(
                                    1,
                                    -20,
                                    0.5,
                                    0
                                )
                                or UDim2.fromOffset(
                                    3,
                                    11.5
                                )
                        },
                        0.18
                    )

                    if options.Callback then
                        task.spawn(
                            options.Callback,
                            value
                        )
                    end

                    if options.OnChanged then
                        task.spawn(
                            options.OnChanged,
                            value
                        )
                    end
                end

                Toggle.SetValue = Set

                ToggleButton.MouseButton1Click:Connect(function()
                    Set(not Toggle.Value)
                end)

                Toggle.Frame = Holder

                RegisterElement(
                    Toggle,
                    options.Text or flag
                )

                return Toggle
            end

            -----------------------------------------------------------------
            -- SLIDER
            -----------------------------------------------------------------

            function Groupbox:AddSlider(flag, options)
                options = options or {}

                local Slider = {}

                local minimum = options.Min or 0
                local maximum = options.Max or 100
                local value = options.Default or minimum

                local rounding =
                    options.Rounding

                if rounding == nil then
                    rounding = 0
                end

                value = Clamp(value, minimum, maximum)

                Slider.Value = value
                Slider.Flag = flag

                Library.Flags[flag] = value

                local Holder = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 67),

                    BackgroundTransparency = 1
                }, ElementsHolder)

                local Label = Create("TextLabel", {
                    Position = UDim2.fromOffset(0, 0),

                    Size = UDim2.new(1, -80, 0, 22),

                    BackgroundTransparency = 1,

                    Text = options.Text or flag,

                    TextColor3 = self.Theme.Text,

                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,

                    TextXAlignment = Enum.TextXAlignment.Left
                }, Holder)

                local ValueLabel = Create("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),

                    Position = UDim2.new(1, 0, 0, 0),

                    Size = UDim2.fromOffset(75, 22),

                    BackgroundTransparency = 1,

                    Text = FormatValue(
                        value,
                        rounding
                    ) .. (options.Suffix or ""),

                    TextColor3 = self.Theme.SubText,

                    Font = Enum.Font.GothamSemibold,
                    TextSize = 12,

                    TextXAlignment = Enum.TextXAlignment.Right
                }, Holder)

                local Bar = Create("Frame", {
                    Position = UDim2.fromOffset(0, 34),

                    Size = UDim2.new(1, 0, 0, 8),

                    BackgroundColor3 =
                        self.Theme.SliderBackground,

                    BorderSizePixel = 0
                }, Holder)

                Corner(Bar, 8)

                Stroke(
                    Bar,
                    self.Theme.Outline,
                    0.5
                )

                local Fill = Create("Frame", {
                    Size = UDim2.new(
                        (value - minimum)
                            / (maximum - minimum),
                        0,
                        1,
                        0
                    ),

                    BackgroundColor3 =
                        self.Theme.Accent,

                    BorderSizePixel = 0
                }, Bar)

                Corner(Fill, 8)

                local Knob = Create("Frame", {
                    AnchorPoint =
                        Vector2.new(0.5, 0.5),

                    Position = UDim2.new(
                        (value - minimum)
                            / (maximum - minimum),
                        0,
                        0.5,
                        0
                    ),

                    Size = UDim2.fromOffset(18, 18),

                    BackgroundColor3 =
                        Color3.fromRGB(
                            245,
                            245,
                            248
                        ),

                    BorderSizePixel = 0
                }, Bar)

                Corner(Knob, 10)

                Stroke(
                    Knob,
                    self.Theme.Accent,
                    0.1
                )

                local draggingSlider = false

                local function SetValue(newValue)
                    newValue = Clamp(
                        newValue,
                        minimum,
                        maximum
                    )

                    newValue =
                        RoundNumber(
                            newValue,
                            rounding
                        )

                    Slider.Value = newValue
                    Library.Flags[flag] = newValue

                    local percent =
                        (newValue - minimum)
                        / (maximum - minimum)

                    Tween(
                        Fill,
                        {
                            Size = UDim2.new(
                                percent,
                                0,
                                1,
                                0
                            )
                        },
                        0.08
                    )

                    Tween(
                        Knob,
                        {
                            Position = UDim2.new(
                                percent,
                                0,
                                0.5,
                                0
                            )
                        },
                        0.08
                    )

                    ValueLabel.Text =
                        FormatValue(
                            newValue,
                            rounding
                        )
                        .. (options.Suffix or "")

                    if options.Callback then
                        task.spawn(
                            options.Callback,
                            newValue
                        )
                    end

                    if options.OnChanged then
                        task.spawn(
                            options.OnChanged,
                            newValue
                        )
                    end
                end

                Slider.SetValue = SetValue

                local function UpdateFromMouse()
                    local mouse =
                        UserInputService:GetMouseLocation()

                    local relative =
                        mouse.X - Bar.AbsolutePosition.X

                    local percent =
                        Clamp(
                            relative
                                / Bar.AbsoluteSize.X,
                            0,
                            1
                        )

                    SetValue(
                        minimum
                        + (
                            maximum - minimum
                        ) * percent
                    )
                end

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType ==
                        Enum.UserInputType.MouseButton1 then

                        draggingSlider = true
                        UpdateFromMouse()
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider
                        and input.UserInputType ==
                            Enum.UserInputType.MouseMovement then

                        UpdateFromMouse()
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType ==
                        Enum.UserInputType.MouseButton1 then

                        draggingSlider = false
                    end
                end)

                Slider.Frame = Holder

                RegisterElement(
                    Slider,
                    options.Text or flag
                )

                return Slider
            end

            -----------------------------------------------------------------
            -- DROPDOWN
            -----------------------------------------------------------------

            function Groupbox:AddDropdown(flag, options)
                options = options or {}

                local Dropdown = {}

                local values =
                    options.Values
                    or options.Options
                    or {}

                local selected =
                    options.Default
                    or values[1]

                Dropdown.Value = selected
                Dropdown.Values = values
                Dropdown.Flag = flag

                Library.Flags[flag] = selected

                local Holder = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 66),

                    BackgroundTransparency = 1
                }, ElementsHolder)

                local Label = Create("TextLabel", {
                    Position = UDim2.fromOffset(0, 0),

                    Size = UDim2.new(1, 0, 0, 20),

                    BackgroundTransparency = 1,

                    Text = options.Text or flag,

                    TextColor3 = self.Theme.Text,

                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,

                    TextXAlignment =
                        Enum.TextXAlignment.Left
                }, Holder)

                local Button = Create("TextButton", {
                    Position = UDim2.fromOffset(0, 28),

                    Size = UDim2.new(1, 0, 0, 34),

                    BackgroundColor3 =
                        self.Theme.SliderBackground,

                    BorderSizePixel = 0,

                    Text = "",
                    AutoButtonColor = false
                }, Holder)

                Corner(Button, 9)

                Stroke(
                    Button,
                    self.Theme.Outline,
                    0.3
                )

                local Value = Create("TextLabel", {
                    Position = UDim2.fromOffset(11, 0),

                    Size = UDim2.new(1, -35, 1, 0),

                    BackgroundTransparency = 1,

                    Text = tostring(selected),

                    TextColor3 = self.Theme.SubText,

                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,

                    TextXAlignment =
                        Enum.TextXAlignment.Left
                }, Button)

                local Arrow = Create("TextLabel", {
                    AnchorPoint =
                        Vector2.new(1, 0.5),

                    Position =
                        UDim2.new(1, -10, 0.5, 0),

                    Size = UDim2.fromOffset(18, 18),

                    BackgroundTransparency = 1,

                    Text = "⌄",

                    TextColor3 =
                        self.Theme.MutedText,

                    Font = Enum.Font.GothamBold,
                    TextSize = 15
                }, Button)

                local Open = false
                local Popup

                local function Close()
                    Open = false

                    if Popup then
                        Popup:Destroy()
                        Popup = nil
                    end
                end

                local function OpenDropdown()
                    if Open then
                        Close()
                        return
                    end

                    Open = true

                    Popup = Create("Frame", {
                        Position = UDim2.fromOffset(
                            Button.AbsolutePosition.X,
                            Button.AbsolutePosition.Y
                                + Button.AbsoluteSize.Y
                                + 5
                        ),

                        Size = UDim2.fromOffset(
                            Button.AbsoluteSize.X,
                            math.min(
                                #values * 31 + 10,
                                170
                            )
                        ),

                        BackgroundColor3 =
                            self.Theme.Element,

                        BorderSizePixel = 0,

                        ZIndex = 100
                    }, Gui)

                    Corner(Popup, 10)
                    Stroke(
                        Popup,
                        self.Theme.Outline,
                        0.2
                    )

                    local Scroll = Create(
                        "ScrollingFrame",
                        {
                            Position =
                                UDim2.fromOffset(5, 5),

                            Size =
                                UDim2.new(1, -10, 1, -10),

                            BackgroundTransparency = 1,

                            BorderSizePixel = 0,

                            ScrollBarThickness = 2,

                            CanvasSize =
                                UDim2.fromOffset(
                                    0,
                                    #values * 31
                                ),

                            ZIndex = 101
                        },
                        Popup
                    )

                    local Layout =
                        Instance.new("UIListLayout")

                    Layout.Padding =
                        UDim.new(0, 2)

                    Layout.Parent = Scroll

                    for _, option in ipairs(values) do
                        local OptionButton =
                            Create(
                                "TextButton",
                                {
                                    Size =
                                        UDim2.new(
                                            1,
                                            0,
                                            0,
                                            29
                                        ),

                                    BackgroundColor3 =
                                        self.Theme.Element,

                                    BackgroundTransparency =
                                        1,

                                    BorderSizePixel = 0,

                                    Text =
                                        tostring(option),

                                    TextColor3 =
                                        self.Theme.SubText,

                                    Font =
                                        Enum.Font.GothamMedium,

                                    TextSize = 12,

                                    ZIndex = 102
                                },
                                Scroll
                            )

                        Corner(OptionButton, 7)

                        OptionButton.MouseEnter:Connect(
                            function()
                                Tween(
                                    OptionButton,
                                    {
                                        BackgroundColor3 =
                                            self.Theme.ElementHover,

                                        BackgroundTransparency =
                                            0
                                    },
                                    0.1
                                )
                            end
                        )

                        OptionButton.MouseLeave:Connect(
                            function()
                                Tween(
                                    OptionButton,
                                    {
                                        BackgroundTransparency =
                                            1
                                    },
                                    0.1
                                )
                            end
                        )

                        OptionButton.MouseButton1Click:Connect(
                            function()
                                selected = option

                                Dropdown.Value =
                                    option

                                Library.Flags[flag] =
                                    option

                                Value.Text =
                                    tostring(option)

                                Close()

                                if options.Callback then
                                    task.spawn(
                                        options.Callback,
                                        option
                                    )
                                end

                                if options.OnChanged then
                                    task.spawn(
                                        options.OnChanged,
                                        option
                                    )
                                end
                            end
                        )
                    end
                end

                Button.MouseButton1Click:Connect(
                    OpenDropdown
                )

                Dropdown.SetValue = function(_, value)
                    if table.find(values, value) then
                        selected = value

                        Dropdown.Value = value
                        Library.Flags[flag] = value

                        Value.Text = tostring(value)
                    end
                end

                Dropdown.Frame = Holder

                RegisterElement(
                    Dropdown,
                    options.Text or flag
                )

                return Dropdown
            end

            -----------------------------------------------------------------
            -- INPUT
            -----------------------------------------------------------------

            function Groupbox:AddInput(flag, options)
                options = options or {}

                local Input = {}

                Input.Value = options.Default or ""
                Input.Flag = flag

                Library.Flags[flag] =
                    Input.Value

                local Holder = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 66),

                    BackgroundTransparency = 1
                }, ElementsHolder)

                local Label = Create("TextLabel", {
                    Position = UDim2.fromOffset(0, 0),

                    Size = UDim2.new(1, 0, 0, 20),

                    BackgroundTransparency = 1,

                    Text = options.Text or flag,

                    TextColor3 = self.Theme.Text,

                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,

                    TextXAlignment =
                        Enum.TextXAlignment.Left
                }, Holder)

                local Box = Create("TextBox", {
                    Position = UDim2.fromOffset(0, 28),

                    Size = UDim2.new(1, 0, 0, 34),

                    BackgroundColor3 =
                        self.Theme.SliderBackground,

                    BorderSizePixel = 0,

                    Text =
                        options.Default or "",

                    PlaceholderText =
                        options.Placeholder or "Enter text...",

                    PlaceholderColor3 =
                        self.Theme.MutedText,

                    TextColor3 =
                        self.Theme.Text,

                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,

                    ClearTextOnFocus = false,

                    TextXAlignment =
                        Enum.TextXAlignment.Left
                }, Holder)

                Corner(Box, 9)

                Stroke(
                    Box,
                    self.Theme.Outline,
                    0.3
                )

                Padding(Box, 11, 11, 0, 0)

                Box.FocusLost:Connect(function()
                    Input.Value = Box.Text

                    Library.Flags[flag] =
                        Box.Text

                    if options.Callback then
                        task.spawn(
                            options.Callback,
                            Box.Text
                        )
                    end

                    if options.OnChanged then
                        task.spawn(
                            options.OnChanged,
                            Box.Text
                        )
                    end
                end)

                Input.SetValue = function(_, value)
                    Input.Value = tostring(value)
                    Box.Text = tostring(value)

                    Library.Flags[flag] =
                        tostring(value)
                end

                Input.Frame = Holder

                RegisterElement(
                    Input,
                    options.Text or flag
                )

                return Input
            end

            -----------------------------------------------------------------
            -- BUTTON
            -----------------------------------------------------------------

            function Groupbox:AddButton(options)
                options = options or {}

                local ButtonObject = {}

                local Holder = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 40),

                    BackgroundTransparency = 1
                }, ElementsHolder)

                local Button = Create("TextButton", {
                    Size = UDim2.fromScale(1, 1),

                    BackgroundColor3 =
                        self.Theme.Accent,

                    BorderSizePixel = 0,

                    Text =
                        options.Text or "Button",

                    TextColor3 =
                        Color3.fromRGB(
                            255,
                            255,
                            255
                        ),

                    Font = Enum.Font.GothamBold,
                    TextSize = 12,

                    AutoButtonColor = false
                }, Holder)

                Corner(Button, 10)

                Button.MouseEnter:Connect(
                    function()
                        Tween(
                            Button,
                            {
                                BackgroundColor3 =
                                    self.Theme.AccentDark
                            },
                            0.15
                        )
                    end
                )

                Button.MouseLeave:Connect(
                    function()
                        Tween(
                            Button,
                            {
                                BackgroundColor3 =
                                    self.Theme.Accent
                            },
                            0.15
                        )
                    end
                )

                Button.MouseButton1Click:Connect(
                    function()
                        if options.Callback then
                            task.spawn(
                                options.Callback
                            )
                        end
                    end
                )

                ButtonObject.Frame = Holder

                RegisterElement(
                    ButtonObject,
                    options.Text or "Button"
                )

                return ButtonObject
            end

            -----------------------------------------------------------------
            -- LABEL
            -----------------------------------------------------------------

            function Groupbox:AddLabel(text)
                local LabelObject = {}

                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 32),

                    BackgroundTransparency = 1,

                    Text = tostring(text),

                    TextColor3 =
                        self.Theme.SubText,

                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,

                    TextWrapped = true,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    TextYAlignment =
                        Enum.TextYAlignment.Center
                }, ElementsHolder)

                LabelObject.Frame = Label

                RegisterElement(
                    LabelObject,
                    tostring(text)
                )

                return LabelObject
            end

            -----------------------------------------------------------------
            -- DIVIDER
            -----------------------------------------------------------------

            function Groupbox:AddDivider()
                local DividerObject = {}

                local Divider = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),

                    BackgroundColor3 =
                        self.Theme.Outline,

                    BackgroundTransparency = 0.45,

                    BorderSizePixel = 0
                }, ElementsHolder)

                DividerObject.Frame = Divider

                return DividerObject
            end

            return Groupbox
        end

        function Tab:AddLeftGroupbox(name)
            return self:AddGroupbox(
                name,
                "Left"
            )
        end

        function Tab:AddRightGroupbox(name)
            return self:AddGroupbox(
                name,
                "Right"
            )
        end

        Select()

        return Tab
    end

    -----------------------------------------------------------------
    -- SEARCH
    -----------------------------------------------------------------

    Search:GetPropertyChangedSignal("Text"):Connect(
        function()
            local query =
                string.lower(Search.Text or "")

            for _, element in ipairs(
                Library._searchElements
            ) do
                if element
                    and element._Frame
                    and element._Frame.Parent then

                    local name =
                        string.lower(
                            element._SearchName or ""
                        )

                    local visible =
                        query == ""
                        or string.find(
                            name,
                            query,
                            1,
                            true
                        ) ~= nil

                    element._Frame.Visible =
                        visible
                end
            end
        end
    )

    -----------------------------------------------------------------
    -- ACCENT
    -----------------------------------------------------------------

    function self:SetAccent(color)
        self.Theme.Accent = color

        self.Theme.AccentDark =
            color:Lerp(
                Color3.new(0, 0, 0),
                0.25
            )

        for _, tab in ipairs(Window.Tabs) do
            for _, groupbox in ipairs(
                tab.Groupboxes
            ) do

                for _, element in ipairs(
                    groupbox.Elements
                ) do

                    -- Existing elements update
                    -- when interacted with again.
                end
            end
        end
    end

    -----------------------------------------------------------------
    -- CLOSE
    -----------------------------------------------------------------

    function Window:Destroy()
        if Gui then
            Gui:Destroy()
        end

        if Shadow then
            Shadow:Destroy()
        end
    end

    -----------------------------------------------------------------
    -- DEFAULT WINDOW
    -----------------------------------------------------------------

    Window:SelectTab = function(_, tab)
        if tab and tab.Select then
            tab:Select()
        end
    end

    return Window
end

---------------------------------------------------------------------
-- COMPATIBILITY HELPERS
---------------------------------------------------------------------

function Library:GetFlag(flag)
    return self.Flags[flag]
end

function Library:SetFlag(flag, value)
    self.Flags[flag] = value
end

function Library:Unload()
    for _, gui in ipairs({
        "KamUI",
        "KamUI_Notifications"
    }) do
        pcall(function()
            local object = CoreGui:FindFirstChild(gui)

            if object then
                object:Destroy()
            end
        end)
    end
end

---------------------------------------------------------------------
-- RETURN
---------------------------------------------------------------------

return Library
