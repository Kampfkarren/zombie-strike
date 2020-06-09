local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Counter = require(ReplicatedStorage.Core.UI.Components.Counter)
local Data = require(ReplicatedStorage.Core.Data)
local ItemModel = require(ReplicatedStorage.Core.UI.Components.ItemModel)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local IMAGE_TYPES = {
	Face = function(item)
		return item.Instance.Texture
	end,

	Spray = function(item)
		return item.Image
	end,

	Particle = function(item)
		return item.Image.Texture
	end,
}

local ItemImage = Roact.Component:extend("ItemImage")

function ItemImage:shouldUpdate(nextProps)
	if nextProps.Item == self.props.Item then
		return false
	end

	return true
end

function ItemImage:render()
	local props = self.props

	if IMAGE_TYPES[props.Item.Type] then
		local image = IMAGE_TYPES[props.Item.Type](props.Item)

		return e(Counter, {
			Render = function(total)
				return e("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = image,
					Position = total:map(function(total)
						return UDim2.fromScale(0.5, 0.5 + math.sin(total) * 1 / 20)
					end),
					Size = UDim2.fromScale(1, 1),
				}, {
					UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
				})
			end,
		})
	else
		return e(ItemModel, {
			Angle = props.Angle,
			Distance = props.Distance,
			Model = Data.GetModel(props.Item),
			SpinSpeed = props.SpinSpeed,
		}, props[Roact.Children])
	end
end

return ItemImage
