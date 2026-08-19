--// MoonHub Custom Icon
--// No Roblox image asset required

local MoonIcon = {}

MoonIcon.Name = "Moon"

MoonIcon.Color = Color3.fromRGB(190, 145, 255)
MoonIcon.GlowColor = Color3.fromRGB(145, 80, 255)

function MoonIcon.Create(Parent, Size, Position)

    if not Parent then
        return nil
    end

    Size = Size or 24
    Position = Position or UDim2.fromOffset(8, 8)

    local Holder = Instance.new("Frame")
    Holder.Name = "MoonHub_CustomMoon"
    Holder.BackgroundTransparency = 1
    Holder.BorderSizePixel = 0
    Holder.Size = UDim2.fromOffset(Size + 16, Size + 16)
    Holder.Position = Position
    Holder.ZIndex = 50
    Holder.Parent = Parent

    ---------------------------------------------------------
    -- PURPLE GLOW
    ---------------------------------------------------------

    local Glow = Instance.new("Frame")
    Glow.Name = "Glow"
    Glow.AnchorPoint = Vector2.new(0.5, 0.5)
    Glow.Position = UDim2.fromScale(0.5, 0.5)
    Glow.Size = UDim2.fromOffset(Size + 12, Size + 12)
    Glow.BackgroundColor3 = MoonIcon.GlowColor
    Glow.BackgroundTransparency = 0.72
    Glow.BorderSizePixel = 0
    Glow.ZIndex = 49
    Glow.Parent = Holder

    local GlowCorner = Instance.new("UICorner")
    GlowCorner.CornerRadius = UDim.new(1, 0)
    GlowCorner.Parent = Glow

    ---------------------------------------------------------
    -- MOON
    ---------------------------------------------------------

    local Moon = Instance.new("Frame")
    Moon.Name = "Moon"
    Moon.AnchorPoint = Vector2.new(0.5, 0.5)
    Moon.Position = UDim2.fromScale(0.5, 0.5)
    Moon.Size = UDim2.fromOffset(Size, Size)
    Moon.BackgroundColor3 = MoonIcon.Color
    Moon.BorderSizePixel = 0
    Moon.ZIndex = 51
    Moon.Parent = Holder

    local MoonCorner = Instance.new("UICorner")
    MoonCorner.CornerRadius = UDim.new(1, 0)
    MoonCorner.Parent = Moon

    ---------------------------------------------------------
    -- SOFT HIGHLIGHT
    ---------------------------------------------------------

    local Highlight = Instance.new("Frame")
    Highlight.Name = "Highlight"
    Highlight.AnchorPoint = Vector2.new(0.5, 0.5)
    Highlight.Position = UDim2.fromScale(0.38, 0.34)
    Highlight.Size = UDim2.fromOffset(Size * 0.22, Size * 0.22)
    Highlight.BackgroundColor3 = Color3.fromRGB(245, 235, 255)
    Highlight.BackgroundTransparency = 0.15
    Highlight.BorderSizePixel = 0
    Highlight.ZIndex = 52
    Highlight.Parent = Moon

    local HighlightCorner = Instance.new("UICorner")
    HighlightCorner.CornerRadius = UDim.new(1, 0)
    HighlightCorner.Parent = Highlight

    ---------------------------------------------------------
    -- SMALL CRATERS
    ---------------------------------------------------------

    local function Crater(X, Y, S, Transparency)

        local C = Instance.new("Frame")

        C.Name = "Crater"
        C.AnchorPoint = Vector2.new(0.5, 0.5)
        C.Position = UDim2.fromScale(X, Y)
        C.Size = UDim2.fromOffset(S, S)

        C.BackgroundColor3 =
            Color3.fromRGB(125, 88, 185)

        C.BackgroundTransparency =
            Transparency or 0.35

        C.BorderSizePixel = 0
        C.ZIndex = 52
        C.Parent = Moon

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(1, 0)
        Corner.Parent = C
    end

    Crater(0.68, 0.30, Size * 0.16, 0.35)
    Crater(0.30, 0.63, Size * 0.13, 0.4)
    Crater(0.70, 0.70, Size * 0.10, 0.45)

    ---------------------------------------------------------
    -- OUTLINE
    ---------------------------------------------------------

    local Stroke = Instance.new("UIStroke")

    Stroke.Name = "MoonStroke"
    Stroke.Color = Color3.fromRGB(220, 190, 255)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.15
    Stroke.Parent = Moon

    ---------------------------------------------------------
    -- GLOW ANIMATION
    ---------------------------------------------------------

    task.spawn(function()

        while Holder.Parent do

            local TweenService =
                game:GetService("TweenService")

            local Tween =
                TweenService:Create(
                    Glow,
                    TweenInfo.new(
                        1.5,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),
                    {
                        BackgroundTransparency = 0.84,
                        Size =
                            UDim2.fromOffset(
                                Size + 16,
                                Size + 16
                            )
                    }
                )

            Tween:Play()
            Tween.Completed:Wait()

            if not Holder.Parent then
                break
            end

            local Tween2 =
                TweenService:Create(
                    Glow,
                    TweenInfo.new(
                        1.5,
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ),
                    {
                        BackgroundTransparency = 0.70,
                        Size =
                            UDim2.fromOffset(
                                Size + 12,
                                Size + 12
                            )
                    }
                )

            Tween2:Play()
            Tween2.Completed:Wait()
        end
    end)

    return Holder
end

return MoonIcon
