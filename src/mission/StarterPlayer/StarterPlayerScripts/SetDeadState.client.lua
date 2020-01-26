local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

ReplicatedStorage.Remotes.SetDeadState.OnClientEvent:connect(function()
	RunService.Heartbeat:wait()
	LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
end)
