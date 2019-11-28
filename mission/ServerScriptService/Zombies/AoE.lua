local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local CircleEffect = require(ReplicatedStorage.Libraries.CircleEffect)
local Common = require(script.Parent.Common)
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local TakeDamage = require(ServerScriptService.Shared.TakeDamage)

local CircleEffectRemote = ReplicatedStorage.Remotes.CircleEffect

local AoE = {}
AoE.__index = AoE

AoE.AttackRange = 15

function AoE.new(level)
	return setmetatable({
		Model = "AoE",
		_deriative = Common.new(level),
	}, {
		__index = function(self, key)
			return AoE[key] or self._deriative[key]
		end,
	})
end

function AoE:AfterSpawn()
	self.animation = self.instance.Humanoid:LoadAnimation(
		ReplicatedStorage
			.Assets
			.Campaign["Campaign" .. Dungeon.GetDungeonData("Campaign")]
			.AoE
			.Stomp
	)

	self.animation.KeyframeReached:connect(function(keyframe)
		if keyframe == "Stomp" then
			self:StompEffect()
		end
	end)

	self.animation:GetPropertyChangedSignal("IsPlaying"):connect(function()
		if not self.animation.IsPlaying then
			self.instance.Humanoid.WalkSpeed = self.lastSpeed
		end
	end)

	self.instance.Humanoid.Died:connect(function()
		self.animation:Stop()
	end)
end

function AoE:Attack()
	self.animation:Play()
	self.lastSpeed = self.instance.Humanoid.WalkSpeed
	self.instance.Humanoid.WalkSpeed = 0

	return true
end

function AoE:StompEffect()
	local range = self:GetScale("Range")

	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character
		if (character.PrimaryPart.Position - self.instance.PrimaryPart.Position).Magnitude <= range / 2 then
			TakeDamage(player, self:GetScale("Damage"))
		end
	end

	CircleEffectRemote:FireAllClients(
		self.instance.PrimaryPart.CFrame,
		CircleEffect.Presets.BIG_ROBO_ZOMBIE
	)
end

return AoE
