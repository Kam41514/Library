--[[
    MoonHubGUI
    Single File UI Library
    Version: 2.0.0

    Clean / Thin / Elegant UI
]]

local Library = {}

---------------------------------------------------------------------
-- SERVICES
---------------------------------------------------------------------

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------------------
-- PUBLIC
---------------------------------------------------------------------

Library.Version = "2.0.0"

Library.Options = {}
Library.Toggles = {}
Library.Flags = {}
Library.Windows = {}

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------

Library.Settings = {
    ToggleKey = Enum.KeyCode.RightShift,

    AnimationSpeed = 0.16,

    Font = Enum.Font.Gotham,

    Theme = {
        Background = Color3.fromRGB(12, 12, 16),
        Sidebar = Color3.fromRGB(15, 15, 20),
        Groupbox = Color3.fromRGB(17, 17, 22),

        Element = Color3.fromRGB(23, 23, 29),
        ElementHover = Color3.fromRGB(29, 29, 36),

        Accent = Color3.fromRGB(145, 105, 235),
        AccentDark = Color3.fromRGB(108, 76, 185),

        Text = Color3.fromRGB(235, 235, 241),
        SubText = Color3.fromRGB(145, 145, 157),

        Border = Color3.fromRGB(39, 39, 48),

        Success = Color3.fromRGB(86, 190, 125),
        Warning = Color3.fromRGB(225, 170, 75),
        Error = Color3.fromRGB(220, 82, 94),

        Shadow = Color3.fromRGB(0, 0, 0)
    }
}

---------------------------------------------------------------------
-- INTERNAL
---------------------------------------------------------------------

local Connections = {}
local Destroyed = false

local function Track(connection)
    if connection then
        table.insert(Connections, connection)
    end

    return connection
end

local function DisconnectAll()
    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
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

local function Tween(object, properties, duration)
    if not object or not object.Parent then
        return
    end

    local tween = TweenService:Create(
        object,
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

local function Corner(object, radius)
    return Create("UICorner", {
        Parent = object,
        CornerRadius = UDim.new(0, radius or 6)
    })
end

local function AddStroke(object, color, transparency)
    return Create("UIStroke", {
        Parent = object,
        Color = color or Library.Settings.Theme.Border,
        Transparency = transparency or 0,
        Thickness = 1
    })
end

local function AddPadding(object, amount)
    return Create("UIPadding", {
        Parent = object,

        PaddingLeft = UDim.new(0, amount),
        PaddingRight = UDim.new(0, amount),
        PaddingTop = UDim.new(0, amount),
        PaddingBottom = UDim.new(0, amount)
    })
end

local function GetGuiParent()
    local success, result = pcall(function()
        return CoreGui
    end)

    if success and result then
        return result
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local function MakeDraggable(frame, handle)
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
-- ELEMENT BASE
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
    self.Disabled = value == true

    if self.Label then
        self.Label.TextTransparency =
            self.Disabled and 0.45 or 0
    end

    return self
end

function Element:SetText(text)
    self.Text = tostring(text)

    if self.Label then
        self.Label.Text = self.Text
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
            BackgroundColor3 =
                Library.Settings.Theme.Accent
        })

        Tween(self.Check, {
            TextTransparency = 0
        })
    else
        Tween(self.Box, {
            BackgroundColor3 =
                Library.Settings.Theme.Element
        })

        Tween(self.Check, {
            TextTransparency = 1
        })
    end

    Library.Flags[self.Flag] = value

    if not silent and self.Callback then
        task.spawn(
            self.Callback,
            value
        )
    end

    return self
end

function Toggle:GetValue()
    return self.Value
end

function Toggle:OnChanged(callback)
    self.Callback = callback
    return self
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

    value = math.clamp(
        tonumber(value) or self.Min,
        self.Min,
        self.Max
    )

    if self.Rounding then
        local multiplier = 10 ^ self.Rounding
        value =
            math.floor(
                value * multiplier + 0.5
            ) / multiplier
    end

    self.Value = value

    local alpha =
        (value - self.Min)
        / (self.Max - self.Min)

    alpha = math.clamp(
        alpha,
        0,
        1
    )

    Tween(self.Fill, {
        Size = UDim2.new(
            alpha,
            0,
            1,
            0
        )
    })

    self.ValueLabel.Text =
        tostring(value)

    Library.Flags[self.Flag] = value

    if not silent and self.Callback then
        task.spawn(
            self.Callback,
            value
        )
    end

    return self
end

function Slider:GetValue()
    return self.Value
end

function Slider:OnChanged(callback)
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

function Input:GetValue()
    return self.Value
end

function Input:OnChanged(callback)
    self.Callback = callback
    return self
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

    Library.Flags[self.Flag] =
        self.Value

    if not silent and self.Callback then
        task.spawn(
            self.Callback,
            self.Value
        )
    end

    return self
end

function Dropdown:GetValue()
    return self.Value
end

function Dropdown:SetValues(values)
    self.Values = values or {}

    self:Rebuild()

    return self
end

function Dropdown:SetOpen(value)
    self.Open = value

    self.List.Visible = value

    Tween(self.Arrow, {
        Rotation = value and 180 or 0
    })

    return self
end

function Dropdown:Rebuild()
    for _, child in ipairs(
        self.List:GetChildren()
    ) do

        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, option in ipairs(
        self.Values
    ) do

        local button = Create("TextButton", {
            Parent = self.List,

            BackgroundColor3 =
                Library.Settings.Theme.Element,

            Size = UDim2.new(
                1,
                0,
                0,
                27
            ),

            Text = tostring(option),

            TextColor3 =
                Library.Settings.Theme.Text,

            TextSize = 11,

            Font = Library.Settings.Font,

            AutoButtonColor = false
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

                self.Value =
                    self.Value or {}

                self.Value[option] =
                    not self.Value[option]

                self:SetValue(
                    self.Value
                )

            else

                self:SetValue(option)

                self:SetOpen(false)
            end
        end)
    end

    self.List.Size = UDim2.new(
        1,
        0,
        0,
        math.min(
            #self.Values * 29 + 8,
            180
        )
    )
end

function Dropdown:OnChanged(callback)
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

    Library.Flags[self.Flag] =
        key

    return self
end

function Keybind:GetValue()
    return self.Value
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

                self:SetValue(
                    input.KeyCode
                )

                self.Listening = false

                pcall(function()
                    connection:Disconnect()
                end)

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

function Keybind:OnChanged(callback)
    self.Callback = callback
    return self
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

    self.Swatch.BackgroundColor3 =
        color

    Library.Flags[self.Flag] =
        color

    if not silent and self.Callback then
        task.spawn(
            self.Callback,
            color
        )
    end

    return self
end

function Colorpicker:GetValue()
    return self.Value
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

function Groupbox:_Element(height)
    local frame = Create("Frame", {
        Parent = self.Container,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            height
        )
    })

    return frame
end

---------------------------------------------------------------------
-- LABEL
---------------------------------------------------------------------

function Groupbox:AddLabel(text)
    local frame =
        self:_Element(25)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            1,
            0
        ),

        Text = tostring(text or ""),

        TextColor3 =
            Library.Settings.Theme.SubText,

        TextSize = 12,

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

---------------------------------------------------------------------
-- DIVIDER
---------------------------------------------------------------------

function Groupbox:AddDivider()
    local frame =
        self:_Element(12)

    Create("Frame", {
        Parent = frame,

        AnchorPoint =
            Vector2.new(
                0,
                0.5
            ),

        Position =
            UDim2.fromScale(
                0,
                0.5
            ),

        Size =
            UDim2.new(
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

    local frame =
        self:_Element(32)

    local button = Create("TextButton", {
        Parent = frame,

        BackgroundColor3 =
            Library.Settings.Theme.Element,

        Size = UDim2.new(
            1,
            0,
            1,
            0
        ),

        Text =
            options.Text
            or "Button",

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 12,

        Font = Library.Settings.Font,

        AutoButtonColor = false
    })

    Corner(button, 6)
    AddStroke(button)

    local object = setmetatable({
        Instance = button,
        Label = button,

        Text =
            options.Text
            or "Button",

        Callback =
            options.Func
            or options.Callback,

        Disabled = false
    }, Button)

    button.MouseEnter:Connect(function()
        if not object.Disabled then
            Tween(button, {
                BackgroundColor3 =
                    Library.Settings.Theme.ElementHover
            })
        end
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

    local frame =
        self:_Element(30)

    local button = Create("TextButton", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            1,
            0
        ),

        Text = "",

        AutoButtonColor = false
    })

    local box = Create("Frame", {
        Parent = button,

        Position = UDim2.new(
            0,
            0,
            0.5,
            -8
        ),

        Size = UDim2.fromOffset(
            16,
            16
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Element
    })

    Corner(box, 4)
    AddStroke(box)

    local check = Create("TextLabel", {
        Parent = box,

        BackgroundTransparency = 1,

        Size = UDim2.fromScale(
            1,
            1
        ),

        Text = "✓",

        TextColor3 =
            Color3.new(1, 1, 1),

        TextSize = 10,

        Font = Enum.Font.GothamBold,

        TextTransparency = 1
    })

    local label = Create("TextLabel", {
        Parent = button,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            25,
            0
        ),

        Size = UDim2.new(
            1,
            -25,
            1,
            0
        ),

        Text =
            options.Text
            or flag,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 12,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local object = setmetatable({
        Instance = frame,

        Label = label,

        Box = box,

        Check = check,

        Text =
            options.Text
            or flag,

        Flag = flag,

        Value =
            options.Default == true,

        Callback =
            options.Callback
            or options.Func,

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
        object.Value,
        true
    )

    return object
end

Groupbox.AddCheckbox =
    Groupbox.AddToggle

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

    local frame =
        self:_Element(48)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            -60,
            0,
            18
        ),

        Text =
            options.Text
            or flag,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 12,

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
            55,
            18
        ),

        Text = tostring(default),

        TextColor3 =
            Library.Settings.Theme.SubText,

        TextSize = 11,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Right
    })

    local slider = Create("TextButton", {
        Parent = frame,

        Position = UDim2.fromOffset(
            0,
            29
        ),

        Size = UDim2.new(
            1,
            0,
            0,
            5
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

        Rounding =
            tonumber(options.Rounding)
            or 0,

        Flag = flag,

        Value = default,

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

        local x =
            input.Position.X

        local start =
            slider.AbsolutePosition.X

        local width =
            slider.AbsoluteSize.X

        local alpha =
            math.clamp(
                (x - start) / width,
                0,
                1
            )

        object:SetValue(
            min
            + (max - min) * alpha
        )
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

    local frame =
        self:_Element(55)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            18
        ),

        Text =
            options.Text
            or flag,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 12,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local textbox = Create("TextBox", {
        Parent = frame,

        Position = UDim2.fromOffset(
            0,
            23
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
            tostring(
                options.Default
                or ""
            ),

        TextSize = 11,

        Font = Library.Settings.Font,

        ClearTextOnFocus = false,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    Corner(textbox, 6)
    AddStroke(textbox)
    AddPadding(textbox, 8)

    local object = setmetatable({
        Instance = frame,

        Label = label,

        TextBox = textbox,

        Value =
            tostring(
                options.Default
                or ""
            ),

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

    local frame =
        self:_Element(55)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            18
        ),

        Text =
            options.Text
            or flag,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 12,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local dropdown = Create("TextButton", {
        Parent = frame,

        Position = UDim2.fromOffset(
            0,
            23
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

        AutoButtonColor = false
    })

    Corner(dropdown, 6)
    AddStroke(dropdown)

    local valueLabel = Create("TextLabel", {
        Parent = dropdown,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            9,
            0
        ),

        Size = UDim2.new(
            1,
            -32,
            1,
            0
        ),

        Text = "None",

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 11,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local arrow = Create("TextLabel", {
        Parent = dropdown,

        BackgroundTransparency = 1,

        AnchorPoint =
            Vector2.new(
                1,
                0.5
            ),

        Position = UDim2.new(
            1,
            -8,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            16,
            16
        ),

        Text = "⌄",

        TextColor3 =
            Library.Settings.Theme.SubText,

        TextSize = 13,

        Font = Library.Settings.Font
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
            Library.Settings.Theme.Groupbox,

        Visible = false,

        ZIndex = 50
    })

    Corner(list, 6)
    AddStroke(list)
    AddPadding(list, 4)

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

        Value = nil,

        Flag = flag,

        Multi =
            options.Multi == true,

        Open = false,

        Callback =
            options.Callback
            or options.Func,

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

            if type(options.Default)
                == "table" then

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

    local frame =
        self:_Element(31)

    local label = Create("TextLabel", {
        Parent = frame,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            -75,
            1,
            0
        ),

        Text =
            options.Text
            or flag,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 12,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local keyButton = Create("TextButton", {
        Parent = frame,

        AnchorPoint =
            Vector2.new(
                1,
                0.5
            ),

        Position = UDim2.new(
            1,
            0,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            65,
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

        TextSize = 10,

        Font = Library.Settings.Font,

        AutoButtonColor = false
    })

    Corner(keyButton, 6)
    AddStroke(keyButton)

    local object = setmetatable({
        Instance = frame,

        Label = label,

        KeyButton = keyButton,

        KeyLabel = keyButton,

        Value =
            options.Default,

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

    local frame =
        self:_Element(31)

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

        TextSize = 12,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local swatch = Create("TextButton", {
        Parent = frame,

        AnchorPoint =
            Vector2.new(
                1,
                0.5
            ),

        Position = UDim2.new(
            1,
            0,
            0.5,
            0
        ),

        Size = UDim2.fromOffset(
            32,
            21
        ),

        BackgroundColor3 =
            options.Default
            or Library.Settings.Theme.Accent,

        Text = "",

        AutoButtonColor = false
    })

    Corner(swatch, 5)
    AddStroke(swatch)

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
        return self
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

    self.Instance.Visible =
        visible

    return self
end

function Groupbox:AddDependencyBox()
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
        Container = frame
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
            0.5,
            -5,
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

function Tab:_CreateGroupbox(name, side)
    local parent =
        side == "Right"
        and self.Right
        or self.Left

    local box = Create("Frame", {
        Parent = parent,

        BackgroundColor3 =
            Library.Settings.Theme.Groupbox,

        Size = UDim2.new(
            1,
            0,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y
    })

    Corner(box, 7)
    AddStroke(box)

    local title = Create("TextLabel", {
        Parent = box,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            12,
            9
        ),

        Size = UDim2.new(
            1,
            -24,
            0,
            18
        ),

        Text =
            tostring(
                name or "Groupbox"
            ),

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 12,

        Font = Enum.Font.GothamMedium,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local line = Create("Frame", {
        Parent = box,

        Position = UDim2.fromOffset(
            12,
            32
        ),

        Size = UDim2.new(
            1,
            -24,
            0,
            1
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Border,

        BorderSizePixel = 0
    })

    local container = Create("Frame", {
        Parent = box,

        Position = UDim2.fromOffset(
            12,
            41
        ),

        Size = UDim2.new(
            1,
            -24,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
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

    Create("UIPadding", {
        Parent = box,

        PaddingBottom =
            UDim.new(
                0,
                12
            )
    })

    return setmetatable({
        Instance = box,

        Title = title,

        Container = container,

        Name = name,

        Tab = self
    }, Groupbox)
end

function Tab:AddLeftGroupbox(name)
    return self:_CreateGroupbox(
        name,
        "Left"
    )
end

function Tab:AddRightGroupbox(name)
    return self:_CreateGroupbox(
        name,
        "Right"
    )
end

---------------------------------------------------------------------
-- TABBOX
---------------------------------------------------------------------

function Tab:AddTabbox()
    local wrapper = Create("Frame", {
        Parent = self.Container,

        BackgroundColor3 =
            Library.Settings.Theme.Groupbox,

        Size = UDim2.new(
            1,
            0,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y
    })

    Corner(wrapper, 7)
    AddStroke(wrapper)

    local header = Create("Frame", {
        Parent = wrapper,

        BackgroundColor3 =
            Library.Settings.Theme.Element,

        Size = UDim2.new(
            1,
            0,
            0,
            32
        ),

        BorderSizePixel = 0
    })

    Corner(header, 7)

    local content = Create("Frame", {
        Parent = wrapper,

        Position = UDim2.fromOffset(
            10,
            40
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

    local tabbox = {
        Instance = wrapper,

        Header = header,

        Content = content,

        Tabs = {}
    }

    function tabbox:AddTab(name)
        local index =
            #self.Tabs + 1

        local button = Create("TextButton", {
            Parent = self.Header,

            BackgroundTransparency = 1,

            Size = UDim2.new(
                1,
                0,
                1,
                0
            ),

            Text = tostring(name),

            TextColor3 =
                Library.Settings.Theme.SubText,

            TextSize = 11,

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

        Create("UIListLayout", {
            Parent = page,

            Padding = UDim.new(
                0,
                5
            )
        })

        local tab = {
            Instance = page,
            Button = button,
            Container = page
        }

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

                existing.Instance.Visible =
                    false

                existing.Button.TextColor3 =
                    Library.Settings.Theme.SubText
            end

            page.Visible = true

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

    local button = Create("TextButton", {
        Parent = self.TabBar,

        BackgroundTransparency = 1,

        Size = UDim2.new(
            1,
            0,
            0,
            34
        ),

        Text =
            icon
            and (icon .. "  " .. name)
            or name,

        TextColor3 =
            Library.Settings.Theme.SubText,

        TextSize = 12,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        AutoButtonColor = false
    })

    AddPadding(button, 11)

    local indicator = Create("Frame", {
        Parent = button,

        Position = UDim2.new(
            0,
            0,
            0.5,
            -7
        ),

        Size = UDim2.fromOffset(
            2,
            14
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Accent,

        BorderSizePixel = 0
    })

    Corner(indicator, 2)

    indicator.Size =
        index == 1
        and UDim2.fromOffset(2, 14)
        or UDim2.fromOffset(2, 0)

    local page = Create("ScrollingFrame", {
        Parent = self.Pages,

        BackgroundTransparency = 1,

        Size = UDim2.fromScale(
            1,
            1
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

        Position = UDim2.fromOffset(
            9,
            9
        ),

        Size = UDim2.new(
            1,
            -18,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    })

    local columns = Create("Frame", {
        Parent = content,

        Size = UDim2.new(
            1,
            0,
            0,
            0
        ),

        AutomaticSize =
            Enum.AutomaticSize.Y,

        BackgroundTransparency = 1
    })

    local left =
        self:_CreateColumn(
            columns
        )

    local right =
        self:_CreateColumn(
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
        if not page.Visible then
            Tween(button, {
                TextColor3 =
                    Library.Settings.Theme.Text
            })
        end
    end)

    button.MouseLeave:Connect(function()
        if not page.Visible then
            Tween(button, {
                TextColor3 =
                    Library.Settings.Theme.SubText
            })
        end
    end)

    button.MouseButton1Click:Connect(function()
        for _, existing in ipairs(
            self.Tabs
        ) do

            existing.Page.Visible =
                false

            existing.Button.TextColor3 =
                Library.Settings.Theme.SubText

            Tween(
                existing.Indicator,
                {
                    Size =
                        UDim2.fromOffset(
                            2,
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
            Size =
                UDim2.fromOffset(
                    2,
                    14
                )
        })
    end)

    return tab
end

---------------------------------------------------------------------
-- WINDOW NOTIFICATION
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
            Library.Settings.Theme.Groupbox,

        Size = UDim2.fromOffset(
            290,
            67
        ),

        BackgroundTransparency = 1
    })

    Corner(notification, 7)
    AddStroke(notification)

    local accent = Create("Frame", {
        Parent = notification,

        Size = UDim2.fromOffset(
            2,
            67
        ),

        BackgroundColor3 =
            options.Color
            or Library.Settings.Theme.Accent,

        BorderSizePixel = 0
    })

    Corner(accent, 2)

    local titleLabel = Create("TextLabel", {
        Parent = notification,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            13,
            9
        ),

        Size = UDim2.new(
            1,
            -25,
            0,
            18
        ),

        Text = title,

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 12,

        Font = Enum.Font.GothamMedium,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local descriptionLabel = Create("TextLabel", {
        Parent = notification,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            13,
            29
        ),

        Size = UDim2.new(
            1,
            -25,
            0,
            28
        ),

        Text = description,

        TextColor3 =
            Library.Settings.Theme.SubText,

        TextSize = 10,

        Font = Library.Settings.Font,

        TextWrapped = true,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        TextYAlignment =
            Enum.TextYAlignment.Top
    })

    Tween(notification, {
        BackgroundTransparency = 0
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

        Tween(descriptionLabel, {
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
                self.Size.X.Offset * 0.94,
                self.Size.Y.Offset * 0.94
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
                        self.Size.X.Offset * 0.94,
                        self.Size.Y.Offset * 0.94
                    )
            }
        )

        task.delay(
            Library.Settings.AnimationSpeed,
            function()
                if not self.Visible
                    and self.ScreenGui then

                    self.ScreenGui.Enabled =
                        false
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

function Window:SetSubtitle(text)
    self.Subtitle.Text =
        tostring(text)

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
            720,
            460
        )

    local screenGui = Create(
        "ScreenGui",
        {
            Name = "MoonHubGUI",

            ResetOnSpawn = false,

            IgnoreGuiInset = true,

            ZIndexBehavior =
                Enum.ZIndexBehavior.Sibling
        }
    )

    screenGui.Parent =
        GetGuiParent()

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

    Corner(main, 9)
    AddStroke(main)

    local topbar = Create("Frame", {
        Parent = main,

        BackgroundColor3 =
            Library.Settings.Theme.Sidebar,

        Size = UDim2.new(
            1,
            0,
            0,
            54
        ),

        BorderSizePixel = 0
    })

    local accent = Create("Frame", {
        Parent = topbar,

        Position = UDim2.new(
            0,
            0,
            1,
            -1
        ),

        Size = UDim2.new(
            1,
            0,
            0,
            1
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Accent,

        BorderSizePixel = 0
    })

    local title = Create("TextLabel", {
        Parent = topbar,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            17,
            8
        ),

        Size = UDim2.new(
            1,
            -34,
            0,
            21
        ),

        Text =
            options.Title
            or "MoonHubGUI",

        TextColor3 =
            Library.Settings.Theme.Text,

        TextSize = 15,

        Font = Enum.Font.GothamBold,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local subtitle = Create("TextLabel", {
        Parent = topbar,

        BackgroundTransparency = 1,

        Position = UDim2.fromOffset(
            18,
            29
        ),

        Size = UDim2.new(
            1,
            -36,
            0,
            15
        ),

        Text =
            options.Subtitle
            or "MoonHub Interface",

        TextColor3 =
            Library.Settings.Theme.SubText,

        TextSize = 9,

        Font = Library.Settings.Font,

        TextXAlignment =
            Enum.TextXAlignment.Left
    })

    local sidebar = Create("Frame", {
        Parent = main,

        Position = UDim2.fromOffset(
            0,
            54
        ),

        Size = UDim2.new(
            0,
            142,
            1,
            -54
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Sidebar,

        BorderSizePixel = 0
    })

    local sidebarLine = Create("Frame", {
        Parent = sidebar,

        Position = UDim2.new(
            1,
            -1,
            0,
            0
        ),

        Size = UDim2.new(
            0,
            1,
            1,
            0
        ),

        BackgroundColor3 =
            Library.Settings.Theme.Border,

        BorderSizePixel = 0
    })

    local tabBar = Create("ScrollingFrame", {
        Parent = sidebar,

        Position = UDim2.fromOffset(
            8,
            9
        ),

        Size = UDim2.new(
            1,
            -16,
            1,
            -18
        ),

        BackgroundTransparency = 1,

        ScrollBarThickness = 0,

        CanvasSize = UDim2.new(),

        AutomaticCanvasSize =
            Enum.AutomaticSize.Y,

        BorderSizePixel = 0
    })

    Create("UIListLayout", {
        Parent = tabBar,

        Padding = UDim.new(
            0,
            2
        ),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    })

    local pages = Create("Frame", {
        Parent = main,

        Position = UDim2.fromOffset(
            142,
            54
        ),

        Size = UDim2.new(
            1,
            -142,
            1,
            -54
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
            -14,
            1,
            -14
        ),

        Size = UDim2.fromOffset(
            300,
            350
        ),

        BackgroundTransparency = 1,

        ZIndex = 1000
    })

    Create("UIListLayout", {
        Parent = notificationHolder,

        Padding = UDim.new(
            0,
            7
        ),

        HorizontalAlignment =
            Enum.HorizontalAlignment.Right,

        VerticalAlignment =
            Enum.VerticalAlignment.Bottom
    })

    local window = setmetatable({
        ScreenGui = screenGui,

        Main = main,

        Topbar = topbar,

        Sidebar = sidebar,

        SidebarLine = sidebarLine,

        Pages = pages,

        TabBar = tabBar,

        Title = title,

        Subtitle = subtitle,

        Accent = accent,

        NotificationHolder =
            notificationHolder,

        Tabs = {},

        Visible = true,

        Destroyed = false,

        Size = size
    }, Window)

    MakeDraggable(
        main,
        topbar
    )

    table.insert(
        Library.Windows,
        window
    )

    return window
end

---------------------------------------------------------------------
-- GLOBAL NOTIFY
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

        if self.Settings.Theme[key] ~= nil then
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
                theme.Sidebar

            window.Sidebar.BackgroundColor3 =
                theme.Sidebar

            window.Pages.BackgroundColor3 =
                theme.Background

            window.Accent.BackgroundColor3 =
                theme.Accent

            window.Title.TextColor3 =
                theme.Text

            window.Subtitle.TextColor3 =
                theme.SubText
        end
    end
end

---------------------------------------------------------------------
-- TOGGLE KEY
---------------------------------------------------------------------

function Library:SetToggleKey(key)
    if typeof(key) ~= "EnumItem" then
        return self
    end

    self.Settings.ToggleKey =
        key

    return self
end

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
