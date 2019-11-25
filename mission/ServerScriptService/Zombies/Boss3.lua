local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local FirelandsBoss = {}
FirelandsBoss.__index = FirelandsBoss

function FirelandsBoss.new()
	return setmetatable({

	}, FirelandsBoss)
end

function FirelandsBoss.GetModel()
	return assert(Workspace:FindFirstChild("Fire Elemental Zombie", true))
end

function FirelandsBoss:InitializeBossAI()
	CollectionService:AddTag(self.instance, "Zombie")
end

function FirelandsBoss:Spawn()
	self:AfterSpawn()
	self:SetupHumanoid()
	return self.instance
end

function FirelandsBoss.UpdateNametag() end

return FirelandsBoss
