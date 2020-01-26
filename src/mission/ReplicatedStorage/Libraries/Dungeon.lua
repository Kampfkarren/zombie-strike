local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Bosses = require(ReplicatedStorage.Core.Bosses)

if RunService:IsServer() then
	return require(ServerScriptService.Libraries.DungeonServer)
end

local Dungeon = {}

function Dungeon.GetDungeonData(key)
	if key == "BossInfo" then
		return Bosses[Dungeon.GetDungeonData("Boss")]
	else
		return ReplicatedStorage.ClientDungeonData:WaitForChild(key).Value
	end
end

function Dungeon.GetGamemodeInfo()
	return require(ReplicatedStorage.GamemodeInfo[Dungeon.GetDungeonData("Gamemode")])
end

return Dungeon
