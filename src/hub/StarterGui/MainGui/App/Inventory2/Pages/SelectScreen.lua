local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Alert = require(ReplicatedStorage.Core.UI.Components.Alert)
local BackButton = require(ReplicatedStorage.Core.UI.Components.BackButton)
local ConfirmPrompt2 = require(ReplicatedStorage.Core.UI.Components.ConfirmPrompt2)
local ItemDetails = require(ReplicatedStorage.Core.UI.Components.ItemDetails)
local ItemPreview = require(ReplicatedStorage.Core.UI.Components.ItemPreview)
local Loot = require(ReplicatedStorage.Core.Loot)
local HoverStack = require(ReplicatedStorage.Core.UI.Components.HoverStack)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)
local SearchBar = require(ReplicatedStorage.Core.UI.Components.SearchBar)
local SearchItemRelevancy = require(ReplicatedStorage.Libraries.SearchItemRelevancy)

local e = Roact.createElement

local SelectScreen = Roact.Component:extend("SelectScreen")

local CELL_PADDING = UDim2.fromOffset(20, 20)
local CELL_SIZE = UDim2.fromOffset(430, 160)

SelectScreen.defaultProps = {
	AllowUnequip = false,
	ShowGearScore = true,
}

local function getId(item)
	if item == nil then
		return nil
	end

	return item.UUID or item.Index
end

function SelectScreen:init()
	self.initialEquip = self.props.Equipped
	self.frameRef = Roact.createRef()

	self:setState({
		equippingAttachment = nil,
		tooHighLevelAlertOpen = false,
		search = "",
	})

	self.searchChanged = function(rbx)
		self:setState({
			search = rbx.Text,
		})
	end

	local equipFunctions = {}

	self.equip = function(item)
		if equipFunctions[item] == nil then
			equipFunctions[item] = function()
				local clickingOnEquipped = getId(item) == getId(self.state.equipped)
				if not self.props.AllowUnequip and clickingOnEquipped then
					return
				end

				if self.state.equippingAttachment == nil
					and Loot.IsAttachment(item)
				then
					self:setState({
						equippingAttachment = item,
					})

					return
				end

				self.props.Equip(item)

				if clickingOnEquipped then
					self:setState({
						equipped = Roact.None,
					})
				else
					self:setState({
						equipped = item,
					})
				end
			end
		end

		return equipFunctions[item]
	end

	self.openLevelWarning = function()
		self:setState({
			tooHighLevelAlertOpen = true,
		})
	end

	self.onCloseLevelWarning = function()
		self:setState({
			tooHighLevelAlertOpen = false,
		})
	end
end

function SelectScreen:didMount()
	self:setState({
		equipped = self.props.Equipped,
	})
end

function SelectScreen:render()
	return e(HoverStack, {
		Render = function(hovered, hover, unhover)
			local props = self.props
			local previewItem = hovered or self.state.equipped

			local inventory = {
				UIGridLayout = e("UIGridLayout", {
					CellPadding = CELL_PADDING,
					CellSize = CELL_SIZE,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}

			local search = self.state.search

			for index, inventoryItem in ipairs(props.Inventory) do
				local layoutOrder
				local name = props.GetName(inventoryItem)

				if search == "" then
					local itemId, equippedId = getId(inventoryItem), getId(self.initialEquip)
					if (itemId ~= nil and itemId == equippedId) or (inventoryItem == self.initialEquip) then
						layoutOrder = 0
					else
						layoutOrder = index
					end
				else
					layoutOrder = SearchItemRelevancy(search, name, inventoryItem)
				end

				if layoutOrder ~= nil then
					local equipped = getId(inventoryItem) == getId(self.state.equipped)

					inventory[inventoryItem.UUID or inventoryItem.Name] = e(ItemPreview, {
						Angle = props.Angle,
						Equipped = equipped,
						HideFavorites = props.HideFavorites,
						Item = inventoryItem,
						LayoutOrder = layoutOrder,
						Name = name,
						ShowGearScore = props.ShowGearScore,
						ZIndex = -layoutOrder,

						Hover = hover(inventoryItem),
						Unhover = unhover(inventoryItem),
						Equip = self.equip(inventoryItem),
						OpenLevelWarning = self.openLevelWarning,
					})
				end
			end

			return e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				[Roact.Ref] = self.frameRef,
			}, {
				Empty = #props.Inventory == 0 and e("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Font = Enum.Font.Gotham,
					Size = UDim2.fromScale(0.9, 0.15),
					Text = "You do not have any " .. props.Plural .. ".",
					TextSize = 40,
					TextWrapped = true,
				}),

				Alert = self.state.tooHighLevelAlertOpen and e(Alert, {
					Window = self.frameRef:getValue(),
					OnClose = self.onCloseLevelWarning,
					Open = self.state.tooHighLevelAlertOpen,
					Text = "You're not a high enough level to equip that!",
				}),

				AttachmentConfirmPrompt = self.state.equippingAttachment and e(ConfirmPrompt2, {
					Text = string.format(
						"Are you sure you want to equip '%s'? It can not be removed from your gun later!",
						Loot.GetLootName(self.state.equippingAttachment)
					),

					Buttons = {
						Yes = {
							Style = "Yes",
							Text = "Yes",
							Activated = function()
								self.equip(self.state.equippingAttachment)()
								self:setState({
									equippingAttachment = Roact.None,
								})
							end,
						},

						No = {
							Style = "No",
							Text = "No",
							Activated = function()
								self:setState({
									equippingAttachment = Roact.None,
								})
							end,
						},
					},
				}),

				Selected = e("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.02, 0.5),
					Size = UDim2.fromOffset(630, 900),
				}, {
					Scale = e(Scale, {
						Size = Vector2.new(630, 900),
					}),

					ChooseA = e("TextLabel", {
						BackgroundTransparency = 1,
						Font = Enum.Font.Gotham,
						Position = UDim2.fromOffset(0, 40),
						Size = UDim2.new(1, 0, 0, 21),
						Text = "Choose " .. props.Text,
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 22,
						TextStrokeTransparency = 0.6,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),

					ItemDetails = previewItem and e(ItemDetails, {
						CompareTo = self.state.equipped,
						Item = previewItem,
						GetName = props.GetName,
						ShowGearScore = props.ShowGearScore,
					}),
--
					BackButton = e(BackButton, {
						GoBack = self.props.GoBack,
					}),
				}),

				Inventory = e("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.98, 0.5),
					Size = UDim2.fromOffset(900, 900),
				}, {
					Scale = e(Scale, {
						Size = Vector2.new(900, 900),
					}),

					SearchBar = #props.Inventory > 0 and e(SearchBar, {
						Search = self.state.search,
						SearchChanged = self.searchChanged,
					}),

					Inventory = e("ScrollingFrame", {
						Active = true,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						CanvasSize = UDim2.fromOffset(0,
							CELL_SIZE.Y.Offset
							* math.ceil(#props.Inventory / 2)
							+ CELL_PADDING.Y.Offset
							* math.ceil(#props.Inventory / 2)
						),
						Position = UDim2.fromOffset(0, 74),
						Size = UDim2.new(1, 0, 0, 792),
					}, inventory),
				}),
			})
		end,
	})
end

return SelectScreen
