-- TODO: Prevent shooters from being moved, or don't run the animation
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Raycast = require(ReplicatedStorage.Libraries.Raycast)

local TURRET_RANGE = 80

local Turret = {}
Turret.__index = Turret

Turret.Model = "Turret"
Turret.Name = "Shooter Zombie"

Turret.Scaling = {
	Damage = {
		Base = 10,
		Scale = 1.15,
	},

	Health = {
		Base = 45,
		Scale = 1.154,
	},

	RateOfFire = {
		Base = 0.5,
		Scale = 1.09,
	},

	Speed = {
		Base = 5,
		Scale = 1,
	},
}

function Turret.new()
	return setmetatable({}, Turret)
end

function Turret:AfterSpawn()
	local instance = self.instance
	local gun = instance.Gun

	local aimAnimation = self:LoadAnimation(gun.Animations.Aim)
	aimAnimation.Priority = Enum.AnimationPriority.Idle
	aimAnimation.Looped = true
	aimAnimation:Play()

	self.shootAnimation = self:LoadAnimation(gun.Animations.AimShoot)
end

function Turret:InitializeAI()
	local rateOfFire = self:GetScale("RateOfFire")

	spawn(function()
		local root = self.instance.HumanoidRootPart
		wait(math.random(30, 120) / 100)

		while self.alive do
			local closest = { nil, math.huge }

			for _, player in pairs(Players:GetPlayers()) do
				local character = player.Character
				if character and character.Humanoid.Health > 0 then
					local hit, position, normal = Raycast(
						root.Position,
						(root.Position - character.HumanoidRootPart.Position).Unit * -TURRET_RANGE,
						{ self.instance }
					)

					if hit and hit:IsDescendantOf(character) then
						local distance = (root.Position - position).Magnitude
						if distance < closest[2] then
							closest = { character, distance, { hit, position, normal, character.Humanoid } }
						end
					end
				end
			end

			if closest[1] then
				local handlePos = self.instance.Gun.Handle.Position

				ReplicatedStorage.RuddevRemotes.Effect:FireAllClients(
					"Shoot",
					self.instance.Gun,
					handlePos,
					{ 0 },
					1000,
					closest[3]
				)

				closest[1].Humanoid:TakeDamage(self:GetScale("Damage"))
				self.shootAnimation:Play()
			end

			wait(1 / rateOfFire)
		end
	end)
end

return Turret
