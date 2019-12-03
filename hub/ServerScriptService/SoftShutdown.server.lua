-- THANK YOU ELLE!
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

game:BindToClose(function()
	local players = Players:GetPlayers()

	if #players == 0 then
		return
	end

	if RunService:IsStudio() then
		return
	end

	for _, player in pairs(Players:GetPlayers()) do
		ReplicatedStorage.Remotes.GameUpdate:FireClient(player)
		TeleportService:Teleport(game.PlaceId, player)
	end
end)
