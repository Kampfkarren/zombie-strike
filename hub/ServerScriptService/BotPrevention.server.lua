local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ConnectPing = ReplicatedStorage.Remotes.ConnectPing

local WAIT_UNTIL_KICK = 15

local waiting = {}

ConnectPing.OnServerEvent:connect(function(player)
	waiting[player] = nil
end)

Players.PlayerAdded:connect(function(player)
	waiting[player] = true
	wait(WAIT_UNTIL_KICK)
	if not player:IsDescendantOf(game) then return end
	if waiting[player] then
		warn(player.Name .. " did not send connect ping")
		player:Kick("You've been disconnected for inactivity.")
	end
end)

Players.PlayerRemoving:connect(function(player)
	waiting[player] = nil
end)
