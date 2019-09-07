local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Libraries.Data)
local Zombie = require(script.Parent.Zombie)

local AMOUNT_FOR_BOSS = 0.3

local Boss = {}
Boss.__index = Boss

Boss.Name = "Boss"

function Boss.new(level, bossInstance, derivativeType)
	local bossInstance = bossInstance:Clone()
	Instance.new("Model", bossInstance.Humanoid).Name = "Boss"
	CollectionService:AddTag(bossInstance, "Boss")
	local derivative = Zombie.new(derivativeType, level)

	return setmetatable({
		Model = bossInstance,
	}, {
		__index = function(_, key)
			return Boss[key] or derivative[key]
		end,
	})
end

function Boss:GetHealth()
	return Data.GetDungeonData("DifficultyInfo").BossStats.Health
end

function Boss:GetSpeed()
	return Data.GetDungeonData("DifficultyInfo").BossStats.Speed
end

function Boss:GetXP()
	return Data.GetDungeonData("DifficultyInfo").XP * AMOUNT_FOR_BOSS
end

function Boss:UpdateNametag()
	local super = Zombie.UpdateNametag(self)
	super.Size = UDim2.new(40, 0, 10, 0)
	return super
end

return Boss
