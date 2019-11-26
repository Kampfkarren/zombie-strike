local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)

local SoundGateFirelands = SoundService.SFX.Gate.Firelands

local Firelands = {}

local LOWER_OFFSET = Vector3.new(0, 17, 0)
local LOWER_TIME = 1.3

local function getPartInfo(part)
	local start = part.CFrame

	return {
		bar = part,
		start = start,
		goal = start - LOWER_OFFSET,
	}
end

function Firelands.Open(gate)
	FastSpawn(function()
		local sound = SoundGateFirelands:Clone()
		sound.Parent = gate.PrimaryPart
		sound:Play()

		local time = 0
		local bars = { getPartInfo(gate.TransparentPart) }

		for _, bar in pairs(gate.GateBar:GetChildren()) do
			table.insert(bars, getPartInfo(bar))
		end

		while time <= LOWER_TIME do
			time = time + RunService.Heartbeat:wait()

			for _, bar in pairs(bars) do
				bar.bar.CFrame = bar.start:Lerp(bar.goal, math.sin((time / LOWER_TIME) * (math.pi / 2)))
			end
		end

		sound:Stop()
	end)

	return gate
end

return Firelands
