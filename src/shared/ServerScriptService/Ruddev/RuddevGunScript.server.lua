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

local DataStore2 = require(ServerScriptService.Vendor.DataStore2)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)

local GiveQuest = ServerStorage.Events.GiveQuest

DataStore2.Combine("DATA", "DamageDealt", "ZombiesKilled")

-- variables

local shots = {}

local cancels = {}

-- functions

-- events

REMOTES.Reload.OnServerEvent:connect(function(player)
	local character = player.Character

	if character and character.Humanoid.Health > 0 then
		local item = character:WaitForChild("Gun")
		local config = CONFIG:GetConfig(item)
		local itemAmmo = item.Ammo

		local ourTick = (cancels[item] or 0) + 1
		cancels[item] = ourTick

		local magazine = config.Magazine

		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player then
				REMOTES.Effect:FireClient(p, "Reload", item)
			end
		end

		local start = tick()
		local elapsed

		repeat
			elapsed = tick() - start
			RunService.Stepped:wait()
		until elapsed >= config.ReloadTime or cancels[item] ~= ourTick

		local needed = magazine - itemAmmo.Value
		if elapsed >= config.ReloadTime then
			itemAmmo.Value = itemAmmo.Value + needed
		end

		cancels[item] = cancels[item] + 1
	end
end)

local function hit(player, hit, index)
	local shot = shots[player]

	if shot then
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
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
								damage = (1 / config.FireRate)
									* config.ScaleBuff
									* damageReceivedScale.Value
									* 100
							end

							DAMAGE:Damage(humanoid, damage, player, config.CritChance, lyingDamage)

							if humanoid.Health <= 0 then
								if hit.Name == "Head" then
									humanoid.Parent.Head.Transparency = 1
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
			end
		end
	end
end

-- REMOTES.Hit.OnServerEvent:connect(hit)

REMOTES.Shoot.OnServerEvent:connect(function(player, position, directions, hits)
	if shots[player] then
		shots[player] = nil
	end

	local character = player.Character
	local rootPart = character.HumanoidRootPart

	local item = character:WaitForChild("Gun")

	if (rootPart.Position - position).Magnitude < 15 then
		local ammo = item.Ammo
		local config = CONFIG:GetConfig(item)

		if #directions == config.ShotSize then
			if ammo.Value > 0 then
				if not ReplicatedStorage.CurrentPowerup.Value:match("Bulletstorm/") then
					ammo.Value = ammo.Value - 1
				end

				for i, dir in pairs(directions) do
					directions[i] = dir.Unit
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
						REMOTES.Effect:FireClient(other, "Shoot", item, position, directions)
					end
				end
			end
		end
	end

	if not ReplicatedStorage.HubWorld.Value then
		local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
		if Dungeon.GetDungeonData("Gamemode") == "Boss" and shots[player] then
			shots[player].Directions = { shots[player].Directions[1] }
			hits = { hits[1] }
		end
	end

	for _, hitMark in pairs(hits) do
		hit(player, unpack(hitMark))
	end
end)

Players.PlayerRemoving:connect(function(player)
	if shots[player] then
		shots[player] = nil
	end
end)