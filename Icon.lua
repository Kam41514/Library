--// MoonHub Custom Icon
--// Static White Moon + Purple Glow
--// No external asset required

local MoonIcon = {}

function MoonIcon.Create(Parent, Size, Position)

    if not Parent then
        return nil
    end

    Size = Size or 22
    Position = Position or UDim2.fromOffset(8, 7)

    ---------------------------------------------------------
    -- HOLDER
    ---------------------------------------------------------

    local Holder = Instance.new("Frame")

    Holder.Name = "MoonHubMoon"
    Holder.BackgroundTransparency = 1
    Holder.BorderSizePixel = 0

    Holder.Size = UDim2.fromOffset(
        Size + 16,
        Size + 16
    )

    Holder.Position = Position

    Holder.ZIndex = 100
    Holder.Parent = Parent

    ---------------------------------------------------------
    -- PURPLE GLOW
    ---------------------------------------------------------

    local Glow = Instance.new("Frame")

    Glow.Name = "PurpleGlow"
    Glow.AnchorPoint = Vector2.new(0.5, 0.5)
    Glow.Position = UDim2.fromScale(0.5, 0.5)

    Glow.Size = UDim2.fromOffset(
        Size + 12,
        Size + 12
    )

    Glow.BackgroundColor3 =
        Color3.fromRGB(155, 95, 255)

    Glow.BackgroundTransparency = 0.78

    Glow.BorderSizePixel = 0
    Glow.ZIndex = 99
    Glow.Parent = Holder

    local GlowCorner = Instance.new("UICorner")

    GlowCorner.CornerRadius =
        UDim.new(1, 0)

    GlowCorner.Parent = Glow

    ---------------------------------------------------------
    -- SOFT SECOND GLOW
    ---------------------------------------------------------

    local SoftGlow = Instance.new("Frame")

    SoftGlow.Name = "SoftGlow"
    SoftGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    SoftGlow.Position = UDim2.fromScale(0.5, 0.5)

    SoftGlow.Size = UDim2.fromOffset(
        Size + 7,
        Size + 7
    )

    SoftGlow.BackgroundColor3 =
        Color3.fromRGB(190, 145, 255)

    SoftGlow.BackgroundTransparency = 0.82

    SoftGlow.BorderSizePixel = 0
    SoftGlow.ZIndex = 100
    SoftGlow.Parent = Holder

    local SoftCorner = Instance.new("UICorner")

    SoftCorner.CornerRadius =
        UDim.new(1, 0)

    SoftCorner.Parent = SoftGlow

    ---------------------------------------------------------
    -- WHITE MOON
    ---------------------------------------------------------

    local Moon = Instance.new("Frame")

    Moon.Name = "Moon"
    Moon.AnchorPoint = Vector2.new(0.5, 0.5)
    Moon.Position = UDim2.fromScale(0.5, 0.5)

    Moon.Size = UDim2.fromOffset(
        Size,
        Size
    )

    Moon.BackgroundColor3 =
        Color3.fromRGB(250, 248, 255)

    Moon.BackgroundTransparency = 0

    Moon.BorderSizePixel = 0
    Moon.ZIndex = 101
    Moon.Parent = Holder

    local MoonCorner = Instance.new("UICorner")

    MoonCorner.CornerRadius =
        UDim.new(1, 0)

    MoonCorner.Parent = Moon

    ---------------------------------------------------------
    -- MOON OUTLINE
    ---------------------------------------------------------

    local MoonStroke = Instance.new("UIStroke")

    MoonStroke.Name = "MoonOutline"

    MoonStroke.Color =
        Color3.fromRGB(220, 200, 255)

    MoonStroke.Thickness = 1
    MoonStroke.Transparency = 0.15

    MoonStroke.Parent = Moon

    ---------------------------------------------------------
    -- CRATER FUNCTION
    ---------------------------------------------------------

    local function CreateCrater(X, Y, Scale, Transparency)

        local Crater = Instance.new("Frame")

        Crater.Name = "Crater"

        Crater.AnchorPoint =
            Vector2.new(0.5, 0.5)

        Crater.Position =
            UDim2.fromScale(X, Y)

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
            Color3.fromRGB(190, 185, 205)

        Crater.BackgroundTransparency =
            Transparency or 0.55

        Crater.BorderSizePixel = 0

        Crater.ZIndex = 102
        Crater.Parent = Moon

        local Corner = Instance.new("UICorner")

        Corner.CornerRadius =
            UDim.new(1, 0)

        Corner.Parent = Crater
    end

    ---------------------------------------------------------
    -- CRATERS
    ---------------------------------------------------------

    CreateCrater(
        0.67,
        0.30,
        0.16,
        0.58
    )

    CreateCrater(
        0.31,
        0.63,
        0.13,
        0.62
    )

    CreateCrater(
        0.70,
        0.70,
        0.10,
        0.65
    )

    CreateCrater(
        0.48,
        0.78,
        0.07,
        0.68
    )

    ---------------------------------------------------------
    -- SMALL WHITE HIGHLIGHT
    ---------------------------------------------------------

    local Highlight = Instance.new("Frame")

    Highlight.Name = "Highlight"

    Highlight.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Highlight.Position =
        UDim2.fromScale(
            0.34,
            0.28
        )

    Highlight.Size =
        UDim2.fromOffset(
            math.max(2, Size * 0.13),
            math.max(2, Size * 0.13)
        )

    Highlight.BackgroundColor3 =
        Color3.fromRGB(255, 255, 255)

    Highlight.BackgroundTransparency = 0.05

    Highlight.BorderSizePixel = 0

    Highlight.ZIndex = 103
    Highlight.Parent = Moon

    local HighlightCorner = Instance.new("UICorner")

    HighlightCorner.CornerRadius =
        UDim.new(1, 0)

    HighlightCorner.Parent = Highlight

    ---------------------------------------------------------
    -- RETURN
    ---------------------------------------------------------

    return Holder
end

return MoonIcon
