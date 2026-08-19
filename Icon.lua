--// MoonHub Custom Icon
--// Minimal Soft White Crescent
--// Centered / Static / No Glow / No Outline

local MoonIcon = {}

function MoonIcon.Create(Parent, Size)

    if not Parent then
        return nil
    end

    ---------------------------------------------------------
    -- SETTINGS
    ---------------------------------------------------------

    Size = Size or 25

    -- Soldan boşluk
    local LeftPadding = 7

    ---------------------------------------------------------
    -- HOLDER
    ---------------------------------------------------------

    local Holder = Instance.new("Frame")

    Holder.Name = "MoonHubMoon"

    Holder.BackgroundTransparency = 1
    Holder.BorderSizePixel = 0

    Holder.Size = UDim2.fromOffset(
        Size,
        Size
    )

    -- Parent'ın dikey merkezine oturur
    Holder.AnchorPoint =
        Vector2.new(0, 0.5)

    Holder.Position =
        UDim2.new(
            0,
            LeftPadding,
            0.5,
            0
        )

    Holder.ZIndex = 100
    Holder.Parent = Parent

    ---------------------------------------------------------
    -- MOON
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

    -- Soft white
    Moon.BackgroundColor3 =
        Color3.fromRGB(
            220,
            220,
            225
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
    -- CRESCENT CUTOUT
    ---------------------------------------------------------

    local Cutout = Instance.new("Frame")

    Cutout.Name = "MoonCutout"

    Cutout.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Cutout.Position =
        UDim2.fromScale(
            0.69,
            0.36
        )

    Cutout.Size =
        UDim2.fromOffset(
            Size * 0.84,
            Size * 0.84
        )

    -- Obsidian'ın koyu arka planı
    Cutout.BackgroundColor3 =
        Color3.fromRGB(
            5,
            5,
            7
        )

    Cutout.BackgroundTransparency = 0
    Cutout.BorderSizePixel = 0

    Cutout.ZIndex = 102
    Cutout.Parent = Holder

    local CutoutCorner =
        Instance.new("UICorner")

    CutoutCorner.CornerRadius =
        UDim.new(1, 0)

    CutoutCorner.Parent = Cutout

    ---------------------------------------------------------
    -- SUBTLE CRATER 1
    ---------------------------------------------------------

    local Detail = Instance.new("Frame")

    Detail.Name = "MoonDetail"

    Detail.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Detail.Position =
        UDim2.fromScale(
            0.34,
            0.34
        )

    Detail.Size =
        UDim2.fromOffset(
            Size * 0.12,
            Size * 0.12
        )

    Detail.BackgroundColor3 =
        Color3.fromRGB(
            185,
            185,
            192
        )

    Detail.BackgroundTransparency = 0.76
    Detail.BorderSizePixel = 0

    Detail.ZIndex = 103
    Detail.Parent = Moon

    local DetailCorner =
        Instance.new("UICorner")

    DetailCorner.CornerRadius =
        UDim.new(1, 0)

    DetailCorner.Parent = Detail

    ---------------------------------------------------------
    -- SUBTLE CRATER 2
    ---------------------------------------------------------

    local Detail2 = Instance.new("Frame")

    Detail2.Name = "MoonDetail2"

    Detail2.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Detail2.Position =
        UDim2.fromScale(
            0.42,
            0.66
        )

    Detail2.Size =
        UDim2.fromOffset(
            Size * 0.085,
            Size * 0.085
        )

    Detail2.BackgroundColor3 =
        Color3.fromRGB(
            185,
            185,
            192
        )

    Detail2.BackgroundTransparency = 0.80
    Detail2.BorderSizePixel = 0

    Detail2.ZIndex = 103
    Detail2.Parent = Moon

    local Detail2Corner =
        Instance.new("UICorner")

    Detail2Corner.CornerRadius =
        UDim.new(1, 0)

    Detail2Corner.Parent = Detail2

    ---------------------------------------------------------
    -- STATIC
    -- NO GLOW
    -- NO OUTLINE
    -- NO ANIMATION
    ---------------------------------------------------------

    return Holder
end

return MoonIcon
