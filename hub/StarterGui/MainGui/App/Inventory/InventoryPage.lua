local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Equipped = require(script.Parent.Equipped)
local InventoryContents = require(script.Parent.InventoryContents)
local InventoryFilter = require(script.Parent.InventoryFilter)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootInfo = require(ReplicatedStorage.Core.UI.Components.LootInfo)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer
local UpdateCosmetics = ReplicatedStorage.Remotes.UpdateCosmetics
local UpdateEquipment = ReplicatedStorage.Remotes.UpdateEquipment
local UpdateSprays = ReplicatedStorage.Remotes.UpdateSprays

local InventoryPage = Roact.Component:extend("InventoryPage")

local function copy(list)
	local copy = {}
	for index, value in pairs(list) do
		copy[index] = value
	end
	return copy
end

function InventoryPage:init()
	self:setState({
		lootStack = {},
	})

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

	local filters, updateFilters = InventoryFilter.CreateStateBinding()
	self.filters = filters
	self.updateFilters = function(newFilters)
		updateFilters(newFilters)
		self:setState(self.state)
	end

	self.onClickCosmetic = function(item, id)
		if id:match("^Spray") then
			UpdateSprays:FireServer(item)
		else
			UpdateCosmetics:FireServer(item)
		end
	end

	self.onClickInventoryUnequipped = function(loot, id)
		if loot.Level and loot.Level > LocalPlayer.PlayerData.Level.Value then
			self.props.openLevelWarning()
		else
			if Loot.IsAttachment(loot) then
				self.props.equipAttachment(loot, id)
			else
				UpdateEquipment:FireServer(id)
			end
		end
	end

	self.noop = function() end
end

function InventoryPage:render()
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
	else
		lootInfo = e(InventoryFilter.Component, {
			Filters = self.filters,
			UpdateFilters = self.updateFilters,
		})
	end

	local inventorySpace

	if props.space and props.inventory then
		inventorySpace = e("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			AutoLocalize = false,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromScale(0.97, 0.01),
			Size = UDim2.fromScale(0.23, 0.08),
			Text = ("%d/%d"):format(#props.inventory, props.space),
			TextColor3 = #props.inventory == props.space
				and Color3.fromRGB(252, 92, 101)
				or Color3.new(1, 1, 1),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 2,
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
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

				Sidebar = e("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					Size = UDim2.fromScale(0.5, 0.95),
				}, {
					e("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						Padding = UDim.new(0.01, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					e(Equipped, {
						LayoutOrder = 1,
						Cosmetic = true,
						Key = "Face",
						Name = "FACE",
						AspectRatio = 2,
						Rectangle = true,

						Default = {
							ParentType = "Face",
							Type = "Face",
							Image = ReplicatedStorage.Dummy.Head.face,
						},
					}),

					e(Equipped, {
						LayoutOrder = 1,
						Cosmetic = true,
						Key = "Spray",
						Name = "EMOTE",
						AspectRatio = 2,
						Rectangle = true,

						Unequip = self.noop,
					}),
				}),

				e(Equipped, {
					LayoutOrder = 2,
					Key = "Pet",
					Name = "PET",
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
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.01, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				e(Equipped, {
					Key = "Weapon",
					Name = "WEAPON",
					LayoutOrder = 1,
					Rectangle = true,
					Size = UDim2.fromScale(0.95, 0.48),
					Rectangle = true,
				}),

				BottomBar = e("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Size = UDim2.fromScale(1, 0.48),
				}, {
					e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						Padding = UDim.new(0.01, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					e(Equipped, {
						LayoutOrder = 1,
						Cosmetic = true,
						Key = "GunSkin",
						Name = "SKIN",
						Size = UDim2.fromScale(0.32, 1),
					}),

					e(Equipped, {
						LayoutOrder = 2,
						Cosmetic = true,
						Key = "Particle",
						Name = "EFFECT",
						Size = UDim2.fromScale(0.32, 1),
					}),

					e(Equipped, {
						LayoutOrder = 3,
						Key = "Attachment",
						Name = "ATTACHMENT",
						Size = UDim2.fromScale(0.32, 1),
					}),
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

			filters = self.filters,

			showCosmetics = true,
			onHover = self.onHover,
			onUnhover = self.onUnhover,

			onClickCosmetic = self.onClickCosmetic,
			onClickInventoryUnequipped = self.onClickInventoryUnequipped,
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
	})
end

return InventoryPage
