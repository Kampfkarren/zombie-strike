local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local function PerfectTextLabel(props)
	local props = copy(props)
	local textSize = TextService:GetTextSize(
		props.Text,
		props.TextSize,
		props.Font,
		Vector2.new(math.huge, props.TextSize)
	) + Vector2.new(2, 2)

	props.BackgroundTransparency = 1
	props.Size = UDim2.fromOffset(textSize.X, textSize.Y)
	props.TextYAlignment = Enum.TextYAlignment.Top

	return e("TextLabel", props)
end

return PerfectTextLabel
