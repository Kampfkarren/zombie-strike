local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loot = require(ReplicatedStorage.Core.Loot)
local SelectScreen = require(script.Parent.SelectScreen)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement

return function(target)
	local inventory = {}

	for _, attachmentType in ipairs(Loot.Attachments) do
		for rarity = 1, 5 do
			table.insert(inventory, {
				Type = attachmentType,
				Rarity = rarity,

				Favorited = false,

				Model = rarity,
				UUID = HttpService:GenerateGUID(false):gsub("-", ""),
			})
		end
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
				ShowGearScore = false,
				Text = "an attachment",

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
