local ServerStorage = game:GetService("ServerStorage")

local BasicZombie = {}
BasicZombie.__index = BasicZombie

BasicZombie.Model = ServerStorage.Zombies.Zombie
BasicZombie.Name = "Zombie"

function BasicZombie.new()
	return setmetatable({}, BasicZombie)
end

return BasicZombie
