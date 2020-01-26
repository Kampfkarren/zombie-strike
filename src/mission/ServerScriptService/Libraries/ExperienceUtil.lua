local ReplicatedStorage = game:GetService("ReplicatedStorage")

local XP = require(ReplicatedStorage.Core.XP)

local ExperienceUtil = {}

function ExperienceUtil.GivePlayerXP(player, xpGain, primaryPart)
	if xpGain <= 0 then return end
	local playerData = player:FindFirstChild("PlayerData")

	if playerData then
		local level = playerData.Level
		local xp = playerData.XP
		local xpGain = xpGain * playerData.XPScale.Value

		local xpNeeded = XP.XPNeededForNextLevel(level.Value)
		if xp.Value + xpGain >= xpNeeded then
			level.Value = level.Value + 1
			xp.Value = 0
			ReplicatedStorage.Remotes.LevelUp:FireAllClients(player)
		else
			xp.Value = xp.Value + xpGain
		end

		if primaryPart then
			ReplicatedStorage.Remotes.XPGain:FireClient(
				player,
				primaryPart.Position,
				math.floor(xpGain)
			)
		end
	end
end

return ExperienceUtil
