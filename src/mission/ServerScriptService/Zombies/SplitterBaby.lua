local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local Common = require(script.Parent.Common)
local Gamemode = require(ServerScriptService.Gamemodes.Gamemode)
local PlayQuickSound = require(ReplicatedStorage.Core.PlayQuickSound)
local RealDelay = require(ReplicatedStorage.Core.RealDelay)

local SplitterBaby = {}

function SplitterBaby.new(level)
	local derivative = Common.new(level)

	return setmetatable({
		Model = "SplitterBaby",
		_derivative = derivative,
	}, {
		__index = function(self, key)
			return SplitterBaby[key] or self._derivative[key]
		end,
	})
end

function SplitterBaby:AfterSpawn()
	self._derivative.AfterSpawn(self)

	RealDelay(self:GetScale("RespawnTime"), function()
		if self.alive then
			local splitter = Gamemode.SpawnZombie("Splitter", self.level, self.instance.PrimaryPart.Position)
			splitter.fromBaby = true
			splitter.GetXP = function()
				return 0
			end
			splitter:Aggro()
			splitter.instance.PrimaryPart.SummonParticle.Dust:Emit(1)
			splitter.instance.PrimaryPart.SummonParticle.Star:Emit(1)

			PlayQuickSound(SoundService.ZombieSounds["1"].Splitter.Combine, splitter.instance.PrimaryPart)

			self:Destroy()
		end
	end)
end

return SplitterBaby
