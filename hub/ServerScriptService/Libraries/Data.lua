local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Loot = require(ReplicatedStorage.Core.Loot)
local MockPlayer = require(ReplicatedStorage.Core.MockData.MockPlayer)

local Data = {}

local equippable = {
	Armor = true,
	Helmet = true,
	Weapon = true,
}

-- TODO: Don't let player in until they load data
function Data.GetPlayerData(player, key)
	if equippable[key] then
		local inventory = Data.GetPlayerData(player, "Inventory")
		local equipped = Data.GetPlayerData(player, "Equipped" .. key)

		return inventory[equipped]
	elseif MockPlayer[key] then
		DataStore2.Combine("DATA", key)

		local dataStore = DataStore2(key, player)

		-- BeforeInitialGet doesn't work well with combined stores
		-- if key == "Inventory" then
			-- dataStore:BeforeInitialGet(Loot.DeserializeTable)
			-- dataStore:BeforeSave(Loot.SerializeTable)
		-- end

		return dataStore:Get(MockPlayer[key])
	else
		error("unknown data key " .. key)
	end
end

return Data
