local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)

local UpdateXPExpiration = ReplicatedStorage.Remotes.UpdateXPExpiration

Players.PlayerAdded:connect(function(player)
	local expires, dataStore = Data.GetPlayerData(player, "XPExpires")

	local function update(expires)
		if os.time() < expires then
			UpdateXPExpiration:FireClient(player, expires)
		end
	end

	update(expires)
	dataStore:OnUpdate(update)
end)
