local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

if RunService:IsServer() then
	return require(ServerScriptService.Libraries.DungeonServer)
end

local Dungeon = {}

function Dungeon.GetDungeonData(key)
	return ReplicatedStorage.ClientDungeonData:WaitForChild(key).Value
end

return Dungeon
