--[[
    Modern Obsidian UI
    ------------------
    Obsidian API korunur.
    Sadece GUI görünümü modern / rounded hale getirilir.

    Usage:

        local Library = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/YOURNAME/ModernObsidian/main/Library.lua"
        ))()

        local Window = Library:CreateWindow({
            Title = "My Script",
            Footer = "v1.0",
            Center = true,
            AutoShow = true,
            Size = UDim2.fromOffset(850, 600),
        })

        local Tab = Window:AddTab("Main")

        local Left = Tab:AddLeftGroupbox("Combat")
        local Right = Tab:AddRightGroupbox("Visuals")

        Left:AddToggle("Aimbot", {
            Text = "Aimbot",
            Default = false,
        })

        Right:AddToggle("ESP", {
            Text = "ESP",
            Default = true,
        })
]]

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

------------------------------------------------------------
-- LOAD ORIGINAL OBSIDIAN
------------------------------------------------------------

local OBSIDIAN_URL =
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"

local Library = loadstring(game:HttpGet(OBSIDIAN_URL))()

------------------------------------------------------------
-- MODERN SETTINGS
------------------------------------------------------------

Library.CornerRadius = 14

Library.Scheme = {
    BackgroundColor = Color3.fromRGB(10, 11, 15),
    MainColor = Color3.fromRGB(18, 19, 25),

    AccentColor = Color3.fromRGB(139, 92, 246),

    OutlineColor = Color3.fromRGB(43, 45, 55),

    FontColor = Color3.fromRGB(238, 238, 245),

    Font = Font.fromEnum(Enum.Font.Gotham),

    RedColor = Color3.fromRGB(255, 80, 90),
    DestructiveColor = Color3.fromRGB(225, 60, 70),

    DarkColor = Color3.fromRGB(8, 8, 11),
    WhiteColor = Color3.fromRGB(255, 255, 255),

    BackgroundImage = "",
}

------------------------------------------------------------
-- UI CONSTANTS
------------------------------------------------------------

local RADIUS = {
    Window = 18,
    Sidebar = 16,
    Groupbox = 15,
    Element = 10,
    Button = 10,
    Input = 10,
    Dropdown = 10,
    Toggle = 999,
    Notification = 14,
    Tab = 10,
}

local COLORS = {
    Window = Color3.fromRGB(10, 11, 15),
    Sidebar = Color3.fromRGB(13, 14, 19),

    Groupbox = Color3.fromRGB(18, 19, 25),
    GroupboxInner = Color3.fromRGB(21, 22, 29),

    Element = Color3.fromRGB(24, 25, 33),
    ElementHover = Color3.fromRGB(29, 30, 40),

    Border = Color3.fromRGB(42, 44, 55),

    Text = Color3.fromRGB(238, 238, 245),
    SubText = Color3.fromRGB(150, 152, 165),

    Accent = Color3.fromRGB(139, 92, 246),
}

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function addCorner(object, radius)
    if not object or not object:IsA("GuiObject") then
        return
    end

    local corner = object:FindFirstChildOfClass("UICorner")

    if not corner then
        corner = Instance.new("UICorner")
        corner.Name = "ModernCorner"
        corner.Parent = object
    end

    corner.CornerRadius = UDim.new(0, radius)

    return corner
end

local function addStroke(object, color, transparency)
    if not object or not object:IsA("GuiObject") then
        return
    end

    local stroke = object:FindFirstChildOfClass("UIStroke")

    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Name = "ModernStroke"
        stroke.Parent = object
    end

    stroke.Color = color or COLORS.Border
    stroke.Transparency = transparency or 0.15
    stroke.Thickness = 1

    return stroke
end

local function tween(object, properties, duration)
    if not object then
        return
    end

    TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.15,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    ):Play()
end

------------------------------------------------------------
-- CLASSIFICATION
------------------------------------------------------------

local function isLayout(object)
    return object:IsA("UIListLayout")
        or object:IsA("UIGridLayout")
        or object:IsA("UIPadding")
        or object:IsA("UIScale")
        or object:IsA("UIAspectRatioConstraint")
        or object:IsA("UIStroke")
        or object:IsA("UICorner")
end

local function objectName(object)
    return string.lower(object.Name or "")
end

local function isGroupbox(object)
    local name = objectName(object)

    return name:find("group")
        or name:find("box")
        or name:find("container")
end

local function isSidebar(object)
    local name = objectName(object)

    return name:find("sidebar")
        or name:find("tab")
end

------------------------------------------------------------
-- STYLE ELEMENT
------------------------------------------------------------

local function styleObject(object)
    if not object then
        return
    end

    if isLayout(object) then
        return
    end

    --------------------------------------------------------
    -- FRAMES
    --------------------------------------------------------

    if object:IsA("Frame") then

        if isSidebar(object) then
            addCorner(object, RADIUS.Sidebar)
            return
        end

        if isGroupbox(object) then
            addCorner(object, RADIUS.Groupbox)
            addStroke(object, COLORS.Border, 0.35)
            return
        end

        -- General containers
        if object.BackgroundTransparency < 1 then
            addCorner(object, RADIUS.Element)
        end

    --------------------------------------------------------
    -- BUTTONS
    --------------------------------------------------------

    elseif object:IsA("TextButton") then

        local name = objectName(object)

        if name:find("tab") then
            addCorner(object, RADIUS.Tab)
        elseif name:find("toggle") then
            addCorner(object, RADIUS.Toggle)
        elseif name:find("key") then
            addCorner(object, RADIUS.Toggle)
        else
            addCorner(object, RADIUS.Button)
        end

        addStroke(object, COLORS.Border, 0.5)

        ----------------------------------------------------
        -- Hover
        ----------------------------------------------------

        local normalColor = object.BackgroundColor3

        object.MouseEnter:Connect(function()
            if object.Parent then
                tween(
                    object,
                    {
                        BackgroundColor3 = COLORS.ElementHover
                    },
                    0.12
                )
            end
        end)

        object.MouseLeave:Connect(function()
            if object.Parent then
                tween(
                    object,
                    {
                        BackgroundColor3 = normalColor
                    },
                    0.16
                )
            end
        end)

    --------------------------------------------------------
    -- TEXT BOX
    --------------------------------------------------------

    elseif object:IsA("TextBox") then
        addCorner(object, RADIUS.Input)
        addStroke(object, COLORS.Border, 0.35)

    --------------------------------------------------------
    -- SCROLLING FRAME
    --------------------------------------------------------

    elseif object:IsA("ScrollingFrame") then
        object.ScrollBarThickness = 3
        object.ScrollBarImageColor3 = COLORS.Accent
        object.ScrollBarImageTransparency = 0.25

    --------------------------------------------------------
    -- IMAGE BUTTON
    --------------------------------------------------------

    elseif object:IsA("ImageButton") then
        addCorner(object, RADIUS.Button)
    end
end

------------------------------------------------------------
-- RECURSIVE SKIN
------------------------------------------------------------

local function skinTree(root)
    if not root then
        return
    end

    styleObject(root)

    for _, child in ipairs(root:GetChildren()) do
        skinTree(child)
    end
end

------------------------------------------------------------
-- LIVE SKIN
------------------------------------------------------------

local function watchTree(root)
    if not root then
        return
    end

    skinTree(root)

    root.DescendantAdded:Connect(function(object)
        task.defer(function()
            if object and object.Parent then
                styleObject(object)

                -- Some Obsidian elements construct their children
                -- one frame later.
                task.defer(function()
                    if object and object.Parent then
                        skinTree(object)
                    end
                end)
            end
        end)
    end)
end

------------------------------------------------------------
-- MODERN WINDOW
------------------------------------------------------------

local OriginalCreateWindow = Library.CreateWindow

function Library:CreateWindow(options)
    options = options or {}

    --------------------------------------------------------
    -- Modern defaults
    --------------------------------------------------------

    options.CornerRadius = options.CornerRadius or RADIUS.Window

    options.Size =
        options.Size
        or UDim2.fromOffset(850, 600)

    options.MinSize =
        options.MinSize
        or Vector2.new(650, 450)

    options.NotifySide =
        options.NotifySide
        or "Right"

    options.Font =
        options.Font
        or Enum.Font.Gotham

    --------------------------------------------------------
    -- Create original Obsidian window
    --------------------------------------------------------

    local Window = OriginalCreateWindow(self, options)

    --------------------------------------------------------
    -- Find ScreenGui / Window
    --------------------------------------------------------

    task.defer(function()

        local root =
            self.WindowContainer
            or self.Window
            or self.ScreenGui

        if root then
            skinTree(root)
            watchTree(root)
        end

    end)

    return Window
end

------------------------------------------------------------
-- MODERN NOTIFICATIONS
------------------------------------------------------------

local OriginalNotify = Library.Notify

if OriginalNotify then

    function Library:Notify(data)
        local result = OriginalNotify(self, data)

        task.defer(function()

            local root =
                self.WindowContainer
                or self.Window
                or self.ScreenGui

            if root then
                for _, object in ipairs(root:GetDescendants()) do

                    local name = objectName(object)

                    if name:find("notification") then
                        addCorner(object, RADIUS.Notification)
                        addStroke(object, COLORS.Border, 0.25)
                    end

                end
            end

        end)

        return result
    end

end

------------------------------------------------------------
-- PUBLIC SKIN API
------------------------------------------------------------

function Library:ApplyModernStyle()
    local root =
        self.WindowContainer
        or self.Window
        or self.ScreenGui

    if not root then
        return false
    end

    skinTree(root)

    return true
end

function Library:SetModernAccent(color)
    if typeof(color) ~= "Color3" then
        return
    end

    COLORS.Accent = color
    self.Scheme.AccentColor = color

    local root =
        self.WindowContainer
        or self.Window
        or self.ScreenGui

    if root then

        for _, object in ipairs(root:GetDescendants()) do

            if object:IsA("UIStroke") then
                if object.Name == "ModernAccentStroke" then
                    object.Color = color
                end
            end

        end

    end
end

------------------------------------------------------------
-- READY
------------------------------------------------------------

Library.Modern = true
Library.ModernVersion = "1.0.0"

return Library
