local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local ImageFloat = require(ReplicatedStorage.Assets.Tarmac.UI.float)

local DEFAULT_PADDING = {
	Horizontal = 50,
	Vertical = 10,
}

local BUTTON_HEIGHT = 30
local BUTTON_GAP = 10
local MAX_WIDTH = 300

local STYLES = {
	Neutral = {
		MinGradient = Color3.fromRGB(120, 120, 120),
		MaxGradient = Color3.fromRGB(120, 120, 120),
	},

	No = {
		MinGradient = Color3.fromRGB(201, 51, 37),
		MaxGradient = Color3.fromRGB(175, 38, 25),
		HoveredMaxGradient = Color3.fromRGB(197, 44, 30),
	},

	Yes = {
		MinGradient = Color3.fromRGB(49, 152, 48),
		MaxGradient = Color3.fromRGB(88, 169, 86),
		HoveredMaxGradient = Color3.fromRGB(120, 238, 118),
	},
}

local function Button(props)
	return e(PerfectTextLabel, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Font = Enum.Font.GothamSemibold,
		Position = UDim2.fromScale(0.5, 0.5),
		Text = props.Text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 24,

		RenderParent = function(element, size)
			return e(GradientButton, {
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 1,
				Image = ImageFloat,
				LayoutOrder = props.LayoutOrder,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(6, 4, 86, 20),
				Size = UDim2.new(0, math.max(size.X.Offset + 25, 80), 1, 0),

				MinGradient = props.MinGradient,
				MaxGradient = props.MaxGradient,
				HoveredMaxGradient = props.HoveredMaxGradient,

				[Roact.Event.Activated] = props.Activated,
			}, {
				Element = element,
			})
		end,
	})
end

local function ConfirmPrompt2(props)
	local buttons = {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for name, button in pairs(props.Buttons) do
		local style = STYLES[button.Style] or {}

		buttons[name] = e(Button, {
			Activated = button.Activated,
			LayoutOrder = button.LayoutOrder,
			Text = button.Text,

			MinGradient = style.MinGradient,
			MaxGradient = style.MaxGradient,
			HoveredMaxGradient = style.HoveredMaxGradient,
		})
	end

	return e(PerfectTextLabel, {
		AnchorPoint = Vector2.new(0.5, 0),
		Font = Enum.Font.GothamSemibold,
		MaxWidth = props.MaxWidth or MAX_WIDTH,
		Position = UDim2.new(0.5, 0, 0, DEFAULT_PADDING.Vertical / 2),
		Text = props.Text,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		TextSize = 26,

		RenderParent = function(element, size)
			return e("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Image = ImageFloat,
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(6, 4, 86, 20),
				Size = size
					+ UDim2.fromOffset(DEFAULT_PADDING.Horizontal, DEFAULT_PADDING.Vertical)
					+ UDim2.fromOffset(0, BUTTON_GAP + BUTTON_HEIGHT),
			}, {
				Text = element,

				Buttons = e("Frame", {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 1, -5),
					Size = UDim2.new(1, 0, 0, BUTTON_HEIGHT),
				}, buttons),

				Gradient = e("UIGradient", {
					Color = ColorSequence.new(
						Color3.fromRGB(65, 65, 65),
						Color3.fromRGB(82, 82, 82)
					),
					Rotation = 90,
				}),

				Scale = props.Scale and e("UIScale", {
					Scale = props.Scale,
				}),
			})
		end,
	})
end

return ConfirmPrompt2
