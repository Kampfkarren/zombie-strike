local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutomatedScrollingFrameComponent = require(script.Parent.Parent.AutomatedScrollingFrameComponent)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local FastSpawn = require(ReplicatedStorage.Core.FastSpawn)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local StyledButton = require(ReplicatedStorage.Core.UI.Components.StyledButton)
local UserThumbnail = require(ReplicatedStorage.Core.UI.Components.UserThumbnail)

local e = Roact.createElement

local PlayerListing = Roact.PureComponent:extend("PlayerListing")

local LocalPlayer = Players.LocalPlayer

local CancelTrade = ReplicatedStorage.Remotes.CancelTrade
local RequestTrade = ReplicatedStorage.Remotes.RequestTrade
local StartTrade = ReplicatedStorage.Remotes.StartTrade

function PlayerListing:init()
	local player = self.props.player

	FastSpawn(function()
		self:setState({
			level = player
				:WaitForChild("PlayerData")
				:WaitForChild("Level")
				.Value,
		})
	end)

	self.cancel = function()
		self:setState({
			asking = false,
		})
	end

	self.maybeCancel = function(otherPlayer)
		if otherPlayer == player then
			self.cancel()
		end
	end

	self.trade = function()
		self:setState({
			asking = true,
		})

		RequestTrade:FireServer(player)
	end
end

function PlayerListing:render()
	if not self.state.level then
		return Roact.createFragment()
	end

	local player = self.props.player

	local tradeButton

	if self.state.asking then
		tradeButton = e(StyledButton, {
			BackgroundColor3 = Color3.fromRGB(163, 163, 163),
			LayoutOrder = 3,
			Size = UDim2.fromScale(0.3, 1),
		}, {
			Label = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.75),
				Text = "...",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),
		})
	else
		tradeButton = e(StyledButton, {
			BackgroundColor3 = Color3.fromRGB(172, 119, 44),
			LayoutOrder = 3,
			Size = UDim2.fromScale(0.3, 1),
			[Roact.Event.Activated] = self.trade,
		}, {
			Label = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.75),
				Text = "TRADE",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0.01, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Avatar = e(UserThumbnail, {
			Player = player,

			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
		}),

		Username = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = 1,
			Size = UDim2.fromScale(0.3, 1),
			Text = player.Name,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),

		LevelLabel = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			LayoutOrder = 2,
			Size = UDim2.fromScale(0.2, 0.7),
			Text = "LV. " .. self.state.level,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),

		TradeButton = tradeButton,

		CancelConnection = e(EventConnection, {
			callback = self.maybeCancel,
			event = CancelTrade.OnClientEvent,
		}),

		StartTradeConnection = e(EventConnection, {
			callback = self.cancel,
			event = StartTrade.OnClientEvent,
		})
	})
end

local SelectScreen = Roact.PureComponent:extend("SelectScreen")

function SelectScreen:init()
	self:GeneratePlayerList()

	Players.PlayerAdded:connect(function()
		self:GeneratePlayerList()
	end)

	Players.PlayerRemoving:connect(function()
		self:GeneratePlayerList()
	end)
end

function SelectScreen:render()
	local children = {}

	children.UIGridLayout = e("UIGridLayout", {
		CellSize = UDim2.fromScale(0.5, 0.15),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}, {
		UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
			AspectRatio = 6,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}),
	})

	for _, player in pairs(self.state.players) do
		if player ~= LocalPlayer then
			children[player.Name] = e(StyledButton, {
				BackgroundColor3 = Color3.fromRGB(163, 163, 163),
			}, {
				Inner = e("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.98, 0.8),
				}, {
					PlayerListing = e(PlayerListing, {
						player = player,
					})
				}),
			})
		end
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Players = e(AutomatedScrollingFrameComponent, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.98, 0.9),
		}, children)
	})
end

function SelectScreen:GeneratePlayerList()
	self:setState({
		players = Players:GetPlayers(),
	})
end

return SelectScreen
