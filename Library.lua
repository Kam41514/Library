--// Modern Obsidian Library
--// Kam41514
--// API: Original Obsidian
--// UI: Modern / Rounded / Clean

local HttpGet = game.HttpGet

local OBSIDIAN_URL =
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"

----------------------------------------------------------------
-- LOAD ORIGINAL OBSIDIAN
----------------------------------------------------------------

local Success, Result = pcall(function()
    return loadstring(
        HttpGet(game, OBSIDIAN_URL)
    )()
end)

if not Success then
    error(
        "[ModernLibrary] Obsidian Library yüklenemedi:\n"
        .. tostring(Result)
    )
end

local Library = Result

----------------------------------------------------------------
-- MODERN THEME
----------------------------------------------------------------

Library.Scheme = {
    BackgroundColor = Color3.fromRGB(10, 11, 15),
    MainColor = Color3.fromRGB(18, 19, 26),

    AccentColor = Color3.fromRGB(139, 92, 246),

    OutlineColor = Color3.fromRGB(43, 45, 56),

    FontColor = Color3.fromRGB(242, 242, 247),

    -- Daha okunaklı
    Font = Font.fromEnum(Enum.Font.Gotham),

    RedColor = Color3.fromRGB(255, 82, 95),
    DestructiveColor = Color3.fromRGB(220, 65, 78),

    DarkColor = Color3.fromRGB(7, 8, 11),
    WhiteColor = Color3.fromRGB(255, 255, 255),

    BackgroundImage = "",
}

----------------------------------------------------------------
-- MODERN SETTINGS
----------------------------------------------------------------

Library.CornerRadius = 14

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

Library.DropdownTransitionInfo = TweenInfo.new(
    0.18,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

Library.GroupboxTweenInfo = TweenInfo.new(
    0.18,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

----------------------------------------------------------------
-- COLORS
----------------------------------------------------------------

local COLORS = {
    Background = Color3.fromRGB(10, 11, 15),
    Sidebar = Color3.fromRGB(13, 14, 19),

    Panel = Color3.fromRGB(18, 19, 26),
    Panel2 = Color3.fromRGB(21, 22, 30),

    Element = Color3.fromRGB(24, 25, 34),
    ElementHover = Color3.fromRGB(30, 31, 42),

    Border = Color3.fromRGB(43, 45, 56),

    Text = Color3.fromRGB(242, 242, 247),
    SubText = Color3.fromRGB(155, 157, 170),

    Accent = Color3.fromRGB(139, 92, 246),
}

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------

local function Corner(Object, Radius)
    if not Object then
        return
    end

    if not Object:IsA("GuiObject") then
        return
    end

    local Existing = Object:FindFirstChild("ModernCorner")

    if not Existing then
        Existing = Instance.new("UICorner")
        Existing.Name = "ModernCorner"
        Existing.Parent = Object
    end

    Existing.CornerRadius = UDim.new(0, Radius)
end

local function Stroke(Object, Color, Transparency)
    if not Object then
        return
    end

    if not Object:IsA("GuiObject") then
        return
    end

    local Existing = Object:FindFirstChild("ModernStroke")

    if not Existing then
        Existing = Instance.new("UIStroke")
        Existing.Name = "ModernStroke"
        Existing.Parent = Object
    end

    Existing.Color = Color or COLORS.Border
    Existing.Transparency = Transparency or 0.25
    Existing.Thickness = 1
end

local function Style(Object)
    if not Object then
        return
    end

    if Object:IsA("TextLabel") then

        Object.FontFace = Library.Scheme.Font
        Object.TextColor3 = COLORS.Text

    elseif Object:IsA("TextButton") then

        Object.FontFace = Library.Scheme.Font
        Object.TextColor3 = COLORS.Text

        Corner(Object, 9)

    elseif Object:IsA("TextBox") then

        Object.FontFace = Library.Scheme.Font
        Object.TextColor3 = COLORS.Text

        Corner(Object, 9)
        Stroke(Object, COLORS.Border, 0.3)

    elseif Object:IsA("ScrollingFrame") then

        Object.ScrollBarThickness = 3
        Object.ScrollBarImageColor3 = COLORS.Accent
        Object.ScrollBarImageTransparency = 0.25

    end
end

----------------------------------------------------------------
-- STYLE ENTIRE GUI
----------------------------------------------------------------

local function StyleTree(Root)
    if not Root then
        return
    end

    Style(Root)

    for _, Object in ipairs(Root:GetDescendants()) do
        Style(Object)
    end
end

----------------------------------------------------------------
-- FIND MAIN GUI
----------------------------------------------------------------

local function GetRoot()
    return Library.WindowContainer
        or Library.Window
        or Library.ScreenGui
end

----------------------------------------------------------------
-- MODERNIZE WINDOW
----------------------------------------------------------------

local OldCreateWindow = Library.CreateWindow

Library.CreateWindow = function(self, Options)

    Options = Options or {}

    ------------------------------------------------------------
    -- Modern defaults
    ------------------------------------------------------------

    Options.Size =
        Options.Size
        or UDim2.fromOffset(900, 600)

    Options.CornerRadius =
        Options.CornerRadius
        or 14

    Options.Font =
        Options.Font
        or Enum.Font.Gotham

    Options.Center =
        Options.Center ~= false

    Options.AutoShow =
        Options.AutoShow ~= false

    Options.NotifySide =
        Options.NotifySide
        or "Right"

    ------------------------------------------------------------
    -- Create ORIGINAL Obsidian Window
    ------------------------------------------------------------

    local Window = OldCreateWindow(self, Options)

    ------------------------------------------------------------
    -- Style after construction
    ------------------------------------------------------------

    task.defer(function()

        task.wait()

        local Root = GetRoot()

        if Root then
            StyleTree(Root)
        end

        --------------------------------------------------------
        -- Window
        --------------------------------------------------------

        if Library.WindowContainer then
            Corner(
                Library.WindowContainer,
                18
            )

            Stroke(
                Library.WindowContainer,
                COLORS.Border,
                0.20
            )
        end

        --------------------------------------------------------
        -- Live elements
        --------------------------------------------------------

        if Root then

            Root.DescendantAdded:Connect(function(Object)

                task.defer(function()

                    if Object and Object.Parent then
                        Style(Object)

                        for _, Child in ipairs(
                            Object:GetDescendants()
                        ) do
                            Style(Child)
                        end
                    end

                end)

            end)

        end

    end)

    return Window
end

----------------------------------------------------------------
-- PUBLIC MODERN STYLE
----------------------------------------------------------------

function Library:ApplyModernStyle()

    local Root = GetRoot()

    if not Root then
        return false
    end

    StyleTree(Root)

    if Library.WindowContainer then

        Corner(
            Library.WindowContainer,
            18
        )

        Stroke(
            Library.WindowContainer,
            COLORS.Border,
            0.20
        )

    end

    return true
end

----------------------------------------------------------------
-- ACCENT
----------------------------------------------------------------

function Library:SetModernAccent(Color)

    if typeof(Color) ~= "Color3" then
        return false
    end

    COLORS.Accent = Color
    Library.Scheme.AccentColor = Color

    return true
end

----------------------------------------------------------------
-- VERSION
----------------------------------------------------------------

Library.Modern = true
Library.ModernVersion = "2.0"

----------------------------------------------------------------
-- RETURN REAL OBSIDIAN LIBRARY
----------------------------------------------------------------

return Library
