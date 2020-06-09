local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)
local Tagged = require(ReplicatedStorage.Core.UI.Components.Tagged)

local e = Roact.createElement

local function Close(props)
	return e(Tagged, {
		Tag = "UIClick",
	}, {
		e("ImageButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://1249929622",
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0.4, 0, 0.2, 0),
			ZIndex = props.ZIndex,
			[Roact.Event.Activated] = props.onClose,
		}, {
			e("UIAspectRatioConstraint"),
		})
	})
end

return Close
