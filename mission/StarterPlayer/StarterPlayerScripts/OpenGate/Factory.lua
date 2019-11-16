local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local GateOpen = ReplicatedStorage.Assets.Campaign.Campaign2.Particles.GateOpen
local SoundGateFactory = SoundService.SFX.Gate.Factory

local GATE_SHIFT = Vector3.new(8.02, 0, 0)
local GATE_OPEN_TIME = 1

local Factory = {}

function Factory.Reset(_gate, _original)
end

function Factory.Open(gate)
	local sound = SoundGateFactory:Clone()
	sound.Parent = gate.PrimaryPart
	sound:Play()
	Debris:AddItem(sound)

	gate.PrimaryPart.CanCollide = false

	local attachment = Instance.new("Attachment")

	local emitter = GateOpen:Clone()
	emitter.Parent = attachment
	emitter:Emit(8)
	Debris:AddItem(emitter)

	attachment.Parent = gate.PrimaryPart

	for _, side in pairs({{ gate.Left, 1 }, { gate.Right, -1 }}) do
		local model = side[1]
		local scale = side[2]

		local origin = model.PrimaryPart.CFrame
		local goal = model.PrimaryPart.CFrame + GATE_SHIFT * scale

		local total = 0

		local connection
		connection = RunService.Heartbeat:Connect(function(delta)
			total = math.min(total + delta, 1)

			local alpha = TweenService:GetValue(
				total / GATE_OPEN_TIME,
				Enum.EasingStyle.Cubic,
				Enum.EasingDirection.Out
			)

			model:SetPrimaryPartCFrame(origin:Lerp(goal, alpha))

			if total >= 1 then
				connection:Disconnect()
			end
		end)
	end

	return gate
end

return Factory
