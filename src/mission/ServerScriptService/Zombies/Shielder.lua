local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = require(script.Parent.Common)
local OnDied = require(ReplicatedStorage.Core.OnDied)

local Shielder = {}

function Shielder.new(level)
	local derivative = Common.new(level)

	return setmetatable({
		Model = "Shielder",
		_derivative = derivative,
	}, {
		__index = function(self, key)
			return Shielder[key] or self._derivative[key]
		end,
	})
end

function Shielder:AfterSpawn()
	self._derivative.AfterSpawn(self)

	self.shieldBashAnimation = self.instance.Humanoid:LoadAnimation(
		self.instance.Animations.Attack
	)

	self.shieldBashAnimation.KeyframeReached:connect(function()
		self:CommitAttack()
	end)

	local shield = self.instance.Shield
	local arm = self.instance.LeftUpperArm

	local shieldAttachment = shield.Hitbox.ShieldGrip
	local armAttachment = arm.LeftElbowRigAttachment

	local motor = Instance.new("Motor6D")
	motor.Name = "ShieldMotor"
	motor.Part0 = arm
	motor.Part1 = shield.PrimaryPart
	motor.C0 = armAttachment.CFrame
	motor.C1 = shieldAttachment.CFrame
	motor.Parent = arm

	shield.Humanoid.MaxHealth = self:GetHealth()
	shield.Humanoid.Health = shield.Humanoid.MaxHealth

	OnDied(shield.Humanoid):connect(function()
		self.instance.Humanoid.WalkSpeed = self:GetScale("EnragedSpeed")
		self.shieldDestroyed = true
	end)

	CollectionService:AddTag(self.instance, "ShieldZombie")
end

function Shielder:PlayAttackAnimation()
	if self.shieldDestroyed then
		self._derivative.PlayAttackAnimation(self)
	else
		self.shieldBashAnimation:Play()
	end
end

return Shielder
