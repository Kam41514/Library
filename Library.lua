--[[
    KamUI
    Fluent UI + Obsidian API Adapter

    UI Engine:
        Fluent

    API:
        Obsidian-style

    Supported:
        CreateWindow
        AddTab
        AddLeftGroupbox
        AddRightGroupbox

        AddToggle
        AddSlider
        AddDropdown
        AddInput
        AddButton
        AddLabel
        AddDivider

        Options
        Toggles
        Registry
        Scheme

    This file does NOT load Obsidian.
]]

------------------------------------------------------------
-- FLUENT
------------------------------------------------------------

local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

------------------------------------------------------------
-- LIBRARY
------------------------------------------------------------

local Library = {}

Library.__index = Library

Library.Version = "1.0.0"

Library.Options = {}
Library.Toggles = {}
Library.Registry = {}

Library.Scheme = {
    BackgroundColor = Color3.fromRGB(15, 15, 18),
    MainColor = Color3.fromRGB(20, 20, 24),
    AccentColor = Color3.fromRGB(138, 92, 246),
    OutlineColor = Color3.fromRGB(42, 42, 49),
    FontColor = Color3.fromRGB(245, 245, 248)
}

Library.Colors = Library.Scheme

Library.Fluent = Fluent

------------------------------------------------------------
-- INTERNAL
------------------------------------------------------------

local CurrentWindow

local Tabs = {}

local function GetOptionName(name)
    return tostring(name)
end

local function RegisterOption(name, object)
    name = GetOptionName(name)

    Library.Options[name] = object

    return object
end

local function RegisterToggle(name, object)
    name = GetOptionName(name)

    Library.Toggles[name] = object
    Library.Options[name] = object

    return object
end

------------------------------------------------------------
-- CREATE WINDOW
------------------------------------------------------------

function Library:CreateWindow(config)

    config = config or {}

    local fluentConfig = {
        Title = config.Title or "KamUI",

        SubTitle =
            config.Subtitle
            or config.SubTitle
            or "",

        TabWidth =
            config.TabWidth
            or 160,

        Size =
            config.Size
            or UDim2.fromOffset(
                920,
                600
            ),

        Acrylic =
            config.Acrylic ~= false,

        Theme =
            config.Theme
            or "Dark",

        MinimizeKey =
            config.MinimizeKey
            or Enum.KeyCode.RightControl
    }

    local window = Fluent:CreateWindow(
        fluentConfig
    )

    CurrentWindow = window

    self.Window = window

    --------------------------------------------------------
    -- WINDOW COMPATIBILITY
    --------------------------------------------------------

    function window:SelectTab(tab)
        if tab and tab.Select then
            tab:Select()
        end
    end

    function window:Notify(data)

        if type(data) == "string" then
            return Fluent:Notify({
                Title = "Notification",
                Content = data,
                Duration = 4
            })
        end

        data = data or {}

        return Fluent:Notify({
            Title =
                data.Title
                or "Notification",

            Content =
                data.Description
                or data.Content
                or "",

            Duration =
                data.Time
                or data.Duration
                or 4
        })
    end

    function window:Minimize()
        if window.Minimize then
            window:Minimize()
        end
    end

    return window
end

------------------------------------------------------------
-- TAB ADAPTER
------------------------------------------------------------

local TabAdapter = {}

TabAdapter.__index = TabAdapter

function Library:AddTab()
    error(
        "AddTab must be called on Window"
    )
end

function Library:BuildTab(window, name, icon)

    local fluentTab =
        window:AddTab({
            Title = name,
            Icon = icon
        })

    local tab =
        setmetatable({

            Library = self,

            Window = window,

            FluentTab = fluentTab,

            Name = name,

            LeftGroupboxes = {},

            RightGroupboxes = {},

            Groupboxes = {}

        }, TabAdapter)

    Tabs[name] = tab

    --------------------------------------------------------
    -- OBSIDIAN STYLE
    --------------------------------------------------------

    function tab:Select()

        if self.FluentTab.Select then
            self.FluentTab:Select()
        end

    end

    return tab
end

------------------------------------------------------------
-- PATCH WINDOW ADDTAB
------------------------------------------------------------

local function PatchWindow(window)

    local originalAddTab =
        window.AddTab

    function window:AddTab(data)

        local name
        local icon

        if type(data) == "string" then
            name = data
        else
            name =
                data.Title
                or data.Name
                or "Tab"

            icon = data.Icon
        end

        local fluentTab =
            originalAddTab(
                self,
                {
                    Title = name,
                    Icon = icon
                }
            )

        local tab =
            setmetatable({

                Library = Library,

                Window = self,

                FluentTab = fluentTab,

                Name = name,

                LeftGroupboxes = {},

                RightGroupboxes = {},

                Groupboxes = {}

            }, TabAdapter)

        ----------------------------------------------------
        -- LEFT
        ----------------------------------------------------

        function tab:AddLeftGroupbox(
            title,
            icon
        )

            local group =
                self.FluentTab:AddSection(
                    title
                )

            local box =
                CreateGroupbox(
                    self,
                    group,
                    title,
                    "Left"
                )

            table.insert(
                self.LeftGroupboxes,
                box
            )

            table.insert(
                self.Groupboxes,
                box
            )

            return box
        end

        ----------------------------------------------------
        -- RIGHT
        ----------------------------------------------------

        function tab:AddRightGroupbox(
            title,
            icon
        )

            local group =
                self.FluentTab:AddSection(
                    title
                )

            local box =
                CreateGroupbox(
                    self,
                    group,
                    title,
                    "Right"
                )

            table.insert(
                self.RightGroupboxes,
                box
            )

            table.insert(
                self.Groupboxes,
                box
            )

            return box
        end

        ----------------------------------------------------
        -- SINGLE GROUPBOX
        ----------------------------------------------------

        function tab:AddGroupbox(
            title
        )

            local group =
                self.FluentTab:AddSection(
                    title
                )

            local box =
                CreateGroupbox(
                    self,
                    group,
                    title,
                    "Left"
                )

            table.insert(
                self.Groupboxes,
                box
            )

            return box
        end

        return tab
    end
end

------------------------------------------------------------
-- GROUPBOX
------------------------------------------------------------

local Groupbox = {}

Groupbox.__index = Groupbox

function CreateGroupbox(
    tab,
    fluentGroup,
    name,
    side
)

    local group =
        setmetatable({

            Library = Library,

            Tab = tab,

            Fluent = fluentGroup,

            Name = name,

            Side = side,

            Elements = {}

        }, Groupbox)

    --------------------------------------------------------
    -- LABEL
    --------------------------------------------------------

    function group:AddLabel(
        text,
        doesWrap
    )

        local element =
            fluentGroup:AddParagraph({
                Title = "",
                Content = tostring(text)
            })

        table.insert(
            group.Elements,
            element
        )

        return element
    end

    --------------------------------------------------------
    -- DIVIDER
    --------------------------------------------------------

    function group:AddDivider()

        if fluentGroup.AddParagraph then

            return fluentGroup:AddParagraph({
                Title = "",
                Content = "────────────"
            })

        end

    end

    --------------------------------------------------------
    -- BUTTON
    --------------------------------------------------------

    function group:AddButton(data)

        if type(data) == "string" then

            data = {
                Text = data
            }

        end

        data = data or {}

        local button =
            fluentGroup:AddButton({

                Title =
                    data.Text
                    or data.Name
                    or "Button",

                Description =
                    data.Description
                    or "",

                Callback =
                    data.Callback
                    or data.Func
                    or function()
                    end

            })

        table.insert(
            group.Elements,
            button
        )

        return button
    end

    --------------------------------------------------------
    -- TOGGLE
    --------------------------------------------------------

    function group:AddToggle(
        name,
        data
    )

        data = data or {}

        local toggle =
            fluentGroup:AddToggle(
                name,
                {

                    Title =
                        data.Text
                        or data.Title
                        or name,

                    Default =
                        data.Default
                        or false,

                    Callback =
                        data.Callback
                        or data.Changed
                        or function()
                        end
                }
            )

        ----------------------------------------------------
        -- OBSIDIAN METHODS
        ----------------------------------------------------

        local object = {

            Name = name,

            Value =
                data.Default
                or false,

            Fluent = toggle

        }

        function object:SetValue(
            value
        )

            object.Value =
                value == true

            if toggle.SetValue then
                toggle:SetValue(
                    object.Value
                )
            end

        end

        function object:GetValue()

            if toggle.GetValue then
                return toggle:GetValue()
            end

            return object.Value
        end

        function object:OnChanged(
            callback
        )

            object.Callback =
                callback

            return object
        end

        RegisterToggle(
            name,
            object
        )

        return object
    end

    --------------------------------------------------------
    -- SLIDER
    --------------------------------------------------------

    function group:AddSlider(
        name,
        data
    )

        data = data or {}

        local min =
            tonumber(data.Min)
            or 0

        local max =
            tonumber(data.Max)
            or 100

        local default =
            tonumber(data.Default)
            or min

        local rounding =
            tonumber(data.Rounding)

        if rounding == nil then
            rounding = 0
        end

        local slider =
            fluentGroup:AddSlider(
                name,
                {

                    Title =
                        data.Text
                        or data.Title
                        or name,

                    Description =
                        data.Description
                        or "",

                    Default =
                        default,

                    Min =
                        min,

                    Max =
                        max,

                    Rounding =
                        rounding,

                    Callback =
                        data.Callback
                        or function()
                        end
                }
            )

        local object = {

            Name = name,

            Min = min,

            Max = max,

            Value = default,

            Rounding = rounding,

            Fluent = slider

        }

        function object:SetValue(
            value
        )

            value =
                tonumber(value)
                or min

            value =
                math.clamp(
                    value,
                    min,
                    max
                )

            object.Value =
                value

            if slider.SetValue then
                slider:SetValue(
                    value
                )
            end

        end

        function object:GetValue()

            if slider.GetValue then
                return slider:GetValue()
            end

            return object.Value
        end

        function object:OnChanged(
            callback
        )

            object.Callback =
                callback

            return object
        end

        RegisterOption(
            name,
            object
        )

        return object
    end

    --------------------------------------------------------
    -- DROPDOWN
    --------------------------------------------------------

    function group:AddDropdown(
        name,
        data
    )

        data = data or {}

        local dropdown =
            fluentGroup:AddDropdown(
                name,
                {

                    Title =
                        data.Text
                        or data.Title
                        or name,

                    Values =
                        data.Values
                        or {},

                    Multi =
                        data.Multi
                        or false,

                    Default =
                        data.Default,

                    Callback =
                        data.Callback
                        or function()
                        end
                }
            )

        local object = {

            Name = name,

            Value =
                data.Default,

            Values =
                data.Values
                or {},

            Fluent = dropdown

        }

        function object:SetValue(
            value
        )

            object.Value =
                value

            if dropdown.SetValue then
                dropdown:SetValue(
                    value
                )
            end

        end

        function object:GetValue()

            if dropdown.GetValue then
                return dropdown:GetValue()
            end

            return object.Value
        end

        function object:SetValues(
            values
        )

            object.Values =
                values

            if dropdown.SetValues then
                dropdown:SetValues(
                    values
                )
            end

        end

        function object:OnChanged(
            callback
        )

            object.Callback =
                callback

            return object
        end

        RegisterOption(
            name,
            object
        )

        return object
    end

    --------------------------------------------------------
    -- INPUT
    --------------------------------------------------------

    function group:AddInput(
        name,
        data
    )

        data = data or {}

        local input =
            fluentGroup:AddInput(
                name,
                {

                    Title =
                        data.Text
                        or data.Title
                        or name,

                    Default =
                        data.Default
                        or "",

                    Placeholder =
                        data.Placeholder
                        or "",

                    Numeric =
                        data.Numeric
                        or false,

                    Finished =
                        data.Finished
                        or false,

                    Callback =
                        data.Callback
                        or function()
                        end
                }
            )

        local object = {

            Name = name,

            Value =
                data.Default
                or "",

            Fluent = input

        }

        function object:SetValue(
            value
        )

            value =
                tostring(value)

            object.Value =
                value

            if input.SetValue then
                input:SetValue(
                    value
                )
            end

        end

        function object:GetValue()

            if input.GetValue then
                return input:GetValue()
            end

            return object.Value
        end

        RegisterOption(
            name,
            object
        )

        return object
    end

    return group
end

------------------------------------------------------------
-- PATCH CREATE WINDOW
------------------------------------------------------------

local OriginalCreateWindow =
    Library.CreateWindow

function Library:CreateWindow(
    config
)

    local window =
        OriginalCreateWindow(
            self,
            config
        )

    PatchWindow(window)

    return window
end

------------------------------------------------------------
-- THEME
------------------------------------------------------------

function Library:SetAccent(
    color
)

    if typeof(color) ~= "Color3" then
        return
    end

    self.Scheme.AccentColor =
        color

    pcall(function()

        Fluent:SetTheme({
            Accent = color
        })

    end)

end

------------------------------------------------------------
-- NOTIFY
------------------------------------------------------------

function Library:Notify(
    data
)

    data = data or {}

    return Fluent:Notify({

        Title =
            data.Title
            or "Notification",

        Content =
            data.Description
            or data.Content
            or "",

        Duration =
            data.Time
            or data.Duration
            or 4

    })

end

------------------------------------------------------------
-- TOGGLE UI
------------------------------------------------------------

function Library:Toggle()

    if self.Window
        and self.Window.Minimize then

        self.Window:Minimize()

    end

end

function Library:ToggleUI()

    self:Toggle()

end

------------------------------------------------------------
-- UNLOAD
------------------------------------------------------------

function Library:Unload()

    if self.Window
        and self.Window.Destroy then

        self.Window:Destroy()

    elseif Fluent.Destroy then

        Fluent:Destroy()

    end

end

------------------------------------------------------------
-- RETURN
------------------------------------------------------------

return Library
