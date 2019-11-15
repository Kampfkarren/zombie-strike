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

local gates = {
	require(script.City),
}

ReplicatedStorage.Remotes.OpenGate.OnClientEvent:connect(function(room, reset)
	local gate = room:FindFirstChild("Gate", true)

	local campaign = Dungeon.GetDungeonData("Campaign")
	local gateModule = assert(gates[campaign], "No gate for campaign " .. campaign)

	if reset then
		gateModule.Reset(gate, reset)
		return
	end

	local direction = Camera.CFrame:VectorToObjectSpace(
		(Camera.CFrame.Position - gateModule.Open(gate).PrimaryPart.Position).Unit
	)

	Shake:Fire(direction * 15)
end)
