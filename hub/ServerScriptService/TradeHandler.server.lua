local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local ChatConstants = require(ReplicatedStorage.ChatConstants)
local Data = require(ReplicatedStorage.Libraries.Data)
local InventoryUtil = require(ServerScriptService.Libraries.InventoryUtil)
local Loot = require(ReplicatedStorage.Core.Loot)
local Promise = require(ReplicatedStorage.Core.Promise)
local t = require(ReplicatedStorage.Vendor.t)
local TradeConstants = require(ReplicatedStorage.TradeConstants)

local AcceptTrade = ReplicatedStorage.Remotes.AcceptTrade
local CancelTrade = ReplicatedStorage.Remotes.CancelTrade
local PingTrade = ReplicatedStorage.Remotes.PingTrade
local RequestTrade = ReplicatedStorage.Remotes.RequestTrade
local StartTrade = ReplicatedStorage.Remotes.StartTrade
local UpdateTrade = ReplicatedStorage.Remotes.UpdateTrade

-- TODO: Don't let inventory be modified in any way while trading

-- Map<Trader, Map<RequestingFrom, resolve>>
local requesting = {}

-- Map<Trader, { accepted: boolean, otherState: TradeState, tradingWith: Player, items: index[] }>
local tradeStates = {}

local pings = {}

local MAX_ITEMS = 10
local PING_COOLDOWN = 2
local SAME_PLAYER_TESTING = false
local REQUEST_TIMEOUT = 7

RequestTrade.OnServerEvent:connect(function(player, otherPlayer)
	if not t.instanceOf("Player")(otherPlayer) then
		warn("not a player")
		return
	end

	if not otherPlayer:IsDescendantOf(game) then
		warn("player already left")
		CancelTrade:FireClient(player, otherPlayer)
		return
	end

	if tradeStates[otherPlayer] then
		warn("player busy")
		CancelTrade:FireClient(player, otherPlayer, TradeConstants.Codes.RejectBusy)
		return
	end

	if player == otherPlayer and not SAME_PLAYER_TESTING then
		warn("same player")
		return
	end

	if requesting[player][otherPlayer] and not SAME_PLAYER_TESTING then
		warn("player trading the same person already")
		return
	end

	-- Check if the person they're requesting a trade from invited them
	for trader, resolve in pairs(requesting[otherPlayer]) do
		if trader == player then
			resolve(true)
			return
		end
	end

	RequestTrade:FireClient(otherPlayer, player)
	Promise.race({
		-- Let other things resolve for us
		Promise.new(function(resolve)
			requesting[player][otherPlayer] = resolve
		end),

		-- Timeout
		Promise.new(function(resolve)
			delay(REQUEST_TIMEOUT, function()
				resolve(false, TradeConstants.Codes.RejectTimeout)
			end)
		end),
	}):andThen(function(success, errorCode)
		if not success then
			CancelTrade:FireClient(player, otherPlayer, errorCode)
			return
		end

		local state1 = {
			accepted = false,
			items = {},
			tradingWith = otherPlayer,
		}

		local state2 = {
			accepted = false,
			items = {},
			tradingWith = player,
		}

		state1.otherState = state2
		state2.otherState = state1

		tradeStates[player] = state1
		tradeStates[otherPlayer] = state2

		StartTrade:FireClient(
			player,
			Loot.SerializeTable(
				Data.GetPlayerData(otherPlayer, "Inventory")
			)
		)

		StartTrade:FireClient(
			otherPlayer,
			Loot.SerializeTable(
				Data.GetPlayerData(player, "Inventory")
			)
		)
	end):finally(function()
		requesting[player][otherPlayer] = nil

		for _, resolve in pairs(requesting[player]) do
			resolve(false, TradeConstants.Codes.RejectAnother)
		end

		requesting[player] = {}
	end)
end)

Players.PlayerAdded:connect(function(player)
	requesting[player] = {}
end)

local function cancelTrade(player, codeForThem, codeForYou)
	local tradeState = assert(tradeStates[player])
	local other = tradeState.tradingWith
	tradeStates[player] = nil
	tradeStates[other] = nil

	CancelTrade:FireClient(other, player, codeForThem)

	if codeForYou then
		CancelTrade:FireClient(player, other, codeForYou)
	end
end

local function tradeFinishing(tradeState)
	return tradeState.accepted and tradeState.otherState.accepted
end

Players.PlayerRemoving:connect(function(player)
	for _, resolve in pairs(requesting[player]) do
		resolve(false, TradeConstants.Codes.RejectLeave)
	end

	requesting[player] = nil
	cancelTrade(player, TradeConstants.Codes.RejectLeave)
end)

AcceptTrade.OnServerEvent:connect(function(player)
	local tradeState = tradeStates[player]
	if not tradeState then
		warn("no tradeState")
		return
	end

	if tradeFinishing(tradeState) then
		warn("AcceptTrade: tradeFinishing")
		return
	end

	tradeState.accepted = not tradeState.accepted
	local other = tradeState.otherState

	if other.accepted then
		local them = tradeState.tradingWith

		local giving = {}
		local receiving = {}

		local ourInventory = Data.GetPlayerData(player, "Inventory")
		local theirInventory = Data.GetPlayerData(them, "Inventory")

		for _, index in pairs(tradeState.items) do
			table.insert(giving, ourInventory[index])
		end

		for _, index in pairs(other.items) do
			table.insert(receiving, theirInventory[index])
		end

		local ourStore, theirStore

		ourInventory, ourStore = InventoryUtil.RemoveItems(player, tradeState.items, true)
		if player ~= them then
			theirInventory, theirStore = InventoryUtil.RemoveItems(them, other.items, true)
		end

		for _, give in pairs(giving) do
			table.insert(theirInventory, give)
		end

		for _, receive in pairs(receiving) do
			table.insert(ourInventory, receive)
		end

		ourStore:Set(ourInventory)
		theirStore:Set(theirInventory)

		tradeStates[player] = nil
		tradeStates[them] = nil

		CancelTrade:FireClient(player, them, TradeConstants.Codes.SuccessfulTrade)
		CancelTrade:FireClient(them, player, TradeConstants.Codes.SuccessfulTrade)

		return
	end

	AcceptTrade:FireClient(player, true, tradeState.accepted)
	AcceptTrade:FireClient(tradeState.tradingWith, false, tradeState.accepted)
end)

CancelTrade.OnServerEvent:connect(function(player, denyFrom)
	local tradeState = tradeStates[player]

	if tradeState then
		if tradeFinishing(tradeState) then
			warn("CancelTrade: tradeFinishing")
			return
		end

		cancelTrade(player, TradeConstants.Codes.RejectCloseThem, TradeConstants.Codes.RejectCloseYou)
	else
		local resolve = requesting[denyFrom][player]
		if resolve then
			resolve(false, TradeConstants.Codes.RejectDeny)
		end
	end
end)

PingTrade.OnServerEvent:connect(function(player, index)
	local tradeState = tradeStates[player]

	if not tradeState then
		warn("ping w/o tradeState")
		return
	end

	if pings[player] then
		return
	end

	pings[player] = true
	delay(PING_COOLDOWN, function()
		pings[player] = nil
	end)

	PingTrade:FireClient(tradeState.tradingWith, index)
end)

UpdateTrade.OnServerEvent:connect(function(player, index)
	if index == 0 then
		warn("UpdateTrade: index == 0")
		return
	end

	local tradeState = tradeStates[player]
	if not tradeState then
		warn("UpdateTrade: no tradeState")
		return
	end

	if tradeFinishing(tradeState) then
		warn("UpdateTrade: tradeFinishing")
		return
	end

	for equippable in pairs(Data.Equippable) do
		local equipped = Data.GetPlayerData(player, "Equipped" .. equippable)
		if equipped == index then
			ReplicatedStorage.Remotes.ChatMessage:FireClient(player, ChatConstants.Codes.TradeEquipped)
			return
		end
	end

	tradeState.accepted = false
	tradeState.otherState.accepted = false

	if index > 0 then
		if #tradeState.items == MAX_ITEMS then
			warn("too many items")
			return
		end

		-- adding an item
		for _, item in pairs(tradeState.items) do
			if item == index then
				warn("already put that item up")
				return
			end
		end

		table.insert(tradeState.items, index)
		UpdateTrade:FireClient(player, true, index)
		UpdateTrade:FireClient(tradeState.tradingWith, false, index)
	else
		local offer = table.remove(tradeState.items, -index)

		if not offer then
			warn("no offer item")
			return
		end

		UpdateTrade:FireClient(player, true, index)
		UpdateTrade:FireClient(tradeState.tradingWith, false, index)
	end
end)

ServerStorage.EquipmentUpdated.Event:connect(function(player)
	local tradeState = tradeStates[player]
	if not tradeState then return end
	cancelTrade(player, TradeConstants.Codes.RejectEquipYou, TradeConstants.Codes.RejectEquipThem)
end)
