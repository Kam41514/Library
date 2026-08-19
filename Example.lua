--// MoonHub Library
--// Complete Example
--// Library + Icon + PathManager + SaveManager + ThemeManager

---------------------------------------------------------------------
-- CONFIG
---------------------------------------------------------------------

local BASE_URL =
    "https://raw.githubusercontent.com/Kam41514/Library/main/"

local function LoadModule(Name)
    local Success, Result = pcall(function()

        local Source =
            game:HttpGet(
                BASE_URL ..
                Name ..
                ".lua?v=" ..
                tostring(os.clock())
            )

        local Loader, Error =
            loadstring(Source)

        if not Loader then
            error(
                "[" .. Name .. "] Compile error:\n" ..
                tostring(Error)
            )
        end

        return Loader()
    end)

    if not Success then
        error(
            "[MoonHub] Failed to load " ..
            Name ..
            ":\n" ..
            tostring(Result)
        )
    end

    return Result
end

---------------------------------------------------------------------
-- LOAD LIBRARY
---------------------------------------------------------------------

local Library =
    LoadModule("Library")

if type(Library) ~= "table" then
    error("[MoonHub] Library failed to load.")
end

---------------------------------------------------------------------
-- LOAD MODULES
---------------------------------------------------------------------

local Icon =
    LoadModule("Icon")

local PathManager =
    LoadModule("PathManager")

local SaveManager =
    LoadModule("SaveManager")

local ThemeManager =
    LoadModule("ThemeManager")

---------------------------------------------------------------------
-- GLOBALS
---------------------------------------------------------------------

local Options =
    Library.Options

local Toggles =
    Library.Toggles

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------

local Window =
    Library:CreateWindow({

        Title = "MoonHub",

        Footer = "Complete Example | v1.0",

        NotifySide = "Left",

        ShowCustomCursor = true,

        Center = true,
    })

---------------------------------------------------------------------
-- TABS
---------------------------------------------------------------------

local Tabs = {}

Tabs.Main =
    Window:AddTab(
        "Main",
        "house"
    )

Tabs.Player =
    Window:AddTab(
        "Player",
        "user"
    )

Tabs.Path =
    Window:AddTab(
        "Path Manager",
        "route"
    )

Tabs.Configuration =
    Window:AddTab(
        "Configuration",
        "folder-cog"
    )

Tabs.Theme =
    Window:AddTab(
        "Theme",
        "palette"
    )

Tabs.Settings =
    Window:AddTab(
        "Settings",
        "settings"
    )

---------------------------------------------------------------------
-- MAIN GROUPBOXES
---------------------------------------------------------------------

local MainLeft =
    Tabs.Main:AddLeftGroupbox(
        "Main"
    )

local MainRight =
    Tabs.Main:AddRightGroupbox(
        "Information"
    )

---------------------------------------------------------------------
-- MAIN UI
---------------------------------------------------------------------

MainLeft:AddLabel(
    "MoonHub Library Example"
)

MainLeft:AddLabel(
    "Library + Managers + Custom Icon",
    true
)

MainLeft:AddDivider()

MainLeft:AddToggle(
    "ExampleToggle",
    {
        Text = "Example Toggle",

        Default = false,

        Tooltip =
            "Test toggle",

        Callback = function(Value)

            Library:Notify({

                Title = "Toggle",

                Description =
                    "Value: " ..
                    tostring(Value),

                Time = 2
            })

        end
    }
)

MainLeft:AddSlider(
    "ExampleSlider",
    {
        Text = "Example Slider",

        Default = 50,

        Min = 0,

        Max = 100,

        Rounding = 0,

        Suffix = "%",

        Compact = false,

        Callback = function(Value)

            print(
                "[MoonHub] Slider:",
                Value
            )

        end
    }
)

MainLeft:AddDropdown(
    "ExampleDropdown",
    {
        Values = {
            "Normal",
            "Fast",
            "Very Fast"
        },

        Default = "Normal",

        Multi = false,

        Text = "Example Dropdown",

        Callback = function(Value)

            print(
                "[MoonHub] Mode:",
                Value
            )

        end
    }
)

MainRight:AddButton({

    Text = "Test Notification",

    Func = function()

        Library:Notify({

            Title = "MoonHub",

            Description =
                "Notification çalışıyor.",

            Time = 3
        })

    end
})

MainRight:AddButton({

    Text = "Print Values",

    Func = function()

        print(
            "Toggle:",
            Toggles.ExampleToggle.Value
        )

        print(
            "Slider:",
            Options.ExampleSlider.Value
        )

        print(
            "Dropdown:",
            Options.ExampleDropdown.Value
        )

    end
})

---------------------------------------------------------------------
-- PLAYER TAB
---------------------------------------------------------------------

local PlayerLeft =
    Tabs.Player:AddLeftGroupbox(
        "Player"
    )

local PlayerRight =
    Tabs.Player:AddRightGroupbox(
        "Player Information"
    )

PlayerLeft:AddToggle(
    "PlayerEnabled",
    {
        Text = "Player Feature",

        Default = false,

        Callback = function(Value)

            print(
                "Player Feature:",
                Value
            )

        end
    }
)

PlayerLeft:AddSlider(
    "PlayerSpeed",
    {
        Text = "WalkSpeed",

        Default = 16,

        Min = 16,

        Max = 100,

        Rounding = 0,

        Suffix = "",

        Compact = false,

        Callback = function(Value)

            local Character =
                game.Players.LocalPlayer.Character

            local Humanoid =
                Character
                and Character:FindFirstChildOfClass(
                    "Humanoid"
                )

            if Humanoid then
                Humanoid.WalkSpeed = Value
            end

        end
    }
)

PlayerRight:AddLabel(
    "Player Settings"
)

PlayerRight:AddLabel(
    "WalkSpeed can be changed above.",
    true
)

---------------------------------------------------------------------
-- PATH MANAGER
---------------------------------------------------------------------

local PathLeft =
    Tabs.Path:AddLeftGroupbox(
        "Path Manager"
    )

local PathRight =
    Tabs.Path:AddRightGroupbox(
        "Path Information"
    )

---------------------------------------------------------------------
-- PATH DATA
---------------------------------------------------------------------

local CurrentPath = {}

local function CreateExamplePoint(
    X,
    Y,
    Z,
    Reset,
    WaitTime
)

    return {

        Position =
            Vector3.new(
                X,
                Y,
                Z
            ),

        Reset =
            Reset == true,

        WaitTime =
            tonumber(
                WaitTime
            ) or 0
    }
end

---------------------------------------------------------------------
-- PATH NAME
---------------------------------------------------------------------

local PathNameInput =
    PathLeft:AddInput(
        "ExamplePathName",
        {
            Text = "Path Name",

            Default = "TestPath",

            Placeholder =
                "Path name..."
        }
    )

---------------------------------------------------------------------
-- CREATE POINT
---------------------------------------------------------------------

PathLeft:AddButton({

    Text = "Create Test Path",

    Func = function()

        table.clear(
            CurrentPath
        )

        local Root =
            game.Players.LocalPlayer.Character
            and game.Players.LocalPlayer.Character:
            FindFirstChild(
                "HumanoidRootPart"
            )

        if not Root then

            Library:Notify({

                Title = "Path",

                Description =
                    "Character bulunamadı.",

                Time = 2
            })

            return
        end

        local Base =
            Root.Position

        table.insert(
            CurrentPath,

            CreateExamplePoint(
                Base.X,
                Base.Y,
                Base.Z,
                false,
                0
            )
        )

        table.insert(
            CurrentPath,

            CreateExamplePoint(
                Base.X + 10,
                Base.Y,
                Base.Z,
                false,
                1
            )
        )

        table.insert(
            CurrentPath,

            CreateExamplePoint(
                Base.X + 20,
                Base.Y,
                Base.Z,
                true,
                1
            )
        )

        Library:Notify({

            Title = "Path",

            Description =
                "3 test point oluşturuldu.",

            Time = 2
        })

    end
})

---------------------------------------------------------------------
-- SAVE PATH
---------------------------------------------------------------------

PathLeft:AddButton({

    Text = "Save Path",

    Func = function()

        local Name =
            tostring(
                PathNameInput.Value
                or ""
            )

        if Name == "" then

            Library:Notify({

                Title = "Path",

                Description =
                    "Path ismi boş.",

                Time = 2
            })

            return
        end

        if #CurrentPath == 0 then

            Library:Notify({

                Title = "Path",

                Description =
                    "Önce test path oluştur.",

                Time = 2
            })

            return
        end

        local Success, Result =
            pcall(function()

                return PathManager.SavePath(
                    Name,
                    CurrentPath
                )

            end)

        if not Success then

            Library:Notify({

                Title = "Path",

                Description =
                    "Save error: " ..
                    tostring(Result),

                Time = 3
            })

            return
        end

        Library:Notify({

            Title = "Path",

            Description =
                "'" ..
                Name ..
                "' kaydedildi.",

            Time = 2
        })

    end
})

---------------------------------------------------------------------
-- LOAD PATH
---------------------------------------------------------------------

PathLeft:AddButton({

    Text = "Load Path",

    Func = function()

        local Name =
            tostring(
                PathNameInput.Value
                or ""
            )

        local Data =
            PathManager.LoadPath(
                Name
            )

        if not Data then

            Library:Notify({

                Title = "Path",

                Description =
                    "Path bulunamadı.",

                Time = 2
            })

            return
        end

        table.clear(
            CurrentPath
        )

        for _, Point in ipairs(
            Data.Points
        ) do

            table.insert(
                CurrentPath,
                Point
            )

        end

        Library:Notify({

            Title = "Path",

            Description =
                "'" ..
                Name ..
                "' yüklendi. " ..
                tostring(
                    #CurrentPath
                ) ..
                " point.",

            Time = 2
        })

    end
})

---------------------------------------------------------------------
-- DELETE PATH
---------------------------------------------------------------------

PathLeft:AddButton({

    Text = "Delete Path",

    Func = function()

        local Name =
            tostring(
                PathNameInput.Value
                or ""
            )

        if PathManager.DeletePath(
            Name
        ) then

            Library:Notify({

                Title = "Path",

                Description =
                    "'" ..
                    Name ..
                    "' silindi.",

                Time = 2
            })

        else

            Library:Notify({

                Title = "Path",

                Description =
                    "Path bulunamadı.",

                Time = 2
            })

        end

    end
})

---------------------------------------------------------------------
-- PATH LIST
---------------------------------------------------------------------

local PathDropdown =
    PathLeft:AddDropdown(
        "PathList",
        {
            Values =
                PathManager.GetPaths(),

            Default = nil,

            AllowNull = true,

            Multi = false,

            Text = "Saved Paths"
        }
    )

PathLeft:AddButton({

    Text = "Refresh Paths",

    Func = function()

        PathDropdown:SetValues(
            PathManager.GetPaths()
        )

    end
})

---------------------------------------------------------------------
-- PATH JSON
---------------------------------------------------------------------

PathRight:AddButton({

    Text = "Export Selected Path",

    Func = function()

        local Name =
            PathDropdown.Value

        if type(Name) ~= "string" then

            Library:Notify({

                Title = "Path",

                Description =
                    "Path seç.",

                Time = 2
            })

            return
        end

        local JSON =
            PathManager.ExportJSON(
                Name
            )

        if not JSON then

            Library:Notify({

                Title = "Path",

                Description =
                    "Export başarısız.",

                Time = 2
            })

            return
        end

        if setclipboard then

            setclipboard(
                JSON
            )

            Library:Notify({

                Title = "Path",

                Description =
                    "JSON clipboard'a kopyalandı.",

                Time = 2
            })

        else

            print(
                JSON
            )

        end

    end
})

PathRight:AddLabel(
    "PathManager API"
)

PathRight:AddLabel(
    "SavePath / LoadPath / DeletePath",
    true
)

PathRight:AddLabel(
    "GetPaths / ExportJSON / ImportJSON",
    true
)

---------------------------------------------------------------------
-- SAVE MANAGER
---------------------------------------------------------------------

SaveManager:SetLibrary(
    Library
)

SaveManager:SetFolder(
    "MoonHub"
)

SaveManager:SetSubFolder(
    "Configs"
)

---------------------------------------------------------------------
-- SAVE MANAGER TAB
---------------------------------------------------------------------

local ConfigBox =
    SaveManager:BuildConfigSection(
        Tabs.Configuration,
        "folder-cog"
    )

---------------------------------------------------------------------
-- SAVE MANAGER EXTRA
---------------------------------------------------------------------

local ConfigInfo =
    Tabs.Configuration:AddLeftGroupbox(
        "Config Information"
    )

ConfigInfo:AddLabel(
    "Config system aktif."
)

ConfigInfo:AddLabel(
    "Configs/MoonHub klasörüne kaydedilir.",
    true
)

ConfigInfo:AddButton({

    Text = "Load Autoload",

    Func = function()

        SaveManager:LoadAutoloadConfig()

    end
})

ConfigInfo:AddButton({

    Text = "Clear Autoload",

    Func = function()

        local Success, Error =
            SaveManager:
            DeleteAutoLoadConfig()

        if Success then

            Library:Notify({

                Title = "Config",

                Description =
                    "Autoload temizlendi.",

                Time = 2
            })

        else

            Library:Notify({

                Title = "Config",

                Description =
                    tostring(Error),

                Time = 2
            })

        end

    end
})

---------------------------------------------------------------------
-- THEME MANAGER
---------------------------------------------------------------------

ThemeManager:SetLibrary(
    Library
)

ThemeManager:SetFolder(
    "MoonHub"
)

---------------------------------------------------------------------
-- THEME TAB
---------------------------------------------------------------------

local ThemeLeft =
    Tabs.Theme:AddLeftGroupbox(
        "Theme"
    )

local ThemeRight =
    Tabs.Theme:AddRightGroupbox(
        "Custom Theme"
    )

ThemeLeft:AddLabel(
    "Theme Manager"
)

ThemeLeft:AddLabel(
    "Library renklerini buradan yönetebilirsin.",
    true
)

ThemeLeft:AddButton({

    Text = "Apply Dark",

    Func = function()

        pcall(function()

            ThemeManager:
                ApplyTheme(
                    "Dark"
                )

        end)

    end
})

ThemeLeft:AddButton({

    Text = "Apply Default",

    Func = function()

        pcall(function()

            ThemeManager:
                ApplyTheme(
                    "Default"
                )

        end)

    end
})

---------------------------------------------------------------------
-- CUSTOM THEME NAME
---------------------------------------------------------------------

local ThemeNameInput =
    ThemeRight:AddInput(
        "ExampleThemeName",
        {
            Text = "Theme Name",

            Default = "MoonPurple",

            Placeholder =
                "Theme name..."
        }
    )

---------------------------------------------------------------------
-- SAVE CUSTOM THEME
---------------------------------------------------------------------

ThemeRight:AddButton({

    Text = "Save Custom Theme",

    Func = function()

        local Name =
            tostring(
                ThemeNameInput.Value
                or ""
            )

        if Name == "" then

            Library:Notify({

                Title = "Theme",

                Description =
                    "Theme name boş.",

                Time = 2
            })

            return
        end

        local Success, Error =
            ThemeManager:
            SaveCustomTheme(
                Name
            )

        if Success then

            Library:Notify({

                Title = "Theme",

                Description =
                    "'" ..
                    Name ..
                    "' kaydedildi.",

                Time = 2
            })

        else

            Library:Notify({

                Title = "Theme",

                Description =
                    tostring(Error),

                Time = 3
            })

        end

    end
})

---------------------------------------------------------------------
-- THEME COLORS
---------------------------------------------------------------------

ThemeRight:AddLabel(
    "Moon Purple"
)

ThemeRight:AddLabel(
    "Accent: Purple",
    true
)

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------

local SettingsLeft =
    Tabs.Settings:AddLeftGroupbox(
        "UI Settings"
    )

local SettingsRight =
    Tabs.Settings:AddRightGroupbox(
        "Information"
    )

---------------------------------------------------------------------
-- CORNER
---------------------------------------------------------------------

SettingsLeft:AddSlider(
    "CornerRadius",
    {
        Text = "Corner Radius",

        Default =
            Library.CornerRadius,

        Min = 0,

        Max = 20,

        Rounding = 0,

        Callback = function(Value)

            pcall(function()

                Window:SetCornerRadius(
                    Value
                )

            end)

        end
    }
)

---------------------------------------------------------------------
-- MENU KEY
---------------------------------------------------------------------

SettingsLeft:AddLabel(
    "Menu Keybind"
):AddKeyPicker(
    "MenuKeybind",
    {
        Default = "RightShift",

        NoUI = true,

        Text = "Menu Keybind"
    }
)

Library.ToggleKeybind =
    Options.MenuKeybind

---------------------------------------------------------------------
-- ICON
---------------------------------------------------------------------

task.defer(function()

    task.wait(0.25)

    if not Icon then
        return
    end

    if not Library.ScreenGui then
        return
    end

    local Main =
        Library.ScreenGui:
        FindFirstChild(
            "Main",
            true
        )

    if not Main then
        return
    end

    pcall(function()

        Icon.Create(
            Main,
            22,
            UDim2.fromOffset(
                8,
                3
            )
        )

    end)

end)

---------------------------------------------------------------------
-- SETTINGS INFO
---------------------------------------------------------------------

SettingsRight:AddLabel(
    "MoonHub Library"
)

SettingsRight:AddLabel(
    "Library.lua",
    true
)

SettingsRight:AddLabel(
    "Icon.lua",
    true
)

SettingsRight:AddLabel(
    "PathManager.lua",
    true
)

SettingsRight:AddLabel(
    "SaveManager.lua",
    true
)

SettingsRight:AddLabel(
    "ThemeManager.lua",
    true
)

SettingsRight:AddDivider()

---------------------------------------------------------------------
-- TEST API
---------------------------------------------------------------------

SettingsRight:AddButton({

    Text = "Test All Modules",

    Func = function()

        local Results = {}

        Results.Library =
            type(Library) == "table"

        Results.Icon =
            type(Icon) == "table"

        Results.PathManager =
            type(PathManager) == "table"

        Results.SaveManager =
            type(SaveManager) == "table"

        Results.ThemeManager =
            type(ThemeManager) == "table"

        for Name, Value in pairs(
            Results
        ) do

            print(
                "[MoonHub]",
                Name,
                Value
            )

        end

        Library:Notify({

            Title = "Module Test",

            Description =
                "Tüm modüller kontrol edildi.",

            Time = 3
        })

    end
})

---------------------------------------------------------------------
-- UNLOAD
---------------------------------------------------------------------

SettingsLeft:AddDivider()

SettingsLeft:AddButton({

    Text = "Unload",

    Func = function()

        pcall(function()

            Library:Unload()

        end)

    end
})

---------------------------------------------------------------------
-- CHANGE LISTENERS
---------------------------------------------------------------------

Toggles.ExampleToggle:
OnChanged(
    function()

        print(
            "[MoonHub] Toggle changed:",
            Toggles.ExampleToggle.Value
        )

    end
)

Options.ExampleSlider:
OnChanged(
    function()

        print(
            "[MoonHub] Slider changed:",
            Options.ExampleSlider.Value
        )

    end
)

---------------------------------------------------------------------
-- UNLOAD CALLBACK
---------------------------------------------------------------------

pcall(function()

    Library:OnUnload(
        function()

            print(
                "[MoonHub] Library unloaded."
            )

            table.clear(
                CurrentPath
            )

        end
    )

end)

---------------------------------------------------------------------
-- STARTUP
---------------------------------------------------------------------

Library:Notify({

    Title = "MoonHub",

    Description =
        "Complete Example loaded.",

    Time = 3
})

print(
    "[MoonHub] Complete Example loaded."
)
