local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Damage = require(ReplicatedStorage.RuddevModules.Damage)
local Data = require(ReplicatedStorage.Core.Data)
local LineOfSight = require(ReplicatedStorage.Libraries.LineOfSight)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)
local PetsDictionary = require(ReplicatedStorage.Core.PetsDictionary)

local PetFire = ReplicatedStorage.Remotes.PetFire

local PET_RANGE = 90

Players.PlayerAdded:connect(function(player)
	local pets = Data.GetPlayerData(player, "Pets")
	local petIndex = pets[2]
	local rarityIndex = pets[3]

	if not petIndex then return end

	local rarity = assert(PetsDictionary.Rarities[rarityIndex], "rarity does not exist")

	local function tryFire()
		-- PetFire:FireAllClients(player.Character, pet)
		local character = player.Character

		if character then
			local closest = { nil, PET_RANGE }
			local rootPosition = character.PrimaryPart.Position

			for _, zombie in pairs(CollectionService:GetTagged("Zombie")) do
				local zombieRoot = zombie.PrimaryPart
				local dist = (zombieRoot.Position - rootPosition).Magnitude

				if dist <= closest[2]
					and Damage:PlayerCanDamage(player, zombie.Humanoid)
					and LineOfSight(
						rootPosition,
						zombie,
						PET_RANGE,
						{ character }
					)
				then
					closest = { zombie, dist }
				end
			end

			if closest[1] then
				local zombie = closest[1]

				Damage:Damage(
					zombie.Humanoid,
					zombie.Humanoid.MaxHealth * rarity.Damage,
					player,
					0
				)

				PetFire:FireAllClients(player, zombie)
			end
		end

		if player:IsDescendantOf(game) then
			RealDelay(rarity.FireRate, tryFire)
		end
	end

	RealDelay(rarity.FireRate, tryFire)
end)
