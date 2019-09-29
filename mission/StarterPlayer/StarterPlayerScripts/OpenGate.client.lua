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

ReplicatedStorage.Remotes.OpenGate.OnClientEvent:connect(function(room, reset)
	local gate = room:FindFirstChild("Gate", true)

	if not CollectionService:HasTag(gate, "LocallyCreated") then
		gate.Parent = nil
	end

	if Dungeon.GetDungeonData("Campaign") == 1 then
		if reset then
			gate.Parent:SetPrimaryPartCFrame(reset)
			return
		end

		local gate = gate:Clone()
		CollectionService:AddTag(gate, "LocallyCreated")
		gate.Parent = Workspace

		local total = 0

		local cframe = gate.PrimaryPart.CFrame
		local finalCFrame = CFrame.new(
			gate.PrimaryPart.Position + Vector3.new(0, 14, -4)
		) * CFrame.Angles(CITY_GATE_ROTATE_ANGLE, 0, 0)

		local gateOpenConnection do
			gateOpenConnection = RunService.Heartbeat:connect(function(delta)
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
					gateOpenConnection:Disconnect()
				end
			end)
		end

		local sound = SoundGateCity:Clone()
		sound.Parent = gate
		sound:Play()
		Debris:AddItem(sound)
	end

	local direction = Camera.CFrame:VectorToObjectSpace(
		(Camera.CFrame.Position - gate.PrimaryPart.Position).Unit
	)

	Shake:Fire(direction * 15)
end)
