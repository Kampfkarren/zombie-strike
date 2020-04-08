local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loot = require(ReplicatedStorage.Core.Loot)
local SelectScreen = require(script.Parent.SelectScreen)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

local ITEMS_TO_CREATE = 15

local function makeArmor()
	return {
		Type = "Armor",
		Level = math.random(1, 40),
		Rarity = math.random(1, 5),

		Upgrades = math.random(0, 5),
		Favorited = false,

		Model = math.random(1, 30),
		UUID = HttpService:GenerateGUID(false):gsub("-", ""),
	}
end

return function(target)
	local inventory = {}

	for _ = 1, ITEMS_TO_CREATE do
		table.insert(inventory, makeArmor())
	end

	local handle = Roact.mount(
		e("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Size = UDim2.fromScale(1, 1),
		}, {
			e(SelectScreen, {
				Angle = Vector3.new(-1, 0.8, -1),
				Equipped = inventory[2],
				Inventory = inventory,
				Text = "an armor",

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
