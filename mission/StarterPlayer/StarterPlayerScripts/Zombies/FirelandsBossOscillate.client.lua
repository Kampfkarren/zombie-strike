local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local BOSS_OSCILLATE_RANGE = Vector3.new(0, 6, 0)

if Dungeon.GetDungeonData("Campaign") ~= 3 then return end

local boss = CollectionService:GetInstanceAddedSignal("BossOscillate"):wait()
local baseCFrame = boss.PrimaryPart.CFrame

local total = 0

RunService.Heartbeat:connect(function(delta)
	total = total + delta
	boss:SetPrimaryPartCFrame(baseCFrame + BOSS_OSCILLATE_RANGE * math.sin(total))
end)
