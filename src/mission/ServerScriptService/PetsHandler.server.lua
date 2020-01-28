local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Damage = require(ReplicatedStorage.RuddevModules.Damage)
local Data = require(ReplicatedStorage.Core.Data)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local Interval = require(ReplicatedStorage.Core.Interval)
local LineOfSight = require(ReplicatedStorage.Libraries.LineOfSight)
local PetsDictionary = require(ReplicatedStorage.Core.PetsDictionary)

local PetFire = ReplicatedStorage.Remotes.PetFire

local BOSS_DAMAGE_SCALE = 1 / 15
local BOSS_GAMEMODE_DAMAGE_SCALE = 1 / 450
local COINS_PER_INTERVAL = 5
local COINS_INTERVAL = 10
local PET_RANGE = 90

local boss

CollectionService:GetInstanceAddedSignal("Boss"):connect(function(newBoss)
	boss = newBoss
end)

Interval(COINS_INTERVAL, function()
	for _, player in ipairs(Players:GetPlayers()) do
		local _, petCoinsStore = Data.GetPlayerData(player, "PetCoins")
		petCoinsStore:Increment(COINS_PER_INTERVAL)
	end
end)

Players.PlayerAdded:connect(function(player)
	local pet = Data.GetPlayerData(player, "Pet")
	if not pet then return end

	local rarityIndex = pet.Rarity

	local rarity = assert(PetsDictionary.Rarities[rarityIndex], "rarity does not exist")

	local function tryFire()
		local character = player.Character

		if character then
			local closest = { nil, PET_RANGE }
			local rootPosition = character.PrimaryPart.Position

			for _, zombie in pairs(CollectionService:GetTagged("Zombie")) do
				if zombie ~= boss then
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
			end

			local zombie = closest[1]
			local damageScale = 1

			if not zombie and boss and not boss.Humanoid:FindFirstChild("NoKill") then
				zombie = boss

				if Dungeon.GetDungeonData("Gamemode") == "Boss" then
					damageScale = BOSS_GAMEMODE_DAMAGE_SCALE
				else
					damageScale = BOSS_DAMAGE_SCALE
				end
			end

			if zombie then
				local lyingDamage
				if Dungeon.GetDungeonData("Gamemode") == "Boss" then
					lyingDamage = false
				end

				Damage:Damage(
					zombie.Humanoid,
					zombie.Humanoid.MaxHealth * rarity.Damage * damageScale,
					player,
					0,
					lyingDamage
				)

				PetFire:FireAllClients(player, zombie)
			end
		end

		if not player:IsDescendantOf(game) then
			return false
		end
	end

	Interval(1 / rarity.FireRate, tryFire)
end)
