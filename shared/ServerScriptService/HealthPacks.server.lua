local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Libraries.Data)
local Equip = require(ServerScriptService.Shared.Ruddev.Equip)

local HealthPackAnimation = ReplicatedStorage.Assets.Animations.HealthPackAnimation

local COOLDOWN = 10
local HEAL_AMOUNT = 0.3

local healthPackCooldowns = {}

ReplicatedStorage.Remotes.HealthPack.OnServerEvent:connect(function(player)
	local character = player.Character
	if not character or character.Humanoid.Health <= 0 then return end

	if tick() - (healthPackCooldowns[player] or 0) > COOLDOWN then
		healthPackCooldowns[player] = tick()

		local healthPack = ReplicatedStorage.Items[
			"HealthPack" .. Data.GetPlayerData(
				player,
				"EquippedHealthPack"
			)
		]:Clone()

		healthPack.Parent = character
		Equip(healthPack, character.LeftHand)

		local humanoid = character.Humanoid
		local animation = humanoid:LoadAnimation(HealthPackAnimation)

		animation.KeyframeReached:connect(function(name)
			if name == "Heal" then
				healthPack:Destroy()
				if humanoid.Health > 0 then
					humanoid.Health = humanoid.Health + humanoid.MaxHealth * HEAL_AMOUNT
					ReplicatedStorage.Remotes.HealthPack:FireClient(player)
				end
			end
		end)

		animation:Play()
	end
end)
