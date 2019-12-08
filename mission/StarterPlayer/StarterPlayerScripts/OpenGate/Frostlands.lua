local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local GATE_ANGLE = math.rad(135)
local GATE_OFFSET = Vector3.new(1, 0, 5)
local GATE_OPEN_TIME = 1

local SoundGateFrostlands = SoundService.SFX.Gate.Frostlands

local Frostlands = {}

local function goalOf(piece, position, angle)
	return piece.PrimaryPart.CFrame:ToWorldSpace(
		CFrame.new(piece.PrimaryPart.Size * position) * angle
	)
end

function Frostlands.Open(gate)
	local sound = SoundGateFrostlands:Clone()
	sound.Parent = gate.PrimaryPart
	sound:Play()
	Debris:AddItem(sound)

	local leftStart = gate:WaitForChild("Left").PrimaryPart.CFrame
	local leftGoal = goalOf(gate.Left, GATE_OFFSET, CFrame.Angles(0, GATE_ANGLE, 0))

	local rightStart = gate:WaitForChild("Right").PrimaryPart.CFrame
	local rightGoal = goalOf(gate.Right, GATE_OFFSET * Vector3.new(1, 1, -1), CFrame.Angles(0, -GATE_ANGLE, 0))

	local total = 0

	while total <= GATE_OPEN_TIME do
		total = total + RunService.Heartbeat:wait()
		local t = math.sin(total / GATE_OPEN_TIME * math.pi / 2)
		gate.Left:SetPrimaryPartCFrame(leftStart:Lerp(leftGoal, t))
		gate.Right:SetPrimaryPartCFrame(rightStart:Lerp(rightGoal, t))
	end

	return gate
end

return Frostlands
