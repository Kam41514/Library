--==================================================
-- LOAD LIBRARY
--==================================================

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Kam41514/Library/main/Library.lua"
))()

local ThemeManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Kam41514/Library/main/ThemeManager.lua"
))()

local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Kam41514/Library/main/SaveManager.lua"
))()


--==================================================
-- CONNECT MANAGERS
--==================================================

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)


--==================================================
-- WINDOW
--==================================================

local Window = Library:CreateWindow({
    Title = "Modern Hub",
    Footer = "v1.0.0",

    Center = true,
    AutoShow = true,

    Size = UDim2.fromOffset(900, 600),
})


--==================================================
-- MAIN
--==================================================

local MainTab = Window:AddTab("Main")

local CombatBox = MainTab:AddLeftGroupbox("Combat")
local CombatSettings = MainTab:AddRightGroupbox("Settings")


CombatBox:AddToggle("Aimbot", {
    Text = "Aimbot",
    Default = false,

    Callback = function(Value)
        print("Aimbot:", Value)
    end,
})


CombatBox:AddToggle("SilentAim", {
    Text = "Silent Aim",
    Default = false,
})


CombatBox:AddSlider("AimFOV", {
    Text = "Aim FOV",

    Default = 90,
    Min = 0,
    Max = 180,

    Rounding = 0,

    Callback = function(Value)
        print("FOV:", Value)
    end,
})


CombatSettings:AddDropdown("AimPart", {
    Text = "Aim Part",

    Values = {
        "Head",
        "Torso",
        "HumanoidRootPart",
    },

    Default = 1,

    Callback = function(Value)
        print("Aim Part:", Value)
    end,
})


CombatSettings:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = true,
})


CombatSettings:AddToggle("WallCheck", {
    Text = "Wall Check",
    Default = true,
})


--==================================================
-- PLAYER
--==================================================

local PlayerTab = Window:AddTab("Player")

local MovementBox = PlayerTab:AddLeftGroupbox("Movement")
local CharacterBox = PlayerTab:AddRightGroupbox("Character")


MovementBox:AddToggle("CustomSpeed", {
    Text = "Custom WalkSpeed",
    Default = false,
})


MovementBox:AddSlider("WalkSpeed", {
    Text = "WalkSpeed",

    Default = 16,
    Min = 1,
    Max = 100,

    Rounding = 0,
})


MovementBox:AddToggle("CustomJump", {
    Text = "Custom JumpPower",
    Default = false,
})


MovementBox:AddSlider("JumpPower", {
    Text = "JumpPower",

    Default = 50,
    Min = 1,
    Max = 150,

    Rounding = 0,
})


CharacterBox:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
})


CharacterBox:AddToggle("NoClip", {
    Text = "No Clip",
    Default = false,
})


CharacterBox:AddButton({
    Text = "Reset Character",

    Func = function()
        local Character =
            game.Players.LocalPlayer.Character

        if Character then
            Character:BreakJoints()
        end
    end,
})


--==================================================
-- VISUALS
--==================================================

local VisualTab = Window:AddTab("Visuals")

local ESPBox = VisualTab:AddLeftGroupbox("ESP")
local ESPSettings = VisualTab:AddRightGroupbox("ESP Settings")


ESPBox:AddToggle("ESPEnabled", {
    Text = "Enable ESP",
    Default = false,
})


ESPBox:AddToggle("ESPBoxes", {
    Text = "Boxes",
    Default = true,
})


ESPBox:AddToggle("ESPNames", {
    Text = "Names",
    Default = true,
})


ESPBox:AddToggle("ESPDistance", {
    Text = "Distance",
    Default = false,
})


ESPSettings:AddDropdown("ESPBoxStyle", {
    Text = "Box Style",

    Values = {
        "Corner",
        "Full",
        "Filled",
    },

    Default = 1,
})


ESPSettings:AddToggle("ESPTeamColor", {
    Text = "Team Color",
    Default = true,
})


ESPSettings:AddLabel("ESP Color"):AddColorPicker("ESPColor", {
    Default = Color3.fromRGB(139, 92, 246),
    Title = "ESP Color",
})


--==================================================
-- MISC
--==================================================

local MiscTab = Window:AddTab("Misc")

local MiscBox = MiscTab:AddLeftGroupbox("Miscellaneous")
local ActionsBox = MiscTab:AddRightGroupbox("Actions")


MiscBox:AddToggle("Notifications", {
    Text = "Notifications",
    Default = true,
})


MiscBox:AddToggle("Watermark", {
    Text = "Watermark",
    Default = false,
})


MiscBox:AddDropdown("NotificationStyle", {
    Text = "Notification Style",

    Values = {
        "Default",
        "Minimal",
        "Compact",
    },

    Default = 1,
})


ActionsBox:AddButton({
    Text = "Test Notification",

    Func = function()
        Library:Notify({
            Title = "Modern Hub",
            Description = "Everything is working!",
            Time = 4,
        })
    end,
})


ActionsBox:AddButton({
    Text = "Test Button",

    Func = function()
        print("Button çalıştı!")
    end,
})


--==================================================
-- SETTINGS
--==================================================

local SettingsTab = Window:AddTab("Settings")


-- Sol tarafta kendi Interface kutumuz
local InterfaceBox =
    SettingsTab:AddLeftGroupbox("Interface")


InterfaceBox:AddToggle("MenuNotifications", {
    Text = "Notifications",
    Default = true,
})


InterfaceBox:AddToggle("MenuWatermark", {
    Text = "Watermark",
    Default = false,
})


--==================================================
-- THEME MANAGER
--==================================================

ThemeManager:SetFolder("ModernHub")

ThemeManager:ApplyToTab(SettingsTab)


--==================================================
-- SAVE MANAGER
--==================================================

SaveManager:IgnoreThemeSettings()

SaveManager:SetFolder("ModernHub")

SaveManager:SetSubFolder("Configs")


-- ÖNEMLİ:
-- SettingsTab veriyoruz.
-- SaveManager kendi RightGroupbox'ını oluşturuyor.
SaveManager:BuildConfigSection(SettingsTab)


--==================================================
-- AUTOLOAD
--==================================================

SaveManager:LoadAutoloadConfig()
