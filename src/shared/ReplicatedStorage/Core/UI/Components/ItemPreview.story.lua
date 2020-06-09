local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemPreview = require(script.Parent.ItemPreview)
local Perks = require(ReplicatedStorage.Core.Perks)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local WEAPON = {
	Type = "Rifle",
	Level = 1,
	Rarity = 5,

	Bonus = 0,
	Favorited = false,
	Seed = 0,

	Perks = {
		{
			Perk = Perks.Perks[1],
			Upgrades = 0,
		},

		{
			Perk = Perks.Perks[2],
			Upgrades = 0,
		},

		{
			Perk = Perks.Perks[3],
			Upgrades = 0,
		},

		{
			Perk = Perks.Perks[23],
			Upgrades = 0,
		},
	},

	Model = 5,
	UUID = HttpService:GenerateGUID(false):gsub("-", ""),
}

return function(target)
	local handle = Roact.mount(
		e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			Item = e(ItemPreview, {
				Item = WEAPON,
				Name = "Weapon",
				ShowGearScore = true,
			}),

			ItemSquare = e("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 170),
				Size = UDim2.fromOffset(420, 420),
			}, {
				Item = e(ItemPreview, {
					CenterWeapon = true,
					FrameSize = UDim2.fromScale(1, 1),
					Item = WEAPON,
					Name = "Weapon",
					ShowGearScore = true,
				}),
			}),
		}), target, "ItemPreview"
	)

	return function()
		Roact.unmount(handle)
	end
end

