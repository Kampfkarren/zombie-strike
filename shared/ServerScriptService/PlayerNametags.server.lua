local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Nametag = require(ServerScriptService.Shared.Nametag)

Players.PlayerAdded:connect(function(player)
	local playerData = player:WaitForChild("PlayerData")
	local level = playerData:WaitForChild("Level")

	local function characterAdded(character)
		Nametag(character, level.Value)

		character.Humanoid.HealthChanged:connect(function()
			Nametag(character, level.Value)
		end)

		level.Changed:connect(function()
			Nametag(character, level.Value)
		end)
	end

	if player.Character then
		characterAdded(player.Character)
	end

	player.CharacterAdded:connect(characterAdded)
end)
