local Upgrades = {}

Upgrades.MaxUpgrades = 5

Upgrades.ArmorBuff = 0.06
Upgrades.DamageBuff = 0.06

local UPGRADE_COSTS_ARMOR = { 500, 1000, 2000, 2500, 3500 }
local UPGRADE_COSTS_PERKS = {
	Common = { 1500, 2000, 3500 },
	Legendary = { 2500, 3000, 5000 },
}

function Upgrades.GetArmorBuff(base, upgrades)
	return base * (Upgrades.ArmorBuff * upgrades)
end

function Upgrades.GetRegenBuff(base, upgrades)
	return base * (Upgrades.ArmorBuff * upgrades)
end

function Upgrades.GetDamageBuff(base, upgrades)
	return base * (Upgrades.DamageBuff * upgrades)
end

function Upgrades.CostToUpgrade(item)
	return UPGRADE_COSTS_ARMOR[item.Upgrades + 1]
end

function Upgrades.CostToUpgradePerk(perk)
	if perk.Perk.LegendaryPerk then
		return UPGRADE_COSTS_PERKS.Legendary[perk.Upgrades + 1]
	else
		return UPGRADE_COSTS_PERKS.Common[perk.Upgrades + 1]
	end
end

return Upgrades
