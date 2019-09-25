local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local Camera = Workspace.CurrentCamera
local Shake = ReplicatedStorage.RuddevEvents.Shake
local SoundGateCity = SoundService.SFX.Gate.City

local CITY_GATE_ROTATE_ANGLE = math.deg(130)

local cityGateChainTween = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.In
)

ReplicatedStorage.Remotes.OpenGate.OnClientEvent:connect(function(room, reset)
	local gate = room:FindFirstChild("Gate", true)

	if Dungeon.GetDungeonData("Campaign") == 1 then
		if reset then
			gate.Parent:SetPrimaryPartCFrame(reset)
			return
		end

		local fixedGate = Instance.new("Model")
		fixedGate.Parent = room
		gate.Parent = fixedGate
		fixedGate.PrimaryPart = gate
		for _, detail in pairs(gate:GetChildren()) do
			detail.Parent = fixedGate
		end

		local chains = {}

		for _, thing in pairs(room:GetDescendants()) do
			if CollectionService:HasTag(thing, "Chain") then
				TweenService:Create(
					thing,
					cityGateChainTween,
					{ TextureSpeed = 3 }
				):Play()

				table.insert(chains, thing)
			end
		end

		local total = 0

		local cframe = gate.CFrame
		local finalCFrame = CFrame.new(
			gate.Position + Vector3.new(0, 6.5, -2.5)
		) * CFrame.Angles(CITY_GATE_ROTATE_ANGLE, 0, 0)

		local gateOpenConnection do
			gateOpenConnection = RunService.Heartbeat:connect(function(delta)
				total = total + delta
				fixedGate:SetPrimaryPartCFrame(
					cframe:Lerp(
						finalCFrame,
						TweenService:GetValue(
							total / 1.5,
							Enum.EasingStyle.Sine,
							Enum.EasingDirection.In
						)
					)
				)

				if total >= 1.5 then
					gateOpenConnection:Disconnect()

					for _, chain in pairs(chains) do
						TweenService:Create(
							chain,
							cityGateChainTween,
							{ TextureSpeed = 0 }
						):Play()
					end
				end
			end)
		end

		local sound = SoundGateCity:Clone()
		sound.Parent = gate
		sound:Play()
		Debris:AddItem(sound)
	end

	local direction = Camera.CFrame:VectorToObjectSpace(
		(Camera.CFrame.Position - gate.Position).Unit
	)

	Shake:Fire(direction * 15)
end)
