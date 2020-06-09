local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuyCaps = require(ReplicatedStorage.Components.BuyCaps)
local Close = require(ReplicatedStorage.Core.UI.Components.Close)
local FormatNumber = require(ReplicatedStorage.Core.FormatNumber)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

local BuyCapsModal = Roact.Component:extend("BuyCaps")

function BuyCapsModal:init()
	self.ref = Roact.createRef()
end

function BuyCapsModal:render()
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.8, 0.9),
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 2,
		}),

		BuyCaps = e(BuyCaps, {
			[Roact.Ref] = self.ref,
			ConfirmPromptScale = 2.3,
			remote = ReplicatedStorage.Remotes.BuyCaps,
		}),

		Close = e(Close, {
			onClose = self.props.onClose,
		}),

		BrainsCount = e("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = 2,
			Position = UDim2.fromScale(0.95, 0.01),
			Size = UDim2.new(0.2, 0, 0, 45),
			Text = FormatNumber(self.props.brains) .. "🧠",
			TextColor3 = Color3.fromRGB(255, 205, 248),
			TextSize = 45,
			TextXAlignment = Enum.TextXAlignment.Right,
		}),
	})
end

return RoactRodux.connect(function(state)
	return {
		brains = state.brains,
	}
end)(BuyCapsModal)
