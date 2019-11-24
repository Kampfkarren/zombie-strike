local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local LootInfo = require(ReplicatedStorage.Core.UI.Components.LootInfo)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local State = require(ReplicatedStorage.State)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer

local TreasureLoot = Roact.PureComponent:extend("TreasureLoot")

local PRODUCT_EPIC = 934232605
local PRODUCT_LEGENDARY = 934232697

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local function DashLine(props)
	return e("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0.1, 0.1, 0.1),
		BorderSizePixel = 1,
		Position = props.Right and UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(0.005, 1),
	})
end

local function buyLoot()
	local epic = State:getState().treasureLoot.loot.Rarity == 4
	MarketplaceService:PromptProductPurchase(
		LocalPlayer,
		epic and PRODUCT_EPIC or PRODUCT_LEGENDARY
	)
end

function TreasureLoot:init()
	self.buyHotkey = UserInputService.InputBegan:connect(function(inputObject, processed)
		if processed then return end
		if inputObject.KeyCode == Enum.KeyCode.B then
			buyLoot()
		end
	end)
end

function TreasureLoot:willUnmount()
	self.buyHotkey:Disconnect()
end

function TreasureLoot:render()
	if not self.props.treasure then
		return e("Frame")
	end

	local hotkey

	if UserInputService.KeyboardEnabled then
		hotkey = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.5, 0.6),
			Size = UDim2.fromScale(0.25, 0.1),
			Text = "Press [B] to unlock!",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextStrokeColor3 = Color3.new(0.1, 0.1, 0.1),
			TextStrokeTransparency = 0,
		})
	else
		hotkey = e("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(76, 209, 55),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.5, 0.1),
			Size = UDim2.fromScale(0.25, 0.1),
			Text = "BUY",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			[Roact.Event.Activated] = buyLoot,
		})
	end

	local loot = copy(self.props.treasure)
	loot.Level = LocalPlayer:WaitForChild("PlayerData"):WaitForChild("Level").Value

	for key, value in pairs(GunScaling.BaseStats(loot.Type, loot.Level, loot.Rarity)) do
		if loot[key] == nil then
			loot[key] = value
		end
	end

	local rarityName = "EPIC"
	if loot.Rarity == 5 then
		rarityName = "LEGENDARY"
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = self.props.open and not self.props.bought,
	}, {
		Inner = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(142, 68, 173),
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.07, 0.5),
			Size = UDim2.fromScale(1, 0.8),
		}, {
			UIAspectRatioConstraint = e("UIAspectRatioConstraint", {
				AspectRatio = 0.6,
				AspectType = Enum.AspectType.ScaleWithParentSize,
				DominantAxis = Enum.DominantAxis.Height,
			}),

			LootInfo = e(LootInfo, {
				Native = {
					Size = UDim2.fromScale(1, 1),
				},

				Loot = loot,
			}),
		}),

		Notice = e("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.5, 0.2),
			Size = UDim2.fromScale(0.4, 0.15),
			Text = "This chest gives " .. rarityName .." loot to your WHOLE TEAM!",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextStrokeColor3 = Color3.new(0.1, 0.1, 0.1),
			TextStrokeTransparency = 0,
		}, {
			Left = e(DashLine),
			Right = e(DashLine, { Right = true }),
		}),

		Hotkey = hotkey,
	})
end

return RoactRodux.connect(function(state)
	return {
		bought = state.treasureLoot.bought,
		open = state.treasureLoot.open,
		treasure = state.treasureLoot.loot,
	}
end)(TreasureLoot)
