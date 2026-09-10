--[[
AI Generated Test Library
]]

local Library = {}

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------------
-- VERSION
---------------------------------------------------------------------

Library.Version = "1.0.0"

---------------------------------------------------------------------
-- REGISTRIES
---------------------------------------------------------------------

Library.Options = {}
Library.Toggles = {}
Library.Flags = {}

Library.Windows = {}

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------

Library.Settings = {
    ToggleKey = Enum.KeyCode.RightShift,

    AnimationSpeed = 0.18,

    Font = Enum.Font.Gotham,

    Theme = {
        Background = Color3.fromRGB(13, 13, 17),
        Secondary = Color3.fromRGB(18, 18, 23),
        Tertiary = Color3.fromRGB(23, 23, 29),

        Element = Color3.fromRGB(28, 28, 35),
        ElementHover = Color3.fromRGB(35, 35, 43),

        Accent = Color3.fromRGB(145, 92, 255),
        AccentDark = Color3.fromRGB(105, 63, 195),

        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(145, 145, 158),

        Border = Color3.fromRGB(44, 44, 54),

        Success = Color3.fromRGB(75, 200, 125),
        Warning = Color3.fromRGB(235, 175, 65),
        Error = Color3.fromRGB(225, 80, 90),

        Shadow = Color3.fromRGB(0, 0, 0),
    }
}

---------------------------------------------------------------------
-- INTERNAL STATE
---------------------------------------------------------------------

local Connections = {}
local Destroyed = false

---------------------------------------------------------------------
-- UTILITY
---------------------------------------------------------------------

local function Track(connection)
    if connection then
        table.insert(Connections, connection)
    end

    return connection
end

local function Disconnect(connection)
    if connection then
        pcall(function()
            connection:Disconnect()
        end)
    end
end

local function DisconnectAll()
    for _, connection in ipairs(Connections) do
        Disconnect(connection)
    end

    table.clear(Connections)
end

local function Create(className, properties)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        pcall(function()
            object[property] = value
        end)
    end

    return object
end

local function Tween(instance, properties, duration)
    if not instance or not instance.Parent then
        return
    end

    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or Library.Settings.AnimationSpeed,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        properties
    )

    tween:Play()

    return tween
end

local function Corner(parent, radius)
    return Create("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius or 6)
    })
end

local function Stroke(parent, color, transparency, thickness)
    return Create("UIStroke", {
        Parent = parent,
        Color = color or Library.Settings.Theme.Border,
        Transparency = transparency or 0,
        Thickness = thickness or 1
    })
end

local function Padding(parent, value)
    return Create("UIPadding", {
        Parent = parent,

        PaddingTop = UDim.new(0, value),
        PaddingBottom = UDim.new(0, value),
        PaddingLeft = UDim.new(0, value),
        PaddingRight = UDim.new(0, value)
    })
end

local function GetParent()
    local success, result = pcall(function()
        return game:GetService("CoreGui")
    end)

    if success and result then
        return result
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local function IsMobile()
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
end

local function ClampNumber(value, min, max)
    return math.clamp(
        tonumber(value) or min,
        min,
        max
    )
end

local function Round(value, decimals)
    local multiplier = 10 ^ (decimals or 0)

    return math.floor(value * multiplier + 0.5)
        / multiplier
end

local function GetInputPosition(input)
    return input.Position
end

---------------------------------------------------------------------
-- DRAGGING
---------------------------------------------------------------------

local function MakeDraggable(frame, handle)
    handle = handle or frame

    local dragging = false
    local dragStart
    local startPosition

    Track(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = frame.Position
        end
    end))

    Track(handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end))

    Track(UserInputService.InputChanged:Connect(function(input)
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
    end))
end

---------------------------------------------------------------------
-- BASE ELEMENT
---------------------------------------------------------------------

local Element = {}
Element.__index = Element

function Element:SetVisible(value)
    self.Visible = value

    if self.Instance then
        self.Instance.Visible = value
    end

    return self
end

function Element:SetDisabled(value)
    self.Disabled = value

    if self.Label then
        self.Label.TextTransparency = value and 0.55 or 0
    end

    if self.Instance and self.Instance:IsA("GuiButton") then
        self.Instance.Active = not value
        self.Instance.AutoButtonColor = not value
    end

    return self
end

function Element:SetText(text)
    self.Text = text

    if self.Label then
        self.Label.Text = text
    end

    return self
end

function Element:Destroy()
    if self.Instance then
        self.Instance:Destroy()
    end
end

---------------------------------------------------------------------
-- TOGGLE
---------------------------------------------------------------------

local Toggle = setmetatable({}, Element)
Toggle.__index = Toggle

function Toggle:SetValue(value, silent)
    if self.Disabled then
        return self
    end

    value = value == true

    self.Value = value

    if value then
        Tween(self.Box, {
            BackgroundColor3 = Library.Settings.Theme.Accent
        })

        Tween(self.Check, {
            TextTransparency = 0
        })
    else
        Tween(self.Box, {
            BackgroundColor3 = Library.Settings.Theme.Element
        })

        Tween(self.Check, {
            TextTransparency = 1
        })
    end

    Library.Flags[self.Flag] = value

    if not silent and self.Callback then
        task.spawn(self.Callback, value)
    end

    return self
end

function Toggle:OnChanged(callback)
    self.Callback = callback
    return self
end

function Toggle:GetValue()
    return self.Value
end

---------------------------------------------------------------------
-- BUTTON
---------------------------------------------------------------------

local Button = setmetatable({}, Element)
Button.__index = Button

function Button:Press()
    if self.Disabled then
        return self
    end

    if self.Callback then
        task.spawn(self.Callback)
    end

    return self
end

---------------------------------------------------------------------
-- SLIDER
---------------------------------------------------------------------

local Slider = setmetatable({}, Element)
Slider.__index = Slider

function Slider:SetValue(value, silent)
    if self.Disabled then
        return self
    end

    value = ClampNumber(
        value,
        self.Min,
        self.Max
    )

    if self.Rounding then
        value = Round(
            value,
            self.Rounding
        )
    end

    self.Value = value

    local alpha = 0

    if self.Max ~= self.Min then
        alpha = (value - self.Min)
            / (self.Max - self.Min)
    end

    Tween(self.Fill, {
        Size = UDim2.new(alpha, 0, 1, 0)
    })

    self.ValueLabel.Text = tostring(value)

    Library.Flags[self.Flag] = value

    if not silent and self.Callback then
        task.spawn(self.Callback, value)
    end

    return self
end

function Slider:OnChanged(callback)
    self.Callback = callback
    return self
end

function Slider:GetValue()
    return self.Value
end

---------------------------------------------------------------------
-- DROPDOWN
---------------------------------------------------------------------

local Dropdown = setmetatable({}, Element)
Dropdown.__index = Dropdown

function Dropdown:SetValue(value, silent)
    if self.Disabled then
        return self
    end

    if self.Multi then
        if type(value) ~= "table" then
            return self
        end

        self.Value = value

        local selected = {}

        for option, enabled in pairs(value) do
            if enabled then
                table.insert(
                    selected,
                    tostring(option)
                )
            end
        end

        table.sort(selected)

        self.ValueLabel.Text =
            #selected > 0
            and table.concat(selected, ", ")
            or "None"

    else
        self.Value = value

        self.ValueLabel.Text =
            value ~= nil
            and tostring(value)
            or "None"
    end

    Library.Flags[self.Flag] = self.Value

    if not silent and self.Callback then
        task.spawn(
            self.Callback,
            self.Value
        )
    end

    return self
end

function Dropdown:SetValues(values)
    self.Values = values or {}

    self:Rebuild()

    return self
end

function Dropdown:Rebuild()
    for _, child in ipairs(self.List:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local count = 0

    for _, value in ipairs(self.Values) do
        count += 1

        local button = Create("TextButton", {
            Parent = self.List,

            BackgroundColor3 =
                Library.Settings.Theme.Element,

            Size = UDim2.new(1, 0, 0, 27),

            Text = tostring(value),

            TextColor3 =
                Library.Settings.Theme.Text,

            TextSize = 12,

            Font = Library.Settings.Font,

            AutoButtonColor = false,

            ZIndex = 100
        })

        Corner(button, 5)

        button.MouseEnter:Connect(function()
            Tween(button, {
                BackgroundColor3 =
                    Library.Settings.Theme.ElementHover
            })
        end)

        button.MouseLeave:Connect(function()
            Tween(button, {
                BackgroundColor3 =
                    Library.Settings.Theme.Element
            })
        end)

        button.MouseButton1Click:Connect(function()
            if self.Multi then
                self.Value = self.Value or {}

                self.Value[value] =
                    not self.Value[value]

                self:SetValue(self.Value)
            else
                self:SetValue(value)

                self:SetOpen(false)
            end
        end)
    end

    self.List.Size = UDim2.new(
        1,
        0,
        0,
        math.min(
            count * 29 + 8,
            180
        )
    )
end

function Dropdown:SetOpen(value)
    self.Open = value

    self.List.Visible = value

    Tween(self.Arrow, {
        Rotation = value and 180 or 0
    })

    return self
end

function Dropdown:OnChanged(callback)
    self.Callback = callback
    return self
end

---------------------------------------------------------------------
-- INPUT
---------------------------------------------------------------------

local Input = setmetatable({}, Element)
Input.__index = Input

function Input:SetValue(value, silent)
    if self.Disabled then
        return self
    end

    value = tostring(value or "")

    self.Value = value

    self.TextBox.Text = value

    Library.Flags[self.Flag] = value

    if not silent and self.Callback then
        task.spawn(
            self.Callback,
            value
        )
    end

    return self
end

function Input:OnChanged(callback)
    self.Callback = callback
    return self
end

---------------------------------------------------------------------
-- KEYBIND
---------------------------------------------------------------------

local Keybind = setmetatable({}, Element)
Keybind.__index = Keybind

function Keybind:SetValue(key)
    self.Value = key

    self.KeyLabel.Text =
        key and key.Name or "None"

    Library.Flags[self.Flag] = key

    return self
end

function Keybind:OnChanged(callback)
    self.Callback = callback
    return self
end

function Keybind:Listen()
    if self.Listening then
        return
    end

    self.Listening = true

    self.KeyLabel.Text = "..."

    local connection

    connection = UserInputService.InputBegan:Connect(
        function(input)
            if input.UserInputType
                == Enum.UserInputType.Keyboard then

                self:SetValue(input.KeyCode)

                self.Listening = false

                Disconnect(connection)

                if self.Callback then
                    task.spawn(
                        self.Callback,
                        input.KeyCode
                    )
                end
            end
        end
    )
end

---------------------------------------------------------------------
-- COLORPICKER
---------------------------------------------------------------------

local Colorpicker = setmetatable({}, Element)
Colorpicker.__index = Colorpicker

function Colorpicker:SetValue(color, silent)
    if self.Disabled then
        return self
    end

    if typeof(color) ~= "Color3" then
        return self
    end

    self.Value = color

    self.Swatch.BackgroundColor3 = color

    Library.Flags[self.Flag] = color

    if not silent and self.Callback then
        task.spawn(
            self.Callback,
            color
        )
    end

    return self
end

function Colorpicker:OnChanged(callback)
    self.Callback = callback
    return self
end

---------------------------------------------------------------------
-- GROUPBOX
---------------------------------------------------------------------

local Groupbox = {}
Groupbox.__index = Groupbox

function Groupbox:_CreateElement(height)
    local frame = Create("Frame", {
        Parent = self.Container,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            height or 32
        )
    })

    return frame
end

function Groupbox:AddLabel(text)
    local frame = self:_CreateElement(25)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 1, 0),

        Text = text or "Label",

        TextColor3 =
            Library.Settings.Theme.SubText,

        TextSize = 13,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    return setmetatable({
        Instance = frame,
        Label = label,
        Text = text
    }, Element)
end

function Groupbox:AddDivider()
    local frame = self:_CreateElement(13)

    Create("Frame", {
        Parent = frame,

        Position = UDim2.new(
            0,
            0,
            0.5,
            0
        ),

        Size = UDim2.new(
            1,
            0,
            0,
            1
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Border,

        BorderSizePixel = 0
    })

    return frame
end

---------------------------------------------------------------------
-- BUTTON
---------------------------------------------------------------------

function Groupbox:AddButton(options)
    options = options or {}

    local text = options.Text or "Button"

    local callback =
        options.Func
        or options.Callback

    local frame = self:_CreateElement(34)

    local button = Create("TextButton", {
        Parent = frame,

        BackgroundColor3 =
            Library.Settings.Theme.Element,

        Size = UDim2.new(1, 0, 1, 0),

        Text = text,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 13,

        Font = Library.Settings.Font,

        AutoButtonColor = false
    })

    Corner(button, 6)
    Stroke(button)

    local object = setmetatable({
        Instance = button,

        Label = button,

        Text = text,

        Callback = callback,

        Disabled = false
    }, Button)

    button.MouseEnter:Connect(function()
        if object.Disabled then
            return
        end

        Tween(button, {
            BackgroundColor3 =
                Library.Settings.Theme.ElementHover
        })
    end)

    button.MouseLeave:Connect(function()
        Tween(button, {
            BackgroundColor3 =
                Library.Settings.Theme.Element
        })
    end)

    button.MouseButton1Click:Connect(function()
        object:Press()
    end)

    return object
end

---------------------------------------------------------------------
-- TOGGLE
---------------------------------------------------------------------

function Groupbox:AddToggle(flag, options)
    options = options or {}

    local text =
        options.Text
        or options.Name
        or flag

    local default =
        options.Default == true

    local callback =
        options.Callback
        or options.Func

    local frame = self:_CreateElement(32)

    local button = Create("TextButton", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 1, 0),

        Text = "",

        AutoButtonColor = false
    })

    local box = Create("Frame", {
        Parent = button,

        Position = UDim2.new(
            0,
            0,
            0.5,
            -9
        ),

        Size = UDim2.fromOffset(
            18,
            18
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Element
    })

    Corner(box, 5)
    Stroke(box)

    local check = Create("TextLabel", {
        Parent = box,

        BackgroundTransparency = 1,

        Size = UDim2.new(1, 0, 1, 0),

        Text = "✓",

        TextColor3 =
            Color3.new(1, 1, 1),

        Font = Enum.Font.GothamBold,

        TextSize = 12,

        TextTransparency = 1
    })

    local label = Create("TextLabel", {
        Parent = button,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            28,
            0
        ),

        Size = UDim2.new(
            1,
            -28,
            1,
            0
        ),

        Text = text,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 13,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local object = setmetatable({
        Instance = frame,

        Label = label,

        Box = box,

        Check = check,

        Text = text,

        Value = default,

        Flag = flag,

        Callback = callback,

        Disabled = false
    }, Toggle)

    Library.Options[flag] = object
    Library.Toggles[flag] = object

    button.MouseButton1Click:Connect(function()
        object:SetValue(
            not object.Value
        )
    end)

    object:SetValue(
        default,
        true
    )

    return object
end

Groupbox.AddCheckbox = Groupbox.AddToggle

---------------------------------------------------------------------
-- SLIDER
---------------------------------------------------------------------

function Groupbox:AddSlider(flag, options)
    options = options or {}

    local min =
        tonumber(options.Min)
        or 0

    local max =
        tonumber(options.Max)
        or 100

    local default =
        tonumber(options.Default)
        or min

    local rounding =
        tonumber(options.Rounding)
        or 0

    local frame = self:_CreateElement(51)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            -70,
            0,
            20
        ),

        Text =
            options.Text
            or flag,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 13,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local valueLabel = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        AnchorPoint =
            Vector2.new(1, 0),

        Position = UDim2.new(
            1,
            0,
            0,
            0
        ),

        Size = UDim2.fromOffset(
            65,
            20
        ),

        Text = tostring(default),

        TextColor3 =
            Library.Settings.Theme.SubText,

        TextSize = 12,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Right
    })

    local slider = Create("TextButton", {
        Parent = frame,

        Position = UDim2.new(
            0,
            0,
            0,
            29
        ),

        Size = UDim2.new(
            1,
            0,
            0,
            6
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Element,

        Text = "",

        AutoButtonColor = false
    })

    Corner(slider, 4)

    local fill = Create("Frame", {
        Parent = slider,

        Size = UDim2.new(
            0,
            0,
            1,
            0
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Accent,

        BorderSizePixel = 0
    })

    Corner(fill, 4)

    local object = setmetatable({
        Instance = frame,

        Label = label,

        Slider = slider,

        Fill = fill,

        ValueLabel = valueLabel,

        Min = min,

        Max = max,

        Value = default,

        Rounding = rounding,

        Flag = flag,

        Callback =
            options.Callback
            or options.Func,

        Disabled = false
    }, Slider)

    Library.Options[flag] = object

    local dragging = false

    local function Update(input)
        if object.Disabled then
            return
        end

        local position = input.Position.X

        local start =
            slider.AbsolutePosition.X

        local width =
            slider.AbsoluteSize.X

        local alpha =
            math.clamp(
                (position - start) / width,
                0,
                1
            )

        local value =
            min
            + ((max - min) * alpha)

        object:SetValue(value)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType
            == Enum.UserInputType.MouseButton1
            or input.UserInputType
            == Enum.UserInputType.Touch then

            dragging = true

            Update(input)
        end
    end)

    Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType
            == Enum.UserInputType.MouseButton1
            or input.UserInputType
            == Enum.UserInputType.Touch then

            dragging = false
        end
    end))

    Track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType
            == Enum.UserInputType.MouseMovement
            or input.UserInputType
            == Enum.UserInputType.Touch then

            Update(input)
        end
    end))

    object:SetValue(
        default,
        true
    )

    return object
end

---------------------------------------------------------------------
-- INPUT
---------------------------------------------------------------------

function Groupbox:AddInput(flag, options)
    options = options or {}

    local frame = self:_CreateElement(58)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            20
        ),

        Text =
            options.Text
            or flag,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 13,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local textbox = Create("TextBox", {
        Parent = frame,

        Position = UDim2.fromOffset(
            0,
            25
        ),

        Size = UDim2.new(
            1,
            0,
            0,
            30
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Element,

        TextColor3 =
            Library.Settings.Theme.Text,

        PlaceholderColor3 =
            Library.Settings.Theme.SubText,

        PlaceholderText =
            options.Placeholder
            or "",

        Text =
            options.Default
            or "",

        TextSize = 12,

        Font = Library.Settings.Font,

        ClearTextOnFocus = false,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    Corner(textbox, 6)
    Stroke(textbox)
    Padding(textbox, 8)

    local object = setmetatable({
        Instance = frame,

        Label = label,

        TextBox = textbox,

        Value =
            options.Default
            or "",

        Flag = flag,

        Callback =
            options.Callback
            or options.Func,

        Disabled = false
    }, Input)

    Library.Options[flag] = object

    Track(textbox.FocusLost:Connect(function()
        object:SetValue(
            textbox.Text
        )
    end))

    return object
end

---------------------------------------------------------------------
-- DROPDOWN
---------------------------------------------------------------------

function Groupbox:AddDropdown(flag, options)
    options = options or {}

    local frame = self:_CreateElement(55)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            20
        ),

        Text =
            options.Text
            or flag,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 13,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local dropdown = Create("TextButton", {
        Parent = frame,

        Position = UDim2.fromOffset(
            0,
            25
        ),

        Size = UDim2.new(
            1,
            0,
            0,
            30
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Element,

        Text = "",

        AutoButtonColor = false,

        ZIndex = 10
    })

    Corner(dropdown, 6)
    Stroke(dropdown)

    local valueLabel = Create("TextLabel", {
        Parent = dropdown,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            9,
            0
        ),

        Size = UDim2.new(
            1,
            -35,
            1,
            0
        ),

        Text = "None",

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 12,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        ZIndex = 11
    })

    local arrow = Create("TextLabel", {
        Parent = dropdown,

        BackgroundTransparency = 1,

        AnchorPoint =
            Vector2.new(1, 0.5),

        Position = UDim2.new(
            1,
            -8,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            18,
            18
        ),

        Text = "⌄",

        TextColor3 =
            Library.Settings.Theme.SubText,

        TextSize = 14,

        Font = Library.Settings.Font,

        ZIndex = 11
    })

    local list = Create("Frame", {
        Parent = frame,

        Position = UDim2.fromOffset(
            0,
            58
        ),

        Size = UDim2.new(
            1,
            0,
            0,
            0
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Secondary,

        Visible = false,

        ZIndex = 50
    })

    Corner(list, 6)
    Stroke(list)

    Padding(list, 4)

    Create("UIListLayout", {
        Parent = list,

        Padding = UDim.new(
            0,
            2
        ),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    })

    local object = setmetatable({
        Instance = frame,

        Label = label,

        Dropdown = dropdown,

        ValueLabel = valueLabel,

        Arrow = arrow,

        List = list,

        Values =
            options.Values
            or {},

        Value = options.Default,

        Flag = flag,

        Callback =
            options.Callback
            or options.Func,

        Multi =
            options.Multi == true,

        Open = false,

        Disabled = false
    }, Dropdown)

    Library.Options[flag] = object

    object:Rebuild()

    dropdown.MouseButton1Click:Connect(function()
        object:SetOpen(
            not object.Open
        )
    end)

    if options.Default ~= nil then
        if object.Multi then
            if type(options.Default) == "table" then
                object:SetValue(
                    options.Default,
                    true
                )
            else
                object:SetValue({
                    [options.Default] = true
                }, true)
            end
        else
            object:SetValue(
                options.Default,
                true
            )
        end
    end

    return object
end

function Groupbox:AddMultiDropdown(flag, options)
    options = options or {}
    options.Multi = true

    return self:AddDropdown(
        flag,
        options
    )
end

---------------------------------------------------------------------
-- KEYBIND
---------------------------------------------------------------------

function Groupbox:AddKeybind(flag, options)
    options = options or {}

    local frame = self:_CreateElement(34)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            -80,
            1,
            0
        ),

        Text =
            options.Text
            or flag,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 13,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local keyButton = Create("TextButton", {
        Parent = frame,

        AnchorPoint =
            Vector2.new(1, 0.5),

        Position = UDim2.new(
            1,
            0,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            70,
            26
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Element,

        Text =
            options.Default
            and options.Default.Name
            or "None",

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 11,

        Font = Library.Settings.Font,

        AutoButtonColor = false
    })

    Corner(keyButton, 6)
    Stroke(keyButton)

    local object = setmetatable({
        Instance = frame,

        Label = label,

        KeyButton = keyButton,

        KeyLabel = keyButton,

        Value = options.Default,

        Flag = flag,

        Callback =
            options.Callback
            or options.Func,

        Listening = false,

        Disabled = false
    }, Keybind)

    Library.Options[flag] = object

    keyButton.MouseButton1Click:Connect(function()
        object:Listen()
    end)

    return object
end

---------------------------------------------------------------------
-- COLORPICKER
---------------------------------------------------------------------

function Groupbox:AddColorpicker(flag, options)
    options = options or {}

    local frame = self:_CreateElement(34)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            -45,
            1,
            0
        ),

        Text =
            options.Text
            or flag,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 13,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local swatch = Create("TextButton", {
        Parent = frame,

        AnchorPoint =
            Vector2.new(1, 0.5),

        Position = UDim2.new(
            1,
            0,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            34,
            22
        ),

        BackgroundColor3 =
            options.Default
            or Library.Settings.Theme.Accent,

        Text = "",

        AutoButtonColor = false
    })

    Corner(swatch, 6)
    Stroke(swatch)

    local object = setmetatable({
        Instance = frame,

        Label = label,

        Swatch = swatch,

        Value =
            options.Default
            or Library.Settings.Theme.Accent,

        Flag = flag,

        Callback =
            options.Callback
            or options.Func,

        Disabled = false
    }, Colorpicker)

    Library.Options[flag] = object

    swatch.MouseButton1Click:Connect(function()
        -- Full picker UI is intentionally kept separate
        -- from the basic swatch interaction in v1.
        --
        -- The selected color can still be changed through:
        -- Options[flag]:SetValue(Color3.new(...))
    end)

    object:SetValue(
        object.Value,
        true
    )

    return object
end

---------------------------------------------------------------------
-- DEPENDENCY BOX
---------------------------------------------------------------------

local DependencyBox = {}
DependencyBox.__index = DependencyBox

function DependencyBox:SetupDependencies(...)
    self.Dependencies = {...}

    self:Update()

    return self
end

function DependencyBox:Update()
    if not self.Dependencies then
        self.Instance.Visible = true
        return
    end

    local visible = true

    for _, dependency in ipairs(
        self.Dependencies
    ) do

        if dependency.Value ~= true then
            visible = false
            break
        end
    end

    self.Instance.Visible = visible

    return self
end

function Groupbox:AddDependencyBox(...)
    local frame = Create("Frame", {
        Parent = self.Container,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y
    })

    Create("UIListLayout", {
        Parent = frame,

        Padding = UDim.new(
            0,
            5
        ),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    })

    return setmetatable({
        Instance = frame,

        Container = frame,

        Dependencies = nil
    }, DependencyBox)
end

---------------------------------------------------------------------
-- TAB
---------------------------------------------------------------------

local Tab = {}
Tab.__index = Tab

function Tab:_CreateColumn(parent)
    local column = Create("Frame", {
        Parent = parent,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y
    })

    Create("UIListLayout", {
        Parent = column,

        Padding = UDim.new(
            0,
            8
        ),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    })

    return column
end

function Tab:_AddGroupbox(name, side)
    local parent =
        side == "Right"
        and self.Right
        or self.Left

    local box = Create("Frame", {
        Parent = parent,

        BackgroundColor3 =
            Library.Settings.Theme.Secondary,

        Size = UDim2.new(
            1,
            0,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y
    })

    Corner(box, 8)
    Stroke(box)

    local title = Create("TextLabel", {
        Parent = box,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            12,
            8
        ),

        Size = UDim2.new(
            1,
            -24,
            0,
            22
        ),

        Text = name or "Groupbox",

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 14,

        Font = Enum.Font.GothamBold,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local container = Create("Frame", {
        Parent = box,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            12,
            36
        ),

        Size = UDim2.new(
            1,
            -24,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y
    })

    Create("UIListLayout", {
        Parent = container,

        Padding = UDim.new(
            0,
            5
        ),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    })

    local groupbox = setmetatable({
        Instance = box,

        Title = title,

        Container = container,

        Name = name,

        Tab = self
    }, Groupbox)

    return groupbox
end

function Tab:AddLeftGroupbox(name)
    return self:_AddGroupbox(
        name,
        "Left"
    )
end

function Tab:AddRightGroupbox(name)
    return self:_AddGroupbox(
        name,
        "Right"
    )
end

function Tab:AddTabbox()
    local wrapper = Create("Frame", {
        Parent = self.Container,

        BackgroundColor3 =
            Library.Settings.Theme.Secondary,

        Size = UDim2.new(
            1,
            0,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y
    })

    Corner(wrapper, 8)
    Stroke(wrapper)

    local buttons = Create("Frame", {
        Parent = wrapper,

        BackgroundColor3 =
            Library.Settings.Theme.Tertiary,

        Size = UDim2.new(
            1,
            0,
            0,
            34
        )
    })

    Corner(buttons, 8)

    local content = Create("Frame", {
        Parent = wrapper,

        Position = UDim2.fromOffset(
            10,
            42
        ),

        Size = UDim2.new(
            1,
            -20,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    })

    local layout = Create("UIListLayout", {
        Parent = buttons,

        FillDirection =
            Enum.FillDirection.Horizontal,

        SortOrder =
            Enum.SortOrder.LayoutOrder
    })

    local tabbox = {
        Instance = wrapper,

        Buttons = buttons,

        Content = content,

        Tabs = {}
    }

    function tabbox:AddTab(name)
        local index =
            #self.Tabs + 1

        local button = Create("TextButton", {
            Parent = self.Buttons,

            BackgroundTransparency = 1,

            Size = UDim2.new(
                1 / math.max(
                    index,
                    1
                ),
                0,
                1,
                0
            ),

            Text = name,

            TextColor3 =
                Library.Settings.Theme.SubText,

            TextSize = 12,

            Font = Library.Settings.Font,

            AutoButtonColor = false
        })

        local page = Create("Frame", {
            Parent = self.Content,

            BackgroundTransparency = 1,

            Size = UDim2.new(
                1,
                0,
                0,
                0
            ),

            AutomaticSize =
                Enum.AutomaticSize.Y,

            Visible = index == 1
        })

        local pageLayout = Create("UIListLayout", {
            Parent = page,

            Padding = UDim.new(
                0,
                5
            ),

            SortOrder =
                Enum.SortOrder.LayoutOrder
        })

        local tab = setmetatable({
            Window = self.Window,

            Page = page,

            Container = page,

            Left = page,

            Right = page,

            Button = button,

            Name = name
        }, Tab)

        table.insert(
            self.Tabs,
            tab
        )

        local width =
            1 / #self.Tabs

        for _, existing in ipairs(
            self.Tabs
        ) do
            existing.Button.Size =
                UDim2.new(
                    width,
                    0,
                    1,
                    0
                )
        end

        button.MouseButton1Click:Connect(function()
            for _, existing in ipairs(
                self.Tabs
            ) do

                existing.Page.Visible = false

                existing.Button.TextColor3 =
                    Library.Settings.Theme.SubText
            end

            tab.Page.Visible = true

            button.TextColor3 =
                Library.Settings.Theme.Text
        end)

        if index == 1 then
            button.TextColor3 =
                Library.Settings.Theme.Text
        end

        return tab
    end

    return tabbox
end

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------

local Window = {}
Window.__index = Window

function Window:AddTab(name, icon)
    local index =
        #self.Tabs + 1

    local buttonText =
        icon
        and (icon .. "  " .. name)
        or name

    local button = Create("TextButton", {
        Parent = self.TabBar,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            36
        ),

        Text = buttonText,

        TextColor3 =
            Library.Settings.Theme.SubText,

        TextSize = 13,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        AutoButtonColor = false
    })

    Padding(button, 10)

    local indicator = Create("Frame", {
        Parent = button,

        AnchorPoint =
            Vector2.new(0, 0.5),

        Position = UDim2.new(
            0,
            0,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            3,
            0
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Accent,

        BorderSizePixel = 0
    })

    Corner(indicator, 3)

    local page = Create("ScrollingFrame", {
        Parent = self.Pages,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            1,
            0
        ),

        CanvasSize = UDim2.new(),

        AutomaticCanvasSize =
            Enum.AutomaticSize.Y,

        ScrollBarThickness = 2,

        ScrollBarImageColor3 =
            Library.Settings.Theme.Accent,

        BorderSizePixel = 0,

        Visible = index == 1
    })

    local content = Create("Frame", {
        Parent = page,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            8,
            8
        ),

        Size = UDim2.new(
            1,
            -16,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y
    })

    local columns = Create("Frame", {
        Parent = content,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y
    })

    local left = self:_CreateColumn(
        columns
    )

    left.Size = UDim2.new(
        0.5,
        -5,
        0,
        0
    )

    local right = self:_CreateColumn(
        columns
    )

    right.AnchorPoint =
        Vector2.new(1, 0)

    right.Position =
        UDim2.new(
            1,
            0,
            0,
            0
        )

    right.Size =
        UDim2.new(
            0.5,
            -5,
            0,
            0
        )

    local tab = setmetatable({
        Window = self,

        Name = name,

        Icon = icon,

        Button = button,

        Indicator = indicator,

        Page = page,

        Container = content,

        Columns = columns,

        Left = left,

        Right = right
    }, Tab)

    table.insert(
        self.Tabs,
        tab
    )

    button.MouseEnter:Connect(function()
        if page.Visible then
            return
        end

        Tween(button, {
            TextColor3 =
                Library.Settings.Theme.Text
        })
    end)

    button.MouseLeave:Connect(function()
        if page.Visible then
            return
        end

        Tween(button, {
            TextColor3 =
                Library.Settings.Theme.SubText
        })
    end)

    button.MouseButton1Click:Connect(function()
        for _, existing in ipairs(
            self.Tabs
        ) do

            existing.Page.Visible = false

            existing.Button.TextColor3 =
                Library.Settings.Theme.SubText

            Tween(
                existing.Indicator,
                {
                    Size = UDim2.fromOffset(
                        3,
                        0
                    )
                }
            )
        end

        page.Visible = true

        Tween(button, {
            TextColor3 =
                Library.Settings.Theme.Text
        })

        Tween(indicator, {
            Size = UDim2.fromOffset(
                3,
                20
            )
        })
    end)

    if index == 1 then
        button.TextColor3 =
            Library.Settings.Theme.Text

        indicator.Size =
            UDim2.fromOffset(
                3,
                20
            )
    end

    return tab
end

---------------------------------------------------------------------
-- WINDOW SEARCH
---------------------------------------------------------------------

function Window:SetSearch(value)
    value = string.lower(
        tostring(value or "")
    )

    self.Search = value

    for _, tab in ipairs(
        self.Tabs
    ) do

        local function Scan(parent)
            for _, child in ipairs(
                parent:GetDescendants()
            ) do

                if child:IsA("TextLabel")
                    or child:IsA("TextButton") then

                    local text =
                        string.lower(
                            child.Text or ""
                        )

                    if value == "" then
                        child.Visible = true
                    elseif string.find(
                        text,
                        value,
                        1,
                        true
                    ) then

                        child.Visible = true
                    end
                end
            end
        end

        Scan(tab.Page)
    end
end

---------------------------------------------------------------------
-- NOTIFICATION
---------------------------------------------------------------------

function Window:Notify(options)
    options = options or {}

    local title =
        options.Title
        or "MoonHubGUI"

    local description =
        options.Description
        or ""

    local duration =
        tonumber(options.Duration)
        or 3

    local notification = Create("Frame", {
        Parent = self.NotificationHolder,

        BackgroundColor3 =
            Library.Settings.Theme.Secondary,

        Size = UDim2.fromOffset(
            300,
            75
        ),

        BackgroundTransparency = 1
    })

    Corner(notification, 8)
    Stroke(notification)

    local accent = Create("Frame", {
        Parent = notification,

        Size = UDim2.new(
            0,
            3,
            1,
            0
        ),

        BackgroundColor3 =
            options.Color
            or Library.Settings.Theme.Accent,

        BorderSizePixel = 0
    })

    Corner(accent, 3)

    local titleLabel = Create("TextLabel", {
        Parent = notification,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            15,
            10
        ),

        Size = UDim2.new(
            1,
            -25,
            0,
            20
        ),

        Text = title,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 14,

        Font = Enum.Font.GothamBold,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextTransparency = 1
    })

    local descLabel = Create("TextLabel", {
        Parent = notification,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            15,
            33
        ),

        Size = UDim2.new(
            1,
            -25,
            0,
            32
        ),

        Text = description,

        TextColor3 =
            Library.Settings.Theme.SubText,

        TextSize = 11,

        Font = Library.Settings.Font,

        TextWrapped = true,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextTransparency = 1
    })

    Tween(notification, {
        BackgroundTransparency = 0
    })

    Tween(titleLabel, {
        TextTransparency = 0
    })

    Tween(descLabel, {
        TextTransparency = 0
    })

    task.delay(duration, function()
        if not notification.Parent then
            return
        end

        Tween(notification, {
            BackgroundTransparency = 1
        })

        Tween(titleLabel, {
            TextTransparency = 1
        })

        Tween(descLabel, {
            TextTransparency = 1
        })

        task.wait(
            Library.Settings.AnimationSpeed
        )

        if notification.Parent then
            notification:Destroy()
        end
    end)

    return notification
end

---------------------------------------------------------------------
-- WINDOW TOGGLE
---------------------------------------------------------------------

function Window:Toggle()
    if self.Destroyed then
        return
    end

    self.Visible =
        not self.Visible

    if self.Visible then
        self.ScreenGui.Enabled = true

        self.Main.Size =
            UDim2.fromOffset(
                0,
                0
            )

        Tween(
            self.Main,
            {
                Size = self.Size
            }
        )
    else
        Tween(
            self.Main,
            {
                Size =
                    UDim2.fromOffset(
                        0,
                        0
                    )
            }
        )

        task.delay(
            Library.Settings.AnimationSpeed,
            function()
                if not self.Visible
                    and self.ScreenGui then

                    self.ScreenGui.Enabled = false
                end
            end
        )
    end
end

---------------------------------------------------------------------
-- WINDOW TITLE
---------------------------------------------------------------------

function Window:SetTitle(title)
    self.Title.Text =
        tostring(title)

    return self
end

function Window:SetSubtitle(subtitle)
    self.Subtitle.Text =
        tostring(subtitle)

    return self
end

---------------------------------------------------------------------
-- WINDOW THEME
---------------------------------------------------------------------

function Window:SetTheme(theme)
    for key, value in pairs(
        theme or {}
    ) do

        if self.Theme[key] ~= nil then
            self.Theme[key] = value
        end
    end

    Library:RefreshTheme()

    return self
end

---------------------------------------------------------------------
-- WINDOW UNLOAD
---------------------------------------------------------------------

function Window:Unload()
    if self.Destroyed then
        return
    end

    self.Destroyed = true

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end

    for i = #Library.Windows, 1, -1 do
        if Library.Windows[i] == self then
            table.remove(
                Library.Windows,
                i
            )
        end
    end
end

---------------------------------------------------------------------
-- CREATE WINDOW
---------------------------------------------------------------------

function Library:CreateWindow(options)
    options = options or {}

    local size =
        options.Size
        or UDim2.fromOffset(
            760,
            520
        )

    if IsMobile() then
        size = options.MobileSize
            or UDim2.new(
                0.92,
                0,
                0.78,
                0
            )
    end

    local screenGui = Create(
        "ScreenGui",
        {
            Name = "MoonHubGUI",

            ResetOnSpawn = false,

            ZIndexBehavior =
                Enum.ZIndexBehavior.Sibling,

            IgnoreGuiInset = true
        }
    )

    screenGui.Parent =
        GetParent()

    local main = Create("Frame", {
        Parent = screenGui,

        AnchorPoint =
            Vector2.new(
                0.5,
                0.5
            ),

        Position =
            UDim2.fromScale(
                0.5,
                0.5
            ),

        Size = size,

        BackgroundColor3 =
            Library.Settings.Theme.Background,

        BorderSizePixel = 0,

        ClipsDescendants = true
    })

    Corner(main, 10)
    Stroke(main)

    local shadow = Create("ImageLabel", {
        Parent = main,

        AnchorPoint =
            Vector2.new(
                0.5,
                0.5
            ),

        Position =
            UDim2.fromScale(
                0.5,
                0.5
            ),

        Size = UDim2.new(
            1,
            30,
            1,
            30
        ),

        BackgroundTransparency = 1,

        Image =
            "rbxassetid://6014261993",

        ImageColor3 =
            Library.Settings.Theme.Shadow,

        ImageTransparency = 0.5,

        ZIndex = 0
    })

    local topbar = Create("Frame", {
        Parent = main,

        BackgroundColor3 =
            Library.Settings.Theme.Secondary,

        Size = UDim2.new(
            1,
            0,
            0,
            58
        ),

        BorderSizePixel = 0,

        ZIndex = 2
    })

    local accent = Create("Frame", {
        Parent = topbar,

        Position = UDim2.new(
            0,
            0,
            1,
            -2
        ),

        Size = UDim2.new(
            1,
            0,
            0,
            2
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Accent,

        BorderSizePixel = 0
    })

    local title = Create("TextLabel", {
        Parent = topbar,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            18,
            8
        ),

        Size = UDim2.new(
            1,
            -36,
            0,
            24
        ),

        Text =
            options.Title
            or "MoonHubGUI",

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 17,

        Font = Enum.Font.GothamBold,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local subtitle = Create("TextLabel", {
        Parent = topbar,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            19,
            32
        ),

        Size = UDim2.new(
            1,
            -38,
            0,
            16
        ),

        Text =
            options.Subtitle
            or "MoonHub Interface",

        TextColor3 =
            Library.Settings.Theme.SubText,

        TextSize = 10,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local sidebar = Create("Frame", {
        Parent = main,

        Position = UDim2.fromOffset(
            0,
            58
        ),

        Size = UDim2.new(
            0,
            155,
            1,
            -58
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Secondary,

        BorderSizePixel = 0
    })

    local tabBar = Create("ScrollingFrame", {
        Parent = sidebar,

        Position = UDim2.fromOffset(
            8,
            10
        ),

        Size = UDim2.new(
            1,
            -16,
            1,
            -20
        ),

        BackgroundTransparency = 1,

        ScrollBarThickness = 0,

        CanvasSize = UDim2.new(),

        AutomaticCanvasSize =
            Enum.AutomaticSize.Y
    })

    Create("UIListLayout", {
        Parent = tabBar,

        Padding = UDim.new(
            0,
            3
        ),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    })

    local pages = Create("Frame", {
        Parent = main,

        Position = UDim2.fromOffset(
            155,
            58
        ),

        Size = UDim2.new(
            1,
            -155,
            1,
            -58
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Background,

        BorderSizePixel = 0
    })

    local notificationHolder = Create("Frame", {
        Parent = screenGui,

        AnchorPoint =
            Vector2.new(
                1,
                1
            ),

        Position = UDim2.new(
            1,
            -15,
            1,
            -15
        ),

        Size = UDim2.fromOffset(
            310,
            400
        ),

        BackgroundTransparency = 1,

        ZIndex = 1000
    })

    Create("UIListLayout", {
        Parent = notificationHolder,

        Padding = UDim.new(
            0,
            8
        ),

        VerticalAlignment =
            Enum.VerticalAlignment.Bottom,

        HorizontalAlignment =
            Enum.HorizontalAlignment.Right
    })

    local window = setmetatable({
        ScreenGui = screenGui,

        Main = main,

        Shadow = shadow,

        Topbar = topbar,

        Accent = accent,

        Title = title,

        Subtitle = subtitle,

        Sidebar = sidebar,

        TabBar = tabBar,

        Pages = pages,

        NotificationHolder =
            notificationHolder,

        Tabs = {},

        Visible = true,

        Destroyed = false,

        Size = size,

        Theme =
            Library.Settings.Theme
    }, Window)

    MakeDraggable(
        main,
        topbar
    )

    table.insert(
        Library.Windows,
        window
    )

    if options.ToggleKey then
        Library.Settings.ToggleKey =
            options.ToggleKey
    end

    if options.AutoShow == false then
        window.Visible = false
        screenGui.Enabled = false
    end

    return window
end

---------------------------------------------------------------------
-- GLOBAL NOTIFICATION
---------------------------------------------------------------------

function Library:Notify(options)
    local window =
        self.Windows[1]

    if window then
        return window:Notify(
            options
        )
    end
end

---------------------------------------------------------------------
-- THEME
---------------------------------------------------------------------

function Library:SetTheme(theme)
    for key, value in pairs(
        theme or {}
    ) do

        if self.Settings.Theme[key]
            ~= nil then

            self.Settings.Theme[key] =
                value
        end
    end

    self:RefreshTheme()

    return self
end

function Library:RefreshTheme()
    local theme =
        self.Settings.Theme

    for _, window in ipairs(
        self.Windows
    ) do

        if not window.Destroyed then

            window.Main.BackgroundColor3 =
                theme.Background

            window.Topbar.BackgroundColor3 =
                theme.Secondary

            window.Sidebar.BackgroundColor3 =
                theme.Secondary

            window.Pages.BackgroundColor3 =
                theme.Background

            window.Accent.BackgroundColor3 =
                theme.Accent

            window.Shadow.ImageColor3 =
                theme.Shadow

            window.Title.TextColor3 =
                theme.Text

            window.Subtitle.TextColor3 =
                theme.SubText
        end
    end
end

---------------------------------------------------------------------
-- KEY
---------------------------------------------------------------------

function Library:SetToggleKey(key)
    assert(
        typeof(key) == "EnumItem",
        "MoonHubGUI: Toggle key must be an EnumItem"
    )

    self.Settings.ToggleKey = key

    return self
end

---------------------------------------------------------------------
-- GLOBAL TOGGLE
---------------------------------------------------------------------

Track(UserInputService.InputBegan:Connect(
    function(input, processed)
        if processed then
            return
        end

        if input.KeyCode
            == Library.Settings.ToggleKey then

            for _, window in ipairs(
                Library.Windows
            ) do

                if not window.Destroyed then
                    window:Toggle()
                end
            end
        end
    end
))

---------------------------------------------------------------------
-- UNLOAD
---------------------------------------------------------------------

function Library:Unload()
    if Destroyed then
        return
    end

    Destroyed = true

    for _, window in ipairs(
        self.Windows
    ) do

        pcall(function()
            window:Unload()
        end)
    end

    table.clear(
        self.Windows
    )

    table.clear(
        self.Options
    )

    table.clear(
        self.Toggles
    )

    table.clear(
        self.Flags
    )

    DisconnectAll()
end

---------------------------------------------------------------------
-- VERSION
---------------------------------------------------------------------

function Library:GetVersion()
    return self.Version
end

---------------------------------------------------------------------
-- RETURN
---------------------------------------------------------------------

return Library
