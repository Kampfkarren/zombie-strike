local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Loot = require(ReplicatedStorage.Core.Loot)
local State = require(ReplicatedStorage.State)
local TradeConstants = require(ReplicatedStorage.TradeConstants)
local UserThumbnail = require(ReplicatedStorage.Core.UI.UserThumbnail)

local CancelTrade = ReplicatedStorage.Remotes.CancelTrade
local RequestTrade = ReplicatedStorage.Remotes.RequestTrade
local StartTrade = ReplicatedStorage.Remotes.StartTrade
local UpdateTrade = ReplicatedStorage.Remotes.UpdateTrade

CancelTrade.OnClientEvent:connect(function(otherPlayer, code)
	local color = Color3.fromRGB(252, 92, 101)

	if code == TradeConstants.Codes.SuccessfulTrade then
		color = Color3.fromRGB(70, 255, 57)
	end

	StarterGui:SetCore("ChatMakeSystemMessage", {
		Text = TradeConstants.Messages[code]:format(otherPlayer.Name),
		Color = color,
		Font = Enum.Font.GothamSemibold,
	})

	StarterGui:SetCore("ChatActive", true)

	State:dispatch({
		type = "CloseTrade",
	})
end)

RequestTrade.OnClientEvent:connect(function(requester)
	local avatarImage = ""
	UserThumbnail(requester):andThen(function(avatar)
		avatarImage = avatar
	end)

	local callback = Instance.new("BindableFunction")
	callback.OnInvoke = function(text)
		if text == "Accept" then
			RequestTrade:FireServer(requester)
		else
			CancelTrade:FireServer(requester)
		end
	end

	StarterGui:SetCore("SendNotification", {
		Title = "Trade Request",
		Text = requester.Name .. " wants to trade!",
		Icon = avatarImage,
		Callback = callback,
		Button1 = "Accept",
		Button2 = "Deny",
	})
end)

StartTrade.OnClientEvent:connect(function(theirInventory, theirEquipment)
	State:dispatch({
		type = "OpenNewTrade",
		theirInventory = Loot.DeserializeTableWithBase(theirInventory),
		theirEquipment = theirEquipment,
	})
end)

UpdateTrade.OnClientEvent:connect(function(us, new, uuid)
	State:dispatch({
		type = new and "OfferTrade" or "TakeDownTrade",
		who = us and "us" or "them",
		uuid = uuid,
	})
end)
