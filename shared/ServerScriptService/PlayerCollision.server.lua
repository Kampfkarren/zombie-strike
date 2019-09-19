local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

PhysicsService:CreateCollisionGroup("Players")
PhysicsService:CreateCollisionGroup("Zombies")

PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)

PhysicsService:CreateCollisionGroup("Grenade")
PhysicsService:CollisionGroupSetCollidable("Grenade", "Players", false)
PhysicsService:CollisionGroupSetCollidable("Grenade", "Zombies", false)

local function collideCharacter(character, group)
	local function playerCollide(part)
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, group)
		end
	end

	for _, part in pairs(character:GetDescendants()) do
		playerCollide(part)
	end

	character.ChildAdded:connect(playerCollide)
end

CollectionService:GetInstanceAddedSignal("Zombie"):connect(function(zombie)
	collideCharacter(zombie, "Zombies")
end)

Players.PlayerAdded:connect(function(player)
	player.CharacterAdded:connect(function(character)
		collideCharacter(character, "Players")
	end)
end)