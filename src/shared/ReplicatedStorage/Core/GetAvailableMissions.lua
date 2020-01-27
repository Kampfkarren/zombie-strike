local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Campaigns = require(ReplicatedStorage.Core.Campaigns)
local Data = require(ReplicatedStorage.Core.Data)

local function GetAvailableMissions(player)
	local level = Data.GetPlayerData(player, "Level")
	local available = {}

	for _, campaign in ipairs(Campaigns) do
		for _, difficulty in ipairs(campaign.Difficulties) do
			if difficulty.MinLevel <= level then
				table.insert(available, difficulty)
			else
				break
			end
		end
	end

	return available
end

return GetAvailableMissions
