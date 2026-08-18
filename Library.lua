--// KamUI Modern Obsidian
--// API preserved - visual layer redesigned

local HttpGet = game.HttpGet
local LoadString = loadstring

local OBSIDIAN_URL =
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"

local Source = HttpGet(
    game,
    OBSIDIAN_URL .. "?kamui=" .. tostring(math.floor(os.clock() * 100000))
)

local Loader, CompileError = LoadString(Source)

if not Loader then
    error("[KamUI] Obsidian compile error:\n" .. tostring(CompileError))
end

local Library = Loader()

if type(Library) ~= "table" then
    error("[KamUI] Obsidian Library failed to load.")
end

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

---------------------------------------------------------------------
-- MODERN THEME
---------------------------------------------------------------------

Library.CornerRadius = 14

Library.Scheme.BackgroundColor = Color3.fromRGB(5, 5, 7)
Library.Scheme.MainColor       = Color3.fromRGB(12, 12, 15)
Library.Scheme.AccentColor     = Color3.fromRGB(135, 100, 255)
Library.Scheme.OutlineColor    = Color3.fromRGB(29, 29, 35)
Library.Scheme.FontColor       = Color3.fromRGB(242, 242, 247)
Library.Scheme.DarkColor       = Color3.fromRGB(2, 2, 3)

Library.Scheme.Font =
    Font.fromEnum(Enum.Font.GothamMedium)

Library.TweenInfo =
    TweenInfo.new(
        0.14,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )

Library.TabTransitionInfo =
    TweenInfo.new(
        0.18,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )

Library.GroupboxTweenInfo =
    TweenInfo.new(
        0.16,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )

Library.DropdownTransitionInfo =
    TweenInfo.new(
        0.16,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------

local function Corner(Object, Radius)
    if not Object then
        return
    end

    local Existing = Object:FindFirstChild("KamUI_Corner")

    if Existing then
        Existing.CornerRadius =
            UDim.new(0, Radius)

        return Existing
    end

    local C = Instance.new("UICorner")

    C.Name = "KamUI_Corner"
    C.CornerRadius = UDim.new(0, Radius)
    C.Parent = Object

    return C
end

local function Stroke(Object, Color, Transparency, Thickness)
    if not Object then
        return
    end

    local Existing =
        Object:FindFirstChild("KamUI_Stroke")

    if Existing and Existing:IsA("UIStroke") then
        Existing.Color = Color
        Existing.Transparency = Transparency
        Existing.Thickness = Thickness

        return Existing
    end

    local S = Instance.new("UIStroke")

    S.Name = "KamUI_Stroke"
    S.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    S.Color = Color
    S.Transparency = Transparency
    S.Thickness = Thickness
    S.Parent = Object

    return S
end

local function SetFont(Object, Size)
    if not (
        Object:IsA("TextLabel")
        or Object:IsA("TextButton")
        or Object:IsA("TextBox")
    ) then
        return
    end

    pcall(function()
        Object.FontFace =
            Font.fromEnum(Enum.Font.GothamMedium)
    end)

    if Size then
        Object.TextSize = Size
    elseif Object.TextSize < 13 then
        Object.TextSize = 13
    end

    Object.TextColor3 =
        Library.Scheme.FontColor
end

---------------------------------------------------------------------
-- PARTICLES
---------------------------------------------------------------------

local function CreateParticles(Main)
    if not Main then
        return
    end

    local Existing =
        Main:FindFirstChild("KamUI_Particles")

    if Existing then
        Existing:Destroy()
    end

    local Holder = Instance.new("Frame")

    Holder.Name = "KamUI_Particles"
    Holder.BackgroundTransparency = 1
    Holder.BorderSizePixel = 0
    Holder.Size = UDim2.fromScale(1, 1)
    Holder.Position = UDim2.fromScale(0, 0)
    Holder.ClipsDescendants = true
    Holder.ZIndex = 0
    Holder.Parent = Main

    local Random = Random.new()

    local ParticleList = {}

    for i = 1, 26 do
        local Dot = Instance.new("Frame")

        Dot.Name = "Dot"
        Dot.BorderSizePixel = 0
        Dot.BackgroundColor3 =
            Color3.fromRGB(
                Random:NextInteger(35, 65),
                Random:NextInteger(35, 65),
                Random:NextInteger(40, 72)
            )

        Dot.BackgroundTransparency =
            Random:NextNumber(0.78, 0.91)

        local Size =
            Random:NextNumber(1.5, 3)

        Dot.Size =
            UDim2.fromOffset(Size, Size)

        Dot.Position =
            UDim2.fromScale(
                Random:NextNumber(0.02, 0.98),
                Random:NextNumber(0.02, 0.98)
            )

        Dot.ZIndex = 0
        Dot.Parent = Holder

        Corner(Dot, 10)

        table.insert(ParticleList, Dot)
    end

    task.spawn(function()
        while Holder.Parent and not Library.Unloaded do
            for _, Dot in ipairs(ParticleList) do
                if Dot.Parent then
                    task.spawn(function()
                        local Target =
                            UDim2.fromScale(
                                math.clamp(
                                    Dot.Position.X.Scale +
                                    Random:NextNumber(-0.025, 0.025),
                                    0,
                                    1
                                ),
                                math.clamp(
                                    Dot.Position.Y.Scale +
                                    Random:NextNumber(-0.025, 0.025),
                                    0,
                                    1
                                )
                            )

                        local Tween =
                            TweenService:Create(
                                Dot,
                                TweenInfo.new(
                                    Random:NextNumber(3, 6),
                                    Enum.EasingStyle.Sine,
                                    Enum.EasingDirection.InOut
                                ),
                                {
                                    Position = Target
                                }
                            )

                        Tween:Play()
                        Tween.Completed:Wait()
                    end)
                end
            end

            task.wait(1.5)
        end
    end)
end

---------------------------------------------------------------------
-- WINDOW SKIN
---------------------------------------------------------------------

local function StyleWindow(Window)
    if not Library.ScreenGui then
        return
    end

    local Gui = Library.ScreenGui

    -----------------------------------------------------------------
    -- FIND MAIN
    -----------------------------------------------------------------

    local Main =
        Gui:FindFirstChild("Main", true)

    if not Main then
        Main = Gui:FindFirstChildWhichIsA(
            "TextButton",
            true
        )
    end

    if not Main then
        return
    end

    -----------------------------------------------------------------
    -- MAIN WINDOW
    -----------------------------------------------------------------

    Main.BackgroundColor3 =
        Color3.fromRGB(5, 5, 7)

    Main.BackgroundTransparency = 0
    Main.ClipsDescendants = true

    Corner(Main, 14)

    Stroke(
        Main,
        Color3.fromRGB(28, 28, 34),
        0,
        1
    )

    CreateParticles(Main)

    -----------------------------------------------------------------
    -- ALL UI
    -----------------------------------------------------------------

    for _, Object in ipairs(Gui:GetDescendants()) do

        -------------------------------------------------------------
        -- TEXT
        -------------------------------------------------------------

        if Object:IsA("TextLabel") then
            SetFont(Object)

            if Object.TextSize >= 17 then
                Object.TextSize = 16
            elseif Object.TextSize >= 14 then
                Object.TextSize = 14
            end
        end

        if Object:IsA("TextButton") then
            SetFont(Object)
        end

        if Object:IsA("TextBox") then
            SetFont(Object, 13)

            Object.BackgroundColor3 =
                Color3.fromRGB(10, 10, 13)

            Object.BackgroundTransparency = 0

            Corner(Object, 8)

            Stroke(
                Object,
                Color3.fromRGB(31, 31, 38),
                0,
                1
            )
        end

        -------------------------------------------------------------
        -- SCROLLING
        -------------------------------------------------------------

        if Object:IsA("ScrollingFrame") then
            Object.ScrollBarThickness = 2

            Object.ScrollBarImageColor3 =
                Color3.fromRGB(70, 70, 80)

            Object.ScrollBarImageTransparency = 0.25
        end

        -------------------------------------------------------------
        -- TAB BUTTONS
        -------------------------------------------------------------

        if Object:IsA("TextButton") then
            local Parent = Object.Parent

            if Parent then
                local Name =
                    string.lower(Object.Name)

                local ParentName =
                    string.lower(Parent.Name)

                if
                    ParentName:find("tab")
                    or Name:find("tab")
                then
                    Corner(Object, 8)

                    Object.BackgroundColor3 =
                        Color3.fromRGB(18, 18, 22)

                    Object.BackgroundTransparency = 1

                    Object.MouseEnter:Connect(function()
                        if not Library.Unloaded then
                            TweenService:Create(
                                Object,
                                Library.TweenInfo,
                                {
                                    BackgroundTransparency = 0.35
                                }
                            ):Play()
                        end
                    end)

                    Object.MouseLeave:Connect(function()
                        if not Library.Unloaded then
                            TweenService:Create(
                                Object,
                                Library.TweenInfo,
                                {
                                    BackgroundTransparency = 1
                                }
                            ):Play()
                        end
                    end)
                end
            end
        end
    end

    -----------------------------------------------------------------
    -- GROUPBOX SKIN
    -----------------------------------------------------------------

    for _, Object in ipairs(
        Gui:GetDescendants()
    ) do

        if Object:IsA("Frame") then

            local Size = Object.AbsoluteSize

            if Size.X >= 150 and Size.Y >= 40 then

                local ParentName =
                    Object.Parent
                    and string.lower(
                        Object.Parent.Name
                    )
                    or ""

                local ObjectName =
                    string.lower(Object.Name)

                if
                    ObjectName:find("group")
                    or ObjectName:find("box")
                    or ParentName:find("group")
                    or ParentName:find("box")
                then

                    Corner(Object, 10)

                    Stroke(
                        Object,
                        Color3.fromRGB(27, 27, 33),
                        0,
                        1
                    )

                    Object.BackgroundColor3 =
                        Color3.fromRGB(10, 10, 13)

                    Object.BackgroundTransparency = 0
                end
            end
        end
    end

    -----------------------------------------------------------------
    -- SLIDER / INPUT STYLE
    -----------------------------------------------------------------

    for _, Object in ipairs(
        Gui:GetDescendants()
    ) do

        if Object:IsA("Frame") then

            local Name =
                string.lower(Object.Name)

            if
                Name:find("slider")
                or Name:find("track")
            then
                Corner(Object, 6)
            end
        end

        if Object:IsA("TextButton") then

            local Name =
                string.lower(Object.Name)

            if
                Name:find("toggle")
                or Name:find("checkbox")
            then

                Corner(Object, 7)

                Object.MouseEnter:Connect(function()
                    TweenService:Create(
                        Object,
                        Library.TweenInfo,
                        {
                            BackgroundTransparency =
                                math.max(
                                    0,
                                    Object.BackgroundTransparency - 0.08
                                )
                        }
                    ):Play()
                end)
            end
        end
    end
end

---------------------------------------------------------------------
-- CREATE WINDOW WRAPPER
---------------------------------------------------------------------

local OriginalCreateWindow =
    Library.CreateWindow

Library.CreateWindow = function(self, Info)

    Info = Info or {}

    Info.CornerRadius =
        Info.CornerRadius or 14

    Info.Font =
        Info.Font or Enum.Font.GothamMedium

    Info.Animations = {
        ToggleWindow = true,
        TabSwitch = true,
        Groupbox = true,
        Dropdown = true,
        KeyPicker = true
    }

    Info.TabTransitionTime =
        Info.TabTransitionTime or 0.18

    Info.TabSwipeOffset =
        Info.TabSwipeOffset or 12

    local Window =
        OriginalCreateWindow(
            self,
            Info
        )

    task.defer(function()
        task.wait(0.08)

        pcall(function()
            Window:SetCornerRadius(14)
        end)

        pcall(function()
            Window:SetAnimations(
                Info.Animations,
                0.18,
                12,
                "bottom"
            )
        end)

        pcall(function()
            StyleWindow(Window)
        end)
    end)

    return Window
end

---------------------------------------------------------------------
-- RE-STYLE NEW ELEMENTS
---------------------------------------------------------------------

task.spawn(function()

    local LastCount = 0

    while not Library.Unloaded do

        task.wait(0.7)

        if Library.ScreenGui then

            local Count = #Library.ScreenGui:GetDescendants()

            if Count ~= LastCount then
                LastCount = Count

                pcall(function()
                    StyleWindow(Library.Window)
                end)
            end
        end
    end
end)

---------------------------------------------------------------------
-- MARKER
---------------------------------------------------------------------

Library.KamUI = true
Library.KamUIVersion = "2.0.0"

return Library
