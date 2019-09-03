local CollectionService = game:GetService("CollectionService")

local Zombie = require(script.Parent.Zombie)

local Boss = {}
Boss.__index = Boss

Boss.Name = "Boss"
Boss.MaxHealth = 750

function Boss.new(bossInstance, derivativeType)
	local bossInstance = bossInstance:Clone()
	Instance.new("Model", bossInstance.Humanoid).Name = "Boss"
	CollectionService:AddTag(bossInstance, "Boss")
	local derivative = Zombie.new(derivativeType)

	return setmetatable({
		Model = bossInstance,
	}, {
		__index = function(_, key)
			return Boss[key] or derivative[key]
		end,
	})
end

function Boss:UpdateNametag()
	local super = Zombie.UpdateNametag(self)
	super.Size = UDim2.new(40, 0, 10, 0)
	return super
end

return Boss
