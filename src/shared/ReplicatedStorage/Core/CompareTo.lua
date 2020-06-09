local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loot = require(ReplicatedStorage.Core.Loot)

local function CompareTo(equipment, loot)
	if Loot.IsWeapon(loot) then
		return equipment.equippedWeapon
	elseif Loot.IsArmor(loot) then
		return equipment.equippedArmor
	elseif Loot.IsHelmet(loot) then
		return equipment.equippedHelmet
	elseif Loot.IsPet(loot) then
		return equipment.equippedPet or loot
	end

	return loot
end

return CompareTo
