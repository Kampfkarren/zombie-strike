-- TODO: Prevent shooters from being moved, or don't run the animation
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Raycast = require(ReplicatedStorage.Libraries.Raycast)

local Turret = {}
Turret.__index = Turret

Turret.Model = "Turret"
Turret.Name = "Shooter Zombie"

Turret.TurretCooldown = 2
Turret.TurretDamage = 2
Turret.TurretRange = 80

function Turret.new()
	return setmetatable({}, Turret)
end

function Turret:InitializeAI()
	spawn(function()
		local root = self.instance.HumanoidRootPart
		wait(math.random(30, self.TurretCooldown * 100) / 100)

		while self.alive do
			local closest = { nil, math.huge }

			for _, player in pairs(Players:GetPlayers()) do
				local character = player.Character
				if character and character.Humanoid.Health > 0 then
					local hit, position, normal = Raycast(
						root.Position,
						(root.Position - character.HumanoidRootPart.Position).Unit * -self.TurretRange,
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

				closest[1].Humanoid:TakeDamage(self.TurretDamage)
			end

			wait(self.TurretCooldown)
		end
	end)
end

return Turret
