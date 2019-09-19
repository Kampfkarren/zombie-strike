local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Data = require(ReplicatedStorage.Core.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootInfoButton = require(ReplicatedStorage.Core.UI.LootInfoButton)
local State = require(ReplicatedStorage.State)
local TradeConstants = require(ReplicatedStorage.TradeConstants)
local UserThumbnail = require(ReplicatedStorage.Core.UI.UserThumbnail)
local ViewportFramePreview = require(ReplicatedStorage.Core.UI.ViewportFramePreview)

local LocalPlayer = Players.LocalPlayer
local Main = script.Parent.Main

local Trading = Main.Trading

local Inner = Trading.Inner

local TWEEN_TIME = 0.3

local open = false
local openTick = 0

local tweens = {
	In = TweenService:Create(
		Trading,
		TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, 0, 0.5, 0) }
	),

	Out = TweenService:Create(
		Trading,
		TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, 0, 1.5, 0) }
	),
}

local function cloneAndDestroy(object)
	local output = object:Clone()
	object:Destroy()
	return output
end

local function toggle(newOpen)
	open = newOpen
	local ourTick = openTick + 1
	openTick = ourTick

	if open then
		Trading.Visible = true
		tweens.In:Play()
	else
		tweens.Out:Play()
		delay(TWEEN_TIME, function()
			if openTick == ourTick then
				Trading.Visible = false
			end
		end)
	end
end

-- Player screen
do
	local PlayersFrame = Inner.Select.Players

	local CancelTrade = ReplicatedStorage.Remotes.CancelTrade
	local RequestTrade = ReplicatedStorage.Remotes.RequestTrade

	local Template = cloneAndDestroy(PlayersFrame.Template)

	local cards = {}

	local function playerAdded(player)
		if player == LocalPlayer then return end
		local playerData = player:WaitForChild("PlayerData")

		local card = Template:Clone()

		local cardInner = card.Inner
		cardInner.Level.Text = "LV. " .. playerData:WaitForChild("Level").Value
		cardInner.Username.Text = player.Name
		card.Parent = PlayersFrame

		UserThumbnail(player):andThen(function(avatar)
			if player:IsDescendantOf(game) then
				cardInner.Avatar.Image = avatar
			end
		end)

		cardInner.TradeButton.MouseButton1Click:connect(function()
			cardInner.TradeButton.ImageColor3 = Color3.new(1, 1, 1)
			cardInner.TradeButton.Label.Text = "..."
			RequestTrade:FireServer(player)
		end)

		cards[player] = card
	end

	local function resetTradeButton(otherPlayer)
		local card = cards[otherPlayer]

		if card then
			card.Inner.TradeButton.ImageColor3 = Template.Inner.TradeButton.ImageColor3
			card.Inner.TradeButton.Label.Text = Template.Inner.TradeButton.Label.Text
		end
	end

	CancelTrade.OnClientEvent:connect(function(otherPlayer, code)
		resetTradeButton(otherPlayer)
		Inner.UIPageLayout:JumpTo(Inner.Select)

		local color = Color3.fromRGB(252, 92, 101)

		if code == TradeConstants.Codes.SuccessfulTrade then
			color = Color3.fromRGB(70, 255, 57)
			toggle(false)
		end

		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = TradeConstants.Messages[code]:format(otherPlayer.Name),
			Color = color,
			Font = Enum.Font.GothamSemibold,
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

	Players.PlayerAdded:connect(playerAdded)
	for _, player in pairs(Players:GetPlayers()) do
		coroutine.wrap(playerAdded)(player)
	end

	Players.PlayerRemoving:connect(function(player)
		if cards[player] then
			cards[player]:Destroy()
			cards[player] = nil
		end
	end)
end

-- Trade Window
do
	local AcceptTrade = ReplicatedStorage.Remotes.AcceptTrade
	local PingTrade = ReplicatedStorage.Remotes.PingTrade
	local StartTrade = ReplicatedStorage.Remotes.StartTrade
	local UpdateTrade = ReplicatedStorage.Remotes.UpdateTrade

	local TradeWindow = Inner.TradeWindow.Inner

	local AcceptButton = TradeWindow.Offers.YourOffer.Topbar.AcceptButton
	local Template = cloneAndDestroy(TradeWindow.YourInventory.Contents.Template)
	local TheirOfferLabel = TradeWindow.Offers.TheirOffer.Label

	local buttons = { them = {}, us = {} }
	local inventories = { them = {}, us = {} }
	local offers = { them = {}, us = {} }

	local lastPing = 0

	local function ping(button)
		coroutine.wrap(function()
			for count = 0, 11 do
				button.BackgroundTransparency = count % 2

				local dt = 0
				repeat
					dt = dt + RunService.Heartbeat:wait()
				until dt >= 0.15
			end
		end)()
	end

	local function fillInventory(frame, inventory, lootInfo, key)
		for _, thing in pairs(frame:GetChildren()) do
			if thing.Name == "Template" then
				thing:Destroy()
			end
		end

		inventories[key] = inventory

		for index, item in ipairs(inventory) do
			local color = Loot.Rarities[item.Rarity].Color

			local button = Template:Clone()
			button.LayoutOrder = -index
			button.ImageColor3 = color
			ViewportFramePreview(button.ViewportFrame, Data.GetModel(item))

			LootInfoButton(button, lootInfo, item)

			if key == "us" then
				button.MouseButton1Click:connect(function()
					UpdateTrade:FireServer(index)
				end)
			else
				button.MouseButton1Click:connect(function()
					if tick() - lastPing >= 3 then
						lastPing = tick()
						PingTrade:FireServer(index)
						ping(button)
					end
				end)
			end

			button.Parent = frame
			buttons[key][index] = button
		end
	end

	for _, button in pairs(TradeWindow.Offers.YourOffer.Contents:GetChildren()) do
		local index = tonumber(button.Name)
		if index then
			button.MouseButton1Click:connect(function()
				UpdateTrade:FireServer(-index)
			end)
		end
	end

	AcceptButton.MouseButton1Click:connect(function()
		AcceptTrade:FireServer()
	end)

	local function toggleAccept(us, accepted)
		if us then
			if accepted then
				AcceptButton.ImageColor3 = Color3.fromRGB(214, 48, 49)
				AcceptButton.Label.Text = "UNACCEPT"
			else
				AcceptButton.ImageColor3 = Color3.fromRGB(70, 255, 57)
				AcceptButton.Label.Text = "ACCEPT"
			end
		else
			if accepted then
				TheirOfferLabel.Text = "✅THEIR OFFER"
			else
				TheirOfferLabel.Text = "THEIR OFFER"
			end
		end
	end

	AcceptTrade.OnClientEvent:connect(toggleAccept)

	PingTrade.OnClientEvent:connect(function(index)
		ping(buttons.us[index])
	end)

	StartTrade.OnClientEvent:connect(function(theirInventory)
		local ourInventory = State:getState().inventory
		assert(ourInventory, "ourInventory == nil when starting a trade!")

		fillInventory(
			TradeWindow.TheirInventory.Contents,
			Loot.DeserializeTable(theirInventory),
			TradeWindow.YourInventory.LootInfo,
			"them"
		)

		fillInventory(
			TradeWindow.YourInventory.Contents,
			ourInventory,
			TradeWindow.TheirInventory.LootInfo,
			"us"
		)

		Inner.UIPageLayout:JumpTo(Inner.TradeWindow)
		toggle(true)
	end)

	UpdateTrade.OnClientEvent:connect(function(us, code)
		toggleAccept(true, false)
		toggleAccept(false, false)

		local key = us and "us" or "them"
		local itemId = math.abs(code)

		local offerWindow

		if us then
			offerWindow = TradeWindow.Offers.YourOffer
		else
			offerWindow = TradeWindow.Offers.TheirOffer
		end

		if code > 0 then
			local button = buttons[key][itemId]
			local item = inventories[key][itemId]

			button.Visible = false

			local color = Loot.Rarities[item.Rarity].Color

			local visual = offerWindow.Contents[#offers[key] + 1]
			visual.ImageColor3 = color
			ViewportFramePreview(visual.ViewportFrame, Data.GetModel(item))

			local offer = LootInfoButton(visual, TradeWindow.TheirInventory.LootInfo, item)
			table.insert(offers[key], { button = button, item = item, maid = offer })
		else
			local offer = table.remove(offers[key], itemId)
			offer.button.Visible = true
			offer.maid:DoCleaning()

			-- Fix parts of the offer after this item
			for index = itemId, #offers[key] do
				local offer = offers[key][index]
				local button = offerWindow.Contents[index]

				offer.maid:DoCleaning()

				local color = Loot.Rarities[offer.item.Rarity].Color
				button.ImageColor3 = color
				button.ViewportFrame:ClearAllChildren()
				ViewportFramePreview(button.ViewportFrame, Data.GetModel(offer.item))

				offers[key][index].maid = LootInfoButton(button, TradeWindow.TheirInventory.LootInfo, offer.item)
			end

			-- Fix ones after the items
			for index = #offers[key] + 1, 10 do
				local button = offerWindow.Contents[index]
				button.ImageColor3 = Color3.new(1, 1, 1)
				button.ViewportFrame:ClearAllChildren()
			end
		end
	end)
end

local function close()
	local currentPage = Inner.UIPageLayout.CurrentPage
	if currentPage == Inner.TradeWindow then
		ReplicatedStorage.Remotes.CancelTrade:FireServer()
	else
		toggle(false)
	end
end

Trading.Close.MouseButton1Click:connect(close)
Main.Buttons.Trading.MouseButton1Click:connect(function()
	if open then
		close()
	else
		toggle(not open)
	end
end)

