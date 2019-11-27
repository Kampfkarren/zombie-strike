local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assign = require(ReplicatedStorage.Core.assign)
local None = require(ReplicatedStorage.Core.None)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local IMAGE_RECTANGLE = "rbxassetid://3973353234"
local IMAGE_SQUARE = "rbxassetid://3973353646"

local function StyledButton(props)
	return e("ImageButton", assign(props, {
		BackgroundTransparency = 1,
		Image = props.Square and IMAGE_SQUARE or IMAGE_RECTANGLE,
		ImageColor3 = props.BackgroundColor3,
		Square = None,
	}))
end

return StyledButton
