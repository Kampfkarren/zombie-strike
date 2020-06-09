local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Perks = require(ReplicatedStorage.Core.Perks)
local PerkDetails = require(script.Parent.PerkDetails)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

return function(target)
	local handle = Roact.mount(
		e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			PerkDetails = e(PerkDetails, {
				Perks = {
					{
						Perk = Perks.Perks[1],
						Upgrades = 0,
					},

					{
						Perk = Perks.Perks[23],
						Upgrades = 1,
					},
				},
				Seed = 0,
			}),

			PerkDetailsRenderParent = e(PerkDetails, {
				Perks = {
					{
						Perk = Perks.Perks[1],
						Upgrades = 0,
					},

					{
						Perk = Perks.Perks[23],
						Upgrades = 1,
					},
				},
				Seed = 0,

				RenderParent = function(element, size)
					return e("Frame", {
						Position = UDim2.fromOffset(0, 250),
						Size = size + UDim2.fromOffset(10, 10),
					}, {
						PerkDetails = e("Frame", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.new(1, 0, 0),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = size,
						}, {
							Contents = element,
						}),
					})
				end,
			}),
		}), target, "PerkDetails"
	)

	return function()
		Roact.unmount(handle)
	end
end
