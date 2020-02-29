local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutomatedScrollingFrameComponent = require(ReplicatedStorage.Core.UI.Components.AutomatedScrollingFrameComponent)
local CollectionLogUtil = require(ReplicatedStorage.Libraries.CollectionLogUtil)
local Context = require(script.Parent.Context)
local Data = require(ReplicatedStorage.Core.Data)
local ItemButton = require(ReplicatedStorage.Core.UI.Components.ItemButton)
local Loot = require(ReplicatedStorage.Core.Loot)
local LootStyles = require(ReplicatedStorage.Core.LootStyles)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local SilhouetteModel = require(ReplicatedStorage.Core.SilhouetteModel)
local ViewportFramePreviewComponent = require(ReplicatedStorage.Core.UI.Components.ViewportFramePreviewComponent)

local CollectionLog = Roact.Component:extend("CollectionLog")

local e = Roact.createElement

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local function getLootName(loot)
	local name = Loot.GetLootName(loot)

	if Loot.IsAurora(loot) then
		return "Aurora " .. name
	else
		return name
	end
end

local function getLootType(loot)
	if Loot.IsPet(loot) then
		return "Pet"
	else
		return LootStyles[loot.Rarity].Name .. " " .. loot.Type
	end
end

local function getObtainMethod(source)
	if source.Method == CollectionLogUtil.ItemSourceMethod.Boss then
		return string.format("Defeat the %s boss", source.Info)
	elseif source.Method == CollectionLogUtil.ItemSourceMethod.Campaign then
		return string.format("Complete %s missions or arenas", source.Info)
	elseif source.Method == CollectionLogUtil.ItemSourceMethod.Attachments then
		return "Complete missions or arenas"
	elseif source.Method == CollectionLogUtil.ItemSourceMethod.MultipleSources then
		return "Playing any mode"
	elseif source.Method == CollectionLogUtil.ItemSourceMethod.Pets then
		return "Collect pet coins through play and open eggs"
	end
end

function CollectionLog:init()
	self:setState({
		items = CollectionLogUtil.GetAllItems(),
		lootStack = {},
	})

	self.addLootToStack = function(loot)
		local lootStack = copy(self.state.lootStack)
		lootStack[loot.UUID] = loot
		self:setState({
			lootStack = lootStack,
		})
	end

	self.removeLootFromStack = function(loot)
		local lootStack = copy(self.state.lootStack)
		lootStack[loot.UUID] = nil
		self:setState({
			lootStack = lootStack,
		})
	end
end

function CollectionLog:LootOwned(item)
	local loot = self.props.itemsCollected[item.Type]
	if loot == nil then
		return false
	end

	return table.find(loot, item.Model) ~= nil
end

function CollectionLog:render()
	return e(Context.Consumer, {
		render = function(context)
			local contents = {}
			contents.UIGridLayout = e("UIGridLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			})

			local items = self.state.items
			local owned, total = 0, 0

			for _, itemType in ipairs(CollectionLogUtil.ItemTypes) do
				for _, item in ipairs(items[itemType]) do
					if context.selectedFilter.Filter(item) then
						local lootOwned = self:LootOwned(item)
						if lootOwned then
							owned = owned + 1
						end

						total = total + 1

						contents[item.Instance.Name] = e(ItemButton, {
							HideFavorites = true,
							LayoutOrder = total,
							Loot = item,
							Silhouette = not lootOwned,

							onHover = self.addLootToStack,
							onUnhover = self.removeLootFromStack,
						})
					end
				end
			end

			local _, selectedLoot = next(self.state.lootStack)
			local selectedOwned = selectedLoot and self:LootOwned(selectedLoot)
			local model

			if selectedLoot ~= nil then
				model = Data.GetModel(selectedLoot)
				if not selectedOwned then
					SilhouetteModel(model)
				end
			end

			return e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				Contents = e(AutomatedScrollingFrameComponent, {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.fromScale(0.75, 0.95),
				}, contents),

				Completion = e("TextLabel", {
					BackgroundTransparency = 1,
					Font = Enum.Font.Gotham,
					Size = UDim2.fromScale(0.75, 0.05),
					Text = string.format("%d/%d (%d%%)", owned, total, math.floor(owned / total * 100)),
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Right,
				}),

				LootInfo = selectedLoot and e("Frame", {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.fromScale(0.25, 1),
				}, {
					e("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						Padding = UDim.new(0.01, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					LootName = e("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamBold,
						LayoutOrder = 1,
						Size = UDim2.new(0.9, 0, 0.1, 0),
						Text = selectedOwned and getLootName(selectedLoot) or "???",
						TextColor3 = Color3.fromRGB(227, 227, 227),
						TextScaled = true,
					}),

					ItemType = e("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						LayoutOrder = 2,
						Size = UDim2.new(0.9, 0, 0.06, 0),
						Text = getLootType(selectedLoot),
						TextColor3 = Color3.fromRGB(227, 227, 227),
						TextScaled = true,
					}),

					Preview = e(ViewportFramePreviewComponent, {
						Model = model,

						Native = {
							BackgroundColor3 = Color3.new(0.3, 0.3, 0.3),
							BackgroundTransparency = 0.6,
							BorderSizePixel = 0,
							LayoutOrder = 3,
							Size = UDim2.fromScale(0.5, 0.5),
						},
					}, {
						e("UIAspectRatioConstraint"),
					}),

					ObtainMethod = e("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						LayoutOrder = 4,
						Size = UDim2.fromScale(0.9, 0.15),
						Text = getObtainMethod(selectedLoot.Source),
						TextColor3 = Color3.fromRGB(227, 227, 227),
						TextScaled = true,
					}),
				}),
			})
		end,
	})
end

return RoactRodux.connect(function(state)
	return {
		itemsCollected = state.itemsCollected,
	}
end)(CollectionLog)
