local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local FactoryBoss = {}
FactoryBoss.__index = FactoryBoss

FactoryBoss.Name = "The Evil Dr. Zombie"

function FactoryBoss.new()
	return setmetatable({
	}, FactoryBoss)
end

function FactoryBoss.GetModel()
	return assert(Workspace:FindFirstChild("The Evil Dr. Zombie", true))
end

function FactoryBoss:InitializeBossAI()
	CollectionService:AddTag(self.instance, "Zombie")
end

function FactoryBoss:Spawn()
	self:AfterSpawn()
	self:SetupHumanoid()
	return self.instance
end

function FactoryBoss.UpdateNametag() end

return FactoryBoss
