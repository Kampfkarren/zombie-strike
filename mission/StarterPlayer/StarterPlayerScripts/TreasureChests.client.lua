local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Collection = require(ReplicatedStorage.Core.Collection)

local OSCILLATE_MAX = 1
local OSCILLATE_RATE = 0.95

ReplicatedStorage.LocalEvents.AmbienceChanged.Event:connect(function(ambienceName)
	SoundService.Music.TreasureCompressor.Enabled = ambienceName == "Treasure"
end)

local function oscillateChest(chest)
	local start = chest.PrimaryPart.CFrame
	local goal = start + Vector3.new(0, OSCILLATE_MAX, 0)

	local total = 0

	RunService.Heartbeat:connect(function(delta)
		total = total + delta * OSCILLATE_RATE
		chest:SetPrimaryPartCFrame(start:Lerp(goal, math.sin(total)))
	end)
end

Collection("ChestEpic", oscillateChest)
Collection("ChestLegendary", oscillateChest)
