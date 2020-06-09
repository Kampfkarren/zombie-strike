local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BackButton = require(ReplicatedStorage.Core.UI.Components.BackButton)
local BuyCapsModal = require(ReplicatedStorage.Components.BuyCapsModal)
local ConfirmPrompt2 = require(ReplicatedStorage.Core.UI.Components.ConfirmPrompt2)
local EventConnection = require(ReplicatedStorage.Core.UI.Components.EventConnection)
local GetGoldShopItems = require(ReplicatedStorage.Libraries.GetGoldShopItems)
local GoldShopItemsUtil = require(ReplicatedStorage.Libraries.GoldShopItemsUtil)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local FormatNumber = require(ReplicatedStorage.Core.FormatNumber)
local InventorySpace = require(ReplicatedStorage.Core.InventorySpace)
local ItemDetails = require(ReplicatedStorage.Core.UI.Components.ItemDetails)
local ItemPreview = require(ReplicatedStorage.Core.UI.Components.ItemPreview)
local Loot = require(ReplicatedStorage.Core.Loot)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local PerkDetails = require(ReplicatedStorage.Core.UI.Components.PerkDetails)
local PlayerDataConsumer = require(ReplicatedStorage.Core.UI.Components.PlayerDataConsumer)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)

local ImageCap = require(ReplicatedStorage.Assets.Tarmac.UI.cap)
local ImageFloat = require(ReplicatedStorage.Assets.Tarmac.UI.float)
local ImagePanelGold = require(ReplicatedStorage.Assets.Tarmac.UI.panel_gold)

local e = Roact.createElement
local GoldShop = ReplicatedStorage.Remotes.GoldShop
local LocalPlayer = Players.LocalPlayer

local GOLD_PIECE_PADDING = 50

local BuyWeapon = Roact.Component:extend("BuyWeapon")
local Weapons = Roact.PureComponent:extend("Weapons")

local function getPlayerId()
	return LocalPlayer and LocalPlayer.UserId or 0
end

local function WeaponCard(props)
	return e(PlayerDataConsumer, {
		Name = "Level",
		Render = function(level)
			local weapons = GetGoldShopItems(getPlayerId(), props.Timestamp, level).Weapons
			local item = weapons[props.Index]

			local costText = FormatNumber(item.Cost) .. "   "

			local function buyWeapon()
				if not props.AlreadyBought then
					props.Buy(props.Index)
				end
			end

			item.Gun.Level = math.min(GoldShopItemsUtil.MAX_LEVEL, level + item.LevelOffset)

			return e("TextButton", {
				BackgroundTransparency = 1,
				LayoutOrder = props.Index,
				Size = UDim2.fromScale(1, 1),
				[Roact.Event.Activated] = buyWeapon,
			}, {
				ItemPreview = e("Frame", {
					BackgroundTransparency = 1,
				}, {
					e(ItemPreview, {
						Name = Loot.GetLootName(item.Gun),
						Item = item.Gun,
						IgnoreLevelCap = true,
						HideFavorites = true,
						ShowGearScore = true,
						Size = props.WeaponSize,
						Equip = buyWeapon,
					}),
				}),

				PriceInfo = e(PerfectTextLabel, {
					AnchorPoint = Vector2.new(0, 1),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Position = UDim2.new(0, 30, 1, -5),
					Text = props.AlreadyBought and "BOUGHT" or costText,
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = props.PriceFont,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Bottom,

					RenderParent = function(element, size)
						return e("ImageLabel", {
							AnchorPoint = Vector2.new(0, 1),
							BackgroundTransparency = 1,
							Image = ImagePanelGold,
							Position = UDim2.fromScale(0, 1),
							ScaleType = Enum.ScaleType.Slice,
							SliceCenter = Rect.new(18, 18, 281, 88),
							Size = size + UDim2.fromOffset(GOLD_PIECE_PADDING, props.GoldPieceSize),
						}, {
							UIGradient = e("UIGradient", {
								Color = props.AlreadyBought
									and ColorSequence.new(
										Color3.fromRGB(122, 122, 122),
										Color3.fromRGB(122, 122, 122)
									)
									or ColorSequence.new(
										Color3.fromRGB(255, 66, 66),
										Color3.fromRGB(255, 116, 116)
									),

								Rotation = 90,
							}),

							Label = element,

							GoldIcon = (not props.AlreadyBought) and e("ImageLabel", {
								AnchorPoint = Vector2.new(1, 1),
								BackgroundTransparency = 1,
								Image = ImageCap,
								Position = UDim2.new(1, -5, 1, -5),
								Size = UDim2.new(1, 0, 0, props.PriceFont + 5),
							}, {
								e("UIAspectRatioConstraint"),
							}),
						})
					end,
				}),
			})
		end,
	})
end

local function WeaponShop(props)
	local items = {
		UIGridLayout = e("UIGridLayout", {
			CellPadding = UDim2.fromOffset(10, 30),
			CellSize = UDim2.new(0.5, -10, 0.5, -30),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}

	for item = 1, GoldShopItemsUtil.GUNS_TO_SELL do
		items["Item" .. item] = e("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = item,
			ZIndex = GoldShopItemsUtil.GUNS_TO_SELL - item,
		}, {
			WeaponCard = e(WeaponCard, {
				AlreadyBought = table.find(props.alreadyBought, item),
				Buy = props.BuyWeapon,
				Index = item,
				GoldPieceSize = 87,
				PriceFont = 45,
				Timestamp = props.timestamp,
				WeaponSize = 777,
			}),
		})
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		BackButton = e(BackButton, {
			GoBack = props.close,
		}),

		Inner = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(1, 0, 0, 750),
		}, {
			BoughtItem = props.BoughtItem and e(ConfirmPrompt2, {
				Text = ("You have bought '%s'!"):format(props.BoughtItem),
				Scale = 3,
				Buttons = {
					OK = {
						LayoutOrder = 1,
						Style = "OK",
						Text = "OK",
						Activated = props.CloseBoughtItem,
					}
				}
			}),

			Items = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, items),
		}),
	})
end

function BuyWeapon:init()
	self:setState({
		promptFull = false,
		promptPoor = false,
		promptPurchase = false,
	})

	self.item = GetGoldShopItems(getPlayerId(), self.props.timestamp).Weapons[self.props.buyingWeapon]

	self.actuallyPurchase = function()
		self.closePrompt()
		GoldShop:FireServer(
			GoldShopItemsUtil.GoldShopPacket.BuyWeapon,
			self.props.buyingWeapon,
			self.props.timestamp -- Used to make *damn* sure we're getting what we want
		)
	end

	self.buy = function()
		InventorySpace(LocalPlayer):andThen(function(space)
			if self.props.usedInventory >= space then
				self:setState({
					promptFull = true,
				})
			elseif self.props.gold < self.item.Cost then
				self:setState({
					promptPoor = true,
				})
			else
				self:setState({
					promptPurchase = true,
				})
			end
		end)
	end

	self.closePrompt = function()
		self:setState({
			promptFull = false,
			promptPoor = false,
			promptPurchase = false,
		})
	end

	self.goldShopIncoming = function(packet, index)
		if packet == GoldShopItemsUtil.GoldShopPacket.BuyWeapon
			and index == self.props.buyingWeapon
		then
			self.props.BoughtItem(Loot.GetLootName(self.item.Gun))
		end
	end

	self.buyCapsRef = Roact.createRef()
end

function BuyWeapon:render()
	local item = self.item

	return e(PlayerDataConsumer, {
		Name = "Level",
		Render = function(level)
			if not self.fixedGunLevel then
				item.Gun.Level = level + item.LevelOffset
				if item.Gun.Level > GoldShopItemsUtil.MAX_LEVEL then
					item.LevelOffset = GoldShopItemsUtil.MAX_LEVEL - item.Gun.Level
					item.Gun.Level = GoldShopItemsUtil.MAX_LEVEL
				end
				self.fixedGunLevel = true
			end

			local confirmPrompt

			if self.state.promptPurchase then
				local text = ("Are you sure you want to buy '%s'?")
					:format(Loot.GetLootName(item.Gun))

				if item.LevelOffset > 0 then
					text = text .. " You are also not the required level to equip this."
				end

				confirmPrompt = e(ConfirmPrompt2, {
					Text = text,
					MaxWidth = 500,
					Scale = 2.3,
					Buttons = {
						Yes = {
							LayoutOrder = 1,
							Style = "Yes",
							Text = "Yes",
							Activated = self.actuallyPurchase,
						},

						No = {
							LayoutOrder = 2,
							Style = "No",
							Text = "No",
							Activated = self.closePrompt,
						},
					},
				})
			elseif self.state.promptFull then
				confirmPrompt = e(ConfirmPrompt2, {
					Text = "Your inventory is full, please sell something.",
					MaxWidth = 500,
					Scale = 2.3,
					Buttons = {
						OK = {
							Style = "Neutral",
							Text = "OK",
							Activated = self.closePrompt,
						},
					}
				})
			end

			return e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				ConfirmPrompt = confirmPrompt,

				GoldShopIncoming = e(EventConnection, {
					callback = self.goldShopIncoming,
					event = GoldShop.OnClientEvent,
				}),

				Selected = e("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 630, 1, 0),
				}, {
					Item = e("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, -70),
					}, {
						ItemDetails = e(ItemDetails, {
							CompareTo = self.props.equippedWeapon,
							Item = item.Gun,
							GetName = Loot.GetLootName,
							ShowGearScore = true,
						}),
					}),

					Buttons = e("Frame", {
						AnchorPoint = Vector2.new(0, 1),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0, 1),
						Size = UDim2.new(1, 0, 0, 54),
					}, {
						UIListLayout = e("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = UDim.new(0, 13),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),

						BackButton = e(BackButton, {
							GoBack = self.props.GoBack,
						}),

						BuyButton = e(PerfectTextLabel, {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Font = Enum.Font.Gotham,
							LayoutOrder = 1,
							Position = UDim2.fromScale(0.5, 0.5),
							Text = ("Buy for %s "):format(FormatNumber(item.Cost)),
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 24,

							RenderParent = function(element, size)
								return e(GradientButton, {
									AnchorPoint = Vector2.new(0, 1),
									BackgroundColor3 = Color3.new(1, 1, 1),
									BackgroundTransparency = 1,
									Image = ImageFloat,
									LayoutOrder = 2,
									ScaleType = Enum.ScaleType.Slice,
									SliceCenter = Rect.new(6, 4, 86, 20),
									Size = UDim2.new(0, math.max(size.X.Offset + 30, 250) + 30, 1, 0),

									AnimateSpeed = 14,
									MinGradient = Color3.fromRGB(0, 209, 70),
									MaxGradient = Color3.fromRGB(0, 148, 50),
									HoveredMaxGradient = Color3.fromRGB(0, 102, 34),

									[Roact.Event.Activated] = self.buy,
								}, {
									UIListLayout = e("UIListLayout", {
										FillDirection = Enum.FillDirection.Horizontal,
										HorizontalAlignment = Enum.HorizontalAlignment.Center,
										SortOrder = Enum.SortOrder.LayoutOrder,
										VerticalAlignment = Enum.VerticalAlignment.Center,
									}),

									Label = element,

									Icon = e("ImageLabel", {
										AnchorPoint = Vector2.new(1, 1),
										BackgroundTransparency = 1,
										Image = ImageCap,
										LayoutOrder = 2,
										Position = UDim2.new(1, -5, 1, -5),
										Size = UDim2.new(1, 0, 0, 30),
									}, {
										e("UIAspectRatioConstraint"),
									}),
								})
							end,
						}),
					}),
				}),

				PerkDetails = e(PerkDetails, {
					Perks = item.Gun.Perks,
					Seed = item.Gun.Seed,

					RenderParent = function(element, size)
						return e("Frame", {
							AnchorPoint = Vector2.new(1, 0.5),
							BackgroundTransparency = 1,
							Position = UDim2.fromScale(1, 0.5),
							Size = size,
						}, {
							PerkDetails = element,

							UIScale = e("UIScale", {
								Scale = 1.4,
							}),
						})
					end,
				}),

				BuyCaps = self.state.promptPoor and e(BuyCapsModal, {
					onClose = function()
						self:setState({
							promptPoor = false,
						})
					end,
				}),
			})
		end,
	})
end

function Weapons:init()
	self.buyWeapon = function(index)
		self:setState({
			boughtItem = Roact.None,
			buyingWeapon = index,
		})
	end

	self.goBack = function()
		self:setState({
			buyingWeapon = Roact.None,
			boughtItem = Roact.None,
		})
	end

	self.boughtItem = function(name)
		self:setState({
			buyingWeapon = Roact.None,
			boughtItem = name,
		})
	end

	self.closeBoughtItem = function()
		self:setState({
			boughtItem = Roact.None,
		})
	end
end

function Weapons:render()
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		Contents = self.state.buyingWeapon
			and e(BuyWeapon, {
				BoughtItem = self.boughtItem,
				buyingWeapon = self.state.buyingWeapon,
				GoBack = self.goBack,
				gold = self.props.gold,
				equippedWeapon = self.props.equippedWeapon,
				timestamp = self.props.timestamp,
				usedInventory = self.props.usedInventory,
			})
			or e(WeaponShop, {
				alreadyBought = self.props.alreadyBought,
				BoughtItem = self.state.boughtItem,
				BuyWeapon = self.buyWeapon,
				close = self.props.close,
				CloseBoughtItem = self.closeBoughtItem,
				timestamp = self.props.timestamp,
			})
	})
end

return RoactRodux.connect(function(state)
	return {
		alreadyBought = state.goldShop.alreadyBought,
		equippedWeapon = state.equipment and state.equipment.equippedWeapon,
		gold = state.gold,
		timestamp = state.goldShop.timestamp,
		usedInventory = state.inventory and #state.inventory or 0,
	}
end, function(dispatch)
	return {
		close = function()
			dispatch({
				type = "CloseGoldShop",
			})
		end,

		openCapsShop = function()
			dispatch({
				type = "OpenStore",
			})

			dispatch({
				type = "SetStorePage",
				page = "Caps",
			})
		end,
	}
end)(Weapons)
