--// Kam41514 Modern / Fluent Style Library
--// Obsidian API Compatible

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

------------------------------------------------------------
-- LOAD ORIGINAL OBSIDIAN API
------------------------------------------------------------

local Source = game:HttpGet(
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"
)

local Loader = loadstring(Source)

if not Loader then
    error("[Kam41514] Failed to load Obsidian Library")
end

local Library = Loader()

if type(Library) ~= "table" then
    error("[Kam41514] Invalid Library")
end

------------------------------------------------------------
-- MODERN PALETTE
------------------------------------------------------------

local Modern = {
    Background = Color3.fromRGB(9, 10, 14),
    Window = Color3.fromRGB(13, 14, 19),

    Sidebar = Color3.fromRGB(11, 12, 17),
    Content = Color3.fromRGB(14, 15, 21),

    Card = Color3.fromRGB(19, 20, 27),
    CardHover = Color3.fromRGB(24, 25, 34),

    Input = Color3.fromRGB(23, 24, 32),
    InputHover = Color3.fromRGB(29, 30, 40),

    Accent = Color3.fromRGB(139, 92, 246),
    AccentHover = Color3.fromRGB(157, 117, 250),

    Text = Color3.fromRGB(245, 245, 248),
    SubText = Color3.fromRGB(157, 160, 174),

    Border = Color3.fromRGB(38, 40, 51),

    Success = Color3.fromRGB(74, 222, 128),
    Danger = Color3.fromRGB(248, 113, 113),
}

------------------------------------------------------------
-- OBSIDIAN SCHEME COMPATIBILITY
------------------------------------------------------------

Library.Scheme.BackgroundColor = Modern.Background
Library.Scheme.MainColor = Modern.Window
Library.Scheme.AccentColor = Modern.Accent
Library.Scheme.OutlineColor = Modern.Border
Library.Scheme.FontColor = Modern.Text
Library.Scheme.RedColor = Modern.Danger
Library.Scheme.DestructiveColor = Color3.fromRGB(220, 70, 80)
Library.Scheme.DarkColor = Color3.fromRGB(6, 7, 10)
Library.Scheme.WhiteColor = Color3.fromRGB(255, 255, 255)

pcall(function()
    Library.Scheme.Font = Font.fromEnum(Enum.Font.Gotham)
end)

------------------------------------------------------------
-- MODERN DEFAULTS
------------------------------------------------------------

Library.CornerRadius = 16

Library.TweenInfo = TweenInfo.new(
    0.16,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

Library.TabTransitionInfo = TweenInfo.new(
    0.20,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

Library.GroupboxTweenInfo = TweenInfo.new(
    0.18,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

Library.DropdownTransitionInfo = TweenInfo.new(
    0.18,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

Library.KeyPickerTransitionInfo = TweenInfo.new(
    0.16,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

Library.WindowAnimationInfo = TweenInfo.new(
    0.25,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function Corner(Object, Radius)

    if not Object or not Object:IsA("GuiObject") then
        return
    end

    local Existing = Object:FindFirstChild("KamModernCorner")

    if not Existing then
        Existing = Instance.new("UICorner")
        Existing.Name = "KamModernCorner"
        Existing.Parent = Object
    end

    Existing.CornerRadius = UDim.new(0, Radius or 10)

    return Existing
end


local function Stroke(Object, Color, Transparency)

    if not Object or not Object:IsA("GuiObject") then
        return
    end

    local Existing = Object:FindFirstChild("KamModernStroke")

    if not Existing then
        Existing = Instance.new("UIStroke")
        Existing.Name = "KamModernStroke"
        Existing.Parent = Object
    end

    Existing.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Existing.Thickness = 1
    Existing.Color = Color or Modern.Border
    Existing.Transparency = Transparency or 0.15

    return Existing
end


local function SetText(Object)

    if not Object then
        return
    end

    if Object:IsA("TextLabel")
        or Object:IsA("TextButton")
        or Object:IsA("TextBox") then

        pcall(function()
            Object.FontFace =
                Font.fromEnum(Enum.Font.Gotham)
        end)

        Object.TextColor3 =
            Object.TextColor3:Lerp(
                Modern.Text,
                0.35
            )

        if Object.TextSize < 12 then
            Object.TextSize = 13
        end
    end
end


local function Animate(Object, Properties)

    if not Object then
        return
    end

    local Tween = TweenService:Create(
        Object,
        Library.TweenInfo,
        Properties
    )

    Tween:Play()

    return Tween
end


local function IsBackground(Object)

    return Object:IsA("Frame")
        or Object:IsA("ScrollingFrame")
        or Object:IsA("TextButton")
        or Object:IsA("TextBox")
end

------------------------------------------------------------
-- STYLE BASIC OBJECT
------------------------------------------------------------

local function StyleObject(Object)

    if not Object then
        return
    end

    SetText(Object)

    if Object:IsA("TextBox") then

        Object.BackgroundColor3 =
            Modern.Input

        Object.BackgroundTransparency = 0

        Corner(Object, 9)
        Stroke(Object, Modern.Border, 0.2)

    elseif Object:IsA("TextButton") then

        Corner(Object, 9)

        Object.AutoButtonColor = false

    end
end

------------------------------------------------------------
-- STYLE GROUPBOX
------------------------------------------------------------

local function StyleGroupbox(Box)

    if not Box then
        return
    end

    local Holder = Box.Holder

    if not Holder then
        return
    end

    Holder.BackgroundColor3 =
        Modern.Card

    Holder.BackgroundTransparency = 0

    Corner(Holder, 15)
    Stroke(Holder, Modern.Border, 0.18)

    --------------------------------------------------------
    -- Header
    --------------------------------------------------------

    for _, Object in ipairs(
        Holder:GetDescendants()
    ) do

        SetText(Object)

        if Object:IsA("TextLabel") then

            if Object.TextSize >= 12 then

                Object.TextColor3 =
                    Modern.Text

            end

        end
    end

    --------------------------------------------------------
    -- Elements
    --------------------------------------------------------

    if Box.Container then

        for _, Object in ipairs(
            Box.Container:GetDescendants()
        ) do

            StyleObject(Object)

        end

    end

    --------------------------------------------------------
    -- Hover
    --------------------------------------------------------

    if not Holder:GetAttribute(
        "KamHoverConnected"
    ) then

        Holder:SetAttribute(
            "KamHoverConnected",
            true
        )

        Holder.MouseEnter:Connect(function()

            Animate(
                Holder,
                {
                    BackgroundColor3 =
                        Modern.CardHover
                }
            )

        end)

        Holder.MouseLeave:Connect(function()

            Animate(
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
-- STYLE TAB BUTTON
------------------------------------------------------------

local function StyleTab(Button)

    if not Button then
        return
    end

    if not Button:IsA("GuiObject") then
        return
    end

    Corner(Button, 10)

    Button.BackgroundTransparency = 1

    --------------------------------------------------------
    -- Text
    --------------------------------------------------------

    for _, Object in ipairs(
        Button:GetDescendants()
    ) do

        SetText(Object)

        if Object:IsA("ImageLabel")
            or Object:IsA("ImageButton") then

            Object.ImageColor3 =
                Modern.SubText

        end
    end

    --------------------------------------------------------
    -- Hover
    --------------------------------------------------------

    if Button:GetAttribute(
        "KamTabConnected"
    ) then
        return
    end

    Button:SetAttribute(
        "KamTabConnected",
        true
    )

    Button.MouseEnter:Connect(function()

        Animate(
            Button,
            {
                BackgroundTransparency = 0.72
            }
        )

    end)

    Button.MouseLeave:Connect(function()

        if not Button:GetAttribute(
            "KamActive"
        ) then

            Animate(
                Button,
                {
                    BackgroundTransparency = 1
                }
            )

        end

    end)

end

------------------------------------------------------------
-- STYLE ALL GROUPBOXES
------------------------------------------------------------

local function StyleTabs()

    for _, TabData in pairs(
        Library.Tabs
    ) do

        if TabData.Groupboxes then

            for _, Box in pairs(
                TabData.Groupboxes
            ) do

                StyleGroupbox(Box)

            end

        end
    end

end

------------------------------------------------------------
-- STYLE SIDEBAR
------------------------------------------------------------

local function StyleSidebar()

    if not Library.WindowContainer then
        return
    end

    local Container =
        Library.WindowContainer

    for _, Object in ipairs(
        Container:GetDescendants()
    ) do

        SetText(Object)

        ----------------------------------------------------
        -- Sidebar-ish ScrollingFrames
        ----------------------------------------------------

        if Object:IsA("ScrollingFrame") then

            Object.ScrollBarThickness = 2

        end

    end

    --------------------------------------------------------
    -- Tab buttons
    --------------------------------------------------------

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

------------------------------------------------------------
-- STYLE WINDOW
------------------------------------------------------------

local function StyleWindow()

    if not Library.WindowContainer then
        return
    end

    local Container =
        Library.WindowContainer

    --------------------------------------------------------
    -- Main container
    --------------------------------------------------------

    if Container:IsA("GuiObject") then

        Container.BackgroundColor3 =
            Modern.Content

    end

    --------------------------------------------------------
    -- Find large window frames
    --------------------------------------------------------

    for _, Object in ipairs(
        Container:GetDescendants()
    ) do

        SetText(Object)

        if Object:IsA("Frame") then

            local Size =
                Object.AbsoluteSize

            ------------------------------------------------
            -- Large cards / containers
            ------------------------------------------------

            if Size.X > 250
                and Size.Y > 100 then

                if Object ~= Container then

                    -- Don't aggressively recolor
                    -- every internal frame.

                    local Existing =
                        Object:FindFirstChild(
                            "KamModernCorner"
                        )

                    if Existing then
                        Existing.CornerRadius =
                            UDim.new(0, 14)
                    end

                end

            end

        end
    end

    StyleSidebar()
    StyleTabs()

end

------------------------------------------------------------
-- ORIGINAL CREATEWINDOW
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
    -- Modern default size
    --------------------------------------------------------

    if Information.Size == nil then

        Information.Size =
            UDim2.fromOffset(
                1050,
                680
            )

    end

    if Information.CornerRadius == nil then
        Information.CornerRadius = 18
    end

    if Information.MinContainerWidth == nil then
        Information.MinContainerWidth = 760
    end

    if Information.MinSidebarWidth == nil then
        Information.MinSidebarWidth = 180
    end

    if Information.SidebarCompactWidth == nil then
        Information.SidebarCompactWidth = 55
    end

    --------------------------------------------------------
    -- Modern animations
    --------------------------------------------------------

    Information.Animations = {
        ToggleWindow = true,
        TabSwitch = true,
        Groupbox = true,
        Dropdown = true,
        KeyPicker = true
    }

    Information.TabTransitionTime = 0.20
    Information.TabSwipeOffset = 16
    Information.TabSwipeFrom = "right"

    --------------------------------------------------------
    -- CREATE ORIGINAL API WINDOW
    --------------------------------------------------------

    local Window =
        OriginalCreateWindow(
            self,
            Information
        )

    --------------------------------------------------------
    -- Apply after Roblox renders everything
    --------------------------------------------------------

    task.defer(function()

        task.wait(0.05)

        StyleWindow()

        task.wait(0.20)

        StyleWindow()

        task.wait(0.50)

        StyleWindow()

    end)

    return Window
end

------------------------------------------------------------
-- PUBLIC STYLE REFRESH
------------------------------------------------------------

function Library:RefreshModernStyle()

    task.defer(function()

        StyleWindow()

    end)

    return true
end

------------------------------------------------------------
-- ACCENT COLOR
------------------------------------------------------------

function Library:SetModernAccent(Color)

    assert(
        typeof(Color) == "Color3",
        "Color must be Color3"
    )

    Modern.Accent = Color

    Library.Scheme.AccentColor =
        Color

    task.defer(function()

        StyleWindow()

    end)

end

------------------------------------------------------------
-- EXPOSE STYLE
------------------------------------------------------------

Library.Modern = Modern
Library.ModernStyle = true
Library.ModernVersion = "4.0"

------------------------------------------------------------
-- RETURN
------------------------------------------------------------

return Library
