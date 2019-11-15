local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Maid = require(ReplicatedStorage.Core.Maid)

local SoundGateCity = SoundService.SFX.Gate.City

local CITY_GATE_ROTATE_ANGLE = math.deg(130)

local City = {}

function City.Reset(gate, original)
	gate.Parent:SetPrimaryPartCFrame(original)
end

function City.Open(gate)
	if not CollectionService:HasTag(gate, "LocallyCreated") then
		gate.Parent = nil
	end

	local gate = gate:Clone()
	CollectionService:AddTag(gate, "LocallyCreated")
	gate.Parent = Workspace

	local total = 0

	local cframe = gate.PrimaryPart.CFrame
	local finalCFrame = CFrame.new(
		gate.PrimaryPart.Position + Vector3.new(0, 14, -4)
	) * CFrame.Angles(CITY_GATE_ROTATE_ANGLE, 0, 0)

	local maid = Maid.new()

	local gateOpenConnection = RunService.Heartbeat:connect(function(delta)
		total = total + delta
		gate:SetPrimaryPartCFrame(
			cframe:Lerp(
				finalCFrame,
				TweenService:GetValue(
					total / 1.5,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.In
				)
			)
		)

		if total >= 1.5 then
			maid:DoCleaning()
		end
	end)

	maid:GiveTask(gateOpenConnection)

	for _, part in pairs(gate:GetDescendants()) do
		if part:IsA("BasePart") and part.CanCollide then
			part.CanCollide = false
			maid:GiveTask(function()
				part.CanCollide = true
			end)
		end
	end

	local sound = SoundGateCity:Clone()
	sound.Parent = gate
	sound:Play()
	Debris:AddItem(sound)

	return gate
end

return City
