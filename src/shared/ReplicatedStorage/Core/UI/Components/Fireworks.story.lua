local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fireworks = require(script.Parent.Fireworks)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

return function(target)
	local handle = Roact.mount(
		e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.6, 0.6),
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint"),

			Fireworks = e(Fireworks, {
				ParticleColor = Color3.new(1, 0, 0),
			}),
		}), target, "Fireworks"
	)

	return function()
		Roact.unmount(handle)
	end
end
