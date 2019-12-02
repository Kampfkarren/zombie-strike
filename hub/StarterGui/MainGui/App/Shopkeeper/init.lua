local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ConfirmPrompt = require(ReplicatedStorage.Core.UI.Components.ConfirmPrompt)
local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)
local InventoryContents = require(script.Parent.Inventory.InventoryContents)
local LootInfo = require(ReplicatedStorage.Core.UI.Components.LootInfo)
local Modalifier = require(ReplicatedStorage.Core.UI.Components.Modalifier)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local SellCost = require(ReplicatedStorage.Libraries.SellCost)
local StyledButton = require(ReplicatedStorage.Core.UI.Components.StyledButton)
local Upgrades = require(ReplicatedStorage.Core.Upgrades)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer
local Sell = ReplicatedStorage.Remotes.Sell
local Upgrade = ReplicatedStorage.Remotes.Upgrade

local ShopkeeperGui = Roact.PureComponent:extend("ShopkeeperGui")

local DISABLED_COLOR = Color3.new(0.4, 0.4, 0.4)
local GOLD_COLOR = Color3.fromRGB(251, 197, 49)
local SELL_COLOR = Color3.fromRGB(195, 64, 50)
local UPGRADE_COLOR = Color3.fromRGB(32, 146, 81)

local function copy(list)
	local copy = {}
	for index, value in pairs(list) do
		copy[index] = value
	end
	return copy
end

function ShopkeeperGui:init()
	self.ref = Roact.createRef()

	self:setState({
		lootStack = {},
		selected = nil,
	})

	self.onHover = function(loot, id)
		local lootStack = copy(self.state.lootStack)
		lootStack[loot] = {
			loot = loot,
			equipped = self.props.equippedItems[id],
		}

		self:setState({
			lootStack = lootStack,
		})
	end

	self.onUnhover = function(loot)
		local lootStack = copy(self.state.lootStack)
		lootStack[loot] = nil

		self:setState({
			lootStack = lootStack,
		})
	end

	self.onClickEquipped = function(loot)
		self:setState({
			selected = {
				loot = loot,
				equipped = true,
			},
		})
	end

	self.onClickUnequipped = function(loot)
		self:setState({
			selected = {
				loot = loot,
				equipped = false,
			},
		})
	end

	self.sellAll = function()
		self:setState({
			selling = true,
		})
	end

	self.closeSellAll = function()
		self:setState({
			selling = false,
		})
	end

	self.trulySellAll = function()
		Sell:FireServer("*")
		self.closeSellAll()
	end
end

function ShopkeeperGui:render()
	local activeButton, lootInfo, tooltip
	local selected = self.state.selected

	if selected ~= nil then
		local loot = selected.loot
		if selected.equipped and loot.Upgrades < Upgrades.MaxUpgrades then
			loot = copy(loot)
			loot.Upgrades = loot.Upgrades + 1
		end

		lootInfo = e(LootInfo, {
			Native = {
				Size = UDim2.fromScale(1, 0.8),
			},

			Loot = loot,
		})

		local text, color, activated

		if selected.equipped then
			if loot.Upgrades >= Upgrades.MaxUpgrades then
				color = DISABLED_COLOR
				text = "MAX UPGRADE"
			else
				local upgradeCost = Upgrades.CostToUpgrade(loot)

				if upgradeCost < LocalPlayer.PlayerData.Gold.Value then
					color = UPGRADE_COLOR
				else
					color = DISABLED_COLOR
				end

				text = "UPGRADE (" .. EnglishNumbers(upgradeCost) .. " G)"

				activated = function()
					Upgrade:FireServer(loot.UUID)
					self:setState({
						selected = {
							equipped = true,
							loot = loot,
						},
					})
				end
			end
		else
			text = "SELL (" .. EnglishNumbers(SellCost(loot)) .. " G)"
			color = SELL_COLOR

			activated = function()
				Sell:FireServer(loot.UUID)
			end
		end

		assert(text ~= nil)
		assert(color ~= nil)

		activeButton = e(StyledButton, {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = color,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.05),
			Size = UDim2.fromScale(0.95, 1),
			[Roact.Event.Activated] = activated,
		}, {
			e("UIAspectRatioConstraint", {
				AspectRatio = 4,
			}),

			Label = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.75),
				Text = text,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),
		})
	end

	local _, hovered = next(self.state.lootStack)
	local itemButtonChildren

	if hovered ~= nil then
		local color = hovered.equipped and UPGRADE_COLOR or SELL_COLOR
		local tooltipText = hovered.equipped and "UPGRADE" or "SELL"

		tooltip = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.8),
			Size = UDim2.fromScale(1, 0.25),
		}, {
			TooltipText = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.95, 0.95),
				Text = tooltipText,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
			}),
		})

		itemButtonChildren = {
			[hovered.loot.UUID] = {
				Tooltip = tooltip,
			}
		}
	end

	local sellAllDropdown

	if self.state.selling then
		sellAllDropdown = e(ConfirmPrompt, {
			Window = self.ref:getValue(),
			Text = "Are you sure you want to sell ALL unequipped and unfavorited items?",
			Yes = self.trulySellAll,
			No = self.closeSellAll,
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.6, 0.7),
		Visible = self.props.open,
		[Roact.Ref] = self.ref,
	}, {
		e("UIAspectRatioConstraint", {
			AspectRatio = 2,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}),

		InventoryContents = e(InventoryContents, {
			Native = {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(0.7, 0.95),
			},

			onHover = self.onHover,
			onUnhover = self.onUnhover,
			onClickInventoryEquipped = self.onClickEquipped,
			onClickInventoryUnequipped = self.onClickUnequipped,

			itemButtonChildren = itemButtonChildren,
		}),

		LootInfo = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(0.3, 1),
		}, {
			Buttons = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 1),
				Size = UDim2.fromScale(0.95, 0.2),
			}, {
				ActiveButton = activeButton,
			}),

			Inner = lootInfo,
		}),

		Gold = e("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(0.69, 1),
			Size = UDim2.fromScale(0.3, 0.1),
			Text = EnglishNumbers(self.props.gold) .. " G",
			TextColor3 = GOLD_COLOR,
			TextScaled = true,
			TextStrokeTransparency = 0,
			TextXAlignment = Enum.TextXAlignment.Right,
		}),

		SellAll = e("TextButton", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = SELL_COLOR,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromScale(0.3, 0.1),
			Text = "SELL ALL",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			[Roact.Event.Activated] = self.sellAll,
		}),

		SellAllDropdown = sellAllDropdown,
	})
end

function ShopkeeperGui.getDerivedStateFromProps(nextProps, lastState)
	if lastState.lastInventory == nextProps.inventory then
		return {}
	end

	local knownUuids = {}
	for index, knownItem in pairs(nextProps.inventory or {}) do
		knownUuids[knownItem.UUID] = { index, knownItem }
	end

	local selected = lastState.selected
	if selected then
		local knownSelected = knownUuids[selected.loot.UUID]
		if knownSelected then
			selected = {
				equipped = nextProps.equippedItems[knownSelected[1]],
				loot = knownSelected[2],
			}
		else
			selected = Roact.None
		end
	end

	return {
		lastInventory = nextProps.inventory,
		lootStack = {},
		selected = selected,
	}
end

return RoactRodux.connect(function(state)
	local equippedItems = {}

	local equipment = state.equipment
	if equipment ~= nil then
		equippedItems[equipment.armor] = true
		equippedItems[equipment.helmet] = true
		equippedItems[equipment.weapon] = true
	end

	return {
		equippedItems = equippedItems,
		gold = state.gold,
		inventory = state.inventory,
		open = state.page.current == "Shopkeeper",
	}
end)(ShopkeeperGui)
