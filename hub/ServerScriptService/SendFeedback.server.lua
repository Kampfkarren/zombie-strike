local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeakInstanceTable = require(ReplicatedStorage.Core.WeakInstanceTable)

local FEEDBACK_URL = "CENSORED URL

local sentFeedback = WeakInstanceTable()

ReplicatedStorage.Remotes.SendFeedback.OnServerEvent:connect(function(player, message)
	if sentFeedback[player] then return end
	sentFeedback[player] = true
	if message:match("[^%s]") then
		HttpService:PostAsync(
			FEEDBACK_URL,
			HttpService:JSONEncode({
				content = message,
				username = player.Name .. " - " .. ReplicatedStorage.Version.Value,
			})
		)
	end
end)
