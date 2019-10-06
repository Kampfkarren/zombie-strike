local ReplicatedStorage = game:GetService("ReplicatedStorage")

local assign = require(ReplicatedStorage.Core.assign)
local Close = require(script.Parent.Close)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Shop = require(script.Shop)

local e = Roact.createElement

local function Store(props)
	return e("Frame", {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(232, 67, 147),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Visible = props.open,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.6, 0, 0.7, 0),
		ZIndex = 3,
	}, {
		e("UIAspectRatioConstraint", {
			AspectRatio = 2,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}),

		Close = e(Close, {
			onClose = props.close,
		}),

		Shop = e(Shop),
	})
end

return RoactRodux.connect(
	function(state)
		return assign({
			open = state.page.current == "Store",
		}, state.store)
	end,

	function(dispatch)
		return {
			close = function()
				dispatch({
					type = "ToggleStore",
				})
			end,
		}
	end
)(Store)
