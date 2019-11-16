local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local HEALTH_COLOR_BLINK_HEALTH = 0.1
local HEALTH_COLOR_BLINK_RATE = 0.2

local BLACK = Color3.new()
local RED = Color3.fromRGB(231, 76, 60)

local FactoryBoss = {}
FactoryBoss.__index = FactoryBoss

FactoryBoss.Name = "The Evil Dr. Zombie"

function FactoryBoss.new()
	return setmetatable({
		blinking = false,
		healthColors = {
			{1 / 3, RED},
			{2 / 3, Color3.fromRGB(241, 196, 15)},
		},
	}, FactoryBoss)
end

function FactoryBoss.GetModel()
	return assert(Workspace:FindFirstChild("The Evil Dr. Zombie", true))
end

function FactoryBoss:InitializeBossAI()
	CollectionService:AddTag(self.instance, "Zombie")

	self.instance.Humanoid.HealthChanged:connect(function(health)
		local nextHealth = self.healthColors[#self.healthColors]
		local ratio = (health / self.instance.Humanoid.MaxHealth)

		if nextHealth ~= nil then
			if ratio <= nextHealth[1] then
				self:SetWarningColor(nextHealth[2])
				table.remove(self.healthColors)
			end
		elseif ratio <= HEALTH_COLOR_BLINK_HEALTH and not self.blinking then
			self.blinking = true

			local color = RED
			local last = 0

			self.aliveMaid:GiveTask(RunService.Heartbeat:connect(function(delta)
				last = last + delta
				if last >= HEALTH_COLOR_BLINK_RATE then
					last = 0

					local newColor = color == RED and BLACK or RED

					self:SetWarningColor(newColor)
					color = newColor
				end
			end))
		end
	end)
end

function FactoryBoss:SetWarningColor(color)
	for _, part in pairs(self.instance.HealthSegment:GetChildren()) do
		if part.Name == "Warning" then
			part.Color = color
		end
	end
end

function FactoryBoss:Spawn()
	self:AfterSpawn()
	self:SetupHumanoid()
	return self.instance
end

function FactoryBoss.UpdateNametag() end

return FactoryBoss
