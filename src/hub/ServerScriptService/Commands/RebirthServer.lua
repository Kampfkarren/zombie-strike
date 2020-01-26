local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local MockPlayer = require(ReplicatedStorage.Core.MockData.MockPlayer)

return function(_, player)
	DataStore2("XP", player):Set(0)
	DataStore2("Level", player):Set(1)
	DataStore2("Inventory", player):Set(MockPlayer().Inventory)
	DataStore2("EquippedWeapon", player):Set(1)
	DataStore2("EquippedArmor", player):Set(2)
	DataStore2("EquippedHelmet", player):Set(3)
	DataStore2("EquippedPet", player):Set(nil)
	DataStore2("DungeonsPlayed", player):Set(0)
	DataStore2("Gold", player):Set(0)
	player:Kick("Rejoin pwease :3c")
end
