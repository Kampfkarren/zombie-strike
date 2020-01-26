local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local ChatConstants = require(ReplicatedStorage.ChatConstants)
local Data = require(ReplicatedStorage.Core.Data)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local InventoryUtil = require(ServerScriptService.Libraries.InventoryUtil)
local Loot = require(ReplicatedStorage.Core.Loot)
local Promise = require(ReplicatedStorage.Core.Promise)
local Settings = require(ReplicatedStorage.Core.Settings)
local t = require(ReplicatedStorage.Vendor.t)
local TradeConstants = require(ReplicatedStorage.TradeConstants)

local AcceptTrade = ReplicatedStorage.Remotes.AcceptTrade
local CancelTrade = ReplicatedStorage.Remotes.CancelTrade
local PingTrade = ReplicatedStorage.Remotes.PingTrade
local RequestTrade = ReplicatedStorage.Remotes.RequestTrade
local StartTrade = ReplicatedStorage.Remotes.StartTrade
local UpdateTrade = ReplicatedStorage.Remotes.UpdateTrade

-- Map<Trader, Map<RequestingFrom, resolve>>
local requesting = {}

-- Map<Trader, { accepted: boolean, otherState: TradeState, tradingWith: Player, items: index[] }>
local tradeStates = {}

local pings = {}

local MAX_ITEMS = 10
local NEAR_LEVEL = 8
local PING_COOLDOWN = 2
local SAME_PLAYER_TESTING = false
local REQUEST_TIMEOUT = 7

local function getEquipment(player)
	local equipment = {}
	local inventory = Data.GetPlayerData(player, "Inventory")

	for equippable in pairs(Data.Equippable) do
		local index = Data.GetPlayerData(player, "Equipped" .. equippable)
		local item = inventory[index]
		table.insert(equipment, item.UUID)
	end

	return equipment
end

local function legitInventory(inventory)
	local items = {}

	for _, item in pairs(inventory) do
		if items[item.UUID] then
			return false
		else
			items[item.UUID] = true
		end
	end

	return true
end

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

	local inventory = Data.GetPlayerData(player, "Inventory")
	if not legitInventory(inventory) then
		warn("duped inventory")
		CancelTrade:FireClient(player, otherPlayer, TradeConstants.Codes.RejectDuped)
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

	local tradeRequestSetting = Settings.GetSettingIndex("Trade Requests", otherPlayer)
	local settingsCancel = false
	if tradeRequestSetting == 2 then
		local ourLevel, theirLevel = Data.GetPlayerData(player, "Level"), Data.GetPlayerData(otherPlayer, "Level")
		settingsCancel = math.abs(ourLevel - theirLevel) > NEAR_LEVEL
	elseif tradeRequestSetting == 3 then
		settingsCancel = true
	end

	if settingsCancel then
		warn("settings disallow")
		CancelTrade:FireClient(player, otherPlayer, TradeConstants.Codes.RejectSettings)
		return
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

		Instance.new("Folder", player).Name = "Trading"
		Instance.new("Folder", otherPlayer).Name = "Trading"

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
			),
			getEquipment(otherPlayer)
		)

		StartTrade:FireClient(
			otherPlayer,
			Loot.SerializeTable(
				Data.GetPlayerData(player, "Inventory")
			),
			getEquipment(player)
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

	local tradeFlag1 = player:FindFirstChild("Trading")
	local tradeFlag2 = other:FindFirstChild("Trading")

	if tradeFlag1 then
		tradeFlag1:Destroy()
	end

	if tradeFlag2 then
		tradeFlag2:Destroy()
	end

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
	if tradeStates[player] then
		cancelTrade(player, TradeConstants.Codes.RejectLeave)
	end
end)

AcceptTrade.OnServerEvent:connect(function(player)
	local tradeState = tradeStates[player]
	if not tradeState then
		warn("AcceptTrade: no tradeState")
		return
	end

	if tradeFinishing(tradeState) then
		warn("AcceptTrade: tradeFinishing")
		return
	end

	tradeState.accepted = not tradeState.accepted
	local other = tradeState.otherState

	if other.accepted then
		tradeState.processing = true
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
			give.Favorited = false
			table.insert(theirInventory, give)
		end

		for _, receive in pairs(receiving) do
			receive.Favorited = false
			table.insert(ourInventory, receive)
		end

		ourStore:Set(ourInventory)
		theirStore:Set(theirInventory)

		cancelTrade(
			player,
			TradeConstants.Codes.SuccessfulTrade,
			TradeConstants.Codes.SuccessfulTrade
		)

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

PingTrade.OnServerEvent:connect(function(player, uuid)
	local tradeState = tradeStates[player]

	if typeof(uuid) ~= "string" then
		return
	end

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

	PingTrade:FireClient(tradeState.tradingWith, uuid)
end)

UpdateTrade.OnServerEvent:connect(function(player, uuid, remove)
	local inventory = Data.GetPlayerData(player, "Inventory")
	local _, index = InventoryUtil.FindByUuid(inventory, uuid)

	if index == nil then
		warn("UpdateTrade: index == nil")
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

	if InventorySpace(tradeState.tradingWith):awaitValue()
		- #Data.GetPlayerData(tradeState.tradingWith, "Inventory")
		<= #tradeState.items
	then
		ReplicatedStorage.Remotes.ChatMessage:FireClient(player, ChatConstants.Codes.TradeTooMuch)
		return
	end

	tradeState.accepted = false
	tradeState.otherState.accepted = false

	if remove then
		local indexInItems = table.find(tradeState.items, index)

		if indexInItems == nil then
			warn("UpdateTrade: indexInItems == nil (removing item not in trade)")
		end

		table.remove(tradeState.items, indexInItems)

		UpdateTrade:FireClient(player, true, false, uuid)
		UpdateTrade:FireClient(tradeState.tradingWith, false, false, uuid)
	else
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
		UpdateTrade:FireClient(player, true, true, uuid)
		UpdateTrade:FireClient(tradeState.tradingWith, false, true, uuid)
	end
end)

ServerStorage.EquipmentUpdated.Event:connect(function(player)
	local tradeState = tradeStates[player]
	if not tradeState then return end
	if tradeState.processing then return end
	cancelTrade(player, TradeConstants.Codes.RejectEquipYou, TradeConstants.Codes.RejectEquipThem)
end)
