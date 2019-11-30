local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local Close = Roact.PureComponent:extend("Close")

function Close:init()
	self.ref = Roact.createRef()
end

function Close:didMount()
	CollectionService:AddTag(self.ref:getValue(), "UIClick")
end

function Close:render()
	local props = self.props

	return e("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1249929622",
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0.4, 0, 0.2, 0),
		ZIndex = props.ZIndex,
		[Roact.Event.Activated] = props.onClose,
		[Roact.Ref] = self.ref,
	}, {
		e("UIAspectRatioConstraint"),
	})
end

return Close
