-- services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- constants

local REMOTES = ReplicatedStorage.RuddevRemotes
local MODULES = ReplicatedStorage:WaitForChild("RuddevModules")
	local CONFIG = require(MODULES.Config)
	local DAMAGE = require(MODULES.Damage)

-- variables

local shots = {}

local cancels = {}

-- functions

-- events

REMOTES.Reload.OnServerEvent:connect(function(player)
	local character = player.Character

	if character then
		local item = character:WaitForChild("Gun")
		local config = CONFIG:GetConfig(item)
		local itemAmmo = item.Ammo

		if cancels[item] then
			cancels[item] = nil
		end
		local magazine = config.Magazine

		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player then
				REMOTES.Effect:FireClient(p, "Reload", item)
			end
		end

		local needed = magazine - itemAmmo.Value
		local start = tick()
		local elapsed

		repeat
			elapsed = tick() - start
			RunService.Stepped:wait()
		until elapsed >= config.ReloadTime or cancels[item]

		if elapsed >= config.ReloadTime then
			itemAmmo.Value = itemAmmo.Value + needed
		end

		if cancels[item] then
			cancels[item] = nil
		end
	end
end)

REMOTES.Hit.OnServerEvent:connect(function(player, hit, index)
	spawn(function() -- spawn to avoid race conditions
		local shot = shots[player]

		if shot then
			local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid then
				if DAMAGE:PlayerCanDamage(player, humanoid) then
					local position = shot.Position
					local direction = shot.Directions[index]
					local config = shot.Config

					if direction then
						local ray = Ray.new(position, direction)
						local distance = (hit.Position - position).Magnitude
						local ignore = {}

						for _, p in pairs(Players:GetPlayers()) do
							if p.Character then
								table.insert(ignore, p.Character)
							end
						end

						--local h = Raycast(position, direction.Unit * distance, ignore)

						if distance <= config.Range then --and (not h) then
							local offset = ray:Distance(hit.Position)
							if offset < 15 then
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
									DAMAGE:Damage(humanoid, damage, player)

									local otherPlayer = Players:GetPlayerFromCharacter(humanoid.Parent)
									if otherPlayer then
										REMOTES.HitIndicator:FireClient(otherPlayer, direction, damage)
									end

									if humanoid.Health <= 0 then
										if hit.Name == "Head" then
											humanoid.Parent.Head.Transparency = 1
										end

										for _, part in pairs(humanoid.Parent:GetChildren()) do
											if part:IsA("BasePart") then
												part.Velocity = direction * config.Damage
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end)
end)

REMOTES.Shoot.OnServerEvent:connect(function(player, position, directions)
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
				ammo.Value = ammo.Value - 1
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
				cancels[item] = true

				for _, other in pairs(Players:GetPlayers()) do
					if other ~= player then
						REMOTES.Effect:FireClient(other, "Shoot", item, position, directions)
					end
				end
			end
		end
	end
end)

Players.PlayerRemoving:connect(function(player)
	if shots[player] then
		shots[player] = nil
	end
end)