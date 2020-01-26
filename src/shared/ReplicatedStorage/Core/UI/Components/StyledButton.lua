local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assign = require(ReplicatedStorage.Core.assign)
local None = require(ReplicatedStorage.Core.None)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local IMAGE_RECTANGLE = "rbxassetid://3973353234"
local IMAGE_SQUARE = "rbxassetid://3973353646"

local StyledButton = Roact.PureComponent:extend("StyledButton")

function StyledButton:init()
	self.ref = Roact.createRef()
end

function StyledButton:didMount()
	local value = self.ref:getValue()
	if value then
		CollectionService:AddTag(value, "UIClick")
	end
end

function StyledButton:render()
	local props = self.props

	if props[Roact.Ref] then
		self.ref = props[Roact.Ref]
	end

	return e("ImageButton", assign(props, {
		BackgroundTransparency = 1,
		Image = props.Square and IMAGE_SQUARE or IMAGE_RECTANGLE,
		ImageColor3 = props.BackgroundColor3,
		Square = None,
		[Roact.Ref] = self.ref,
	}))
end

return StyledButton
