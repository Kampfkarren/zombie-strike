local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local Loot = require(ReplicatedStorage.Core.Loot)
local State = require(ReplicatedStorage.State)

local UpdateEquipped = ReplicatedStorage.Remotes.UpdateEquipped

UpdateEquipped.OnClientEvent:connect(function(armor, helmet, weapon)
	for key, value in pairs({
		Armor = armor,
		Helmet = helmet,
		Weapon = weapon,
	}) do
		local item = Loot.Deserialize(value)

		if item.Type ~= "Helmet" and item.Type ~= "Armor" then
			for key, value in pairs(GunScaling.BaseStats(item.Type, item.Level, item.Rarity)) do
				if item[key] == nil then
					item[key] = value
				end
			end
		end

		Data.SetLocalPlayerData(key, item)
	end

	State:dispatch({
		type = "RefreshEquipment",
	})
end)
