-- services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- constants

local REMOTES = ReplicatedStorage.RuddevRemotes
local MODULES = ReplicatedStorage:WaitForChild("RuddevModules")
	local CONFIG = require(MODULES.Config)
	local DAMAGE = require(MODULES.Damage)

local DamageCalculations = require(ReplicatedStorage.Core.DamageCalculations)
local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local Effects = require(ReplicatedStorage.RuddevModules.Effects)
local GetCharacter = require(ReplicatedStorage.Core.GetCharacter)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local GunSpray = require(ReplicatedStorage.Core.GunSpray)
local Perk = require(ReplicatedStorage.Core.Perks.Perk)
local Perks = require(ReplicatedStorage.Core.Perks)
local Reloading = require(ReplicatedStorage.Core.Reloading)

local GiveQuest = ServerStorage.Events.GiveQuest

DataStore2.Combine("DATA", "DamageDealt", "ZombiesKilled")

-- variables

local shots = {}

local cancels = {}

-- functions

-- events

REMOTES.Reload.OnServerEvent:connect(function(player)
	local character = player.Character

	if character and character.Humanoid.Health > 0 and not Reloading.IsReloading(player) then
		Reloading.SetReloading(player, true)

		local item = character:WaitForChild("Gun")
		local config = CONFIG:GetConfig(item)
		local itemAmmo = item.Ammo

		local reloadTime = config.ReloadTime
		for _, perk in ipairs(Perks.GetPerksFor(player)) do
			reloadTime = perk:ModifyReloadTime(reloadTime)
		end

		local ourTick = (cancels[item] or 0) + 1
		cancels[item] = ourTick

		local magazine = config.Magazine

		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player then
				REMOTES.Effect:FireClient(p, Effects.EffectIDs.Reload, item)
			end
		end

		local start = tick()
		local elapsed

		repeat
			elapsed = tick() - start
			RunService.Stepped:wait()
		until elapsed >= reloadTime or cancels[item] ~= ourTick

		local needed = magazine - itemAmmo.Value
		if elapsed >= reloadTime then
			itemAmmo.Value = itemAmmo.Value + needed

			for _, perk in ipairs(Perks.GetPerksFor(player)) do
				perk:Reloaded(magazine)
			end
		end

		cancels[item] = cancels[item] + 1
		Reloading.SetReloading(player, false)
	end
end)

local function hit(player, hit, index)
	local shot = shots[player]

	if shot then
		local character = GetCharacter(hit)
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if DAMAGE:PlayerCanDamage(player, humanoid) then
				local position = shot.Position
				local direction = shot.Directions[index]
				local config = shot.Config

				if direction then
					local distance = (hit.Position - position).Magnitude
					local ignore = {}

					for _, p in ipairs(Players:GetPlayers()) do
						if p.Character then
							table.insert(ignore, p.Character)
						end
					end

					--local h = Raycast(position, direction.Unit * distance, ignore)
					if distance <= config.Range then --and (not h) then
						if humanoid.Health > 0 then
							shot.Directions[index] = nil
							local numDir = 0
							for _, v in pairs(shot.Directions) do
								if v then
									numDir = numDir + 1
								end
							end
							if numDir == 0 then
								shots[player] = nil
							end

							local damage = DAMAGE:Calculate(shot.Item, hit, position)
							local lyingDamage
							DataStore2("DamageDealt", player):Update(function(damageDealt)
								return math.log10(10 ^ (damageDealt or 0) + damage)
							end)

							local damageReceivedScale = humanoid:FindFirstChild("DamageReceivedScale")
							if damageReceivedScale then
								lyingDamage = damage
								-- damage = (1 / config.FireRate)
								-- 	* config.ScaleBuff
								-- 	* damageReceivedScale.Value
								-- 	* 100

								-- TODO: This is to preserve old behavior
								-- but we might not actually need it for bosses to balanced
								local critlessConfig = {}
								for key, value in pairs(config) do
									critlessConfig[key] = value
								end

								critlessConfig.CritChance = 0

								damage = DamageCalculations.GetDamageNeededForDPS(critlessConfig, damageReceivedScale.Value * 100)
							end

							local shouldCrit = math.random() <= config.CritChance
							local forcedCrit = false

							local tellPlayer = false

							for _, perk in ipairs(Perks.GetPerksFor(player)) do
								perk:DamageDealt(damage, humanoid)
								damage = perk:ModifyDamage(damage, humanoid)

								if shouldCrit then
									perk:Critted(
										forcedCrit and Perk.CritMethod.Forced or Perk.CritMethod.Natural
									)

									-- Only tell the player if any of their perks would actually care
									if perk.Critted ~= Perk.WeaponPerk.Critted
										and perk.Scope ~= Perk.Scope.Server
									then
										tellPlayer = true
									end
								end

								if not forcedCrit then
									local perkCritDecision = perk:ShouldCrit()
									if perkCritDecision ~= Perk.CritDecision.Default then
										shouldCrit = perkCritDecision == Perk.CritDecision.ForceCrit
										forcedCrit = true
									end
								end
							end

							if tellPlayer then
								ReplicatedStorage.Remotes.Critted:FireClient(player)
							end

							DAMAGE:Damage(
								humanoid,
								damage,
								player,
								shouldCrit,
								config.CritDamage,
								lyingDamage
							)

							if humanoid.Health <= 0 then
								if hit.Name == "Head" then
									humanoid.Parent.Head.Transparency = 1
								end

								for _, perk in ipairs(Perks.GetPerksFor(player)) do
									perk:ZombieKilled(humanoid)
								end

								for _, part in ipairs(humanoid.Parent:GetChildren()) do
									if part:IsA("BasePart") then
										part.Velocity = direction * GunScaling.BaseStats(
											shot.Item.WeaponData.Type.Value,
											1, 1
										).Damage
									end
								end

								for _, player in ipairs(Players:GetPlayers()) do
									GiveQuest:Fire(player, "KillZombiesWeapon", 1, function(quest)
										return quest.Args[2] == shot.Item.WeaponData.Type.Value
									end)
								end

								DataStore2("ZombiesKilled", player):Update(function(zombiesKilled)
									return (zombiesKilled or 0) + 1
								end)
							end
						end
					end
				end
			else
				local otherPlayer = Players:GetPlayerFromCharacter(character)
				if otherPlayer ~= nil and otherPlayer ~= player then
					for _, perk in ipairs(Perks.GetPerksFor(player)) do
						perk:TeammateShot(humanoid)
					end
				end
			end
		end
	end
end

-- REMOTES.Hit.OnServerEvent:connect(hit)

REMOTES.Shoot.OnServerEvent:connect(function(player, position, mouseCFrame, hits)
	if shots[player] then
		shots[player] = nil
	end

	local character = player.Character
	local rootPart = character.HumanoidRootPart

	local item = character:WaitForChild("Gun")

	if (rootPart.Position - position).Magnitude < 15 then
		local ammo = item.Ammo
		local config = CONFIG:GetConfig(item)

		if #hits <= config.ShotSize then
			if ammo.Value > 0 then
				if not ReplicatedStorage.CurrentPowerup.Value:match("Bulletstorm/")
					and item.WeaponData.Type.Value ~= "Crystal"
				then
					local ammoCost = 1

					for _, perk in ipairs(Perks.GetPerksFor(player)) do
						ammoCost = perk:ModifyAmmoCost(ammoCost)
					end

					ammo.Value = ammo.Value - math.min(ammo.Value, ammoCost)
				end

				local directions = {}

				for _, dir in pairs(GunSpray(mouseCFrame, config)) do
					table.insert(directions, dir.LookVector.Unit)
				end

				local shot = {
					Item = item;
					Config = config;
					Position = position;
					Directions = directions;
				}

				shots[player] = shot
				cancels[item] = (cancels[item] or 0) + 1

				for _, other in pairs(Players:GetPlayers()) do
					if other ~= player then
						REMOTES.Effect:FireClient(other, Effects.EffectIDs.Shoot, item, position)
					end
				end
			end
		end
	end

	if not ReplicatedStorage.HubWorld.Value then
		local DungeonState = require(ServerScriptService.DungeonState)
		if DungeonState.CurrentGamemode.Scales() and shots[player] then
			shots[player].Directions = { shots[player].Directions[1] }
			hits = { hits[1] }
		end
	end

	for index, hitMark in pairs(hits) do
		hit(player, hitMark, index)
	end
end)

Players.PlayerRemoving:connect(function(player)
	if shots[player] then
		shots[player] = nil
	end
end)