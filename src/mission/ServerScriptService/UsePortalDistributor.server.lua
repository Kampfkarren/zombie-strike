local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UsePortal = ReplicatedStorage.Remotes.Tower.UsePortal

UsePortal.OnServerEvent:connect(function(player)
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if player ~= otherPlayer then
			UsePortal:FireServer(otherPlayer, player)
		end
	end
end)
