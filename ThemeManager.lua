--// KamUI ThemeManager
--// Obsidian ThemeManager compatibility layer
--// Keeps theme API while protecting the visual skin.

local HttpService = game:GetService("HttpService")

local SOURCE =
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"

local source = game:HttpGet(
    SOURCE .. "?kamui=" .. tostring(os.clock())
)

local loader, err = loadstring(source)

if not loader then
    error("[KamUI ThemeManager] Compile error:\n" .. tostring(err))
end

local ThemeManager = loader()

if type(ThemeManager) ~= "table" then
    error("[KamUI ThemeManager] Failed to load.")
end

---------------------------------------------------------------------
-- ORIGINAL FUNCTIONS
---------------------------------------------------------------------

local OriginalSetLibrary =
    ThemeManager.SetLibrary

local OriginalSaveCustomTheme =
    ThemeManager.SaveCustomTheme

local OriginalApplyTheme =
    ThemeManager.ApplyTheme

local OriginalThemeUpdate =
    ThemeManager.ThemeUpdate

---------------------------------------------------------------------
-- SET LIBRARY
---------------------------------------------------------------------

ThemeManager.SetLibrary = function(self, Library)

    OriginalSetLibrary(self, Library)

    -- Mark the Library as being controlled by KamUI.
    Library.KamUISkin = true

    -- Values that ThemeManager is allowed to control.
    Library.KamUIThemeIndexes = {
        "FontColor",
        "MainColor",
        "AccentColor",
        "BackgroundColor",
        "OutlineColor"
    }

end

---------------------------------------------------------------------
-- SAVE CUSTOM THEME
---------------------------------------------------------------------

ThemeManager.SaveCustomTheme = function(self, ThemeName)

    local Library = self.Library

    if not Library then
        return false, "Library is not set"
    end

    if type(ThemeName) ~= "string"
        or ThemeName:gsub("%s+", "") == "" then

        return false, "Invalid theme name provided"
    end

    if string.lower(ThemeName) == "default" then
        return false, "Invalid theme name provided"
    end

    local folder =
        self.Folder .. "/themes"

    if not isfolder(folder) then
        makefolder(self.Folder)
        makefolder(folder)
    end

    local path =
        folder .. "/" .. ThemeName .. ".json"

    -----------------------------------------------------------------
    -- ONLY THEME VALUES ARE SAVED
    -----------------------------------------------------------------

    local Data = {}

    local Scheme = Library.Scheme

    local ThemeIndexes = {
        "FontColor",
        "MainColor",
        "AccentColor",
        "BackgroundColor",
        "OutlineColor"
    }

    for _, Name in ipairs(ThemeIndexes) do

        local Color = Scheme[Name]

        if typeof(Color) == "Color3" then
            Data[Name] = Color:ToHex()
        end
    end

    -----------------------------------------------------------------
    -- FONT
    -----------------------------------------------------------------

    local FontValue

    if Library.Options
        and Library.Options.FontFace then

        FontValue =
            Library.Options.FontFace.Value
    end

    if type(FontValue) == "string" then
        Data.FontFace = FontValue
    else
        Data.FontFace = "Gotham"
    end

    -----------------------------------------------------------------
    -- BACKGROUND IMAGE
    -----------------------------------------------------------------

    if Library.Options
        and Library.Options.BackgroundImage then

        local Value =
            Library.Options.BackgroundImage.Value

        if type(Value) == "string" then
            Data.BackgroundImage = Value
        else
            Data.BackgroundImage = ""
        end

    else

        Data.BackgroundImage = ""

    end

    -----------------------------------------------------------------
    -- WRITE
    -----------------------------------------------------------------

    local success, encoded =
        pcall(
            HttpService.JSONEncode,
            HttpService,
            Data
        )

    if not success then
        return false, "Failed to encode theme"
    end

    local writeSuccess, writeError =
        pcall(
            writefile,
            path,
            encoded
        )

    if not writeSuccess then
        return false,
            "Failed to write theme: "
            .. tostring(writeError)
    end

    return true
end

---------------------------------------------------------------------
-- APPLY THEME
---------------------------------------------------------------------

ThemeManager.ApplyTheme = function(self, ThemeName)

    local result, err =
        OriginalApplyTheme(
            self,
            ThemeName
        )

    if not result then
        return result, err
    end

    -----------------------------------------------------------------
    -- REAPPLY KAMUI VISUAL LAYER
    -----------------------------------------------------------------

    task.defer(function()

        task.wait(0.08)

        local Library = self.Library

        if not Library then
            return
        end

        -------------------------------------------------------------
        -- DO NOT LET THEME CHANGE LAYOUT
        -------------------------------------------------------------

        Library.CornerRadius = 14

        Library.KamUISkin = true

        -------------------------------------------------------------
        -- REAPPLY VISUAL CALLBACK
        -------------------------------------------------------------

        if Library.KamUIRefresh then

            pcall(function()
                Library:KamUIRefresh()
            end)

        end

    end)

    return true
end

---------------------------------------------------------------------
-- THEME UPDATE
---------------------------------------------------------------------

ThemeManager.ThemeUpdate = function(self)

    local Library = self.Library

    if not Library then
        return
    end

    -----------------------------------------------------------------
    -- ONLY UPDATE THEME COLORS
    -----------------------------------------------------------------

    local Indexes = {
        "FontColor",
        "MainColor",
        "AccentColor",
        "BackgroundColor",
        "OutlineColor"
    }

    for _, Name in ipairs(Indexes) do

        local Option =
            Library.Options
            and Library.Options[Name]

        if Option then

            local Value =
                Option.Value

            if typeof(Value) == "Color3" then
                Library.Scheme[Name] = Value
            end

        end
    end

    -----------------------------------------------------------------
    -- UPDATE REGISTRY
    -----------------------------------------------------------------

    pcall(function()
        Library:UpdateColorsUsingRegistry()
    end)

    -----------------------------------------------------------------
    -- RESTORE VISUAL SKIN
    -----------------------------------------------------------------

    task.defer(function()

        task.wait(0.05)

        if Library.KamUIRefresh then

            pcall(function()
                Library:KamUIRefresh()
            end)

        end

    end)

end

---------------------------------------------------------------------
-- PROTECTED FONT
---------------------------------------------------------------------

local OriginalSetFont =
    ThemeManager.Library
    and ThemeManager.Library.SetFont

---------------------------------------------------------------------
-- MARKER
---------------------------------------------------------------------

ThemeManager.KamUI = true
ThemeManager.KamUIVersion = "2.0.0"

return ThemeManager
