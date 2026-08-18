--// Kam41514 Modern Library
--// Obsidian API Compatible
--// Compact / Fluent-inspired UI

------------------------------------------------------------
-- SERVICES
------------------------------------------------------------

local TweenService = game:GetService("TweenService")

------------------------------------------------------------
-- ORIGINAL OBSIDIAN LIBRARY
------------------------------------------------------------

local Source = game:HttpGet(
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"
)

local Library = loadstring(Source)()

if type(Library) ~= "table" then
    error("[Kam41514 Library] Failed to load Library")
end

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------

local Modern = {
    WindowSize = UDim2.fromOffset(1050, 650),

    SidebarWidth = 145,
    CompactSidebarWidth = 48,

    TabHeight = 36,
    TabSpacing = 5,

    WindowRadius = 18,
    GroupboxRadius = 13,
    ElementRadius = 8,

    Background = Color3.fromRGB(9, 10, 14),
    Window = Color3.fromRGB(13, 14, 19),
    Sidebar = Color3.fromRGB(11, 12, 17),
    Content = Color3.fromRGB(14, 15, 21),

    Card = Color3.fromRGB(19, 20, 27),
    CardHover = Color3.fromRGB(23, 24, 33),

    Element = Color3.fromRGB(23, 24, 32),
    ElementHover = Color3.fromRGB(29, 30, 39),

    Accent = Color3.fromRGB(139, 92, 246),
    AccentHover = Color3.fromRGB(158, 116, 250),

    Text = Color3.fromRGB(238, 238, 245),
    Secondary = Color3.fromRGB(155, 158, 173),

    Border = Color3.fromRGB(39, 40, 51),

    Green = Color3.fromRGB(74, 222, 128),
    Red = Color3.fromRGB(248, 113, 113),
}

------------------------------------------------------------
-- SCHEME
------------------------------------------------------------

pcall(function()

    Library.Scheme.BackgroundColor =
        Modern.Background

    Library.Scheme.MainColor =
        Modern.Window

    Library.Scheme.AccentColor =
        Modern.Accent

    Library.Scheme.OutlineColor =
        Modern.Border

    Library.Scheme.FontColor =
        Modern.Text

    Library.Scheme.RedColor =
        Modern.Red

    Library.Scheme.DarkColor =
        Color3.fromRGB(6, 7, 10)

    Library.Scheme.WhiteColor =
        Color3.fromRGB(255, 255, 255)

    Library.Scheme.DestructiveColor =
        Color3.fromRGB(220, 70, 80)

end)

------------------------------------------------------------
-- TWEEN
------------------------------------------------------------

local FastTween = TweenInfo.new(
    0.14,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

local NormalTween = TweenInfo.new(
    0.20,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

local function Tween(Object, Properties, Info)

    if not Object then
        return
    end

    local T = TweenService:Create(
        Object,
        Info or FastTween,
        Properties
    )

    T:Play()

    return T
end

------------------------------------------------------------
-- CORNER
------------------------------------------------------------

local function Corner(Object, Radius)

    if not Object or not Object:IsA("GuiObject") then
        return
    end

    local C =
        Object:FindFirstChild("ModernCorner")

    if not C then

        C = Instance.new("UICorner")
        C.Name = "ModernCorner"
        C.Parent = Object

    end

    C.CornerRadius =
        UDim.new(0, Radius)

end

------------------------------------------------------------
-- STROKE
------------------------------------------------------------

local function Border(Object, Color, Transparency)

    if not Object or not Object:IsA("GuiObject") then
        return
    end

    local S =
        Object:FindFirstChild("ModernBorder")

    if not S then

        S = Instance.new("UIStroke")
        S.Name = "ModernBorder"
        S.Parent = Object

    end

    S.Thickness = 1
    S.Color = Color or Modern.Border
    S.Transparency =
        Transparency or 0.2

end

------------------------------------------------------------
-- FONT
------------------------------------------------------------

local function Font(Object)

    if not Object then
        return
    end

    if Object:IsA("TextLabel")
        or Object:IsA("TextButton")
        or Object:IsA("TextBox") then

        pcall(function()

            Object.FontFace =
                Font.fromEnum(
                    Enum.Font.Gotham
                )

        end)

    end

end

------------------------------------------------------------
-- STYLE TEXT
------------------------------------------------------------

local function StyleText(Object)

    Font(Object)

    if Object:IsA("TextLabel")
        or Object:IsA("TextButton")
        or Object:IsA("TextBox") then

        if Object.TextSize < 12 then
            Object.TextSize = 13
        end

        Object.TextColor3 =
            Modern.Text

    end

end

------------------------------------------------------------
-- STYLE INPUT
------------------------------------------------------------

local function StyleInput(Object)

    if Object:IsA("TextBox") then

        Object.BackgroundColor3 =
            Modern.Element

        Object.BackgroundTransparency = 0

        Corner(
            Object,
            Modern.ElementRadius
        )

        Border(
            Object,
            Modern.Border,
            0.15
        )

        if not Object:GetAttribute(
            "ModernInput"
        ) then

            Object:SetAttribute(
                "ModernInput",
                true
            )

            Object.Focused:Connect(function()

                Tween(
                    Object,
                    {
                        BackgroundColor3 =
                            Modern.ElementHover
                    }
                )

                local S =
                    Object:FindFirstChild(
                        "ModernBorder"
                    )

                if S then

                    Tween(
                        S,
                        {
                            Color =
                                Modern.Accent,
                            Transparency = 0
                        }
                    )

                end

            end)

            Object.FocusLost:Connect(function()

                Tween(
                    Object,
                    {
                        BackgroundColor3 =
                            Modern.Element
                    }
                )

                local S =
                    Object:FindFirstChild(
                        "ModernBorder"
                    )

                if S then

                    Tween(
                        S,
                        {
                            Color =
                                Modern.Border,
                            Transparency = 0.15
                        }
                    )

                end

            end)

        end

    end

end

------------------------------------------------------------
-- STYLE BUTTON
------------------------------------------------------------

local function StyleButton(Object)

    if not Object:IsA("TextButton") then
        return
    end

    Object.AutoButtonColor = false

    Corner(
        Object,
        Modern.ElementRadius
    )

    if not Object:GetAttribute(
        "ModernButton"
    ) then

        Object:SetAttribute(
            "ModernButton",
            true
        )

        Object.MouseEnter:Connect(function()

            Tween(
                Object,
                {
                    BackgroundColor3 =
                        Modern.ElementHover
                }
            )

        end)

        Object.MouseLeave:Connect(function()

            Tween(
                Object,
                {
                    BackgroundColor3 =
                        Modern.Element
                }
            )

        end)

    end

end

------------------------------------------------------------
-- STYLE GROUPBOX
------------------------------------------------------------

local function StyleGroupbox(Groupbox)

    if not Groupbox then
        return
    end

    local Holder =
        Groupbox.Holder

    if not Holder then
        return
    end

    --------------------------------------------------------
    -- CARD
    --------------------------------------------------------

    Holder.BackgroundColor3 =
        Modern.Card

    Holder.BackgroundTransparency = 0

    Corner(
        Holder,
        Modern.GroupboxRadius
    )

    Border(
        Holder,
        Modern.Border,
        0.18
    )

    --------------------------------------------------------
    -- CHILDREN
    --------------------------------------------------------

    for _, Object in ipairs(
        Holder:GetDescendants()
    ) do

        StyleText(Object)

        StyleInput(Object)

        StyleButton(Object)

    end

    --------------------------------------------------------
    -- HOVER CARD
    --------------------------------------------------------

    if not Holder:GetAttribute(
        "ModernGroupbox"
    ) then

        Holder:SetAttribute(
            "ModernGroupbox",
            true
        )

        Holder.MouseEnter:Connect(function()

            Tween(
                Holder,
                {
                    BackgroundColor3 =
                        Modern.CardHover
                }
            )

        end)

        Holder.MouseLeave:Connect(function()

            Tween(
                Holder,
                {
                    BackgroundColor3 =
                        Modern.Card
                }
            )

        end)

    end

end

------------------------------------------------------------
-- STYLE TAB
------------------------------------------------------------

local function StyleTab(Button)

    if not Button then
        return
    end

    if not Button:IsA("GuiObject") then
        return
    end

    Corner(
        Button,
        9
    )

    Button.BackgroundTransparency = 1

    for _, Object in ipairs(
        Button:GetDescendants()
    ) do

        StyleText(Object)

        if Object:IsA("ImageLabel")
            or Object:IsA("ImageButton") then

            Object.ImageColor3 =
                Modern.Secondary

        end

    end

    if Button:GetAttribute(
        "ModernTab"
    ) then
        return
    end

    Button:SetAttribute(
        "ModernTab",
        true
    )

    Button.MouseEnter:Connect(function()

        if not Button:GetAttribute(
            "ModernActive"
        ) then

            Tween(
                Button,
                {
                    BackgroundColor3 =
                        Modern.Element,
                    BackgroundTransparency =
                        0.25
                }
            )

        end

    end)

    Button.MouseLeave:Connect(function()

        if not Button:GetAttribute(
            "ModernActive"
        ) then

            Tween(
                Button,
                {
                    BackgroundTransparency = 1
                }
            )

        end

    end)

end

------------------------------------------------------------
-- STYLE SIDEBAR
------------------------------------------------------------

local function StyleSidebar()

    if not Library.WindowContainer then
        return
    end

    --------------------------------------------------------
    -- Find scrolling frames
    --------------------------------------------------------

    for _, Object in ipairs(
        Library.WindowContainer:GetDescendants()
    ) do

        if Object:IsA("ScrollingFrame") then

            Object.ScrollBarThickness = 2

        end

        StyleText(Object)

    end

    --------------------------------------------------------
    -- Tabs
    --------------------------------------------------------

    if Library.TabButtons then

        for _, Data in ipairs(
            Library.TabButtons
        ) do

            if Data.Label then

                local Button =
                    Data.Label.Parent

                if Button then

                    StyleTab(Button)

                end

            end

        end

    end

end

------------------------------------------------------------
-- STYLE WINDOW
------------------------------------------------------------

local function StyleWindow()

    local Container =
        Library.WindowContainer

    if not Container then
        return
    end

    --------------------------------------------------------
    -- ROOT
    --------------------------------------------------------

    Container.BackgroundColor3 =
        Modern.Content

    --------------------------------------------------------
    -- ALL TEXT / INPUTS
    --------------------------------------------------------

    for _, Object in ipairs(
        Container:GetDescendants()
    ) do

        StyleText(Object)

        StyleInput(Object)

        StyleButton(Object)

    end

    --------------------------------------------------------
    -- GROUPBOXES
    --------------------------------------------------------

    if Library.Tabs then

        for _, Tab in pairs(
            Library.Tabs
        ) do

            if Tab.Groupboxes then

                for _, Groupbox in pairs(
                    Tab.Groupboxes
                ) do

                    StyleGroupbox(
                        Groupbox
                    )

                end

            end

        end

    end

    --------------------------------------------------------
    -- SIDEBAR
    --------------------------------------------------------

    StyleSidebar()

end

------------------------------------------------------------
-- CREATE WINDOW WRAPPER
------------------------------------------------------------

local OriginalCreateWindow =
    Library.CreateWindow

Library.CreateWindow = function(
    self,
    Information
)

    Information =
        Information or {}

    --------------------------------------------------------
    -- COMPACT FLUENT-LIKE DEFAULTS
    --------------------------------------------------------

    if not Information.Size then

        Information.Size =
            Modern.WindowSize

    end

    if not Information.CornerRadius then

        Information.CornerRadius =
            Modern.WindowRadius

    end

    if not Information.MinContainerWidth then

        Information.MinContainerWidth = 760

    end

    if not Information.MinSidebarWidth then

        Information.MinSidebarWidth =
            Modern.SidebarWidth

    end

    if not Information.SidebarCompactWidth then

        Information.SidebarCompactWidth =
            Modern.CompactSidebarWidth

    end

    --------------------------------------------------------
    -- ANIMATIONS
    --------------------------------------------------------

    Information.Animations = {
        ToggleWindow = true,
        TabSwitch = true,
        Groupbox = true,
        Dropdown = true,
        KeyPicker = true
    }

    Information.TabTransitionTime =
        0.18

    Information.TabSwipeOffset =
        12

    Information.TabSwipeFrom =
        "right"

    --------------------------------------------------------
    -- ORIGINAL OBSIDIAN WINDOW
    --------------------------------------------------------

    local Window =
        OriginalCreateWindow(
            self,
            Information
        )

    --------------------------------------------------------
    -- APPLY MODERN STYLE
    --------------------------------------------------------

    task.spawn(function()

        task.wait(0.05)

        StyleWindow()

        task.wait(0.15)

        StyleWindow()

        task.wait(0.4)

        StyleWindow()

    end)

    return Window

end

------------------------------------------------------------
-- PUBLIC REFRESH
------------------------------------------------------------

function Library:RefreshModernStyle()

    task.spawn(function()

        StyleWindow()

    end)

    return true

end

------------------------------------------------------------
-- CHANGE ACCENT
------------------------------------------------------------

function Library:SetModernAccent(Color)

    assert(
        typeof(Color) == "Color3",
        "Color must be Color3"
    )

    Modern.Accent = Color

    Library.Scheme.AccentColor =
        Color

    self:RefreshModernStyle()

end

------------------------------------------------------------
-- PUBLIC STYLE INFO
------------------------------------------------------------

Library.Modern = Modern
Library.ModernStyle = true
Library.ModernVersion = "5.0"

------------------------------------------------------------
-- RETURN
------------------------------------------------------------

return Library
