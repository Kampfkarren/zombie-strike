local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

local FollowConstants = require(ReplicatedStorage.FollowConstants)
local PlaceIds = require(ReplicatedStorage.Core.PlaceIds)

ReplicatedStorage.Remotes.FollowFriend.OnServerInvoke = function(player, userId)
	local success, errorOrCurrentInstance, _, placeId, instanceId = pcall(function()
		return TeleportService:GetPlayerPlaceInstanceAsync(userId)
	end)

	if not success then
		warn("FollowFriend step 1: " .. errorOrCurrentInstance)
		return FollowConstants.Codes.TeleportServiceFailure, errorOrCurrentInstance
	end

	if errorOrCurrentInstance then
		player.Character:SetPrimaryPartCFrame(Players:GetPlayerByUserId(userId).Character.PrimaryPart.CFrame)
		return
	end

	if placeId == PlaceIds.GetMissionPlace() then
		return FollowConstants.Codes.PlayerInMission
	else
		local success, problem = pcall(function()
			return TeleportService:TeleportToPlaceInstance(placeId, instanceId, player)
		end)

		if not success then
			warn("FollowFriend step 2: " .. problem)
			return FollowConstants.Codes.TeleportServiceFailure, problem
		end
	end
end
