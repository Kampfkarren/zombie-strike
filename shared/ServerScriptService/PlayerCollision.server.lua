local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

PhysicsService:CreateCollisionGroup("Players")
PhysicsService:CreateCollisionGroup("Zombies")

PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)
PhysicsService:CollisionGroupSetCollidable("Zombies", "Zombies", false)

if not ReplicatedStorage.HubWorld.Value then
	local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)
	if Dungeon.GetDungeonData("Gamemode") == "Arena" then
		PhysicsService:CollisionGroupSetCollidable("Players", "Zombies", false)
	end
end

PhysicsService:CreateCollisionGroup("Grenade")
PhysicsService:CollisionGroupSetCollidable("Grenade", "Players", false)
PhysicsService:CollisionGroupSetCollidable("Grenade", "Zombies", false)

PhysicsService:CreateCollisionGroup("DeadZombies")
PhysicsService:CollisionGroupSetCollidable("DeadZombies", "DeadZombies", false)
PhysicsService:CollisionGroupSetCollidable("DeadZombies", "Zombies", false)
PhysicsService:CollisionGroupSetCollidable("DeadZombies", "Players", false)

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

	zombie.Humanoid.Died:connect(function()
		collideCharacter(zombie, "DeadZombies")
	end)
end)

local function playerAdded(player)
	player.CharacterAdded:connect(function(character)
		collideCharacter(character, "Players")
	end)
end

for _, player in pairs(Players:GetPlayers()) do
	playerAdded(player)
end

Players.PlayerAdded:connect(playerAdded)
