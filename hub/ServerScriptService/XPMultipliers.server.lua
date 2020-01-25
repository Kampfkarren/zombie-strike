local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local XPMultiplierDictionary = require(ReplicatedStorage.XPMultiplierDictionary)

local XPMultipliers = ReplicatedStorage.Remotes.XPMultipliers

XPMultipliers.OnServerEvent:connect(function(player, index)
	local multiplier = XPMultiplierDictionary[index]
	if not multiplier then
		warn("XPMultipliers: invalid product", index)
		return
	end

	local brains, brainsStore = Data.GetPlayerData(player, "Brains")
	if brains < multiplier.Cost then
		warn("XPMultipliers: not enough brains")
		return
	end

	local xpExpires, xpExpiresStore = Data.GetPlayerData(player, "XPExpires")
	if os.time() > xpExpires then
		xpExpiresStore:Set(os.time() + multiplier.Time)
	else
		xpExpiresStore:Set(xpExpires + multiplier.Time)
	end

	brainsStore:Increment(-multiplier.Cost)
	brainsStore:Save()
end)

Players.PlayerAdded:connect(function(player)
	local expires, dataStore = Data.GetPlayerData(player, "XPExpires")

	local function update(expires)
		if os.time() < expires then
			XPMultipliers:FireClient(player, expires)
		end
	end

	update(expires)
	dataStore:OnUpdate(update)
end)
