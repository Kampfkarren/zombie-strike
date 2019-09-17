local CityBoss = {}
CityBoss.__index = CityBoss

CityBoss.Name = "Master Chief"
CityBoss.Model = "Boss"

function CityBoss.new()
	return setmetatable({}, CityBoss)
end

function CityBoss:InitializeAI()
	local instance = self.instance
	instance.PrimaryPart.Anchored = true
end

return CityBoss
