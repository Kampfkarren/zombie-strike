local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local BOSS_MOVE_TIME = 0.3
local BOSS_OSCILLATE_RANGE = Vector3.new(0, 6, 0)

if Dungeon.GetDungeonData("Campaign") ~= 3 then return end

local boss = CollectionService:GetInstanceAddedSignal("BossOscillate"):wait()

local total = 0

RunService.Heartbeat:connect(function(delta)
	total = total + delta
	boss.Body:SetPrimaryPartCFrame(boss.PrimaryPart.CFrame + BOSS_OSCILLATE_RANGE * math.sin(total))
end)

boss.NextPosition.Changed:connect(function(newPositionObject)
	local newPosition = newPositionObject.WorldPosition
	local base = boss.PrimaryPart.CFrame
	local goal = CFrame.new(newPosition, Workspace.Rooms.BossSection.PrimaryPart.RespawnPoint.WorldPosition)

	local total = 0
	while total < BOSS_MOVE_TIME do
		total = total + RunService.Heartbeat:wait()
		boss:SetPrimaryPartCFrame(base:Lerp(goal, math.sin(total / BOSS_MOVE_TIME)))
	end
end)
