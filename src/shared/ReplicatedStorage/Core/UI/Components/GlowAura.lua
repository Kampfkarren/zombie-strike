local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local GLOW_TRANSPARENCY = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.03, 0.38125),
	NumberSequenceKeypoint.new(0.1079, 0.23125),
	NumberSequenceKeypoint.new(0.8955, 0.45625),
	NumberSequenceKeypoint.new(1, 1)
})

local ROTATION_INTERVAL = 15
local STEPS = 11

local function GlowLine(props)
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = props.Color or Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Rotation = props.Rotation,
		Size = UDim2.fromScale(0.08, 1),
	}, {
		UIGradient = e("UIGradient", {
			Color = ColorSequence.new(Color3.new(1, 1, 1)),
			Rotation = -90,
			Transparency = GLOW_TRANSPARENCY,
		}),
	})
end

local function GlowAura(props)
	local children = {}

	for index = 0, STEPS do
		table.insert(children, e(GlowLine, {
			Color = props.Color,
			Rotation = ROTATION_INTERVAL * index,
		}))
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, children)
end

return GlowAura
