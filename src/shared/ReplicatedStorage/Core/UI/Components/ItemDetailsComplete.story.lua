local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemDetailsComplete = require(script.Parent.ItemDetailsComplete)
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
			Perk = Perks.Perks[4],
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
			Size = UDim2.new(0, 400, 1, 0),
		}, {
			Item = e(ItemDetailsComplete, {
				CompareTo = WEAPON,
				IconSize = 36,
				Item = WEAPON,
				ShowGearScore = true,
			}),
		}), target, "ItemDetailsComplete"
	)

	return function()
		Roact.unmount(handle)
	end
end

