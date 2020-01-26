local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local TeleportScreen = require(ReplicatedStorage.Libraries.TeleportScreen)

local GetCurrentLobby = ReplicatedStorage.LocalEvents.GetCurrentLobby
local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local TeleportGui = PlayerGui:WaitForChild("TeleportGui")

ReplicatedStorage.Remotes.Teleporting.OnClientEvent:connect(function(teleporting)
	if teleporting then
		local lobby = GetCurrentLobby:Invoke()

		TeleportScreen(TeleportGui, lobby)
		TeleportService:SetTeleportGui(TeleportGui)
	end

	TeleportGui.Enabled = teleporting
end)
