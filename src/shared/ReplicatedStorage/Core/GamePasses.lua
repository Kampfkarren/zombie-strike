local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Promise = require(ReplicatedStorage.Core.Promise)
local WeakInstanceTable = require(ReplicatedStorage.Core.WeakInstanceTable)

local FreeGamePasses = ReplicatedStorage:FindFirstChild("FreeGamePasses")
local freeGamePasses = FreeGamePasses and FreeGamePasses.Value and RunService:IsStudio()

local boughtGamePasses = WeakInstanceTable()
local boughtPassUpdated = WeakInstanceTable()

local listeningPasses = {}

local GamePasses = {}

MarketplaceService.PromptGamePassPurchaseFinished:connect(function(player, gamePassId, purchased)
	if not purchased then return end
	boughtGamePasses[player] = boughtGamePasses[player] or {}
	boughtGamePasses[player][gamePassId] = true
	GamePasses.BoughtPassUpdated(player):Fire()
end)

function GamePasses.ListenForPass(gamePassId)
	if listeningPasses[gamePassId] then return end
	listeningPasses[gamePassId] = true

	local function checkGamePassOwnership(player)
		boughtGamePasses[player] = boughtGamePasses[player] or {}
		boughtGamePasses[player][gamePassId] = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
		GamePasses.BoughtPassUpdated(player):Fire()
	end

	if RunService:IsServer() then
		Players.PlayerAdded:connect(checkGamePassOwnership)
		for _, player in pairs(Players:GetPlayers()) do
			coroutine.wrap(checkGamePassOwnership)(player)
		end
	else
		coroutine.wrap(checkGamePassOwnership)(Players.LocalPlayer)
	end
end

function GamePasses.PlayerOwnsPass(player, gamePassId)
	boughtGamePasses[player] = boughtGamePasses[player] or {}
	return freeGamePasses or not not boughtGamePasses[player][gamePassId]
end

function GamePasses.BoughtPassUpdated(player)
	local player = player or Players.LocalPlayer
	local event = boughtPassUpdated[player]
	if event == nil then
		event = Instance.new("BindableEvent")
		boughtPassUpdated[player] = event
	end
	return event
end

function GamePasses.PlayerOwnsPassAsync(player, gamePassId)
	boughtGamePasses[player] = boughtGamePasses[player] or {}

	return Promise.promisify(function()
		while boughtGamePasses[player][gamePassId] == nil do
			GamePasses.BoughtPassUpdated(player).Event:wait()
		end

		return GamePasses.PlayerOwnsPass(player, gamePassId)
	end)()
end

return GamePasses
