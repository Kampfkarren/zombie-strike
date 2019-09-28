local Upgrades = {}

Upgrades.GoldBase = 11
Upgrades.GoldScale = 1.262
Upgrades.MaxUpgrades = 5
Upgrades.UpgradeTax = 1.1

Upgrades.ArmorBuff = 0.05
Upgrades.DamageBuff = 0.05

function Upgrades.GetArmorBuff(base, upgrades)
	return base * (Upgrades.ArmorBuff * upgrades)
end

function Upgrades.GetDamageBuff(base, upgrades)
	return base * (Upgrades.DamageBuff * upgrades)
end

function Upgrades.CostToUpgrade(item)
	return math.floor((Upgrades.GoldBase * Upgrades.GoldScale ^ (item.Level - 1))
		* (Upgrades.UpgradeTax ^ item.Upgrades))
end

return Upgrades
