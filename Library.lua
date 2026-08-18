--// KamUI Obsidian Skin
--// Keeps the original Obsidian API intact.
--// Visual layer only.

local OBsidIAN_URL =
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"

local source = game:HttpGet(
    OBsidIAN_URL .. "?kamui=" .. tostring(os.clock())
)

local loader, compileError = loadstring(source)

if not loader then
    error(
        "[KamUI] Obsidian Library compile error:\n"
        .. tostring(compileError)
    )
end

local Library = loader()

if type(Library) ~= "table" then
    error("[KamUI] Obsidian Library did not return a table.")
end

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

---------------------------------------------------------------------
-- KAMUI THEME
---------------------------------------------------------------------

Library.CornerRadius = 14

Library.Scheme.BackgroundColor =
    Color3.fromRGB(5, 5, 7)

Library.Scheme.MainColor =
    Color3.fromRGB(11, 11, 14)

Library.Scheme.AccentColor =
    Color3.fromRGB(125, 90, 255)

Library.Scheme.OutlineColor =
    Color3.fromRGB(30, 30, 36)

Library.Scheme.FontColor =
    Color3.fromRGB(245, 245, 248)

Library.Scheme.DarkColor =
    Color3.fromRGB(1, 1, 2)

Library.Scheme.RedColor =
    Color3.fromRGB(255, 70, 80)

Library.Scheme.DestructiveColor =
    Color3.fromRGB(220, 50, 60)

Library.Scheme.WhiteColor =
    Color3.fromRGB(255, 255, 255)

---------------------------------------------------------------------
-- FONT
---------------------------------------------------------------------

Library.Scheme.Font =
    Font.fromEnum(Enum.Font.GothamMedium)

---------------------------------------------------------------------
-- ANIMATIONS
---------------------------------------------------------------------

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
    0.16,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

Library.KeyPickerTransitionInfo = TweenInfo.new(
    0.15,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

Library.RotatingChevronTweenInfo = TweenInfo.new(
    0.22,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

---------------------------------------------------------------------
-- DEFAULT WINDOW SETTINGS
---------------------------------------------------------------------

-- We do not replace CreateWindow.
-- We only intercept its returned Window and add the visual layer.

local OriginalCreateWindow = Library.CreateWindow

---------------------------------------------------------------------
-- PARTICLE SYSTEM
---------------------------------------------------------------------

local function CreateParticles(MainFrame)

    if not MainFrame then
        return
    end

    local old = MainFrame:FindFirstChild(
        "KamUI_BackgroundParticles"
    )

    if old then
        old:Destroy()
    end

    local particleHolder = Instance.new("Frame")

    particleHolder.Name =
        "KamUI_BackgroundParticles"

    particleHolder.BackgroundTransparency = 1

    particleHolder.BorderSizePixel = 0

    particleHolder.Size =
        UDim2.fromScale(1, 1)

    particleHolder.Position =
        UDim2.fromScale(0, 0)

    particleHolder.ClipsDescendants = true

    particleHolder.ZIndex = 0

    particleHolder.Parent = MainFrame

    local random = Random.new()

    local particles = {}

    for i = 1, 30 do

        local particle = Instance.new("Frame")

        particle.Name = "Particle"

        particle.BorderSizePixel = 0

        particle.BackgroundColor3 =
            Color3.fromRGB(
                random:NextInteger(28, 55),
                random:NextInteger(28, 55),
                random:NextInteger(32, 65)
            )

        particle.BackgroundTransparency =
            random:NextNumber(0.70, 0.88)

        local size =
            random:NextNumber(1.5, 3.2)

        particle.Size =
            UDim2.fromOffset(size, size)

        particle.Position =
            UDim2.fromScale(
                random:NextNumber(0.02, 0.98),
                random:NextNumber(0.02, 0.98)
            )

        particle.ZIndex = 0

        particle.Parent = particleHolder

        local corner =
            Instance.new("UICorner")

        corner.CornerRadius =
            UDim.new(1, 0)

        corner.Parent = particle

        table.insert(
            particles,
            particle
        )
    end

    task.spawn(function()

        while
            particleHolder.Parent
            and not Library.Unloaded
        do

            for _, particle in ipairs(particles) do

                if not particle.Parent then
                    continue
                end

                task.spawn(function()

                    local target =
                        UDim2.fromScale(
                            math.clamp(
                                particle.Position.X.Scale
                                    + random:NextNumber(-0.035, 0.035),
                                0,
                                1
                            ),
                            math.clamp(
                                particle.Position.Y.Scale
                                    + random:NextNumber(-0.035, 0.035),
                                0,
                                1
                            )
                        )

                    local duration =
                        random:NextNumber(2.5, 5)

                    local tween =
                        TweenService:Create(
                            particle,
                            TweenInfo.new(
                                duration,
                                Enum.EasingStyle.Sine,
                                Enum.EasingDirection.InOut
                            ),
                            {
                                Position = target
                            }
                        )

                    tween:Play()

                    tween.Completed:Wait()
                end)

            end

            task.wait(1.2)
        end
    end)

    return particleHolder
end

---------------------------------------------------------------------
-- EXTRA VISUAL TUNING
---------------------------------------------------------------------

local function ApplyVisuals(Window)

    if not Window then
        return
    end

    -----------------------------------------------------------------
    -- CORNER RADIUS
    -----------------------------------------------------------------

    pcall(function()
        Window:SetCornerRadius(14)
    end)

    -----------------------------------------------------------------
    -- WINDOW FRAME
    -----------------------------------------------------------------

    local MainFrame

    if Library.ScreenGui then

        MainFrame =
            Library.ScreenGui:FindFirstChild(
                "Main"
            )
    end

    if not MainFrame then

        MainFrame =
            Library.ScreenGui
            and Library.ScreenGui:FindFirstChildWhichIsA(
                "TextButton",
                true
            )
    end

    if MainFrame then

        MainFrame.BackgroundColor3 =
            Library.Scheme.BackgroundColor

        MainFrame.BackgroundTransparency = 0

        MainFrame.ClipsDescendants = true

        CreateParticles(MainFrame)

        -------------------------------------------------------------
        -- OUTLINE
        -------------------------------------------------------------

        local stroke =
            MainFrame:FindFirstChild(
                "KamUI_Outline"
            )

        if not stroke then

            stroke =
                Instance.new("UIStroke")

            stroke.Name =
                "KamUI_Outline"

            stroke.Color =
                Color3.fromRGB(28, 28, 34)

            stroke.Thickness = 1

            stroke.Transparency = 0

            stroke.Parent = MainFrame
        end

        -------------------------------------------------------------
        -- CORNER
        -------------------------------------------------------------

        local corner =
            MainFrame:FindFirstChild(
                "KamUI_MainCorner"
            )

        if not corner then

            corner =
                Instance.new("UICorner")

            corner.Name =
                "KamUI_MainCorner"

            corner.CornerRadius =
                UDim.new(0, 14)

            corner.Parent = MainFrame
        end
    end

    -----------------------------------------------------------------
    -- GROUPBOXES
    -----------------------------------------------------------------

    if Library.ScreenGui then

        for _, object in ipairs(
            Library.ScreenGui:GetDescendants()
        ) do

            if object:IsA("Frame") then

                local width =
                    object.AbsoluteSize.X

                if width > 180 then

                    local existing =
                        object:FindFirstChild(
                            "KamUI_GroupCorner"
                        )

                    if not existing then

                        local corner =
                            Instance.new("UICorner")

                        corner.Name =
                            "KamUI_GroupCorner"

                        corner.CornerRadius =
                            UDim.new(0, 11)

                        corner.Parent =
                            object
                    end
                end
            end
        end
    end

    -----------------------------------------------------------------
    -- TEXT CLARITY
    -----------------------------------------------------------------

    if Library.ScreenGui then

        for _, object in ipairs(
            Library.ScreenGui:GetDescendants()
        ) do

            if object:IsA("TextLabel")
                or object:IsA("TextButton")
                or object:IsA("TextBox") then

                if object.TextSize < 12 then
                    object.TextSize = 13
                end

                object.TextColor3 =
                    Library.Scheme.FontColor

                pcall(function()
                    object.FontFace =
                        Library.Scheme.Font
                end)
            end
        end
    end
end

---------------------------------------------------------------------
-- WRAP CREATEWINDOW
---------------------------------------------------------------------

Library.CreateWindow = function(self, info)

    info = info or {}

    -----------------------------------------------------------------
    -- OUR DEFAULT VISUAL SETTINGS
    -----------------------------------------------------------------

    if info.CornerRadius == nil then
        info.CornerRadius = 14
    end

    if info.Font == nil then
        info.Font =
            Enum.Font.GothamMedium
    end

    if info.Animations == nil then

        info.Animations = {
            ToggleWindow = true,
            TabSwitch = true,
            Groupbox = true,
            Dropdown = true,
            KeyPicker = true
        }

    end

    if info.TabTransitionTime == nil then
        info.TabTransitionTime = 0.18
    end

    if info.TabSwipeOffset == nil then
        info.TabSwipeOffset = 12
    end

    -----------------------------------------------------------------
    -- CREATE ORIGINAL OBSIDIAN WINDOW
    -----------------------------------------------------------------

    local Window =
        OriginalCreateWindow(
            self,
            info
        )

    -----------------------------------------------------------------
    -- APPLY OUR SKIN
    -----------------------------------------------------------------

    task.defer(function()

        task.wait()

        pcall(function()
            ApplyVisuals(Window)
        end)

    end)

    return Window
end

---------------------------------------------------------------------
-- RE-APPLY AFTER TAB / GROUPBOX CREATION
---------------------------------------------------------------------

if Library.Signals then

    task.spawn(function()

        while not Library.Unloaded do

            task.wait(1)

            if Library.ScreenGui then

                pcall(function()

                    for _, object in ipairs(
                        Library.ScreenGui:GetDescendants()
                    ) do

                        if object:IsA("TextLabel")
                            or object:IsA("TextButton")
                            or object:IsA("TextBox") then

                            if object.TextSize < 12 then
                                object.TextSize = 13
                            end

                            object.TextColor3 =
                                Library.Scheme.FontColor

                            pcall(function()
                                object.FontFace =
                                    Library.Scheme.Font
                            end)
                        end
                    end

                end)

            end
        end
    end)
end

---------------------------------------------------------------------
-- KAMUI INFO
---------------------------------------------------------------------

Library.KamUI = true
Library.KamUIVersion = "1.0"

return Library
