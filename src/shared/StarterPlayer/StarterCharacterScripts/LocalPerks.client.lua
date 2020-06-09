local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.RuddevModules.Config)
local LocalAmmoInfo = require(ReplicatedStorage.Core.LocalAmmoInfo)
local Perks = require(ReplicatedStorage.Core.Perks)

local LocalPlayer = Players.LocalPlayer

local character = LocalPlayer.Character

local lastKnownPerks = {}

local function updatePerks()
	local newPerks = {}

	local weapon = character:FindFirstChild("Gun")

	if weapon ~= nil then
		local config = Config:GetConfig(weapon)
		for _, perk in ipairs(config.Perks) do
			if Perks.PerkInScope(perk.Perk) then
				table.insert(newPerks, {
					-- I do not believe this is a 1:1 type conversion
					Item = config,
					GunType = config.GunType,
					PerkClass = perk.Perk,
					Seed = config.Seed,
					Upgrades = perk.Upgrades,
				})
			end
		end
	end

	-- If our perks haven't changed, move on
	if #newPerks == #lastKnownPerks then
		local identical = true
		for index, currentPerk in ipairs(lastKnownPerks) do
			local newPerk = newPerks[index]

			if newPerk.GunType ~= currentPerk.GunType
				or newPerk.PerkClass ~= currentPerk.PerkClass
			then
				identical = false
				break
			end
		end

		if identical then
			return
		end
	end

	for _, lastKnownPerk in ipairs(lastKnownPerks) do
		lastKnownPerk.Instance:Destroy()
	end

	local instances = {}
	for _, perk in ipairs(newPerks) do
		local instance = perk.PerkClass.new(LocalPlayer, perk.Seed, perk.Upgrades, perk.Item)
		instance.AmmoInfo = LocalAmmoInfo
		perk.Instance = instance
		table.insert(instances, instance)
	end

	lastKnownPerks = newPerks
	Perks.SetPerksFor(LocalPlayer, instances)
end

ReplicatedStorage.Remotes.Critted.OnClientEvent:connect(function()
	for _, perk in ipairs(Perks.GetPerksFor(LocalPlayer)) do
		perk:Critted()
	end
end)

character.ChildAdded:connect(updatePerks)
character.ChildRemoved:connect(updatePerks)
updatePerks()
