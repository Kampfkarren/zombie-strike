local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutomatedScrollingFrameComponent = require(script.Parent.AutomatedScrollingFrameComponent)
local Close = require(script.Parent.Close)
local CosmeticButton = require(script.Parent.Store.CosmeticButton)
local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local Equipped = require(script.Equipped)
local LootInfo = require(ReplicatedStorage.Core.UI.Components.LootInfo)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local ItemButton = require(script.ItemButton)
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
		lootStack = {},
	})

	InventorySpace(LocalPlayer):andThen(function(space)
		self:setState({
			space = space,
		})
	end)

	self.onHover = function(loot)
		local lootStack = copy(self.state.lootStack)
		lootStack[loot] = true
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
end

function Inventory:render()
	local props = self.props

	local inventory = {}
	inventory.UIGridLayout = e("UIGridLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for id, item in pairs(self.props.inventory or {}) do
		inventory["Item" .. item.UUID] = e(ItemButton, {
			LayoutOrder = -id,
			Loot = item,

			onHover = self.onHover,
			onUnhover = self.onUnhover,

			equip = function()
				UpdateEquipment:FireServer(id)
			end,
		})
	end

	for id, item in pairs(self.props.cosmeticsInventory) do
		inventory["Cosmetic" .. id] = e(CosmeticButton, {
			Item = Cosmetics.Cosmetics[item],
			PreviewSize = UDim2.fromScale(1, 1),

			Native = {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = "http://www.roblox.com/asset/?id=3973353646",
				LayoutOrder = id,

				[Roact.Event.Activated] = function()
					UpdateCosmetics:FireServer(item)
				end,
			}
		})
	end

	local lootInfo
	local hovered = next(self.state.lootStack)

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

		Contents = e(AutomatedScrollingFrameComponent, {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.25, 1),
			ScrollBarThickness = 4,
			Size = UDim2.fromScale(0.45, 0.95),
		}, inventory),

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
	})
end

return RoactRodux.connect(function(state)
	return {
		cosmeticsInventory = state.store.contents,
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
