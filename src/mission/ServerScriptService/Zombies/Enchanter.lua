local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Common = require(script.Parent.Common)
local GetCharacterAttachment = require(ReplicatedStorage.Core.GetCharacterAttachment)
local Maid = require(ReplicatedStorage.Core.Maid)
local Zombie = require(script.Parent.Zombie)

local Enchanter = {}

local RANGE = 60

function Enchanter.new(level)
	local derivative = Common.new(level)

	return setmetatable({
		Model = "Enchanter",
		enchanterBuffs = Maid.new(),
		_derivative = derivative,
	}, {
		__index = function(self, key)
			return Enchanter[key] or self._derivative[key]
		end,
	})
end

function Enchanter:AfterSpawn()
	self._derivative.AfterSpawn(self)

	self.aliveMaid:GiveTask(self.enchanterBuffs)

	self.aliveMaid:GiveTask(RunService.Heartbeat:connect(function()
		local selfPosition = self.instance.PrimaryPart.Position

		for _, zombie in ipairs(Zombie.GetAliveZombies()) do
			local inRange = (selfPosition - zombie.instance.PrimaryPart.Position).Magnitude <= RANGE

			if zombie ~= self and (self.enchanterBuffs[zombie] ~= nil) ~= inRange then
				if inRange then
					local buffMaid = Maid.new()
					buffMaid:GiveTask(zombie:GiveBuff("Defense", self:GetScale("Buff")))

					local buffParticle1 = self:GetAsset("BuffParticle1"):Clone()
					buffParticle1.Parent = zombie.instance.PrimaryPart
					buffMaid:GiveTaskParticleEffect(buffParticle1)

					local buffParticle2 = self:GetAsset("BuffParticle2"):Clone()
					buffParticle2.Parent = zombie.instance.PrimaryPart
					buffMaid:GiveTaskParticleEffect(buffParticle2)

					local buffBeam = self:GetAsset("BuffBeam"):Clone()
					buffBeam.Attachment0 = GetCharacterAttachment.GetCenter(zombie.instance)
					buffBeam.Attachment1 = GetCharacterAttachment.GetCenter(self.instance)
					buffBeam.Parent = self.instance.PrimaryPart
					buffMaid:GiveTask(buffBeam)

					buffMaid:GiveTask(zombie.Died:connect(function()
						buffMaid:DoCleaning()
						self.enchanterBuffs[zombie] = nil
					end))

					local loopSound = self:GetAsset("Loop"):Clone()
					loopSound.Parent = zombie.instance.PrimaryPart
					loopSound:Play()
					buffMaid:GiveTask(loopSound)

					self.enchanterBuffs[zombie] = buffMaid
				else
					self.enchanterBuffs[zombie]:DoCleaning()
					self.enchanterBuffs[zombie] = nil
				end
			end
		end
	end))
end

return Enchanter
