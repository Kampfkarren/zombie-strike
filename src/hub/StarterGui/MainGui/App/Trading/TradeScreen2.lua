local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local HoverStack = require(ReplicatedStorage.Core.UI.Components.HoverStack)
local ItemDetailsComplete = require(ReplicatedStorage.Core.UI.Components.ItemDetailsComplete)
local ItemPreview = require(ReplicatedStorage.Core.UI.Components.ItemPreview)
local Loot = require(ReplicatedStorage.Core.Loot)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local e = Roact.createElement

local ImageFloat = require(ReplicatedStorage.Assets.Tarmac.UI.float)
local ImageItemButton = require(ReplicatedStorage.Assets.Tarmac.UI.item_button)

local INVENTORY_ITEM_SIZE = 160
local INVENTORY_ITEM_PADDING = 10

local ACCEPT_COLORS = {
	Green = {
		MinGradient = Color3.fromRGB(0, 209, 70),
		MaxGradient = Color3.fromRGB(0, 148, 50),
		HoveredMaxGradient = Color3.fromRGB(0, 102, 34),
	},

	Red = {
		MinGradient = Color3.fromRGB(201, 51, 37),
		MaxGradient = Color3.fromRGB(175, 38, 25),
		HoveredMaxGradient = Color3.fromRGB(197, 44, 30),
	}
}

local ITEM_TYPES = {
	[Loot.IsWeapon] = {
		EquipmentKey = "equippedWeapon",
		EquippedOrder = 1,
		ShowGearScore = true,
		UpgradePerks = true,
	},

	[Loot.IsArmor] = {
		Angle = Vector3.new(-1, 0.8, -1),
		EquipmentKey = "equippedArmor",
		EquippedOrder = 2,
		ShowGearScore = true,
		UpgradeBasic = true,
	},

	[Loot.IsHelmet] = {
		Angle = Vector3.new(1, 0, 0),
		EquipmentKey = "equippedHelmet",
		EquippedOrder = 3,
		ShowGearScore = true,
		UpgradeBasic = true,
	},

	[Loot.IsPet] = {
		EquipmentKey = "equippedPet",
		EquippedOrder = 4,
	},

	[Loot.IsAttachment] = {
		Angle = Vector3.new(-1, 0.8, -1),
	},
}

local function getItemData(item)
	for check, data in pairs(ITEM_TYPES) do
		if check(item) then
			return data
		end
	end
end

local function offer(uuids, inventory)
	local loot = {}
	local uuidsAndLoot = {}

	for _, item in pairs(inventory) do
		uuidsAndLoot[item.UUID] = item
	end

	for _, uuid in ipairs(uuids) do
		local lootByUuid = assert(uuidsAndLoot[uuid], "couldn't find loot that matched uuid")
		table.insert(loot, lootByUuid)
	end

	return loot
end

local function Inventory(props)
	local children = {}
	children.UIListLayout = e("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, INVENTORY_ITEM_PADDING),
	})

	for index, item in ipairs(props.inventory) do
		local equipped = table.find(props.equipped, item.UUID) ~= nil

		local previewProps = {
			Angle = getItemData(item).Angle,
			Equipped = equipped,
			HideFavorites = true,
			IgnoreLevelCap = true,
			Item = item,
			LayoutOrder = equipped and index or -index, -- Re-order equipped items to the bottom
			Name = Loot.GetLootName(item),

			Equip = props.activated and props.activated(item),
			Hover = props.hover(item),
			Unhover = props.unhover(item),
		}

		if table.find(props.offer, item) ~= nil then
			previewProps[Roact.Children] = e("ImageLabel", {
				BackgroundTransparency = 1,
				Image = ImageItemButton,
				ImageColor3 = Color3.new(0, 0, 0),
				ImageTransparency = 0.5,
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.fromScale(1, 1),
				SliceCenter = Rect.new(0, 10, 419, 149),
				ZIndex = 11,
			})
		end

		local preview = e(ItemPreview, previewProps)

		children["Item" .. index] = preview
	end

	return e("ScrollingFrame", {
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromOffset(
			0,
			(INVENTORY_ITEM_SIZE * #props.inventory)
			+ (INVENTORY_ITEM_PADDING * #props.inventory - 1)
		),
		Size = UDim2.new(0, 465, 1, 0),
		VerticalScrollBarPosition = props.VerticalScrollBarPosition,
	}, children)
end

local function Offer(props)
	local offerContents = {}
	offerContents.UIListLayout = e("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 9),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for index, item in ipairs(props.Offer) do
		offerContents["Item" .. index] = e(ItemPreview, {
			Angle = getItemData(item).Angle,
			HideFavorites = true,
			IgnoreLevelCap = true,
			Item = item,
			LayoutOrder = index,
			Name = Loot.GetLootName(item),

			Equip = props.Activated and props.Activated(item),
			Hover = props.Hover(item),
			Unhover = props.Unhover(item),
		})
	end

	local colors = props.Accept
		and (props.Accepted and ACCEPT_COLORS.Red or ACCEPT_COLORS.Green)
		or (props.Accepted and ACCEPT_COLORS.Green or ACCEPT_COLORS.Red)

	return e("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	}, {
		Text = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(0, 15),
			Size = UDim2.new(1, 0, 0, 60),
			Text = props.Text,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}, {
			UITextSizeConstraint = e("UITextSizeConstraint", {
				MaxTextSize = 60,
			}),
		}),

		Offer = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 79),
			Size = UDim2.new(1, 0, 0, 639),
		}, offerContents),

		Accept = props.Accept and e(GradientButton, {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Image = ImageFloat,
			Position = UDim2.new(0, 0, 1, -15),
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(6, 4, 86, 20),
			Size = UDim2.new(1, 0, 0, 44),

			AnimateSpeed = 14,

			MinGradient = colors.MinGradient,
			MaxGradient = colors.MaxGradient,
			HoveredMaxGradient = colors.HoveredMaxGradient,

			[Roact.Event.Activated] = props.Accept,
		}, {
			Label = e("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Size = UDim2.new(0.95, 0, 0.8, 0),
				Text = props.Accepted and "Unaccept" or "Accept",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				Position = UDim2.fromScale(0.5, 0.5),
			}),
		}) or e("TextLabel", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.new(0, 0, 1, -15),
			Size = UDim2.new(1, 0, 0, 44),
			Text = props.Accepted and "Accepted ✅" or "Not accepted",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),
	})
end

local TradeScreen2 = Roact.Component:extend("TradeScreen2")

function TradeScreen2:render()
	local props = self.props

	return e(HoverStack, {
		Render = function(hovered, hover, unhover)
			-- we're really still doing it like this, huh
			local theirHoveredDetails, yourHoveredDetails
			if hovered ~= nil then
				local itemData = getItemData(hovered)
				local itemDetails = e("Frame", {
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.5,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 465, 1, 0),
				}, {
					Inner = e("Frame", {
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 0),
						Size = UDim2.new(0, 400, 1, 0),
					}, {
						Details = e(ItemDetailsComplete, {
							CompareTo = itemData.EquipmentKey and props.equipment[itemData.EquipmentKey] or hovered,
							Item = hovered,
							GetName = Loot.GetLootName,
							ShowGearScore = itemData.ShowGearScore,
						}),
					}),
				})

				local fromUs = table.find(props.inventory, hovered) ~= nil

				if fromUs then
					yourHoveredDetails = itemDetails
				else
					theirHoveredDetails = itemDetails
				end
			end

			return e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				YourInventory = e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 465, 1, 0),
				}, {
					Inventory = e(Inventory, {
						equipped = self.state.equipmentIds,
						inventory = props.inventory,
						offer = props.yourOffer,

						activated = props.offerItem,
						hover = hover,
						unhover = unhover,
					}),

					ItemDetails = theirHoveredDetails,
				}),

				YourOffer = e("Frame", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 511, 0, 0),
					Size = UDim2.new(0, 430, 1, 0),
				}, {
					Offer = e(Offer, {
						Accept = props.weAccept,
						Accepted = props.weAccepted,
						Activated = props.removeItem,
						Text = "YOUR OFFER",
						Offer = props.yourOffer,

						Hover = hover,
						Unhover = unhover,
					}),
				}),

				TheirOffer = e("Frame", {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -506, 0, 0),
					Size = UDim2.new(0, 430, 1, 0),
				}, {
					Offer = e(Offer, {
						Text = "THEIR OFFER",
						Offer = props.theirOffer,
						Accepted = props.theyAccepted,

						Hover = hover,
						Unhover = unhover,
					}),
				}),

				TheirInventory = e("Frame", {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.new(0, 465, 1, 0),
				}, {
					Inventory = e(Inventory, {
						equipped = props.theirEquipment,
						inventory = props.theirInventory,
						offer = props.theirOffer,

						activated = props.ping,
						hover = hover,
						unhover = unhover,

						VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
					}),

					ItemDetails = yourHoveredDetails,
				})
			})
		end,
	})
end

function TradeScreen2.getDerivedStateFromProps(nextProps)
	local equipmentIds = {}
	for key in pairs(Data.Equippable) do
		local item = nextProps.equipment["equipped" .. key]
		if item ~= nil then
			table.insert(equipmentIds, item.UUID)
		end
	end

	return {
		equipmentIds = equipmentIds,
	}
end

return RoactRodux.connect(function(state)
	local trading = state.trading

	return {
		equipment = state.equipment,
		inventory = state.inventory,

		theirEquipment = trading.theirEquipment,
		theirInventory = trading.theirInventory,
		theirOffer = offer(trading.theirOffer, trading.theirInventory),

		yourOffer = offer(trading.yourOffer, state.inventory),
	}
end)(TradeScreen2)
