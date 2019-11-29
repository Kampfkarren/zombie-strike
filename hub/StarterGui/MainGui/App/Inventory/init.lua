local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Alert = require(ReplicatedStorage.Core.UI.Components.Alert)
local Close = require(script.Parent.Close)
local Equipped = require(script.Equipped)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local GamePasses = require(ReplicatedStorage.Core.GamePasses)
local LootInfo = require(ReplicatedStorage.Core.UI.Components.LootInfo)
local InventoryContents = require(script.InventoryContents)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer
local UpdateCosmetics = ReplicatedStorage.Remotes.UpdateCosmetics
local UpdateEquipment = ReplicatedStorage.Remotes.UpdateEquipment

local Inventory = Roact.PureComponent:extend("Inventory")

local function copy(list)
	local copy = {}
	for index, value in pairs(list) do
		copy[index] = value
	end
	return copy
end

function Inventory:init()
	self:setState({
		levelWarningOpen = false,
		lootStack = {},
	})

	InventorySpace(LocalPlayer):andThen(function(space)
		self:setState({
			space = space,
		})
	end)

	self.onHover = function(loot)
		local lootStack = copy(self.state.lootStack)
		lootStack[loot.UUID] = loot
		self:setState({
			lootStack = lootStack,
		})
	end

	self.onUnhover = function(loot)
		local lootStack = copy(self.state.lootStack)
		lootStack[loot.UUID] = nil
		self:setState({
			lootStack = lootStack,
		})
	end

	self.resetInventorySpace = function()
		InventorySpace(LocalPlayer):andThen(function(space)
			self:setState({
				space = space,
			})
		end)
	end

	self.onCloseLevelWarning = function()
		self:setState({
			levelWarningOpen = false,
		})
	end
end

function Inventory:render()
	local props = self.props

	local lootInfo

	local _, hovered = next(self.state.lootStack)

	if hovered then
		lootInfo = e(LootInfo, {
			Native = {
				Size = UDim2.fromScale(1, 1),
			},

			Loot = hovered,
		})
	end

	local inventorySpace

	if self.state.space and props.inventory then
		inventorySpace = e("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			AutoLocalize = false,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromScale(0.97, 0.01),
			Size = UDim2.fromScale(0.23, 0.08),
			Text = ("%d/%d"):format(#props.inventory, self.state.space),
			TextColor3 = #props.inventory == self.state.space
				and Color3.fromRGB(252, 92, 101)
				or Color3.new(1, 1, 1),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 2,
		})
	end

	return e("Frame", {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.6, 0.7),
		Visible = self.props.open,
		ZIndex = 2,
	}, {
		e("UIAspectRatioConstraint", {
			AspectRatio = 2.3,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}),

		e(Close, {
			onClose = props.onClose,
			ZIndex = 2,
		}),

		Loadout = e("Frame", {
			BackgroundColor3 = Color3.fromRGB(18, 18, 18),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.25, 1),
		}, {
			e("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Face = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 0,
				Size = UDim2.fromScale(0.9, 0.25),
			}, {
				e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.05, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				e(Equipped, {
					LayoutOrder = 1,
					Cosmetic = true,
					Key = "Face",
					Name = "FACE",

					Default = {
						ParentType = "Face",
						Type = "Face",
						Image = ReplicatedStorage.Dummy.Head.face,
					},
				}),
			}),

			Armor = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.9, 0.25),
			}, {
				e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.05, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				e(Equipped, {
					LayoutOrder = 1,
					Key = "Armor",
					Name = "ARMOR",
				}),

				e(Equipped, {
					LayoutOrder = 2,
					Cosmetic = true,
					Key = "Armor",
					Name = "COSMETIC",
				}),
			}),

			Helmet = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.9, 0.25),
			}, {
				e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.05, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				e(Equipped, {
					LayoutOrder = 1,
					Key = "Helmet",
					Name = "HELMET",
				}),

				e(Equipped, {
					LayoutOrder = 2,
					Cosmetic = true,
					Key = "Helmet",
					Name = "COSMETIC",
				}),
			}),

			Weapon = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				Size = UDim2.fromScale(0.9, 0.25),
			}, {
				e("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.05, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				e(Equipped, {
					LayoutOrder = 1,
					Key = "Weapon",
					Name = "WEAPON",
				}),

				e(Equipped, {
					LayoutOrder = 2,
					Cosmetic = true,
					Key = "Particle",
					Name = "EFFECT",
				}),
			}),
		}),

		Contents = e(InventoryContents, {
			Native = {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.25, 1),
				ScrollBarThickness = 4,
				Size = UDim2.fromScale(0.45, 0.95),
			},

			showCosmetics = true,
			onHover = self.onHover,
			onUnhover = self.onUnhover,

			onClickCosmetic = function(item)
				UpdateCosmetics:FireServer(item)
			end,

			onClickInventoryUnequipped = function(loot, id)
				if loot.Level > LocalPlayer.PlayerData.Level.Value then
					self:setState({
						levelWarningOpen = true,
					})
				else
					UpdateEquipment:FireServer(id)
				end
			end,
		}),

		LootInfo = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.7,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(0.3, 1),
		}, {
			Inner = lootInfo,
		}),

		InventorySpace = inventorySpace,

		LevelWarning = e(Alert, {
			OnClose = self.onCloseLevelWarning,
			Open = self.state.levelWarningOpen,
			Text = "You're not a high enough level to equip that!",
		}),

		GamePassConnection = e(EventConnection, {
			callback = self.resetInventorySpace,
			event = GamePasses.BoughtPassUpdated(LocalPlayer).Event,
		}),
	})
end

return RoactRodux.connect(function(state)
	return {
		inventory = state.inventory,
		open = state.page.current == "Inventory",
	}
end, function(dispatch)
	return {
		onClose = function()
			dispatch({
				type = "ToggleInventory",
			})
		end,
	}
end)(Inventory)
