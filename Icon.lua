--// MoonHub Custom Icon
--// Minimal Soft White Moon
--// Static / No Glow / No Outline / No Animation

local MoonIcon = {}

function MoonIcon.Create(Parent, Size, Position)

    if not Parent then
        return nil
    end

    Size = Size or 21

    -- Biraz daha yukarı
    Position = Position or UDim2.fromOffset(8, 0)

    ---------------------------------------------------------
    -- HOLDER
    ---------------------------------------------------------

    local Holder = Instance.new("Frame")

    Holder.Name = "MoonHubMoon"

    Holder.BackgroundTransparency = 1
    Holder.BorderSizePixel = 0

    Holder.Size =
        UDim2.fromOffset(
            Size,
            Size
        )

    Holder.Position = Position

    Holder.ZIndex = 100
    Holder.Parent = Parent

    ---------------------------------------------------------
    -- SOFT WHITE MOON
    ---------------------------------------------------------

    local Moon = Instance.new("Frame")

    Moon.Name = "Moon"

    Moon.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Moon.Position =
        UDim2.fromScale(
            0.5,
            0.5
        )

    Moon.Size =
        UDim2.fromOffset(
            Size,
            Size
        )

    -- Koyu arka planda gözü yormayan soft beyaz
    Moon.BackgroundColor3 =
        Color3.fromRGB(
            218,
            218,
            224
        )

    Moon.BackgroundTransparency = 0

    Moon.BorderSizePixel = 0

    Moon.ZIndex = 101
    Moon.Parent = Holder

    ---------------------------------------------------------
    -- ROUND MOON
    ---------------------------------------------------------

    local MoonCorner =
        Instance.new("UICorner")

    MoonCorner.CornerRadius =
        UDim.new(
            1,
            0
        )

    MoonCorner.Parent = Moon

    ---------------------------------------------------------
    -- SUBTLE CRATERS
    ---------------------------------------------------------

    local function CreateCrater(
        X,
        Y,
        Scale,
        Transparency
    )

        local Crater =
            Instance.new("Frame")

        Crater.Name =
            "Crater"

        Crater.AnchorPoint =
            Vector2.new(
                0.5,
                0.5
            )

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
                175,
                175,
                182
            )

        Crater.BackgroundTransparency =
            Transparency or 0.82

        Crater.BorderSizePixel = 0

        Crater.ZIndex = 102
        Crater.Parent = Moon

        local Corner =
            Instance.new("UICorner")

        Corner.CornerRadius =
            UDim.new(
                1,
                0
            )

        Corner.Parent = Crater
    end

    ---------------------------------------------------------
    -- VERY SUBTLE CRATERS
    ---------------------------------------------------------

    CreateCrater(
        0.67,
        0.30,
        0.16,
        0.82
    )

    CreateCrater(
        0.31,
        0.63,
        0.13,
        0.84
    )

    CreateCrater(
        0.70,
        0.70,
        0.10,
        0.85
    )

    CreateCrater(
        0.48,
        0.78,
        0.07,
        0.87
    )

    ---------------------------------------------------------
    -- NO GLOW
    -- NO OUTLINE
    -- NO ANIMATION
    ---------------------------------------------------------

    return Holder
end

return MoonIcon
