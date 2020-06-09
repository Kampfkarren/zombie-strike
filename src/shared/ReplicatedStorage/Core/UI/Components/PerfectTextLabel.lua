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

	assert(props.Text ~= nil, "Text is nil")
	assert(props.TextSize ~= nil, "TextSize is nil")
	assert(props.Font ~= nil, "Font is nil")

	local textSize = TextService:GetTextSize(
		props.Text,
		props.TextSize,
		props.Font,
		Vector2.new(props.MaxWidth or math.huge, math.huge)
	) + Vector2.new(2, 2)

	local textSizeY = textSize.Y
	if props.MaxHeight ~= nil then
		textSizeY = math.min(textSize.Y, props.MaxHeight)
	end

	props.MaxWidth = nil
	props.BackgroundTransparency = 1
	props.Size = UDim2.new(
		UDim.new(0, textSize.X),
		props.ForceY or UDim.new(0, textSizeY)
	)
	props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center

	props.ForceY = nil
	props.MaxHeight = nil

	if props.RenderParent then
		local renderParent = props.RenderParent
		props.RenderParent = nil
		return renderParent(e("TextLabel", props), props.Size)
	else
		return e("TextLabel", props)
	end
end

return PerfectTextLabel
