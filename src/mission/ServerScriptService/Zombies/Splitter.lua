local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local Common = require(script.Parent.Common)
local Gamemode = require(ServerScriptService.Gamemodes.Gamemode)
local PlayQuickSound = require(ReplicatedStorage.Core.PlayQuickSound)

local Splitter = {}

function Splitter.new(level)
	local derivative = Common.new(level)

	return setmetatable({
		Model = "Splitter",
		_derivative = derivative,
	}, {
		__index = function(self, key)
			return Splitter[key] or self._derivative[key]
		end,
	})
end

function Splitter:AfterDeath()
	if self.fromBaby then
		return
	end

	for _ = 1, self:GetScale("BabiesSpawned") do
		local position = self.instance.PrimaryPart.Position

		local _, position = Workspace:FindPartOnRayWithIgnoreList(
			Ray.new(position, Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))),
			{ Workspace.Zombies }
		)

		local baby = Gamemode.SpawnZombie("SplitterBaby", self.level, position)
		baby.GetXP = function()
			return 0
		end
		baby:Aggro()
		baby.instance.PrimaryPart.Split.ParticleEmitter:Emit(5)

		PlayQuickSound(SoundService.ZombieSounds["1"].Splitter.Split, baby.instance.PrimaryPart)
	end
end

return Splitter
