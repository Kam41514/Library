--[[
    Kam41514 Modern Library
    Obsidian-compatible visual skin

    API değiştirilmez.
    CreateWindow / AddTab / Groupbox / Toggle / Slider /
    Dropdown / Button / Input / ThemeManager / SaveManager
    Obsidian ile uyumlu kalır.
]]

------------------------------------------------------------
-- LOAD ORIGINAL OBSIDIAN LIBRARY
------------------------------------------------------------

local OBSIDIAN_URL =
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"

local ok, result = pcall(function()
    return loadstring(game:HttpGet(OBSIDIAN_URL))()
end)

if not ok or type(result) ~= "table" then
    error("[ModernLibrary] Obsidian Library yüklenemedi: " .. tostring(result))
end

local Library = result

------------------------------------------------------------
-- SERVICES
------------------------------------------------------------

local TweenService = game:GetService("TweenService")

------------------------------------------------------------
-- MODERN PALETTE
------------------------------------------------------------

local Colors = {
    Background = Color3.fromRGB(8, 9, 13),
    Main = Color3.fromRGB(14, 15, 21),

    Sidebar = Color3.fromRGB(11, 12, 17),
    Content = Color3.fromRGB(12, 13, 18),

    Card = Color3.fromRGB(19, 20, 28),
    CardHover = Color3.fromRGB(24, 25, 35),

    Element = Color3.fromRGB(24, 25, 34),
    ElementHover = Color3.fromRGB(31, 32, 43),

    Accent = Color3.fromRGB(139, 92, 246),
    AccentLight = Color3.fromRGB(167, 139, 250),

    Text = Color3.fromRGB(245, 245, 250),
    SecondaryText = Color3.fromRGB(164, 166, 180),

    Border = Color3.fromRGB(43, 45, 58),

    Success = Color3.fromRGB(74, 222, 128),
    Red = Color3.fromRGB(248, 113, 113),
}

------------------------------------------------------------
-- SCHEME
------------------------------------------------------------

-- ÖNEMLİ:
-- Scheme tablosunu değiştirmiyoruz.
-- Mevcut ThemeManager referansları korunuyor.

Library.Scheme.BackgroundColor = Colors.Background
Library.Scheme.MainColor = Colors.Main
Library.Scheme.AccentColor = Colors.Accent
Library.Scheme.OutlineColor = Colors.Border
Library.Scheme.FontColor = Colors.Text
Library.Scheme.RedColor = Colors.Red
Library.Scheme.DestructiveColor = Color3.fromRGB(220, 70, 80)
Library.Scheme.DarkColor = Color3.fromRGB(5, 6, 9)
Library.Scheme.WhiteColor = Color3.fromRGB(255, 255, 255)

-- Daha okunaklı font
Library.Scheme.Font = Font.fromEnum(Enum.Font.Gotham)

------------------------------------------------------------
-- ANIMATION
------------------------------------------------------------

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
    0.22,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

Library.DropdownTransitionInfo = TweenInfo.new(
    0.18,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function AddCorner(Object, Radius)

    if not Object or not Object:IsA("GuiObject") then
        return
    end

    local Corner = Object:FindFirstChild("ModernCorner")

    if not Corner then
        Corner = Instance.new("UICorner")
        Corner.Name = "ModernCorner"
        Corner.Parent = Object
    end

    Corner.CornerRadius = UDim.new(0, Radius)
end


local function AddStroke(Object, Color, Transparency)

    if not Object or not Object:IsA("GuiObject") then
        return
    end

    local Stroke = Object:FindFirstChild("ModernStroke")

    if not Stroke then
        Stroke = Instance.new("UIStroke")
        Stroke.Name = "ModernStroke"
        Stroke.Parent = Object
    end

    Stroke.Color = Color or Colors.Border
    Stroke.Transparency = Transparency or 0.2
    Stroke.Thickness = 1
end


local function Tween(Object, Properties)

    if not Object then
        return
    end

    local Animation = TweenService:Create(
        Object,
        Library.TweenInfo,
        Properties
    )

    Animation:Play()

    return Animation
end

------------------------------------------------------------
-- TEXT STYLE
------------------------------------------------------------

local function StyleText(Object)

    if Object:IsA("TextLabel")
        or Object:IsA("TextButton")
        or Object:IsA("TextBox") then

        pcall(function()
            Object.FontFace = Library.Scheme.Font
        end)

        if Object.TextSize < 12 then
            Object.TextSize = 13
        end
    end
end

------------------------------------------------------------
-- ELEMENT STYLE
------------------------------------------------------------

local function StyleElement(Object)

    if not Object or not Object:IsA("GuiObject") then
        return
    end

    StyleText(Object)

    --------------------------------------------------------
    -- INPUT / DROPDOWN / BUTTON
    --------------------------------------------------------

    if Object:IsA("TextButton") then

        AddCorner(Object, 9)

        Object.MouseEnter:Connect(function()

            if Object.Visible then

                local Original =
                    Object:GetAttribute("ModernOriginalColor")

                if not Original then
                    Object:SetAttribute(
                        "ModernOriginalColor",
                        Object.BackgroundColor3
                    )
                end

                Tween(Object, {
                    BackgroundColor3 = Colors.ElementHover
                })

            end

        end)

        Object.MouseLeave:Connect(function()

            local Original =
                Object:GetAttribute("ModernOriginalColor")

            if Original then
                Tween(Object, {
                    BackgroundColor3 = Color3.fromRGB(
                        Original,
                        Original,
                        Original
                    )
                })
            end

        end)

    elseif Object:IsA("TextBox") then

        AddCorner(Object, 9)
        AddStroke(Object, Colors.Border, 0.15)

        Object.Focused:Connect(function()

            Tween(Object, {
                BackgroundColor3 = Colors.ElementHover
            })

            local Stroke =
                Object:FindFirstChild("ModernStroke")

            if Stroke then
                Tween(Stroke, {
                    Color = Colors.Accent,
                    Transparency = 0
                })
            end

        end)

        Object.FocusLost:Connect(function()

            Tween(Object, {
                BackgroundColor3 = Colors.Element
            })

            local Stroke =
                Object:FindFirstChild("ModernStroke")

            if Stroke then
                Tween(Stroke, {
                    Color = Colors.Border,
                    Transparency = 0.15
                })
            end

        end)

    end
end

------------------------------------------------------------
-- STYLE GROUPBOX
------------------------------------------------------------

local function StyleGroupbox(Groupbox)

    if not Groupbox or not Groupbox.Holder then
        return
    end

    local Holder = Groupbox.Holder

    --------------------------------------------------------
    -- CARD
    --------------------------------------------------------

    Holder.BackgroundColor3 = Colors.Card

    AddCorner(
        Holder,
        15
    )

    AddStroke(
        Holder,
        Colors.Border,
        0.15
    )

    --------------------------------------------------------
    -- HEADER
    --------------------------------------------------------

    local Children = Holder:GetChildren()

    for _, Child in ipairs(Children) do

        if Child:IsA("TextLabel") then

            Child.FontFace = Library.Scheme.Font

            if Child.TextSize < 14 then
                Child.TextSize = 14
            end

            Child.TextColor3 = Colors.Text

        elseif Child:IsA("ImageLabel") then

            if Child.Size.X.Offset <= 24
                and Child.Size.Y.Offset <= 24 then

                Child.ImageColor3 = Colors.AccentLight

            end

        end

    end

    --------------------------------------------------------
    -- CONTENT
    --------------------------------------------------------

    if Groupbox.Container then

        for _, Object in ipairs(
            Groupbox.Container:GetDescendants()
        ) do

            StyleElement(Object)

        end

    end

end

------------------------------------------------------------
-- STYLE TAB BUTTON
------------------------------------------------------------

local function StyleTabButton(Button)

    if not Button then
        return
    end

    AddCorner(
        Button,
        10
    )

    Button.BackgroundColor3 =
        Colors.Element

    Button.BackgroundTransparency = 1

    --------------------------------------------------------
    -- LABEL
    --------------------------------------------------------

    local Label = Button:FindFirstChildWhichIsA(
        "TextLabel",
        true
    )

    if Label then

        Label.FontFace =
            Library.Scheme.Font

        Label.TextSize = 14
        Label.TextColor3 =
            Colors.Text

    end

    --------------------------------------------------------
    -- ICON
    --------------------------------------------------------

    local Icon = Button:FindFirstChildWhichIsA(
        "ImageLabel",
        true
    )

    if Icon then
        Icon.ImageColor3 =
            Colors.AccentLight
    end

end

------------------------------------------------------------
-- MODERN TAB SELECTION
------------------------------------------------------------

local function SetupTabAnimations()

    for _, Entry in ipairs(Library.TabButtons) do

        local Label = Entry.Label

        if not Label then
            continue
        end

        local Button = Label.Parent

        if not Button then
            continue
        end

        StyleTabButton(Button)

        ----------------------------------------------------
        -- ACTIVE INDICATOR
        ----------------------------------------------------

        local Indicator =
            Button:FindFirstChild("ModernIndicator")

        if not Indicator then

            Indicator = Instance.new("Frame")
            Indicator.Name = "ModernIndicator"

            Indicator.AnchorPoint =
                Vector2.new(0, 0.5)

            Indicator.Position =
                UDim2.new(0, 4, 0.5, 0)

            Indicator.Size =
                UDim2.fromOffset(3, 22)

            Indicator.BackgroundColor3 =
                Colors.Accent

            Indicator.BorderSizePixel = 0

            Indicator.BackgroundTransparency = 1

            Indicator.Parent = Button

            AddCorner(
                Indicator,
                3
            )

        end

        ----------------------------------------------------
        -- HOVER
        ----------------------------------------------------

        Button.MouseEnter:Connect(function()

            if Library.ActiveTab then

                local ActiveLabel =
                    Library.ActiveTab

                if Label.Text ~= ActiveLabel.Name then

                    Tween(Button, {
                        BackgroundTransparency = 0.65
                    })

                end

            end

        end)

        Button.MouseLeave:Connect(function()

            if Library.ActiveTab then

                Tween(Button, {
                    BackgroundTransparency = 1
                })

            end

        end)

        ----------------------------------------------------
        -- CLICK
        ----------------------------------------------------

        Button.MouseButton1Click:Connect(function()

            for _, Other in ipairs(
                Library.TabButtons
            ) do

                if Other.Label then

                    local OtherButton =
                        Other.Label.Parent

                    if OtherButton then

                        local OtherIndicator =
                            OtherButton:FindFirstChild(
                                "ModernIndicator"
                            )

                        Tween(
                            OtherButton,
                            {
                                BackgroundTransparency = 1
                            }
                        )

                        if OtherIndicator then

                            Tween(
                                OtherIndicator,
                                {
                                    BackgroundTransparency = 1
                                }
                            )

                        end

                    end

                end

            end

            Tween(
                Button,
                {
                    BackgroundTransparency = 0
                }
            )

            Tween(
                Indicator,
                {
                    BackgroundTransparency = 0
                }
            )

        end)

    end

end

------------------------------------------------------------
-- STYLE WINDOW
------------------------------------------------------------

local function StyleWindow()

    local MainFrame = Library.WindowContainer

    if not MainFrame then
        return
    end

    -- WindowContainer'ın parent'ı ana frame'dir.
    local WindowFrame = MainFrame.Parent

    --------------------------------------------------------
    -- WINDOW
    --------------------------------------------------------

    if WindowFrame and WindowFrame:IsA("GuiObject") then

        WindowFrame.BackgroundColor3 =
            Colors.Main

        AddCorner(
            WindowFrame,
            20
        )

        AddStroke(
            WindowFrame,
            Colors.Border,
            0.05
        )

    end

    --------------------------------------------------------
    -- CONTENT
    --------------------------------------------------------

    MainFrame.BackgroundColor3 =
        Colors.Content

    --------------------------------------------------------
    -- CHILDREN
    --------------------------------------------------------

    for _, Object in ipairs(
        MainFrame:GetDescendants()
    ) do

        StyleText(Object)

        if Object:IsA("TextBox") then

            AddCorner(
                Object,
                9
            )

            AddStroke(
                Object,
                Colors.Border,
                0.15
            )

        end

    end

    --------------------------------------------------------
    -- SIDEBAR
    --------------------------------------------------------

    if WindowFrame then

        for _, Object in ipairs(
            WindowFrame:GetChildren()
        ) do

            if Object:IsA("ScrollingFrame") then

                Object.BackgroundColor3 =
                    Colors.Sidebar

            end

        end

    end

    --------------------------------------------------------
    -- GROUPBOXES
    --------------------------------------------------------

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

    --------------------------------------------------------
    -- TABS
    --------------------------------------------------------

    SetupTabAnimations()

end

------------------------------------------------------------
-- ORIGINAL CREATE WINDOW
------------------------------------------------------------

local OriginalCreateWindow =
    Library.CreateWindow

Library.CreateWindow = function(
    self,
    WindowInfo
)

    WindowInfo =
        WindowInfo or {}

    --------------------------------------------------------
    -- MODERN DEFAULTS
    --------------------------------------------------------

    if WindowInfo.Size == nil then

        WindowInfo.Size =
            UDim2.fromOffset(
                1050,
                680
            )

    end

    if WindowInfo.Font == nil then
        WindowInfo.Font =
            Enum.Font.Gotham
    end

    if WindowInfo.CornerRadius == nil then
        WindowInfo.CornerRadius = 18
    end

    if WindowInfo.MinContainerWidth == nil then
        WindowInfo.MinContainerWidth = 700
    end

    WindowInfo.Animations = {
        ToggleWindow = true,
        TabSwitch = true,
        Groupbox = true,
        Dropdown = true,
        KeyPicker = true,
    }

    WindowInfo.TabTransitionTime = 0.18

    WindowInfo.TabSwipeOffset = 18

    WindowInfo.TabSwipeFrom = "right"

    --------------------------------------------------------
    -- CREATE ORIGINAL WINDOW
    --------------------------------------------------------

    local Window =
        OriginalCreateWindow(
            self,
            WindowInfo
        )

    --------------------------------------------------------
    -- WAIT FOR UI
    --------------------------------------------------------

    task.defer(function()

        task.wait(0.05)

        StyleWindow()

        ----------------------------------------------------
        -- REAPPLY AFTER ALL HUB ELEMENTS ARE CREATED
        ----------------------------------------------------

        task.wait(0.25)

        StyleWindow()

    end)

    return Window

end

------------------------------------------------------------
-- PUBLIC MODERN STYLE
------------------------------------------------------------

function Library:ApplyModernStyle()

    task.defer(function()

        StyleWindow()

    end)

    return true

end

------------------------------------------------------------
-- ACCENT API
------------------------------------------------------------

function Library:SetModernAccent(Color)

    if typeof(Color) ~= "Color3" then
        return false
    end

    Colors.Accent = Color
    Colors.AccentLight = Color:Lerp(
        Color3.new(1, 1, 1),
        0.25
    )

    Library.Scheme.AccentColor =
        Color

    return true

end

------------------------------------------------------------
-- MODERN INFO
------------------------------------------------------------

Library.Modern = true
Library.ModernVersion = "3.0"
Library.ModernColors = Colors

------------------------------------------------------------
-- RETURN ORIGINAL API OBJECT
------------------------------------------------------------

return Library
