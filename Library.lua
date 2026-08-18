--// KamUI Library
--// Clean Modern UI
--// Obsidian-style API compatible core

local Library = {}

Library.__VERSION = "3.0.0"
Library.Version = Library.__VERSION

Library.Flags = {}
Library.Options = {}
Library.Toggles = {}

Library.Accent = Color3.fromRGB(115, 90, 255)
Library.Background = Color3.fromRGB(13, 13, 16)
Library.Surface = Color3.fromRGB(19, 19, 23)
Library.Surface2 = Color3.fromRGB(24, 24, 29)
Library.Border = Color3.fromRGB(40, 40, 47)
Library.Text = Color3.fromRGB(245, 245, 248)
Library.SubText = Color3.fromRGB(155, 155, 165)

Library.Windows = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

local function New(class, properties)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    return object
end

local function Tween(object, properties, duration)
    local info = TweenInfo.new(
        duration or 0.18,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )

    TweenService:Create(object, info, properties):Play()
end

local function Corner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object

    return corner
end

local function Stroke(object, color, transparency)
    local stroke = Instance.new("UIStroke")

    stroke.Color = color or Library.Border
    stroke.Transparency = transparency or 0
    stroke.Thickness = 1

    stroke.Parent = object

    return stroke
end

local function Padding(object, left, right, top, bottom)
    local pad = Instance.new("UIPadding")

    pad.PaddingLeft = UDim.new(0, left or 0)
    pad.PaddingRight = UDim.new(0, right or 0)
    pad.PaddingTop = UDim.new(0, top or 0)
    pad.PaddingBottom = UDim.new(0, bottom or 0)

    pad.Parent = object

    return pad
end

local function MakeDraggable(frame, handle)
    handle = handle or frame

    local dragging = false
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)

        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)
end

---------------------------------------------------------------------
-- NOTIFICATION
---------------------------------------------------------------------

function Library:Notify(data)

    data = data or {}

    local title = data.Title or "Notification"
    local description = data.Description or ""
    local duration = data.Time or 3

    local parent = Library.NotificationHolder

    if not parent then

        parent = New("Frame", {
            Name = "Notifications",
            Parent = Library.ScreenGui,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 320, 1, -30),
            Position = UDim2.new(1, -340, 0, 15)
        })

        local layout = New("UIListLayout", {
            Parent = parent,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Top
        })

        Library.NotificationHolder = parent
    end

    local notification = New("Frame", {
        Parent = parent,
        BackgroundColor3 = Library.Surface,
        Size = UDim2.new(0, 310, 0, 72),
        BackgroundTransparency = 0,
        BorderSizePixel = 0
    })

    Corner(notification, 12)
    Stroke(notification, Library.Border)

    local accent = New("Frame", {
        Parent = notification,
        BackgroundColor3 = Library.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, -20),
        Position = UDim2.new(0, 10, 0, 10)
    })

    Corner(accent, 4)

    New("TextLabel", {
        Parent = notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 25, 0, 12),
        Size = UDim2.new(1, -35, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextSize = 14,
        TextColor3 = Library.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    New("TextLabel", {
        Parent = notification,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 25, 0, 34),
        Size = UDim2.new(1, -35, 0, 28),
        Font = Enum.Font.Gotham,
        Text = description,
        TextSize = 12,
        TextColor3 = Library.SubText,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    task.delay(duration, function()

        if notification and notification.Parent then

            Tween(notification, {
                BackgroundTransparency = 1
            }, 0.2)

            task.wait(0.2)

            notification:Destroy()
        end
    end)
end

---------------------------------------------------------------------
-- ACCENT
---------------------------------------------------------------------

function Library:SetAccent(color)

    Library.Accent = color

    for _, object in ipairs(Library.AccentObjects or {}) do

        if object and object.Parent then
            object.BackgroundColor3 = color
        end
    end
end

Library.AccentObjects = {}

local function RegisterAccent(object)

    table.insert(Library.AccentObjects, object)

    object.BackgroundColor3 = Library.Accent

    return object
end

---------------------------------------------------------------------
-- OPTION HELPERS
---------------------------------------------------------------------

function Library:GetFlag(name)
    return Library.Flags[name]
end

function Library:SetFlag(name, value)
    Library.Flags[name] = value

    local option = Library.Options[name]

    if option and option.SetValue then
        option:SetValue(value)
    end
end

---------------------------------------------------------------------
-- ELEMENT BASE
---------------------------------------------------------------------

local function CreateElement(parent, height)

    local frame = New("Frame", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 36)
    })

    return frame
end

---------------------------------------------------------------------
-- TOGGLE
---------------------------------------------------------------------

local function AddToggle(groupbox, flag, data)

    data = data or {}

    local default = data.Default or false

    Library.Flags[flag] = default
    Library.Toggles[flag] = true

    local element = CreateElement(groupbox.Content, 38)

    local label = New("TextLabel", {
        Parent = element,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 2, 0, 3),
        Size = UDim2.new(1, -55, 0, 30),
        Font = Enum.Font.GothamMedium,
        Text = data.Text or flag,
        TextSize = 14,
        TextColor3 = Library.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local toggle = New("TextButton", {
        Parent = element,
        BackgroundColor3 = Color3.fromRGB(35, 35, 41),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -43, 0.5, -10),
        Size = UDim2.fromOffset(40, 20),
        Text = ""
    })

    Corner(toggle, 10)

    local knob = New("Frame", {
        Parent = toggle,
        BackgroundColor3 = Color3.fromRGB(180, 180, 185),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(0, 2, 0.5, -8)
    })

    Corner(knob, 8)

    local option = {}

    function option:SetValue(value)

        value = value == true

        Library.Flags[flag] = value

        if value then

            Tween(toggle, {
                BackgroundColor3 = Library.Accent
            })

            Tween(knob, {
                Position = UDim2.new(1, -18, 0.5, -8),
                BackgroundColor3 = Color3.new(1, 1, 1)
            })

        else

            Tween(toggle, {
                BackgroundColor3 = Color3.fromRGB(35, 35, 41)
            })

            Tween(knob, {
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(180, 180, 185)
            })
        end

        if data.Callback then
            task.spawn(data.Callback, value)
        end
    end

    function option:GetValue()
        return Library.Flags[flag]
    end

    toggle.MouseButton1Click:Connect(function()
        option:SetValue(not Library.Flags[flag])
    end)

    option:SetValue(default)

    Library.Options[flag] = option

    return option
end

---------------------------------------------------------------------
-- SLIDER
---------------------------------------------------------------------

local function AddSlider(groupbox, flag, data)

    data = data or {}

    local min = data.Min or 0
    local max = data.Max or 100
    local default = data.Default or min
    local rounding = data.Rounding or 0
    local suffix = data.Suffix or ""

    Library.Flags[flag] = default

    local element = CreateElement(groupbox.Content, 62)

    local label = New("TextLabel", {
        Parent = element,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 2, 0, 0),
        Size = UDim2.new(0.65, 0, 0, 24),
        Font = Enum.Font.GothamMedium,
        Text = data.Text or flag,
        TextSize = 14,
        TextColor3 = Library.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local valueLabel = New("TextLabel", {
        Parent = element,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.65, 0, 0, 0),
        Size = UDim2.new(0.35, -2, 0, 24),
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = Library.Accent,
        TextXAlignment = Enum.TextXAlignment.Right
    })

    local bar = New("Frame", {
        Parent = element,
        BackgroundColor3 = Color3.fromRGB(34, 34, 40),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 2, 0, 34),
        Size = UDim2.new(1, -4, 0, 6)
    })

    Corner(bar, 4)

    local fill = RegisterAccent(New("Frame", {
        Parent = bar,
        BackgroundColor3 = Library.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0)
    }))

    Corner(fill, 4)

    local knob = New("Frame", {
        Parent = bar,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, -7, 0.5, -7)
    })

    Corner(knob, 7)

    local dragging = false

    local option = {}

    local function format(value)

        if rounding <= 0 then
            return tostring(math.floor(value + 0.5)) .. suffix
        end

        return string.format(
            "%." .. tostring(rounding) .. "f",
            value
        ) .. suffix
    end

    local function setFromX(x)

        local percentage = math.clamp(
            (x - bar.AbsolutePosition.X)
                / bar.AbsoluteSize.X,
            0,
            1
        )

        local value = min + (max - min) * percentage

        if rounding <= 0 then
            value = math.floor(value + 0.5)
        else
            local mult = 10 ^ rounding
            value = math.floor(value * mult + 0.5) / mult
        end

        option:SetValue(value)
    end

    function option:SetValue(value)

        value = math.clamp(
            tonumber(value) or min,
            min,
            max
        )

        if rounding <= 0 then
            value = math.floor(value + 0.5)
        else
            local mult = 10 ^ rounding
            value = math.floor(value * mult + 0.5) / mult
        end

        Library.Flags[flag] = value

        local percentage =
            (value - min) / (max - min)

        fill.Size = UDim2.new(
            percentage,
            0,
            1,
            0
        )

        knob.Position = UDim2.new(
            percentage,
            -7,
            0.5,
            -7
        )

        valueLabel.Text = format(value)

        if data.Callback then
            task.spawn(data.Callback, value)
        end
    end

    function option:GetValue()
        return Library.Flags[flag]
    end

    bar.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)

        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    option:SetValue(default)

    Library.Options[flag] = option

    return option
end

---------------------------------------------------------------------
-- BUTTON
---------------------------------------------------------------------

local function AddButton(groupbox, data)

    data = data or {}

    local button = New("TextButton", {
        Parent = groupbox.Content,
        BackgroundColor3 = Library.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Font = Enum.Font.GothamSemibold,
        Text = data.Text or "Button",
        TextSize = 13,
        TextColor3 = Library.Text,
        AutoButtonColor = false
    })

    Corner(button, 8)
    Stroke(button, Library.Border)

    button.MouseEnter:Connect(function()

        Tween(button, {
            BackgroundColor3 = Color3.fromRGB(31, 31, 37)
        })
    end)

    button.MouseLeave:Connect(function()

        Tween(button, {
            BackgroundColor3 = Library.Surface2
        })
    end)

    button.MouseButton1Click:Connect(function()

        if data.Callback then
            task.spawn(data.Callback)
        end
    end)

    return button
end

---------------------------------------------------------------------
-- LABEL
---------------------------------------------------------------------

local function AddLabel(groupbox, text)

    local label = New("TextLabel", {
        Parent = groupbox.Content,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Font = Enum.Font.Gotham,
        Text = tostring(text),
        TextSize = 13,
        TextColor3 = Library.SubText,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    return label
end

---------------------------------------------------------------------
-- DIVIDER
---------------------------------------------------------------------

local function AddDivider(groupbox)

    local divider = New("Frame", {
        Parent = groupbox.Content,
        BackgroundColor3 = Library.Border,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1)
    })

    return divider
end

---------------------------------------------------------------------
-- INPUT
---------------------------------------------------------------------

local function AddInput(groupbox, flag, data)

    data = data or {}

    Library.Flags[flag] = data.Default or ""

    local element = CreateElement(groupbox.Content, 62)

    New("TextLabel", {
        Parent = element,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 2, 0, 0),
        Size = UDim2.new(1, 0, 0, 22),
        Font = Enum.Font.GothamMedium,
        Text = data.Text or flag,
        TextSize = 14,
        TextColor3 = Library.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local input = New("TextBox", {
        Parent = element,
        BackgroundColor3 = Library.Surface2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 27),
        Size = UDim2.new(1, 0, 0, 32),
        Font = Enum.Font.Gotham,
        Text = data.Default or "",
        PlaceholderText = data.Placeholder or "",
        TextSize = 13,
        TextColor3 = Library.Text,
        PlaceholderColor3 = Library.SubText,
        ClearTextOnFocus = false
    })

    Corner(input, 8)
    Stroke(input, Library.Border)
    Padding(input, 10, 10, 0, 0)

    local option = {}

    function option:SetValue(value)

        value = tostring(value or "")

        Library.Flags[flag] = value
        input.Text = value

        if data.Callback then
            task.spawn(data.Callback, value)
        end
    end

    function option:GetValue()
        return Library.Flags[flag]
    end

    input.FocusLost:Connect(function()

        Library.Flags[flag] = input.Text

        if data.Callback then
            task.spawn(data.Callback, input.Text)
        end
    end)

    Library.Options[flag] = option

    return option
end

---------------------------------------------------------------------
-- DROPDOWN
---------------------------------------------------------------------

local function AddDropdown(groupbox, flag, data)

    data = data or {}

    local values = data.Values or {}
    local default = data.Default or values[1]

    Library.Flags[flag] = default

    local element = CreateElement(groupbox.Content, 62)

    New("TextLabel", {
        Parent = element,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 2, 0, 0),
        Size = UDim2.new(1, 0, 0, 22),
        Font = Enum.Font.GothamMedium,
        Text = data.Text or flag,
        TextSize = 14,
        TextColor3 = Library.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local dropdown = New("TextButton", {
        Parent = element,
        BackgroundColor3 = Library.Surface2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 27),
        Size = UDim2.new(1, 0, 0, 32),
        Font = Enum.Font.Gotham,
        Text = tostring(default or "Select"),
        TextSize = 13,
        TextColor3 = Library.Text,
        AutoButtonColor = false
    })

    Corner(dropdown, 8)
    Stroke(dropdown, Library.Border)

    local option = {}
    local opened = false

    function option:SetValue(value)

        Library.Flags[flag] = value
        dropdown.Text = tostring(value)

        if data.Callback then
            task.spawn(data.Callback, value)
        end
    end

    function option:GetValue()
        return Library.Flags[flag]
    end

    local menu

    dropdown.MouseButton1Click:Connect(function()

        opened = not opened

        if opened then

            if menu then
                menu:Destroy()
            end

            menu = New("Frame", {
                Parent = Library.ScreenGui,
                BackgroundColor3 = Library.Surface,
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(
                    dropdown.AbsoluteSize.X,
                    math.min(#values * 30 + 8, 180)
                ),
                Position = UDim2.fromOffset(
                    dropdown.AbsolutePosition.X,
                    dropdown.AbsolutePosition.Y
                        + dropdown.AbsoluteSize.Y
                        + 4
                ),
                ZIndex = 50
            })

            Corner(menu, 8)
            Stroke(menu, Library.Border)

            local layout = New("UIListLayout", {
                Parent = menu,
                Padding = UDim.new(0, 2)
            })

            Padding(menu, 4, 4, 4, 4)

            for _, value in ipairs(values) do

                local optionButton = New("TextButton", {
                    Parent = menu,
                    BackgroundColor3 = Library.Surface,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 26),
                    Font = Enum.Font.Gotham,
                    Text = tostring(value),
                    TextSize = 12,
                    TextColor3 = Library.Text,
                    AutoButtonColor = false,
                    ZIndex = 51
                })

                Corner(optionButton, 6)

                optionButton.MouseButton1Click:Connect(function()

                    option:SetValue(value)

                    opened = false

                    if menu then
                        menu:Destroy()
                        menu = nil
                    end
                end)
            end

        else

            if menu then
                menu:Destroy()
                menu = nil
            end
        end
    end)

    option:SetValue(default)

    Library.Options[flag] = option

    return option
end

---------------------------------------------------------------------
-- GROUPBOX
---------------------------------------------------------------------

local function CreateGroupbox(parent, title)

    local groupbox = {}

    local frame = New("Frame", {
        Parent = parent,
        BackgroundColor3 = Library.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 200)
    })

    Corner(frame, 12)
    Stroke(frame, Library.Border)

    local titleLabel = New("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(1, -32, 0, 24),
        Font = Enum.Font.GothamSemibold,
        Text = title or "Groupbox",
        TextSize = 15,
        TextColor3 = Library.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local line = New("Frame", {
        Parent = frame,
        BackgroundColor3 = Library.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 16, 0, 42),
        Size = UDim2.new(1, -32, 0, 1)
    })

    local content = New("Frame", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 52),
        Size = UDim2.new(1, -32, 1, -62)
    })

    local layout = New("UIListLayout", {
        Parent = content,
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    groupbox.Frame = frame
    groupbox.Content = content

    function groupbox:AddToggle(flag, data)
        return AddToggle(groupbox, flag, data)
    end

    function groupbox:AddSlider(flag, data)
        return AddSlider(groupbox, flag, data)
    end

    function groupbox:AddDropdown(flag, data)
        return AddDropdown(groupbox, flag, data)
    end

    function groupbox:AddInput(flag, data)
        return AddInput(groupbox, flag, data)
    end

    function groupbox:AddButton(data)
        return AddButton(groupbox, data)
    end

    function groupbox:AddLabel(text)
        return AddLabel(groupbox, text)
    end

    function groupbox:AddDivider()
        return AddDivider(groupbox)
    end

    task.defer(function()

        local function update()

            local height =
                layout.AbsoluteContentSize.Y + 70

            frame.Size = UDim2.new(
                1,
                0,
                0,
                math.max(height, 90)
            )
        end

        layout:GetPropertyChangedSignal(
            "AbsoluteContentSize"
        ):Connect(update)

        update()
    end)

    return groupbox
end

---------------------------------------------------------------------
-- TAB
---------------------------------------------------------------------

local function CreateTab(window, name, icon)

    local tab = {}

    tab.Name = name
    tab.Select = function()
        window:SelectTab(tab)
    end

    local button = New("TextButton", {
        Parent = window.Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 40),
        Font = Enum.Font.GothamMedium,
        Text = (icon and icon .. "  " or "") .. name,
        TextSize = 14,
        TextColor3 = Library.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false
    })

    Corner(button, 9)
    Padding(button, 13, 5, 0, 0)

    local page = New("ScrollingFrame", {
        Parent = window.Content,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Library.Accent,
        BorderSizePixel = 0,
        Visible = false
    })

    Padding(page, 4, 8, 4, 12)

    local layout = New("UIListLayout", {
        Parent = page,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local left = New("Frame", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -6, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })

    local right = New("Frame", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -6, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })

    local leftLayout = New("UIListLayout", {
        Parent = left,
        Padding = UDim.new(0, 12)
    })

    local rightLayout = New("UIListLayout", {
        Parent = right,
        Padding = UDim.new(0, 12)
    })

    function tab:AddLeftGroupbox(title)
        return CreateGroupbox(left, title)
    end

    function tab:AddRightGroupbox(title)
        return CreateGroupbox(right, title)
    end

    function tab:AddGroupbox(title)
        return CreateGroupbox(left, title)
    end

    tab.Button = button
    tab.Page = page

    button.MouseButton1Click:Connect(function()
        tab:Select()
    end)

    table.insert(window.Tabs, tab)

    return tab
end

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------

function Library:CreateWindow(settings)

    settings = settings or {}

    local window = {}

    window.Tabs = {}

    local existing = CoreGui:FindFirstChild(
        "KamUI"
    )

    if existing then
        existing:Destroy()
    end

    local gui = New("ScreenGui", {
        Name = "KamUI",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    Library.ScreenGui = gui

    local main = New("Frame", {
        Parent = gui,
        BackgroundColor3 = Library.Background,
        BorderSizePixel = 0,
        Size = settings.Size or UDim2.fromOffset(900, 600),
        Position = UDim2.new(0.5, -450, 0.5, -300)
    })

    Corner(main, 16)
    Stroke(main, Color3.fromRGB(35, 35, 42))

    window.Frame = main

    local top = New("Frame", {
        Parent = main,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 64)
    })

    MakeDraggable(main, top)

    New("TextLabel", {
        Parent = top,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 22, 0, 10),
        Size = UDim2.new(0, 300, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = settings.Title or "KamUI",
        TextSize = 18,
        TextColor3 = Library.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    New("TextLabel", {
        Parent = top,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 22, 0, 34),
        Size = UDim2.new(0, 300, 0, 18),
        Font = Enum.Font.Gotham,
        Text = settings.Subtitle or "Modern Interface",
        TextSize = 11,
        TextColor3 = Library.SubText,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -----------------------------------------------------------------
    -- SEARCH
    -----------------------------------------------------------------

    local search = New("TextBox", {
        Parent = top,
        BackgroundColor3 = Library.Surface2,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 15),
        Size = UDim2.fromOffset(280, 34),
        Font = Enum.Font.Gotham,
        PlaceholderText = "Search modules...",
        Text = "",
        TextSize = 13,
        TextColor3 = Library.Text,
        PlaceholderColor3 = Library.SubText,
        ClearTextOnFocus = false
    })

    Corner(search, 9)
    Stroke(search, Library.Border)
    Padding(search, 12, 12, 0, 0)

    window.Search = search

    -----------------------------------------------------------------
    -- SIDEBAR
    -----------------------------------------------------------------

    local sidebar = New("Frame", {
        Parent = main,
        BackgroundColor3 = Color3.fromRGB(11, 11, 14),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 76),
        Size = UDim2.new(0, 150, 1, -88)
    })

    Corner(sidebar, 12)

    local sidebarLayout = New("UIListLayout", {
        Parent = sidebar,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    Padding(sidebar, 10, 10, 12, 10)

    window.Sidebar = sidebar

    -----------------------------------------------------------------
    -- CONTENT
    -----------------------------------------------------------------

    local content = New("Frame", {
        Parent = main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 174, 0, 76),
        Size = UDim2.new(1, -186, 1, -88)
    })

    window.Content = content

    -----------------------------------------------------------------
    -- TAB SELECT
    -----------------------------------------------------------------

    function window:SelectTab(tab)

        for _, current in ipairs(self.Tabs) do

            local selected =
                current == tab

            current.Page.Visible = selected

            if selected then

                Tween(current.Button, {
                    BackgroundColor3 =
                        Color3.fromRGB(29, 29, 35),
                    TextColor3 =
                        Library.Text
                })

            else

                Tween(current.Button, {
                    BackgroundTransparency = 1,
                    TextColor3 =
                        Library.SubText
                })
            end
        end
    end

    function window:AddTab(name, icon)
        return CreateTab(self, name, icon)
    end

    function window:Destroy()

        if gui then
            gui:Destroy()
        end
    end

    function window:SelectTabByName(name)

        for _, tab in ipairs(self.Tabs) do

            if tab.Name == name then
                self:SelectTab(tab)
                return tab
            end
        end
    end

    -----------------------------------------------------------------
    -- SEARCH SYSTEM
    -----------------------------------------------------------------

    search:GetPropertyChangedSignal("Text"):Connect(function()

        local query =
            string.lower(search.Text or "")

        for _, tab in ipairs(window.Tabs) do

            for _, group in ipairs({
                tab.Page
            }) do

                for _, object in ipairs(group:GetDescendants()) do

                    if object:IsA("TextLabel")
                        or object:IsA("TextButton") then

                        if object.Text
                            and object ~= search then

                            local matches =
                                query == ""
                                or string.find(
                                    string.lower(object.Text),
                                    query,
                                    1,
                                    true
                                ) ~= nil

                            object.Visible = matches
                        end
                    end
                end
            end
        end
    end)

    MakeDraggable(main, top)

    table.insert(
        Library.Windows,
        window
    )

    return window
end

---------------------------------------------------------------------
-- UNLOAD
---------------------------------------------------------------------

function Library:Unload()

    for _, window in ipairs(Library.Windows) do

        if window.Destroy then
            pcall(function()
                window:Destroy()
            end)
        end
    end

    Library.Windows = {}

    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
        Library.ScreenGui = nil
    end
end

return Library
