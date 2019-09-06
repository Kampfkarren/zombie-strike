local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Libraries.Data)

local InventoryUtil = {}

function InventoryUtil.RemoveItems(player, indexes, dontSet)
	local inventory, inventoryStore = Data.GetPlayerData(player, "Inventory")

	local equipped = {}

	for equippable in pairs(Data.Equippable) do
		local item = Data.GetPlayerData(player, equippable)
		equipped[equippable] = item.UUID
	end

	local indexSet = {}

	for _, index in pairs(indexes) do
		indexSet[index] = true
	end

	local newInventory = {}

	for index, item in pairs(inventory) do
		if not indexSet[index] then
			table.insert(newInventory, item)
		end
	end

	inventory = newInventory

	local uuidByPosition = {}

	for index, item in pairs(inventory) do
		uuidByPosition[item.UUID] = index
	end

	for equippable, id in pairs(equipped) do
		local _, store = Data.GetPlayerData(player, "Equipped" .. equippable)
		store:Set(uuidByPosition[id])
	end

	if not dontSet then
		inventoryStore:Set(inventory)
	end

	return inventory, inventoryStore
end

return InventoryUtil
