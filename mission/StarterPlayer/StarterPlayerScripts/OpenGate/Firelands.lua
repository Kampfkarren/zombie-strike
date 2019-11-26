local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local SoundGateFirelands = SoundService.SFX.Gate.Firelands

local Firelands = {}

local LOWER_OFFSET = Vector3.new(0, 17, 0)
local LOWER_TIME = 1.3

function Firelands.Open(gate)
	local sound = SoundGateFirelands:Clone()
	sound.Parent = gate.PrimaryPart
	sound:Play()

	local time = 0
	local start = gate.PrimaryPart.CFrame
	local goal = start - LOWER_OFFSET

	while time <= LOWER_TIME do
		time = time + RunService.Heartbeat:wait()
		gate:SetPrimaryPartCFrame(start:Lerp(goal, math.sin(time / LOWER_TIME * math.pi / 2)))
	end

	sound:Stop()

	return gate
end

return Firelands
