local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local Loot = require(ReplicatedStorage.Core.Loot)
local SelectScreen = require(script.Parent.SelectScreen)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local ITEMS_TO_CREATE = 15

local function makeWeapon(giveAttachment, forceType)
	local attachment

	if giveAttachment then
		local rarity = math.random(1, 5)

		attachment = {
			Type = Loot.Attachments[math.random(#Loot.Attachments)],
			Rarity = rarity,

			Favorited = false,

			Model = rarity,
			UUID = HttpService:GenerateGUID(false):gsub("-", ""),

			Upgrades = math.random(0, 5),
		}
	end

	return {
		Type = forceType or GunScaling.RandomClassicType(),
		Level = math.random(1, 40),
		Rarity = math.random(1, 5),

		Bonus = math.random(0, 35),
		Upgrades = math.random(0, 5),
		Favorited = false,

		Model = math.random(1, 5),
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),

		Attachment = attachment,
	}
end

return function(target)
	local inventory = {
		makeWeapon(false, "Crystal"),
	}

	for index = 1, ITEMS_TO_CREATE do
		table.insert(inventory, makeWeapon(index % 3 == 0))
	end

	local handle = Roact.mount(
		e("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.fromScale(1, 1),
		}, {
			e(SelectScreen, {
				Equipped = inventory[2],
				Inventory = inventory,
				Text = "a weapon",

				GetName = Loot.GetLootName,
				GoBack = function() end,
				Equip = function() end,
			})
		}), target, "SelectScreen"
	)

	return function()
		Roact.unmount(handle)
	end
end
