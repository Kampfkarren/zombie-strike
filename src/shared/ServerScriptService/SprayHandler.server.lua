local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local WeakInstanceTable = require(ReplicatedStorage.Core.WeakInstanceTable)

local UseSpray = ReplicatedStorage.Remotes.UseSpray

local SPRAY_COOLDOWN = 4

local lastSprayed = WeakInstanceTable()

UseSpray.OnServerEvent:connect(function(player)
	local sprayIndex = Data.GetPlayerData(player, "Sprays").Equipped
	if not sprayIndex then
		warn("UseSpray: no spray equipped")
		return
	end

	if tick() - (lastSprayed[player] or 0) > SPRAY_COOLDOWN then
		lastSprayed[player] = tick()
		UseSpray:FireAllClients(player.Character, sprayIndex)
	end
end)
