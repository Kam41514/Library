--// Kam41514 Modern Library
--// Obsidian-compatible API
--// Standalone implementation
--// Fluent-inspired UI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Library = {
    ScreenGui = nil,
    Window = nil,
    WindowContainer = nil,

    Tabs = {},
    TabButtons = {},

    Options = {},
    Toggles = {},
    Labels = {},
    Buttons = {},

    Notifications = {},

    ActiveTab = nil,
    Toggled = true,
    Unloaded = false,

    IsLightTheme = false,

    Scheme = {
        BackgroundColor = Color3.fromRGB(8, 9, 13),
        MainColor = Color3.fromRGB(14, 15, 21),
        AccentColor = Color3.fromRGB(139, 92, 246),
        OutlineColor = Color3.fromRGB(39, 40, 52),
        FontColor = Color3.fromRGB(240, 240, 245),
        RedColor = Color3.fromRGB(248, 113, 113),
        DarkColor = Color3.fromRGB(5, 6, 9),
        WhiteColor = Color3.fromRGB(255, 255, 255),
        Font = Font.fromEnum(Enum.Font.Gotham),
    },

    Colors = {
        Background = Color3.fromRGB(8, 9, 13),
        Sidebar = Color3.fromRGB(11, 12, 17),
        Content = Color3.fromRGB(14, 15, 21),
        Card = Color3.fromRGB(19, 20, 27),
        CardHover = Color3.fromRGB(23, 24, 33),
        Element = Color3.fromRGB(24, 25, 33),
        ElementHover = Color3.fromRGB(30, 31, 41),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(157, 159, 173),
        Border = Color3.fromRGB(39, 40, 52),
        Accent = Color3.fromRGB(139, 92, 246),
    },

    TweenInfo = TweenInfo.new(
        0.16,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    ),

    Animations = {
        ToggleWindow = true,
        TabSwitch = true,
        Groupbox = true,
        Dropdown = true,
        KeyPicker = true,
    },
}

------------------------------------------------------------
-- UTIL
------------------------------------------------------------

local function tween(object, properties, info)
    if not object then
        return
    end

    local t = TweenService:Create(
        object,
        info or Library.TweenInfo,
        properties
    )

    t:Play()
    return t
end

local function corner(object, radius)
    local c = object:FindFirstChild("LibraryCorner")

    if not c then
        c = Instance.new("UICorner")
        c.Name = "LibraryCorner"
        c.Parent = object
    end

    c.CornerRadius = UDim.new(0, radius)
    return c
end

local function stroke(object, color, transparency)
    local s = object:FindFirstChild("LibraryStroke")

    if not s then
        s = Instance.new("UIStroke")
        s.Name = "LibraryStroke"
        s.Parent = object
    end

    s.Color = color or Library.Colors.Border
    s.Transparency = transparency or 0.2
    s.Thickness = 1

    return s
end

local function padding(object, left, right, top, bottom)
    local p = object:FindFirstChild("LibraryPadding")

    if not p then
        p = Instance.new("UIPadding")
        p.Name = "LibraryPadding"
        p.Parent = object
    end

    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)

    return p
end

local function create(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        pcall(function()
            object[property] = value
        end)
    end

    object.Parent = parent
    return object
end

------------------------------------------------------------
-- GLOBAL CALLBACK REGISTRY
------------------------------------------------------------

local function registerOption(name, object)
    if not name then
        return
    end

    Library.Options[name] = object
end

------------------------------------------------------------
-- WINDOW
------------------------------------------------------------

function Library:CreateWindow(info)
    info = info or {}

    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end

    local size =
        info.Size
        or UDim2.fromOffset(1050, 650)

    local title =
        info.Title
        or "Modern Hub"

    local footer =
        info.Footer
        or ""

    --------------------------------------------------------
    -- SCREEN GUI
    --------------------------------------------------------

    local gui = create("ScreenGui", {
        Name = "Kam41514Library",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })

    pcall(function()
        gui.Parent = gethui()
    end)

    if not gui.Parent then
        gui.Parent = game:GetService("CoreGui")
    end

    self.ScreenGui = gui

    --------------------------------------------------------
    -- WINDOW
    --------------------------------------------------------

    local window = create("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
        BackgroundColor3 = self.Colors.Content,
        BorderSizePixel = 0,
    }, gui)

    corner(window, 18)
    stroke(window, self.Colors.Border, 0.1)

    self.Window = window
    self.WindowContainer = window

    --------------------------------------------------------
    -- HEADER
    --------------------------------------------------------

    local header = create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = self.Colors.Content,
        BorderSizePixel = 0,
    }, window)

    corner(header, 18)

    local headerMask = create("Frame", {
        Name = "HeaderMask",
        Position = UDim2.new(0, 0, 1, -18),
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundColor3 = self.Colors.Content,
        BorderSizePixel = 0,
    }, header)

    local titleLabel = create("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(20, 0),
        Size = UDim2.new(1, -150, 1, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.Colors.Text,
        FontFace = Font.fromEnum(Enum.Font.GothamBold),
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    --------------------------------------------------------
    -- DRAGGING
    --------------------------------------------------------

    do
        local dragging = false
        local dragStart
        local startPosition

        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then

                dragging = true
                dragStart = input.Position
                startPosition = window.Position
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

            window.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then

                dragging = false
            end
        end)
    end

    --------------------------------------------------------
    -- CLOSE
    --------------------------------------------------------

    local close = create("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = Color3.fromRGB(40, 25, 30),
        BackgroundTransparency = 0.2,
        Text = "×",
        TextColor3 = self.Colors.RedColor,
        FontFace = Font.fromEnum(Enum.Font.GothamBold),
        TextSize = 19,
        AutoButtonColor = false,
    }, header)

    corner(close, 9)

    close.MouseEnter:Connect(function()
        tween(close, {
            BackgroundColor3 = Color3.fromRGB(80, 35, 45)
        })
    end)

    close.MouseLeave:Connect(function()
        tween(close, {
            BackgroundColor3 = Color3.fromRGB(40, 25, 30)
        })
    end)

    close.MouseButton1Click:Connect(function()
        self:Unload()
    end)

    --------------------------------------------------------
    -- SIDEBAR
    --------------------------------------------------------

    local sidebar = create("Frame", {
        Name = "Sidebar",
        Position = UDim2.fromOffset(10, 58),
        Size = UDim2.new(0, 145, 1, -68),
        BackgroundColor3 = self.Colors.Sidebar,
        BorderSizePixel = 0,
    }, window)

    corner(sidebar, 14)
    stroke(sidebar, self.Colors.Border, 0.35)

    padding(sidebar, 7, 7, 8, 8)

    local tabLayout = create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, sidebar)

    self.Sidebar = sidebar

    --------------------------------------------------------
    -- CONTENT
    --------------------------------------------------------

    local content = create("Frame", {
        Name = "Content",
        Position = UDim2.new(0, 165, 0, 58),
        Size = UDim2.new(1, -175, 1, -68),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, window)

    self.Content = content

    --------------------------------------------------------
    -- FOOTER
    --------------------------------------------------------

    if footer ~= "" then
        create("TextLabel", {
            Name = "Footer",
            Position = UDim2.new(0, 20, 1, -22),
            Size = UDim2.new(1, -40, 0, 16),
            BackgroundTransparency = 1,
            Text = footer,
            TextColor3 = self.Colors.SubText,
            FontFace = Font.fromEnum(Enum.Font.Gotham),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, window)
    end

    self._TitleLabel = titleLabel

    return self
end

------------------------------------------------------------
-- TAB
------------------------------------------------------------

local Tab = {}
Tab.__index = Tab

function Library:AddTab(name, icon)
    assert(self.Sidebar, "CreateWindow must be called first")

    local tab = setmetatable({
        Name = name,
        Icon = icon,
        Groupboxes = {},
        LeftGroupboxes = {},
        RightGroupboxes = {},
        Elements = {},
    }, Tab)

    --------------------------------------------------------
    -- BUTTON
    --------------------------------------------------------

    local button = create("TextButton", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = self.Colors.Element,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = #self.TabButtons + 1,
    }, self.Sidebar)

    corner(button, 9)

    local iconLabel

    if icon then
        iconLabel = create("ImageLabel", {
            Name = "Icon",
            Position = UDim2.fromOffset(10, 9),
            Size = UDim2.fromOffset(18, 18),
            BackgroundTransparency = 1,
            Image = "rbxassetid://0",
            ImageColor3 = self.Colors.SubText,
        }, button)

        pcall(function()
            iconLabel.Image = "rbxassetid://" .. tostring(icon)
        end)
    end

    local textPosition = icon and 37 or 12

    local label = create("TextLabel", {
        Name = "Label",
        Position = UDim2.fromOffset(textPosition, 0),
        Size = UDim2.new(1, -textPosition - 8, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.Colors.SubText,
        FontFace = Font.fromEnum(Enum.Font.GothamMedium),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, button)

    --------------------------------------------------------
    -- PAGE
    --------------------------------------------------------

    local page = create("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Colors.Accent,
        Visible = false,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, self.Content)

    padding(page, 5, 5, 5, 15)

    local columns = create("Frame", {
        Name = "Columns",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, page)

    local left = create("Frame", {
        Name = "Left",
        Size = UDim2.new(0.5, -7, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, columns)

    local right = create("Frame", {
        Name = "Right",
        Position = UDim2.new(0.5, 7, 0, 0),
        Size = UDim2.new(0.5, -7, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, columns)

    local leftLayout = create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, left)

    local rightLayout = create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, right)

    tab.Button = button
    tab.Page = page
    tab.Left = left
    tab.Right = right
    tab.Label = label
    tab.IconObject = iconLabel

    self.Tabs[name] = tab
    table.insert(self.TabButtons, {
        Tab = tab,
        Button = button,
        Label = label,
    })

    --------------------------------------------------------
    -- SWITCH
    --------------------------------------------------------

    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            tween(button, {
                BackgroundColor3 = self.Colors.ElementHover,
                BackgroundTransparency = 0.25,
            })
        end
    end)

    button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            tween(button, {
                BackgroundTransparency = 1,
            })
        end
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

    for _, data in ipairs(self.TabButtons) do
        local active = data.Tab == tab

        data.Tab.Page.Visible = active

        if active then
            tween(data.Button, {
                BackgroundColor3 = self.Colors.Accent,
                BackgroundTransparency = 0.78,
            })

            tween(data.Label, {
                TextColor3 = self.Colors.Text,
            })

            if data.Tab.IconObject then
                tween(data.Tab.IconObject, {
                    ImageColor3 = self.Colors.Accent,
                })
            end
        else
            tween(data.Button, {
                BackgroundTransparency = 1,
            })

            tween(data.Label, {
                TextColor3 = self.Colors.SubText,
            })

            if data.Tab.IconObject then
                tween(data.Tab.IconObject, {
                    ImageColor3 = self.Colors.SubText,
                })
            end
        end
    end
end

------------------------------------------------------------
-- GROUPBOX
------------------------------------------------------------

local Groupbox = {}
Groupbox.__index = Groupbox

function Tab:AddLeftGroupbox(title, icon)
    return self:_AddGroupbox(title, icon, self.Left, self.LeftGroupboxes)
end

function Tab:AddRightGroupbox(title, icon)
    return self:_AddGroupbox(title, icon, self.Right, self.RightGroupboxes)
end

function Tab:_AddGroupbox(title, icon, parent, collection)
    local box = setmetatable({
        Title = title,
        Icon = icon,
        Elements = {},
        Parent = parent,
    }, Groupbox)

    local frame = create("Frame", {
        Name = title,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Library.Colors.Card,
        BorderSizePixel = 0,
    }, parent)

    corner(frame, 13)
    stroke(frame, Library.Colors.Border, 0.15)
    padding(frame, 14, 14, 12, 14)

    local titleLabel = create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Library.Colors.Text,
        FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    local container = create("Frame", {
        Name = "Container",
        Position = UDim2.fromOffset(0, 31),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, frame)

    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, container)

    box.Holder = frame
    box.Container = container
    box.TitleLabel = titleLabel

    table.insert(collection, box)
    table.insert(self.Groupboxes, box)

    return box
end

------------------------------------------------------------
-- LABEL
------------------------------------------------------------

function Groupbox:AddLabel(text, doesWrap)
    local label = create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, doesWrap and 40 or 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Library.Colors.SubText,
        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 12,
        TextWrapped = doesWrap or false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, self.Container)

    table.insert(self.Elements, label)

    return label
end

------------------------------------------------------------
-- DIVIDER
------------------------------------------------------------

function Groupbox:AddDivider()
    local divider = create("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Library.Colors.Border,
        BorderSizePixel = 0,
    }, self.Container)

    table.insert(self.Elements, divider)

    return divider
end

------------------------------------------------------------
-- BUTTON
------------------------------------------------------------

function Groupbox:AddButton(info)
    if type(info) == "string" then
        info = {
            Text = info,
        }
    end

    info = info or {}

    local button = create("TextButton", {
        Name = info.Name or info.Text or "Button",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Library.Colors.Element,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = info.Text or "Button",
        TextColor3 = Library.Colors.Text,
        FontFace = Font.fromEnum(Enum.Font.GothamMedium),
        TextSize = 13,
    }, self.Container)

    corner(button, 9)

    button.MouseEnter:Connect(function()
        tween(button, {
            BackgroundColor3 = Library.Colors.ElementHover,
        })
    end)

    button.MouseLeave:Connect(function()
        tween(button, {
            BackgroundColor3 = Library.Colors.Element,
        })
    end)

    button.MouseButton1Click:Connect(function()
        if info.Func then
            info.Func()
        elseif info.Callback then
            info.Callback()
        end
    end)

    table.insert(Library.Buttons, button)
    table.insert(self.Elements, button)

    return button
end

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------

local Toggle = {}
Toggle.__index = Toggle

function Groupbox:AddToggle(name, info)
    info = info or {}

    local object = setmetatable({
        Name = name,
        Value = info.Default or false,
        Callback = info.Callback or function() end,
        Changed = info.Changed or function() end,
    }, Toggle)

    local holder = create("Frame", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
    }, self.Container)

    local label = create("TextLabel", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -55, 1, 0),
        BackgroundTransparency = 1,
        Text = info.Text or name,
        TextColor3 = Library.Colors.Text,
        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    local toggle = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(42, 22),
        BackgroundColor3 = Color3.fromRGB(45, 46, 56),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, holder)

    corner(toggle, 11)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Color3.fromRGB(205, 205, 215),
        BorderSizePixel = 0,
    }, toggle)

    corner(knob, 8)

    object.Holder = holder
    object.Toggle = toggle
    object.Knob = knob

    local function update(value, silent)
        object.Value = value == true

        if object.Value then
            tween(toggle, {
                BackgroundColor3 = Library.Colors.Accent,
            })

            tween(knob, {
                Position = UDim2.new(1, -19, 0.5, 0),
                BackgroundColor3 = Color3.new(1, 1, 1),
            })
        else
            tween(toggle, {
                BackgroundColor3 = Color3.fromRGB(45, 46, 56),
            })

            tween(knob, {
                Position = UDim2.new(0, 3, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(205, 205, 215),
            })
        end

        if not silent then
            object.Callback(object.Value)
            object.Changed(object.Value)
        end
    end

    function object:SetValue(value)
        update(value)
    end

    function object:GetValue()
        return object.Value
    end

    function object:OnChanged(callback)
        object.Changed = callback
        return object
    end

    toggle.MouseButton1Click:Connect(function()
        update(not object.Value)
    end)

    update(object.Value, true)

    Library.Toggles[name] = object
    Library.Options[name] = object

    table.insert(self.Elements, object)

    return object
end

------------------------------------------------------------
-- SLIDER
------------------------------------------------------------

local Slider = {}
Slider.__index = Slider

function Groupbox:AddSlider(name, info)
    info = info or {}

    local min = info.Min or 0
    local max = info.Max or 100
    local default = info.Default or min

    local object = setmetatable({
        Name = name,
        Value = default,
        Min = min,
        Max = max,
        Callback = info.Callback or function() end,
        Changed = info.Changed or function() end,
    }, Slider)

    local holder = create("Frame", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundTransparency = 1,
    }, self.Container)

    local label = create("TextLabel", {
        Size = UDim2.new(1, -70, 0, 20),
        BackgroundTransparency = 1,
        Text = info.Text or name,
        TextColor3 = Library.Colors.Text,
        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    local valueLabel = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(65, 20),
        BackgroundTransparency = 1,
        TextColor3 = Library.Colors.SubText,
        FontFace = Font.fromEnum(Enum.Font.GothamMedium),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, holder)

    local bar = create("Frame", {
        Position = UDim2.new(0, 0, 0, 31),
        Size = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = Color3.fromRGB(38, 39, 48),
        BorderSizePixel = 0,
    }, holder)

    corner(bar, 3)

    local fill = create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Library.Colors.Accent,
        BorderSizePixel = 0,
    }, bar)

    corner(fill, 3)

    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    }, bar)

    corner(knob, 7)

    object.Holder = holder
    object.Bar = bar
    object.Fill = fill
    object.Knob = knob
    object.ValueLabel = valueLabel

    local function setValue(value, silent)
        value = math.clamp(value, min, max)

        if info.Rounding ~= nil then
            local mult = 10 ^ info.Rounding
            value = math.floor(value * mult + 0.5) / mult
        end

        object.Value = value

        local alpha =
            (value - min) /
            (max - min)

        fill.Size =
            UDim2.fromScale(alpha, 1)

        knob.Position =
            UDim2.fromScale(alpha, 0.5)

        valueLabel.Text =
            tostring(info.Prefix or "")
            .. tostring(value)
            .. tostring(info.Suffix or "")

        if not silent then
            object.Callback(value)
            object.Changed(value)
        end
    end

    local dragging = false

    local function updateFromInput(input)
        local x =
            input.Position.X - bar.AbsolutePosition.X

        local alpha =
            math.clamp(
                x / bar.AbsoluteSize.X,
                0,
                1
            )

        setValue(
            min + (max - min) * alpha
        )
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            updateFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then

                updateFromInput(input)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    function object:SetValue(value)
        setValue(value)
    end

    function object:GetValue()
        return object.Value
    end

    function object:OnChanged(callback)
        object.Changed = callback
        return object
    end

    setValue(default, true)

    Library.Options[name] = object

    table.insert(self.Elements, object)

    return object
end

------------------------------------------------------------
-- DROPDOWN
------------------------------------------------------------

local Dropdown = {}
Dropdown.__index = Dropdown

function Groupbox:AddDropdown(name, info)
    info = info or {}

    local values = info.Values or {}

    local object = setmetatable({
        Name = name,
        Values = values,
        Value = info.Default,
        Multi = info.Multi or false,
        Callback = info.Callback or function() end,
        Changed = info.Changed or function() end,
    }, Dropdown)

    local holder = create("Frame", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
    }, self.Container)

    local label = create("TextLabel", {
        Size = UDim2.new(0.42, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = info.Text or name,
        TextColor3 = Library.Colors.Text,
        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    local dropdown = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0.55, 0, 0, 34),
        BackgroundColor3 = Library.Colors.Element,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
    }, holder)

    corner(dropdown, 8)
    stroke(dropdown, Library.Colors.Border, 0.2)

    local valueText = create("TextLabel", {
        Position = UDim2.fromOffset(11, 0),
        Size = UDim2.new(1, -32, 1, 0),
        BackgroundTransparency = 1,
        Text = tostring(object.Value or "Select"),
        TextColor3 = Library.Colors.SubText,
        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, dropdown)

    local arrow = create("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(15, 15),
        BackgroundTransparency = 1,
        Text = "⌄",
        TextColor3 = Library.Colors.SubText,
        FontFace = Font.fromEnum(Enum.Font.GothamBold),
        TextSize = 15,
    }, dropdown)

    local list = create("Frame", {
        Name = "List",
        Position = UDim2.new(0, 0, 1, 5),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Library.Colors.Card,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 20,
        ClipsDescendants = true,
    }, dropdown)

    corner(list, 9)
    stroke(list, Library.Colors.Border, 0.1)

    local layout = create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)

    padding(list, 5, 5, 5, 5)

    object.Holder = holder
    object.Dropdown = dropdown
    object.List = list

    local opened = false

    local function refresh()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for index, value in ipairs(values) do
            local option = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Library.Colors.Element,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = tostring(value),
                TextColor3 = Library.Colors.Text,
                FontFace = Font.fromEnum(Enum.Font.Gotham),
                TextSize = 12,
                AutoButtonColor = false,
                LayoutOrder = index,
                ZIndex = 21,
            }, list)

            corner(option, 7)

            option.MouseEnter:Connect(function()
                tween(option, {
                    BackgroundColor3 = Library.Colors.ElementHover,
                    BackgroundTransparency = 0,
                })
            end)

            option.MouseLeave:Connect(function()
                tween(option, {
                    BackgroundTransparency = 1,
                })
            end)

            option.MouseButton1Click:Connect(function()
                object:SetValue(value)
                opened = false
                list.Visible = false
            end)
        end

        list.Size = UDim2.new(
            1,
            0,
            0,
            math.min(
                #values * 32 + 10,
                220
            )
        )
    end

    function object:SetValue(value)
        object.Value = value
        valueText.Text = tostring(value)

        object.Callback(value)
        object.Changed(value)
    end

    function object:GetValue()
        return object.Value
    end

    function object:SetValues(newValues)
        values = newValues or {}
        object.Values = values
        refresh()
    end

    function object:OnChanged(callback)
        object.Changed = callback
        return object
    end

    dropdown.MouseButton1Click:Connect(function()
        opened = not opened
        list.Visible = opened

        if opened then
            refresh()
        end
    end)

    Library.Options[name] = object

    table.insert(self.Elements, object)

    return object
end

------------------------------------------------------------
-- INPUT
------------------------------------------------------------

function Groupbox:AddInput(name, info)
    info = info or {}

    local holder = create("Frame", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundTransparency = 1,
    }, self.Container)

    local label = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = info.Text or name,
        TextColor3 = Library.Colors.Text,
        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    local input = create("TextBox", {
        Position = UDim2.fromOffset(0, 27),
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Library.Colors.Element,
        BorderSizePixel = 0,
        Text = tostring(info.Default or ""),
        PlaceholderText = info.Placeholder or "",
        PlaceholderColor3 = Library.Colors.SubText,
        TextColor3 = Library.Colors.Text,
        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 12,
        ClearTextOnFocus = info.ClearTextOnFocus ~= false,
    }, holder)

    corner(input, 8)
    stroke(input, Library.Colors.Border, 0.2)
    padding(input, 10, 10, 0, 0)

    local object = {
        Name = name,
        Value = input.Text,
        Input = input,
        Callback = info.Callback or function() end,
        Changed = info.Changed or function() end,
    }

    function object:SetValue(value)
        input.Text = tostring(value)
        object.Value = input.Text
        object.Callback(object.Value)
        object.Changed(object.Value)
    end

    function object:GetValue()
        return input.Text
    end

    function object:OnChanged(callback)
        object.Changed = callback
        return object
    end

    input.FocusLost:Connect(function()
        object.Value = input.Text
        object.Callback(input.Text)
        object.Changed(input.Text)
    end)

    Library.Options[name] = object

    table.insert(self.Elements, object)

    return object
end

------------------------------------------------------------
-- TAB ELEMENT ALIASES
------------------------------------------------------------

function Tab:AddLeftTabbox()
    return self:AddLeftGroupbox("Tabbox")
end

function Tab:AddRightTabbox()
    return self:AddRightGroupbox("Tabbox")
end

------------------------------------------------------------
-- NOTIFICATIONS
------------------------------------------------------------

function Library:Notify(info)
    if type(info) == "string" then
        info = {
            Title = "Notification",
            Description = info,
            Time = 4,
        }
    end

    info = info or {}

    local title = info.Title or "Notification"
    local description = info.Description or ""
    local duration = info.Time or 4

    local holder = create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -20, 1, 100),
        Size = UDim2.fromOffset(310, 82),
        BackgroundColor3 = Library.Colors.Card,
        BorderSizePixel = 0,
    }, self.ScreenGui)

    corner(holder, 13)
    stroke(holder, Library.Colors.Border, 0.1)

    create("TextLabel", {
        Position = UDim2.fromOffset(15, 10),
        Size = UDim2.new(1, -30, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Library.Colors.Text,
        FontFace = Font.fromEnum(Enum.Font.GothamSemibold),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    create("TextLabel", {
        Position = UDim2.fromOffset(15, 32),
        Size = UDim2.new(1, -30, 0, 38),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = Library.Colors.SubText,
        FontFace = Font.fromEnum(Enum.Font.Gotham),
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, holder)

    table.insert(self.Notifications, holder)

    tween(holder, {
        Position = UDim2.new(1, -20, 1, -20),
    })

    task.delay(duration, function()
        if holder.Parent then
            tween(holder, {
                Position = UDim2.new(1, 330, 1, -20),
            }, TweenInfo.new(
                0.2,
                Enum.EasingStyle.Quart,
                Enum.EasingDirection.In
            ))

            task.wait(0.22)
            holder:Destroy()
        end
    end)

    return holder
end

------------------------------------------------------------
-- UPDATE COLORS
------------------------------------------------------------

function Library:UpdateColorsUsingRegistry()
    return true
end

function Library:ApplyTheme(theme)
    if not theme then
        return
    end

    for key, value in pairs(theme) do
        if self.Scheme[key] ~= nil then
            self.Scheme[key] = value
        end
    end
end

------------------------------------------------------------
-- TOGGLE WINDOW
------------------------------------------------------------

function Library:Toggle()
    if not self.Window then
        return
    end

    self.Toggled = not self.Toggled
    self.Window.Visible = self.Toggled
end

function Library:ToggleUI()
    self:Toggle()
end

------------------------------------------------------------
-- UNLOAD
------------------------------------------------------------

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
    self.WindowContainer = nil

    for _, object in pairs(self.Options) do
        if type(object) == "table"
            and object.Destroy then
            pcall(function()
                object:Destroy()
            end)
        end
    end
end

------------------------------------------------------------
-- LIBRARY INFO
------------------------------------------------------------

Library.Version = "1.0.0"
Library.Modern = true
Library.ModernStyle = "Fluent"
Library.IsStandalone = true

return Library
