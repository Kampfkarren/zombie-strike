local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local assign = require(ReplicatedStorage.Core.assign)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)

local e = Roact.createElement

local DEFAULT_PADDING = {
	Left = 0,
	Right = 0,
	Top = 7,
	Bottom = 7,
}

local COMMON_TEXT_COLOR = Color3.fromRGB(57, 57, 57)
local FONT = Enum.Font.Gotham
local TEXT_SIZE = 16

local function Rarity(props)
	local rarity = LootStyles[props.Rarity]
	local size = TextService:GetTextSize(
		rarity.Name,
		TEXT_SIZE,
		FONT,
		Vector2.new(math.huge, TEXT_SIZE)
	) + Vector2.new(2, 2)

	local padding = assign(props.Padding or {}, DEFAULT_PADDING)

	return e("Frame", assign({
		BackgroundColor3 = rarity.Color,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Position = props.Position,
		Size = UDim2.fromOffset(size.X + padding.Left + padding.Right, padding.Top + padding.Bottom + size.Y),
	}, props.Native or {}), assign({
		TextLabel = e("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Font = FONT,
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.new(0, size.X, 1, 0),
			Text = rarity.Name,
			TextColor3 = props.Rarity == 1 and COMMON_TEXT_COLOR or Color3.new(1, 1, 1),
			TextSize = TEXT_SIZE,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		UIPadding = e("UIPadding", {
			PaddingLeft = UDim.new(0, padding.Left),
			PaddingRight = UDim.new(0, padding.Right),
			PaddingTop = UDim.new(0, padding.Top),
			PaddingBottom = UDim.new(0, padding.Bottom),
		}),
	}, props[Roact.Children] or {}))
end

return Rarity
