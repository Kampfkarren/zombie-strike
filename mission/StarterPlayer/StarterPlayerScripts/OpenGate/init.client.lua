local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local Camera = Workspace.CurrentCamera
local Shake = ReplicatedStorage.RuddevEvents.Shake

local gates = {
	require(script.City),
	require(script.Factory),
}

ReplicatedStorage.Remotes.OpenGate.OnClientEvent:connect(function(room)
	local gate = room:FindFirstChild("Gate", true)

	local campaign = Dungeon.GetDungeonData("Campaign")
	local gateModule = assert(gates[campaign], "No gate for campaign " .. campaign)

	if not CollectionService:HasTag(gate, "LocallyCreated") then
		gate.Parent = nil
	end

	local gate = gate:Clone()
	CollectionService:AddTag(gate, "LocallyCreated")
	gate.Parent = Workspace

	local direction = Camera.CFrame:VectorToObjectSpace(
		(Camera.CFrame.Position - gateModule.Open(gate).PrimaryPart.Position).Unit
	)

	Shake:Fire(direction * 15)
end)
