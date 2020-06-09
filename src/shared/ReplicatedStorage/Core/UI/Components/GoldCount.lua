local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FormatNumber = require(ReplicatedStorage.Core.FormatNumber)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local ImageCap = require(ReplicatedStorage.Assets.Tarmac.UI.cap)
local ImagePanel2 = require(ReplicatedStorage.Assets.Tarmac.UI.panel2)

local e = Roact.createElement

local GOLD_FONT_SIZE = 45
local GOLD_PADDING_LEFT = 60
local GOLD_PADDING_RIGHT = 36

local function GoldCount(props)
	local goldText = FormatNumber(props.gold)

	return e(PerfectTextLabel, {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		LayoutOrder = 1,
		Position = UDim2.new(0, GOLD_PADDING_LEFT - GOLD_PADDING_RIGHT, 0.5, 0),
		Text = goldText,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = GOLD_FONT_SIZE,

		RenderParent = function(element, size)
			return e("ImageLabel", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = ImagePanel2,
				Position = UDim2.fromScale(1, 0),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(13, 10, 369, 82),
				Size = UDim2.new(0, size.X.Offset
					+ GOLD_PADDING_LEFT
					+ GOLD_PADDING_RIGHT, 1, 0),
			}, {
				UIGradient = e("UIGradient", {
					Color = ColorSequence.new(
						Color3.fromRGB(255, 66, 66),
						Color3.fromRGB(255, 116, 116)
					),

					Rotation = 90,
				}),

				GoldText = element,
				GoldIcon = e("ImageLabel", {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					Image = ImageCap,
					Position = UDim2.new(1, -5, 0, 0),
					Size = UDim2.fromScale(1, 1),
				}, {
					e("UIAspectRatioConstraint"),
				}),
			})
		end,
	})
end

return RoactRodux.connect(function(state)
	return {
		gold = state.gold,
	}
end)(GoldCount)
