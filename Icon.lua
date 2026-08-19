--// MoonHub Custom Icon
--// Minimal Soft White Crescent Moon
--// No Glow / No Outline / No Animation

local MoonIcon = {}

function MoonIcon.Create(Parent, Size, Position)

    if not Parent then
        return nil
    end

    -- Icon boyutu
    Size = Size or 25

    -- Yazıyla aynı hizada, solda hafif boşluk
    Position = Position or UDim2.fromOffset(8, 1)

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

    Holder.Position = Position

    Holder.ZIndex = 100
    Holder.Parent = Parent

    ---------------------------------------------------------
    -- WHITE MOON
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
    -- DARK CUTOUT
    -- Sağ tarafı keserek hilal oluşturur
    ---------------------------------------------------------

    local Cutout = Instance.new("Frame")

    Cutout.Name = "MoonCutout"

    Cutout.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Cutout.Position =
        UDim2.fromScale(
            0.68,
            0.38
        )

    Cutout.Size =
        UDim2.fromOffset(
            Size * 0.86,
            Size * 0.86
        )

    -- Obsidian arka planıyla aynı koyu renk
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
    -- SUBTLE MOON DETAIL
    ---------------------------------------------------------

    local Detail = Instance.new("Frame")

    Detail.Name = "MoonDetail"

    Detail.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Detail.Position =
        UDim2.fromScale(
            0.34,
            0.35
        )

    Detail.Size =
        UDim2.fromOffset(
            Size * 0.13,
            Size * 0.13
        )

    Detail.BackgroundColor3 =
        Color3.fromRGB(
            190,
            190,
            196
        )

    Detail.BackgroundTransparency = 0.72
    Detail.BorderSizePixel = 0

    Detail.ZIndex = 102
    Detail.Parent = Moon

    local DetailCorner =
        Instance.new("UICorner")

    DetailCorner.CornerRadius =
        UDim.new(1, 0)

    DetailCorner.Parent = Detail

    ---------------------------------------------------------
    -- SECOND SUBTLE DETAIL
    ---------------------------------------------------------

    local Detail2 = Instance.new("Frame")

    Detail2.Name = "MoonDetail2"

    Detail2.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Detail2.Position =
        UDim2.fromScale(
            0.43,
            0.67
        )

    Detail2.Size =
        UDim2.fromOffset(
            Size * 0.09,
            Size * 0.09
        )

    Detail2.BackgroundColor3 =
        Color3.fromRGB(
            190,
            190,
            196
        )

    Detail2.BackgroundTransparency = 0.78
    Detail2.BorderSizePixel = 0

    Detail2.ZIndex = 102
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
