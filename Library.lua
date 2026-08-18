--// KamUI Library
--// Custom UI - Obsidian inspired API
--// No Fluent / No Obsidian dependency

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}

Library.Version = "2.0.0"

Library.Options = {}
Library.Toggles = {}
Library.Registry = {}
Library.Tabs = {}

Library.Theme = {
    Background = Color3.fromRGB(8, 8, 10),
    Sidebar = Color3.fromRGB(11, 11, 14),
    Groupbox = Color3.fromRGB(14, 14, 17),
    Element = Color3.fromRGB(20, 20, 24),
    ElementHover = Color3.fromRGB(27, 27, 32),

    Outline = Color3.fromRGB(38, 38, 44),

    Accent = Color3.fromRGB(135, 95, 255),

    Text = Color3.fromRGB(245, 245, 248),
    SecondaryText = Color3.fromRGB(180, 180, 190),
    MutedText = Color3.fromRGB(125, 125, 135),

    White = Color3.fromRGB(255, 255, 255)
}

Library.Scheme = Library.Theme

Library.TweenInfo = TweenInfo.new(
    0.16,
    Enum.EasingStyle.Quart,
    Enum.EasingDirection.Out
)

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
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object

    return corner
end

local function Outline(object, color, transparency)
    local stroke = Instance.new("UIStroke")

    stroke.Color = color or Library.Theme.Outline
    stroke.Transparency = transparency or 0
    stroke.Thickness = 1

    stroke.Parent = object

    return stroke
end

local function Tween(object, properties)
    if not object or not object.Parent then
        return
    end

    TweenService:Create(
        object,
        Library.TweenInfo,
        properties
    ):Play()
end

local function AddPadding(object, left, right, top, bottom)
    local padding = Instance.new("UIPadding")

    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)

    padding.Parent = object

    return padding
end

local function Label(parent, properties)
    properties.Font = properties.Font or Enum.Font.GothamMedium
    properties.TextSize = properties.TextSize or 12
    properties.TextColor3 = properties.TextColor3 or Library.Theme.Text
    properties.BackgroundTransparency = 1

    return Create("TextLabel", properties, parent)
end

local function GetParent()
    local success, result = pcall(function()
        return gethui()
    end)

    if success and result then
        return result
    end

    return game:GetService("CoreGui")
end

----------------------------------------------------------------
-- WINDOW
----------------------------------------------------------------

function Library:CreateWindow(config)
    config = config or {}

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end

    self.Options = {}
    self.Toggles = {}
    self.Registry = {}
    self.Tabs = {}

    local gui = Create("ScreenGui", {
        Name = "KamUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, GetParent())

    self.ScreenGui = gui

    local window = Create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = config.Size or UDim2.fromOffset(960, 600),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0
    }, gui)

    Corner(window, 16)
    Outline(window, self.Theme.Outline, 0.15)

    self.Window = window

    ------------------------------------------------------------
    -- HEADER
    ------------------------------------------------------------

    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundTransparency = 1
    }, window)

    Label(header, {
        Position = UDim2.fromOffset(20, 11),
        Size = UDim2.new(1, -100, 0, 24),
        Text = config.Title or "KamUI",
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    Label(header, {
        Position = UDim2.fromOffset(21, 35),
        Size = UDim2.new(1, -100, 0, 17),
        Text = config.Subtitle or "Modern Interface",
        TextColor3 = self.Theme.MutedText,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local close = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -17, 0.5, 0),
        Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = self.Theme.SecondaryText,
        Font = Enum.Font.Gotham,
        TextSize = 20,
        AutoButtonColor = false
    }, header)

    Corner(close, 10)

    close.MouseEnter:Connect(function()
        Tween(close, {
            BackgroundColor3 = Color3.fromRGB(65, 30, 38),
            TextColor3 = Color3.fromRGB(255, 100, 110)
        })
    end)

    close.MouseLeave:Connect(function()
        Tween(close, {
            BackgroundColor3 = self.Theme.Element,
            TextColor3 = self.Theme.SecondaryText
        })
    end)

    close.MouseButton1Click:Connect(function()
        self:Unload()
    end)

    ------------------------------------------------------------
    -- DRAG
    ------------------------------------------------------------

    local dragging = false
    local dragStart
    local startPosition

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = window.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local delta = input.Position - dragStart

        window.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    ------------------------------------------------------------
    -- BODY
    ------------------------------------------------------------

    local body = Create("Frame", {
        Position = UDim2.fromOffset(10, 64),
        Size = UDim2.new(1, -20, 1, -74),
        BackgroundTransparency = 1
    }, window)

    ------------------------------------------------------------
    -- SIDEBAR
    ------------------------------------------------------------

    local sidebar = Create("Frame", {
        Size = UDim2.new(0, 175, 1, 0),
        BackgroundColor3 = self.Theme.Sidebar,
        BorderSizePixel = 0
    }, body)

    Corner(sidebar, 12)
    Outline(sidebar, self.Theme.Outline, 0.35)

    AddPadding(sidebar, 8, 8, 8, 8)

    local search = Create("TextBox", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        PlaceholderText = "Search...",
        PlaceholderColor3 = self.Theme.MutedText,
        Text = "",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ClearTextOnFocus = false
    }, sidebar)

    Corner(search, 10)
    Outline(search, self.Theme.Outline, 0.45)
    AddPadding(search, 11, 8, 0, 0)

    local tabHolder = Create("ScrollingFrame", {
        Position = UDim2.fromOffset(0, 46),
        Size = UDim2.new(1, 0, 1, -46),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new()
    }, sidebar)

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabHolder

    self.Navigation = tabHolder

    ------------------------------------------------------------
    -- CONTENT
    ------------------------------------------------------------

    local content = Create("Frame", {
        Position = UDim2.fromOffset(185, 0),
        Size = UDim2.new(1, -185, 1, 0),
        BackgroundTransparency = 1
    }, body)

    self.Content = content

    ------------------------------------------------------------
    -- SEARCH
    ------------------------------------------------------------

    search:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(search.Text)

        for _, tab in pairs(self.Tabs) do
            local visible = query == ""

            if not visible then
                visible = string.find(
                    string.lower(tab.Name),
                    query,
                    1,
                    true
                ) ~= nil
            end

            tab.Button.Visible = visible
        end
    end)

    return self
end

----------------------------------------------------------------
-- TAB
----------------------------------------------------------------

local Tab = {}
Tab.__index = Tab

function Library:AddTab(name, icon)
    local tab = setmetatable({
        Name = name,
        Icon = icon or "•",
        Groupboxes = {},
        LeftGroupboxes = {},
        RightGroupboxes = {}
    }, Tab)

    tab.Library = self

    local button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    }, self.Navigation)

    Corner(button, 9)

    local indicator = Create("Frame", {
        Position = UDim2.fromOffset(3, 9),
        Size = UDim2.fromOffset(3, 22),
        BackgroundColor3 = self.Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, button)

    Corner(indicator, 3)

    Label(button, {
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.fromOffset(22, 40),
        Text = tab.Icon,
        TextColor3 = self.Theme.MutedText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local title = Label(button, {
        Position = UDim2.fromOffset(44, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Text = name,
        TextColor3 = self.Theme.SecondaryText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local page = Create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new()
    }, self.Content)

    AddPadding(page, 7, 7, 5, 12)

    local columns = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    }, page)

    local left = Create("Frame", {
        Size = UDim2.new(0.5, -6, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    }, columns)

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 9)
    leftLayout.Parent = left

    local right = Create("Frame", {
        Position = UDim2.new(0.5, 6, 0, 0),
        Size = UDim2.new(0.5, -6, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    }, columns)

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Padding = UDim.new(0, 9)
    rightLayout.Parent = right

    tab.Button = button
    tab.Page = page
    tab.Left = left
    tab.Right = right
    tab.Indicator = indicator
    tab.Title = title

    self.Tabs[name] = tab

    button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(button, {
                BackgroundColor3 = self.Theme.Element,
                BackgroundTransparency = 0.2
            })
        end
    end)

    button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(button, {
                BackgroundTransparency = 1
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

function Library:SelectTab(tab)
    if type(tab) == "string" then
        tab = self.Tabs[tab]
    end

    if not tab then
        return
    end

    self.ActiveTab = tab

    for _, current in pairs(self.Tabs) do
        local active = current == tab

        current.Page.Visible = active

        if active then
            Tween(current.Button, {
                BackgroundColor3 = self.Theme.Element,
                BackgroundTransparency = 0
            })

            Tween(current.Indicator, {
                BackgroundTransparency = 0
            })

            Tween(current.Title, {
                TextColor3 = self.Theme.Text
            })
        else
            Tween(current.Button, {
                BackgroundTransparency = 1
            })

            Tween(current.Indicator, {
                BackgroundTransparency = 1
            })

            Tween(current.Title, {
                TextColor3 = self.Theme.SecondaryText
            })
        end
    end
end

----------------------------------------------------------------
-- GROUPBOX
----------------------------------------------------------------

local Groupbox = {}
Groupbox.__index = Groupbox

function Tab:_CreateGroupbox(name, parent, collection)
    local group = setmetatable({
        Name = name,
        Library = self.Library,
        Elements = {}
    }, Groupbox)

    local frame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Library.Theme.Groupbox,
        BorderSizePixel = 0
    }, parent)

    Corner(frame, 12)
    Outline(frame, self.Library.Theme.Outline, 0.25)

    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 43),
        BackgroundTransparency = 1
    }, frame)

    Label(header, {
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local container = Create("Frame", {
        Position = UDim2.fromOffset(13, 41),
        Size = UDim2.new(1, -26, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1
    }, frame)

    AddPadding(container, 0, 0, 0, 13)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 7)
    layout.Parent = container

    group.Frame = frame
    group.Container = container

    table.insert(collection, group)
    table.insert(self.Groupboxes, group)

    return group
end

function Tab:AddLeftGroupbox(name, icon)
    return self:_CreateGroupbox(
        name,
        self.Left,
        self.LeftGroupboxes
    )
end

function Tab:AddRightGroupbox(name, icon)
    return self:_CreateGroupbox(
        name,
        self.Right,
        self.RightGroupboxes
    )
end

----------------------------------------------------------------
-- LABEL
----------------------------------------------------------------

function Groupbox:AddLabel(text, wrap)
    local label = Label(self.Container, {
        Size = UDim2.new(1, 0, 0, wrap and 42 or 25),
        Text = tostring(text),
        TextColor3 = self.Library.Theme.SecondaryText,
        TextSize = 12,
        TextWrapped = wrap == true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    return label
end

----------------------------------------------------------------
-- DIVIDER
----------------------------------------------------------------

function Groupbox:AddDivider()
    return Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = self.Library.Theme.Outline,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0
    }, self.Container)
end

----------------------------------------------------------------
-- BUTTON
----------------------------------------------------------------

function Groupbox:AddButton(data)
    if type(data) == "string" then
        data = {
            Text = data
        }
    end

    data = data or {}

    local button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = self.Library.Theme.Element,
        BorderSizePixel = 0,
        Text = data.Text or "Button",
        TextColor3 = self.Library.Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        AutoButtonColor = false
    }, self.Container)

    Corner(button, 9)
    Outline(button, self.Library.Theme.Outline, 0.35)

    button.MouseEnter:Connect(function()
        Tween(button, {
            BackgroundColor3 = self.Library.Theme.ElementHover
        })
    end)

    button.MouseLeave:Connect(function()
        Tween(button, {
            BackgroundColor3 = self.Library.Theme.Element
        })
    end)

    button.MouseButton1Click:Connect(function()
        local callback = data.Callback or data.Func

        if callback then
            callback()
        end
    end)

    return button
end

----------------------------------------------------------------
-- TOGGLE
----------------------------------------------------------------

local Toggle = {}
Toggle.__index = Toggle

function Groupbox:AddToggle(name, info)
    info = info or {}

    local toggle = setmetatable({
        Name = name,
        Value = info.Default == true,
        Callback = info.Callback or function() end,
        Changed = info.Changed or function() end
    }, Toggle)

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1
    }, self.Container)

    Label(holder, {
        Size = UDim2.new(1, -65, 1, 0),
        Text = info.Text or info.Title or name,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local switch = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(42, 22),
        BackgroundColor3 = self.Library.Theme.Outline,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    }, holder)

    Corner(switch, 11)

    local knob = Create("Frame", {
        Position = UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Color3.fromRGB(190, 190, 195),
        BorderSizePixel = 0
    }, switch)

    Corner(knob, 8)

    local function Set(value, silent)
        toggle.Value = value == true

        if toggle.Value then
            Tween(switch, {
                BackgroundColor3 = self.Library.Theme.Accent
            })

            Tween(knob, {
                Position = UDim2.new(1, -19, 0.5, 0),
                BackgroundColor3 = self.Library.Theme.White
            })
        else
            Tween(switch, {
                BackgroundColor3 = self.Library.Theme.Outline
            })

            Tween(knob, {
                Position = UDim2.new(0, 3, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(190, 190, 195)
            })
        end

        if not silent then
            toggle.Callback(toggle.Value)
            toggle.Changed(toggle.Value)
        end
    end

    function toggle:SetValue(value)
        Set(value, false)
    end

    function toggle:GetValue()
        return toggle.Value
    end

    function toggle:OnChanged(callback)
        toggle.Changed = callback
        return toggle
    end

    switch.MouseButton1Click:Connect(function()
        Set(not toggle.Value, false)
    end)

    Set(toggle.Value, true)

    self.Library.Toggles[name] = toggle
    self.Library.Options[name] = toggle

    return toggle
end

----------------------------------------------------------------
-- KEY PICKER
----------------------------------------------------------------

local KeyPicker = {}
KeyPicker.__index = KeyPicker

function Toggle:AddKeyPicker(name, info)
    info = info or {}

    local picker = setmetatable({
        Name = name,
        Value = info.Default or info.Keybind or Enum.KeyCode.Unknown,
        Mode = info.Mode or "Toggle",
        Callback = info.Callback or function() end,
        Changed = info.Changed or function() end
    }, KeyPicker)

    function picker:SetValue(value)
        self.Value = value
        self.Callback(value)
        self.Changed(value)
    end

    function picker:SetKey(value)
        self:SetValue(value)
    end

    function picker:GetValue()
        return self.Value
    end

    function picker:GetKey()
        return self.Value
    end

    self.Library.Options[name] = picker

    return picker
end

----------------------------------------------------------------
-- SLIDER
----------------------------------------------------------------

local Slider = {}
Slider.__index = Slider

function Groupbox:AddSlider(name, info)
    info = info or {}

    local minimum = tonumber(info.Min) or 0
    local maximum = tonumber(info.Max) or 100
    local rounding = tonumber(info.Rounding)

    if rounding == nil then
        rounding = 0
    end

    local default = tonumber(info.Default) or minimum

    local slider = setmetatable({
        Name = name,
        Min = minimum,
        Max = maximum,
        Value = default,
        Rounding = rounding,
        Callback = info.Callback or function() end,
        Changed = info.Changed or function() end
    }, Slider)

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundTransparency = 1
    }, self.Container)

    Label(holder, {
        Size = UDim2.new(1, -80, 0, 22),
        Text = info.Text or info.Title or name,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local valueLabel = Label(holder, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(80, 22),
        TextColor3 = self.Library.Theme.SecondaryText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local bar = Create("Frame", {
        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = self.Library.Theme.Outline,
        BorderSizePixel = 0
    }, holder)

    Corner(bar, 4)

    local fill = Create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = self.Library.Theme.Accent,
        BorderSizePixel = 0
    }, bar)

    Corner(fill, 4)

    local knob = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = self.Library.Theme.White,
        BorderSizePixel = 0
    }, bar)

    Corner(knob, 8)

    local function Round(value)
        local power = 10 ^ rounding
        return math.floor(value * power + 0.5) / power
    end

    local function Format(value)
        if rounding <= 0 then
            return tostring(math.floor(value + 0.5))
        end

        return string.format(
            "%." .. rounding .. "f",
            value
        )
    end

    local function Set(value, silent)
        value = tonumber(value) or minimum

        value = math.clamp(
            value,
            minimum,
            maximum
        )

        value = Round(value)

        slider.Value = value

        local alpha = 0

        if maximum ~= minimum then
            alpha = (value - minimum) / (maximum - minimum)
        end

        Tween(fill, {
            Size = UDim2.fromScale(alpha, 1)
        })

        Tween(knob, {
            Position = UDim2.fromScale(alpha, 0.5)
        })

        valueLabel.Text =
            tostring(info.Prefix or "")
            .. Format(value)
            .. tostring(info.Suffix or "")

        if not silent then
            slider.Callback(value)
            slider.Changed(value)
        end
    end

    local draggingSlider = false

    local function UpdateFromMouse(input)
        local x = input.Position.X
        local start = bar.AbsolutePosition.X
        local width = bar.AbsoluteSize.X

        if width <= 0 then
            return
        end

        local alpha = math.clamp(
            (x - start) / width,
            0,
            1
        )

        Set(
            minimum + (maximum - minimum) * alpha,
            false
        )
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
            UpdateFromMouse(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateFromMouse(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)

    function slider:SetValue(value)
        Set(value, false)
    end

    function slider:GetValue()
        return slider.Value
    end

    function slider:OnChanged(callback)
        slider.Changed = callback
        return slider
    end

    Set(default, true)

    self.Library.Options[name] = slider

    return slider
end

----------------------------------------------------------------
-- INPUT
----------------------------------------------------------------

function Groupbox:AddInput(name, info)
    info = info or {}

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundTransparency = 1
    }, self.Container)

    Label(holder, {
        Size = UDim2.new(1, 0, 0, 21),
        Text = info.Text or name,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local input = Create("TextBox", {
        Position = UDim2.fromOffset(0, 27),
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = self.Library.Theme.Element,
        BorderSizePixel = 0,
        Text = tostring(info.Default or ""),
        PlaceholderText = info.Placeholder or "",
        PlaceholderColor3 = self.Library.Theme.MutedText,
        TextColor3 = self.Library.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    }, holder)

    Corner(input, 9)
    Outline(input, self.Library.Theme.Outline, 0.35)
    AddPadding(input, 10, 10, 0, 0)

    local object = {
        Name = name,
        Value = input.Text,
        Input = input,
        Callback = info.Callback or function() end,
        Changed = info.Changed or function() end
    }

    function object:SetValue(value)
        input.Text = tostring(value)
        object.Value = input.Text
        object.Callback(object.Value)
    end

    function object:GetValue()
        return input.Text
    end

    input.FocusLost:Connect(function()
        object.Value = input.Text
        object.Callback(object.Value)
        object.Changed(object.Value)
    end)

    self.Library.Options[name] = object

    return object
end

----------------------------------------------------------------
-- DROPDOWN
----------------------------------------------------------------

function Groupbox:AddDropdown(name, info)
    info = info or {}

    local values = info.Values or {}
    local current = info.Default or values[1]

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1
    }, self.Container)

    Label(holder, {
        Size = UDim2.new(0.4, 0, 1, 0),
        Text = info.Text or name,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local button = Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0.58, 0, 0, 34),
        BackgroundColor3 = self.Library.Theme.Element,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    }, holder)

    Corner(button, 9)
    Outline(button, self.Library.Theme.Outline, 0.35)

    local selected = Label(button, {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Text = tostring(current or "Select"),
        TextColor3 = self.Library.Theme.SecondaryText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    Label(button, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(15, 18),
        Text = "⌄",
        TextColor3 = self.Library.Theme.MutedText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    local object = {
        Name = name,
        Values = values,
        Value = current,
        Callback = info.Callback or function() end,
        Changed = info.Changed or function() end
    }

    function object:SetValue(value)
        object.Value = value
        selected.Text = tostring(value)
        object.Callback(value)
        object.Changed(value)
    end

    function object:GetValue()
        return object.Value
    end

    function object:SetValues(newValues)
        object.Values = newValues or {}
    end

    function object:OnChanged(callback)
        object.Changed = callback
        return object
    end

    button.MouseButton1Click:Connect(function()
        if #object.Values == 0 then
            return
        end

        local index = table.find(
            object.Values,
            object.Value
        ) or 0

        index = index + 1

        if index > #object.Values then
            index = 1
        end

        object:SetValue(
            object.Values[index]
        )
    end)

    self.Library.Options[name] = object

    return object
end

----------------------------------------------------------------
-- NOTIFICATION
----------------------------------------------------------------

function Library:Notify(data)
    if type(data) == "string" then
        data = {
            Description = data
        }
    end

    data = data or {}

    local notification = Create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, 320, 1, -20),
        Size = UDim2.fromOffset(310, 78),
        BackgroundColor3 = self.Theme.Groupbox,
        BorderSizePixel = 0,
        ZIndex = 500
    }, self.ScreenGui)

    Corner(notification, 12)
    Outline(notification, self.Theme.Outline, 0.1)

    Create("Frame", {
        Position = UDim2.fromOffset(0, 14),
        Size = UDim2.fromOffset(3, 50),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 501
    }, notification)

    Label(notification, {
        Position = UDim2.fromOffset(15, 9),
        Size = UDim2.new(1, -25, 0, 20),
        Text = data.Title or "Notification",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        ZIndex = 502
    })

    Label(notification, {
        Position = UDim2.fromOffset(15, 32),
        Size = UDim2.new(1, -25, 0, 34),
        Text = data.Description or data.Content or "",
        TextColor3 = self.Theme.SecondaryText,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 502
    })

    Tween(notification, {
        Position = UDim2.new(1, -20, 1, -20)
    })

    task.delay(data.Time or data.Duration or 3, function()
        if notification and notification.Parent then
            Tween(notification, {
                Position = UDim2.new(1, 320, 1, -20)
            })

            task.wait(0.2)

            if notification then
                notification:Destroy()
            end
        end
    end)

    return notification
end

----------------------------------------------------------------
-- UI TOGGLE
----------------------------------------------------------------

function Library:Toggle()
    if self.Window then
        self.Window.Visible = not self.Window.Visible
    end
end

function Library:ToggleUI()
    self:Toggle()
end

----------------------------------------------------------------
-- ACCENT
----------------------------------------------------------------

function Library:SetAccent(color)
    if typeof(color) ~= "Color3" then
        return
    end

    self.Theme.Accent = color
    self.Scheme.Accent = color
end

----------------------------------------------------------------
-- UNLOAD
----------------------------------------------------------------

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
