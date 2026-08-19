--// MoonHub Custom Moon Icon

local MoonIcon = {}

function MoonIcon.Create(Parent, Size, Position)

    if not Parent then
        return
    end

    Size = Size or 22
    Position = Position or UDim2.fromOffset(8, 7)

    local Holder = Instance.new("Frame")
    Holder.Name = "MoonHubMoon"
    Holder.BackgroundTransparency = 1
    Holder.BorderSizePixel = 0
    Holder.Size = UDim2.fromOffset(Size + 14, Size + 14)
    Holder.Position = Position
    Holder.ZIndex = 100
    Holder.Parent = Parent

    -- MOR GLOW
    local Glow = Instance.new("Frame")
    Glow.Name = "Glow"
    Glow.AnchorPoint = Vector2.new(0.5, 0.5)
    Glow.Position = UDim2.fromScale(0.5, 0.5)
    Glow.Size = UDim2.fromOffset(Size + 10, Size + 10)
    Glow.BackgroundColor3 = Color3.fromRGB(150, 80, 255)
    Glow.BackgroundTransparency = 0.72
    Glow.BorderSizePixel = 0
    Glow.ZIndex = 100
    Glow.Parent = Holder

    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(1, 0)
    GlowCorner.Parent = Glow

    -- AY
    local Moon = Instance.new("Frame")
    Moon.Name = "Moon"
    Moon.AnchorPoint = Vector2.new(0.5, 0.5)
    Moon.Position = UDim2.fromScale(0.5, 0.5)
    Moon.Size = UDim2.fromOffset(Size, Size)
    Moon.BackgroundColor3 = Color3.fromRGB(195, 155, 255)
    Moon.BorderSizePixel = 0
    Moon.ZIndex = 101
    Moon.Parent = Holder

    local MoonCorner = Instance.new("UICorner")
    MoonCorner.CornerRadius = UDim.new(1, 0)
    MoonCorner.Parent = Moon

    local MoonStroke = Instance.new("UIStroke")
    MoonStroke.Color = Color3.fromRGB(235, 215, 255)
    MoonStroke.Thickness = 1
    MoonStroke.Transparency = 0.1
    MoonStroke.Parent = Moon

    -- KRATERLER
    local function Crater(X, Y, S)

        local C = Instance.new("Frame")
        C.Name = "Crater"
        C.AnchorPoint = Vector2.new(0.5, 0.5)
        C.Position = UDim2.fromScale(X, Y)
        C.Size = UDim2.fromOffset(S, S)
        C.BackgroundColor3 = Color3.fromRGB(145, 105, 205)
        C.BackgroundTransparency = 0.35
        C.BorderSizePixel = 0
        C.ZIndex = 102
        C.Parent = Moon

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(1, 0)
        Corner.Parent = C
    end

    Crater(0.68, 0.30, math.max(2, Size * 0.16))
    Crater(0.30, 0.65, math.max(2, Size * 0.13))
    Crater(0.70, 0.70, math.max(2, Size * 0.10))

    -- IŞIK NOKTASI
    local Shine = Instance.new("Frame")
    Shine.Name = "Shine"
    Shine.AnchorPoint = Vector2.new(0.5, 0.5)
    Shine.Position = UDim2.fromScale(0.35, 0.30)
    Shine.Size = UDim2.fromOffset(
        math.max(2, Size * 0.16),
        math.max(2, Size * 0.16)
    )
    Shine.BackgroundColor3 = Color3.fromRGB(255, 245, 255)
    Shine.BackgroundTransparency = 0.1
    Shine.BorderSizePixel = 0
    Shine.ZIndex = 103
    Shine.Parent = Moon

    local ShineCorner = Instance.new("UICorner")
    ShineCorner.CornerRadius = UDim.new(1, 0)
    ShineCorner.Parent = Shine

    -- GLOW ANİMASYONU
    task.spawn(function()

        local TweenService = game:GetService("TweenService")

        while Holder.Parent do

            local A = TweenService:Create(
                Glow,
                TweenInfo.new(
                    1.4,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut
                ),
                {
                    BackgroundTransparency = 0.84,
                    Size = UDim2.fromOffset(
                        Size + 15,
                        Size + 15
                    )
                }
            )

            A:Play()
            A.Completed:Wait()

            if not Holder.Parent then
                break
            end

            local B = TweenService:Create(
                Glow,
                TweenInfo.new(
                    1.4,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut
                ),
                {
                    BackgroundTransparency = 0.68,
                    Size = UDim2.fromOffset(
                        Size + 10,
                        Size + 10
                    )
                }
            )

            B:Play()
            B.Completed:Wait()
        end
    end)

    return Holder
end

return MoonIcon
