--// MoonHub Custom Icon
--// Soft White Moon + Subtle Purple Glow
--// Static / No Animation / No Asset

local MoonIcon = {}

function MoonIcon.Create(Parent, Size, Position)

    if not Parent then
        return nil
    end

    Size = Size or 22

    -- Biraz daha yukarı
    Position = Position or UDim2.fromOffset(8, 3)

    ---------------------------------------------------------
    -- HOLDER
    ---------------------------------------------------------

    local Holder = Instance.new("Frame")

    Holder.Name = "MoonHubMoon"
    Holder.BackgroundTransparency = 1
    Holder.BorderSizePixel = 0

    Holder.Size = UDim2.fromOffset(
        Size + 18,
        Size + 18
    )

    Holder.Position = Position

    Holder.ZIndex = 100
    Holder.Parent = Parent

    ---------------------------------------------------------
    -- SOFT PURPLE OUTER GLOW
    ---------------------------------------------------------

    local Glow = Instance.new("Frame")

    Glow.Name = "PurpleGlow"

    Glow.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Glow.Position =
        UDim2.fromScale(0.5, 0.5)

    Glow.Size =
        UDim2.fromOffset(
            Size + 13,
            Size + 13
        )

    Glow.BackgroundColor3 =
        Color3.fromRGB(
            135,
            85,
            220
        )

    Glow.BackgroundTransparency = 0.90

    Glow.BorderSizePixel = 0

    Glow.ZIndex = 99
    Glow.Parent = Holder

    local GlowCorner =
        Instance.new("UICorner")

    GlowCorner.CornerRadius =
        UDim.new(1, 0)

    GlowCorner.Parent = Glow

    ---------------------------------------------------------
    -- VERY SOFT INNER GLOW
    ---------------------------------------------------------

    local SoftGlow =
        Instance.new("Frame")

    SoftGlow.Name = "SoftGlow"

    SoftGlow.AnchorPoint =
        Vector2.new(0.5, 0.5)

    SoftGlow.Position =
        UDim2.fromScale(0.5, 0.5)

    SoftGlow.Size =
        UDim2.fromOffset(
            Size + 5,
            Size + 5
        )

    SoftGlow.BackgroundColor3 =
        Color3.fromRGB(
            165,
            120,
            235
        )

    SoftGlow.BackgroundTransparency = 0.92

    SoftGlow.BorderSizePixel = 0

    SoftGlow.ZIndex = 100
    SoftGlow.Parent = Holder

    local SoftCorner =
        Instance.new("UICorner")

    SoftCorner.CornerRadius =
        UDim.new(1, 0)

    SoftCorner.Parent = SoftGlow

    ---------------------------------------------------------
    -- SOFT WHITE MOON
    ---------------------------------------------------------

    local Moon =
        Instance.new("Frame")

    Moon.Name = "Moon"

    Moon.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Moon.Position =
        UDim2.fromScale(0.5, 0.5)

    Moon.Size =
        UDim2.fromOffset(
            Size,
            Size
        )

    -- Soft white, not pure bright white
    Moon.BackgroundColor3 =
        Color3.fromRGB(
            238,
            238,
            242
        )

    Moon.BackgroundTransparency = 0

    Moon.BorderSizePixel = 0

    Moon.ZIndex = 101
    Moon.Parent = Holder

    local MoonCorner =
        Instance.new("UICorner")

    MoonCorner.CornerRadius =
        UDim.new(1, 0)

    MoonCorner.Parent = Moon

    ---------------------------------------------------------
    -- DARK / SUBTLE PURPLE OUTLINE
    ---------------------------------------------------------

    local MoonStroke =
        Instance.new("UIStroke")

    MoonStroke.Name =
        "MoonOutline"

    -- Dark purple so it doesn't stand out too much
    MoonStroke.Color =
        Color3.fromRGB(
            75,
            55,
            105
        )

    MoonStroke.Thickness = 1

    MoonStroke.Transparency = 0.58

    MoonStroke.Parent = Moon

    ---------------------------------------------------------
    -- CRATER FUNCTION
    ---------------------------------------------------------

    local function CreateCrater(
        X,
        Y,
        Scale,
        Transparency
    )

        local Crater =
            Instance.new("Frame")

        Crater.Name = "Crater"

        Crater.AnchorPoint =
            Vector2.new(0.5, 0.5)

        Crater.Position =
            UDim2.fromScale(
                X,
                Y
            )

        local CraterSize =
            math.max(
                2,
                Size * Scale
            )

        Crater.Size =
            UDim2.fromOffset(
                CraterSize,
                CraterSize
            )

        Crater.BackgroundColor3 =
            Color3.fromRGB(
                190,
                190,
                198
            )

        Crater.BackgroundTransparency =
            Transparency or 0.72

        Crater.BorderSizePixel = 0

        Crater.ZIndex = 102
        Crater.Parent = Moon

        local Corner =
            Instance.new("UICorner")

        Corner.CornerRadius =
            UDim.new(1, 0)

        Corner.Parent = Crater
    end

    ---------------------------------------------------------
    -- SUBTLE CRATERS
    ---------------------------------------------------------

    CreateCrater(
        0.67,
        0.30,
        0.16,
        0.72
    )

    CreateCrater(
        0.31,
        0.63,
        0.13,
        0.75
    )

    CreateCrater(
        0.70,
        0.70,
        0.10,
        0.77
    )

    CreateCrater(
        0.48,
        0.78,
        0.07,
        0.79
    )

    ---------------------------------------------------------
    -- SOFT HIGHLIGHT
    ---------------------------------------------------------

    local Highlight =
        Instance.new("Frame")

    Highlight.Name =
        "Highlight"

    Highlight.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Highlight.Position =
        UDim2.fromScale(
            0.34,
            0.28
        )

    Highlight.Size =
        UDim2.fromOffset(
            math.max(
                2,
                Size * 0.12
            ),
            math.max(
                2,
                Size * 0.12
            )
        )

    Highlight.BackgroundColor3 =
        Color3.fromRGB(
            248,
            248,
            250
        )

    Highlight.BackgroundTransparency = 0.15

    Highlight.BorderSizePixel = 0

    Highlight.ZIndex = 103
    Highlight.Parent = Moon

    local HighlightCorner =
        Instance.new("UICorner")

    HighlightCorner.CornerRadius =
        UDim.new(1, 0)

    HighlightCorner.Parent = Highlight

    ---------------------------------------------------------
    -- RETURN
    ---------------------------------------------------------

    return Holder
end

return MoonIcon
