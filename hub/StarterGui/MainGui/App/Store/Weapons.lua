local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cosmetics = require(ReplicatedStorage.Core.Cosmetics)
local DayTimer = require(ReplicatedStorage.Core.UI.Components.DayTimer)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local LootInfo = require(ReplicatedStorage.Core.UI.Components.LootInfo)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local StoreCard = require(script.Parent.StoreCard)

local e = Roact.createElement

local Weapons = Roact.Component:extend("Weapons")

local function copy(list)
	local copy = {}
	for index, value in pairs(list) do
		copy[index] = value
	end
	return copy
end

function Weapons:init()
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

	self.createOnHover = function(lootType, index)
		return function()
			self.onHover(Cosmetics.GetStoreItems()[lootType][index])
		end
	end

	self.createOnUnhover = function(lootType, index)
		return function()
			self.onUnhover(Cosmetics.GetStoreItems()[lootType][index])
		end
	end
end

function Weapons:render()
	local props = self.props
	local _, hovered = next(self.state.lootStack)

	if hovered then
		for key, value in pairs(GunScaling.BaseStats(hovered.Type, hovered.Level, hovered.Rarity)) do
			if hovered[key] == nil then
				hovered[key] = value
			end
		end
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),

		[Roact.Ref] = props[Roact.Ref],
	}, {
		Contents = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.985, 0),
			Size = UDim2.new(0.95, 0, 0.9, 0),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.01, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Mythic = e(StoreCard, {
				ItemIndex = 1,
				ItemType = "Mythic",
				Size = UDim2.new(0.3, 0, 1, 0),

				Prices = Cosmetics.Costs.Mythic,
				Window = props[Roact.Ref],

				OnHover = self.createOnHover("Mythic", 1),
				OnUnhover = self.createOnUnhover("Mythic", 1),
			}),

			Legendary = e("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Size = UDim2.new(0.3, 0, 1, 0),
			}, {
				e("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.01, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				Legendary1 = e(StoreCard, {
					ItemIndex = 1,
					ItemType = "Legendary",
					Size = UDim2.new(1, 0, 0.5, 0),

					LayoutOrder = 1,
					Prices = Cosmetics.Costs.Legendary,
					Window = props[Roact.Ref],

					OnHover = self.createOnHover("Legendary", 1),
					OnUnhover = self.createOnUnhover("Legendary", 1),
				}),

				Legendary2 = e(StoreCard, {
					ItemIndex = 2,
					ItemType = "Legendary",
					Size = UDim2.new(1, 0, 0.5, 0),

					LayoutOrder = 2,
					Prices = Cosmetics.Costs.Legendary,
					Window = props[Roact.Ref],

					OnHover = self.createOnHover("Legendary", 2),
					OnUnhover = self.createOnUnhover("Legendary", 2),
				}),
			}),

			LootInfoFrame = e("Frame", {
				BackgroundColor3 = Color3.new(),
				BackgroundTransparency = 0.3,
				BorderSizePixel = 0,
				LayoutOrder = 3,
				Size = UDim2.fromScale(0.37, 1),
			}, {
				LootInfo = hovered and e(LootInfo, {
					Native = {
						Size = UDim2.fromScale(1, 1),
					},

					Loot = hovered,
				}),
			}),
		}),

		TimerFrame = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0.025, 0, 0.01, 0),
			Size = UDim2.new(0.4, 0, 0.07, 0),
		}, {
			Timer = e(DayTimer, {
				Native = {
					Font = Enum.Font.GothamBlack,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextStrokeTransparency = 0,
				},
			}),
		}),
	})
end

return Weapons
