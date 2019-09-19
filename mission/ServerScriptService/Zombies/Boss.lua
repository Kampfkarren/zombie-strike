local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
local Zombie = require(script.Parent.Zombie)

local AMOUNT_FOR_BOSS = 0.3

local Boss = {}
Boss.__index = Boss

function Boss.new(level)
	local derivative = Zombie.new(
		"Boss" .. Dungeon.GetDungeonData("Campaign"),
		level
	)

	return setmetatable({
		_derivative = derivative,
	}, {
		__index = function(_, key)
			return Boss[key] or derivative[key]
		end,
	})
end

function Boss:AfterSpawn()
	CollectionService:AddTag(self.instance, "Boss")
	if self._derivative.AfterSpawn then
		self._derivative.AfterSpawn(self)
	end
end

function Boss.GetHealth()
	return Dungeon.GetDungeonData("DifficultyInfo").BossStats.Health
end

function Boss.GetSpeed()
	return Dungeon.GetDungeonData("DifficultyInfo").BossStats.Speed
end

function Boss.GetXP()
	return Dungeon.GetDungeonData("DifficultyInfo").XP * AMOUNT_FOR_BOSS
end

function Boss:UpdateNametag()
	local super = Zombie.UpdateNametag(self)
	super.Size = UDim2.new(40, 0, 10, 0)
	return super
end

return Boss
