local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local Loot = require(ReplicatedStorage.Core.Loot)

local UpdateEquipped = ReplicatedStorage.Remotes.UpdateEquipped

UpdateEquipped.OnClientEvent:connect(function(armor, helmet, weapon)
	for key, value in pairs({
		Armor = armor,
		Helmet = helmet,
		Weapon = weapon,
	}) do
		Data.SetLocalPlayerData(key, Loot.Deserialize(value))
	end
end)
