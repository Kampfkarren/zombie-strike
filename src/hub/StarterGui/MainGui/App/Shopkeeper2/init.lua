local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local assign = require(ReplicatedStorage.Core.assign)
local BackButton = require(ReplicatedStorage.Core.UI.Components.BackButton)
local BuyCapsModal = require(ReplicatedStorage.Components.BuyCapsModal)
local ConfirmPrompt2 = require(ReplicatedStorage.Core.UI.Components.ConfirmPrompt2)
local FocusContent = require(ReplicatedStorage.Core.UI.Components.FocusContent)
local FormatNumber = require(ReplicatedStorage.Core.FormatNumber)
local GoldCount = require(ReplicatedStorage.Core.UI.Components.GoldCount)
local GradientButton = require(ReplicatedStorage.Core.UI.Components.GradientButton)
local HoverStack = require(ReplicatedStorage.Core.UI.Components.HoverStack)
local ItemDetails = require(ReplicatedStorage.Core.UI.Components.ItemDetails)
local ItemPreview = require(ReplicatedStorage.Core.UI.Components.ItemPreview)
local Loot = require(ReplicatedStorage.Core.Loot)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local PerkDetails = require(ReplicatedStorage.Core.UI.Components.PerkDetails)
local PerkUtil = require(ReplicatedStorage.Core.Perks.PerkUtil)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)
local SellCost = require(ReplicatedStorage.Libraries.SellCost)
local Tagged = require(ReplicatedStorage.Core.UI.Components.Tagged)
local Tooltip = require(ReplicatedStorage.Core.UI.Components.Tooltip)
local Upgrades = require(ReplicatedStorage.Core.Upgrades)

local ImageCap = require(ReplicatedStorage.Assets.Tarmac.UI.cap)
local ImageFloat = require(ReplicatedStorage.Assets.Tarmac.UI.float)
local ImageStar = require(ReplicatedStorage.Assets.Tarmac.UI.star)

local e = Roact.createElement
local Sell = ReplicatedStorage.Remotes.Sell
local Upgrade = ReplicatedStorage.Remotes.Upgrade

local OpenedItem = Roact.Component:extend("OpenedItem")
local Shopkeeper2 = Roact.Component:extend("Shopkeeper2")

local ITEM_PREVIEW_CELL_PADDING = UDim2.fromOffset(35, 39)
local ITEM_PREVIEW_CELL_SIZE = UDim2.fromOffset(424, 160)

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

function OpenedItem:init()
	local upgradePerkCallbacks = {}

	self.closePrompt = function()
		self:setState({
			sellPopup = Roact.None,
			upgradeCost = Roact.None,
			upgradeBasicPopup = Roact.None,
			upgradePerkPopup = Roact.None,
		})
	end

	self.createUpgradePerk = function(perkIndex, cost)
		local callback = upgradePerkCallbacks[perkIndex]
		if callback ~= nil and callback.Cost == cost then
			return callback.Callback
		end

		local newCallback = function()
			self:setState({
				upgradeCost = cost,
				upgradePerkPopup = perkIndex,
			})
		end

		upgradePerkCallbacks[perkIndex] = {
			Cost = cost,
			Callback = newCallback,
		}

		return newCallback
	end

	self.openSellPrompt = function()
		self:setState({
			sellPopup = true,
		})
	end

	self.sellItem = function()
		Sell:FireServer(self.props.item.UUID)
		self.props.close()
	end

	self.openBasicUpgrade = function()
		self:setState({
			upgradeBasicPopup = true,
			upgradeCost = Upgrades.CostToUpgrade(self.props.item),
		})
	end

	self.basicUpgrade = function()
		Upgrade:FireServer(self.props.item.UUID)
		self.nextUpgrade = nil
		self.closePrompt()
	end

	self.upgradePerk = function()
		Upgrade:FireServer(self.props.item.UUID, self.state.upgradePerkPopup)
		self.closePrompt()
	end

	self.hoverBasicUpgrade = function()
		self:setState({
			basicUpgradeHover = true,
		})
	end

	self.unhoverBasicUpgrade = function()
		self:setState({
			basicUpgradeHover = false,
		})
	end
end

function OpenedItem:ItemForDetails()
	if self.state.basicUpgradeHover then
		if self.nextUpgrade == nil then
			self.nextUpgrade = assign({
				Upgrades = self.props.item.Upgrades + 1,
			}, self.props.item)
		end

		return self.nextUpgrade
	end

	return self.props.item
end

function OpenedItem:render()
	local confirmPrompt

	if self.state.upgradeCost ~= nil and self.state.upgradeCost > self.props.gold then
		confirmPrompt = e(BuyCapsModal, {
			onClose = self.closePrompt,
		})
	else
		if self.state.upgradePerkPopup then
			local perk = self.props.item.Perks[self.state.upgradePerkPopup]

			confirmPrompt = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				Prompt = e(ConfirmPrompt2, {
					Text = ("Are you sure you want to upgrade %s for %s caps?")
						:format(
							perk.Perk.Name,
							FormatNumber(self.state.upgradeCost)
						),
					Scale = 1.8,
					Buttons = {
						Yes = {
							LayoutOrder = 1,
							Style = "Yes",
							Text = "Yes",
							Activated = self.upgradePerk,
						},

						No = {
							LayoutOrder = 2,
							Style = "No",
							Text = "No",
							Activated = self.closePrompt,
						},
					},
				}),

				PerkDescription = e(PerfectTextLabel, {
					AnchorPoint = Vector2.new(0.5, 0),
					MaxWidth = 600,
					Font = Enum.Font.Gotham,
					Position = UDim2.fromScale(0.5, 0.62),
					Text = PerkUtil.GetPerkDescription(perk.Perk, self.props.item.Seed, perk.Upgrades + 1),
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 30,
					TextStrokeTransparency = 0.2,
					TextWrapped = true,
					TextYAlignment = Enum.TextYAlignment.Top,
				}),
			})
		elseif self.state.upgradeBasicPopup then
			confirmPrompt = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				Prompt = e(ConfirmPrompt2, {
					Text = ("Are you sure you want to upgrade for %d caps?")
						:format(self.state.upgradeCost),
					Scale = 1.8,
					Buttons = {
						Yes = {
							LayoutOrder = 1,
							Style = "Yes",
							Text = "Yes",
							Activated = self.basicUpgrade,
						},

						No = {
							LayoutOrder = 2,
							Style = "No",
							Text = "No",
							Activated = self.closePrompt,
						},
					},
				}),
			})
		elseif self.state.sellPopup then
			if self.props.equipped then
				confirmPrompt = e(ConfirmPrompt2, {
					MaxWidth = 450,
					Text = "You cannot sell equipped items",
					Scale = 1.8,
					Buttons = {
						OK = {
							Style = "Neutral",
							Text = "OK",
							Activated = self.closePrompt,
						},
					},
				})
			else
				confirmPrompt = e(ConfirmPrompt2, {
					Text = ("Are you sure you want to sell this for %d caps?"):format(SellCost(self.props.item)),
					Scale = 1.8,
					Buttons = {
						Yes = {
							LayoutOrder = 1,
							Style = "Yes",
							Text = "Yes",
							Activated = self.sellItem,
						},

						No = {
							LayoutOrder = 2,
							Style = "No",
							Text = "No",
							Activated = self.closePrompt,
						},
					},
				})
			end
		end
	end

	local basicUpgradeStars
	if self.props.itemTypeData.UpgradeBasic then
		basicUpgradeStars = {}

		for star = 1, self.props.item.Upgrades do
			basicUpgradeStars["Star" .. star] = e("ImageLabel", {
				BackgroundTransparency = 1,
				Image = ImageStar,
				ImageColor3 = Color3.new(1, 1, 0.4),
				LayoutOrder = star,
				Size = UDim2.fromOffset(120, 120),
			})
		end
	end

	return e("ImageButton", {
		Active = true,
		AutoButtonColor = false,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		Image = "",
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,

		[Roact.Event.Activated] = self.props.close,
	}, {
		Background = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(10, 10), -- whatever
			ZIndex = -1,
		}),

		Contents = e("ImageButton", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(1361, 1012),
		}, {
			Scale = e(Scale, {
				Size = Vector2.new(1361, 1012),
			}),

			Details = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 630, 1, -54),
			}, {
				ItemDetails = e(ItemDetails, {
					CompareTo = self.props.compareTo or self.props.Item,
					Item = self:ItemForDetails(),
					GetName = Loot.GetLootName,
					ShowGearScore = self.props.itemTypeData.ShowGearScore,
				}),
			}),

			ConfirmPrompt = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,
			}, {
				confirmPrompt,
			}),

			GoldCount = e("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 59),
				Size = UDim2.new(1, 0, 0, 45),
			}, {
				e(GoldCount),
			}),

			PerkDetails = self.props.itemTypeData.UpgradePerks and e(PerkDetails, {
				Perks = self.props.item.Perks,
				Seed = self.props.item.Seed,

				RenderParent = function(element, size)
					return e(HoverStack, {
						Render = function(hovered, hover, unhover)
							local upgradeButtons = {}

							for perkIndex, perk in ipairs(self.props.item.Perks) do
								if perk.Upgrades < PerkUtil.MAX_PERK_UPGRADES then
									local upgradeCost = Upgrades.CostToUpgradePerk(perk)
									local tooltipSize = TextService:GetTextSize(
										upgradeCost,
										22,
										Enum.Font.GothamBold,
										Vector2.new(250, math.huge)
									)

									upgradeButtons["Perk" .. perkIndex] = e("ImageButton", {
										AnchorPoint = Vector2.new(0, 0),
										BackgroundTransparency = 1,
										Image = "rbxassetid://711219057",
										LayoutOrder = perkIndex,
										Position = UDim2.fromScale(1, 0),
										Size = UDim2.fromScale(1, 1),
										ZIndex = -perkIndex,

										[Roact.Event.Activated] = self.createUpgradePerk(perkIndex, upgradeCost),
										[Roact.Event.MouseEnter] = hover(perkIndex),
										[Roact.Event.MouseLeave] = unhover(perkIndex),
									}, {
										e("UIAspectRatioConstraint"),

										Tooltip = e(Tooltip, {
											Open = hovered == perkIndex,
											Size = UDim2.fromOffset(tooltipSize.X + 50, tooltipSize.Y + 16),
											Render = function(transparency)
												return {
													Inner = e("Frame", {
														BackgroundTransparency = 1,
														Position = UDim2.fromOffset(0, 12),
														Size = UDim2.new(1, 0, 1, -12),
													}, {
														UIListLayout = e("UIListLayout", {
															FillDirection = Enum.FillDirection.Horizontal,
															HorizontalAlignment = Enum.HorizontalAlignment.Center,
															SortOrder = Enum.SortOrder.LayoutOrder,
															VerticalAlignment = Enum.VerticalAlignment.Center,
														}),

														Label = e("TextLabel", {
															BackgroundTransparency = 1,
															Font = Enum.Font.GothamBold,
															Size = UDim2.new(0, tooltipSize.X, 1, 0),
															Text = upgradeCost,
															TextColor3 = Color3.new(1, 1, 1),
															TextSize = 22,
															TextTransparency = transparency,
														}),

														CapIcon = e("ImageLabel", {
															BackgroundTransparency = 1,
															Image = ImageCap,
															ImageTransparency = transparency,
															LayoutOrder = 2,
															Size = UDim2.fromScale(1, 1),
														}, {
															UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
														}),
													}),
												}
											end,
										}),
									})
								else
									-- Take up space
									upgradeButtons["Perk" .. perkIndex] = e("Frame", {
										AnchorPoint = Vector2.new(0, 0),
										BackgroundTransparency = 1,
										LayoutOrder = perkIndex,
										Position = UDim2.fromScale(1, 0),
										Size = UDim2.fromScale(1, 1),
									}, {
										e("UIAspectRatioConstraint"),
									})
								end
							end

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

								UpgradeButton = e("Frame", {
									BackgroundTransparency = 1,
									Position = UDim2.fromScale(1, 0),
									Size = UDim2.new(0, 45, 1, 0),
								}, {
									UIListLayout = e("UIListLayout", {
										Padding = UDim.new(1 / (3 * #self.props.item.Perks), 0),
										SortOrder = Enum.SortOrder.LayoutOrder,
										VerticalAlignment = Enum.VerticalAlignment.Center,
									}),

									UpgradeButtons = Roact.createFragment(upgradeButtons),
								}),
							})
						end,
					})
				end,
			}),

			BasicUpgrade = self.props.itemTypeData.UpgradeBasic and e("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(1, 0.5),
				Size = UDim2.fromOffset(650, 230),
			}, {
				Line = e("Frame", {
					BackgroundColor3 = Color3.fromRGB(155, 155, 155),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 6, 1, 0),
				}),

				Contents = e("Frame", {
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.new(0, 620, 1, 0),
				}, {
					Stars = e("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 120),
					}, {
						UIListLayout = e("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = UDim.new(0, 4),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),

						Stars = Roact.createFragment(basicUpgradeStars),
					}),

					Upgrade = self.props.item.Upgrades < Upgrades.MaxUpgrades and e(PerfectTextLabel, {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Font = Enum.Font.GothamSemibold,
						Position = UDim2.fromScale(0.5, 0.5),
						Text = "Upgrade - " .. FormatNumber(Upgrades.CostToUpgrade(self.props.item)) .. " ",
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 38,

						RenderParent = function(element, size)
							return e(GradientButton, {
								BackgroundColor3 = Color3.new(1, 1, 1),
								BackgroundTransparency = 1,
								Image = ImageFloat,
								LayoutOrder = 2,
								Position = UDim2.fromOffset(0, 145),
								ScaleType = Enum.ScaleType.Slice,
								SliceCenter = Rect.new(6, 4, 86, 20),
								Size = UDim2.fromOffset(145, 54),
								Size = size + UDim2.fromOffset(100, 20),

								AnimateSpeed = 14,
								MinGradient = Color3.fromRGB(0, 209, 70),
								MaxGradient = Color3.fromRGB(0, 148, 50),
								HoveredMaxGradient = Color3.fromRGB(0, 102, 34),

								[Roact.Event.Activated] = self.openBasicUpgrade,
								[Roact.Event.MouseEnter] = self.hoverBasicUpgrade,
								[Roact.Event.MouseLeave] = self.unhoverBasicUpgrade,
							}, {
								UIListLayout = e("UIListLayout", {
									HorizontalAlignment = Enum.HorizontalAlignment.Center,
									FillDirection = Enum.FillDirection.Horizontal,
									SortOrder = Enum.SortOrder.LayoutOrder,
									VerticalAlignment = Enum.VerticalAlignment.Center,
								}),

								Label = element,

								CapIcon = e("ImageLabel", {
									BackgroundTransparency = 1,
									Image = ImageCap,
									LayoutOrder = 2,
									Size = UDim2.fromScale(1, 1),
								}, {
									UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
								}),
							})
						end,
					}),
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
					Padding = UDim.new(0, 28),
				}),

				BackButton = e(BackButton, {
					GoBack = self.props.close,
				}),

				Sell = e(PerfectTextLabel, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Font = Enum.Font.GothamSemibold,
					Position = UDim2.fromScale(0.5, 0.5),
					Text = "Sell",
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 24,

					RenderParent = function(element, size)
						return e(GradientButton, {
							BackgroundColor3 = Color3.new(1, 1, 1),
							BackgroundTransparency = 1,
							Image = ImageFloat,
							LayoutOrder = 2,
							ScaleType = Enum.ScaleType.Slice,
							SliceCenter = Rect.new(6, 4, 86, 20),
							Size = UDim2.fromOffset(145, 54),
							Size = UDim2.new(0, size.X.Offset + 42, 1, 0),

							AnimateSpeed = 14,
							MinGradient = Color3.fromRGB(201, 51, 37),
							MaxGradient = Color3.fromRGB(175, 38, 25),
							HoveredMaxGradient = Color3.fromRGB(197, 44, 30),

							[Roact.Event.Activated] = self.openSellPrompt,
						}, {
							Label = element,
						})
					end,
				}),
			}),
		})
	})
end

function Shopkeeper2:init()
	self.closeOpenedItem = function()
		self:setState({
			openedItem = Roact.None,
		})
	end

	self.closePrompt = function()
		self:setState({
			sellAll = false,
		})
	end

	self.openItem = function(item)
		local newState = {
			openedItem = item.UUID,
		}

		for check, data in pairs(ITEM_TYPES) do
			if check(item) then
				newState.compareToItem = (self.props.equipment[data.EquipmentKey] or {}).UUID
				newState.itemTypeData = data
			end
		end

		self:setState(newState)
	end

	self.sellAll = function()
		Sell:FireServer("*")
		self.closePrompt()
	end

	self.openSellAll = function()
		self:setState({
			sellAll = true,
		})
	end
end

function Shopkeeper2:FindByUUID(uuid)
	if uuid == nil then
		return nil
	end

	for _, item in ipairs(self.props.inventory) do
		if item.UUID == uuid then
			return item
		end
	end
end

function Shopkeeper2:render()
	if not self.props.visible then
		return nil
	end

	local inventoryContents = {}
	local cells = 0

	for index, item in ipairs(self.props.inventory) do
		for check, data in pairs(ITEM_TYPES) do
			if check(item) then
				cells = cells + 1
				local equipped = self.props.equipped[item.UUID]
				local layoutOrder = equipped and data.EquippedOrder or (index + 100)

				inventoryContents[item.UUID] = e(ItemPreview, {
					Angle = data.Angle,
					Equipped = equipped,
					Item = item,
					LayoutOrder = layoutOrder,
					Name = Loot.GetLootName(item),
					ShowGearScore = data.ShowGearScore,
					ZIndex = -layoutOrder,

					Equip = function()
						self.openItem(item)
					end,

					-- I am an idiot
					OpenLevelWarning = function()
						self.openItem(item)
					end,
				})
			end
		end
	end

	local rows = math.ceil(cells / 3)
	local inventoryHeight = (rows * ITEM_PREVIEW_CELL_SIZE.Y.Offset)
		+ (rows * ITEM_PREVIEW_CELL_PADDING.Y.Offset)

	local confirmPrompt

	if self.state.sellAll then
		confirmPrompt = e(ConfirmPrompt2, {
			Text = "Are you sure you want to sell ALL unequipped and unfavorited items?",
			MaxWidth = 420,
			Buttons = {
				Yes = {
					LayoutOrder = 1,
					Style = "Yes",
					Text = "Yes",
					Activated = self.sellAll,
				},

				No = {
					LayoutOrder = 2,
					Style = "No",
					Text = "No",
					Activated = self.closePrompt,
				},
			},
		})
	end

	return e(FocusContent, {
		BackgroundColor = Color3.fromRGB(131, 74, 0),
	}, {
		HideCrosshair = e(Tagged, {
			Tag = "HideCrosshair",
		}, {
			Full = e("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				ConfirmPrompt = confirmPrompt,

				OpenedItem = self.state.openedItem and e(OpenedItem, {
					close = self.closeOpenedItem,
					compareTo = self:FindByUUID(self.state.compareToItem),
					equipped = self.state.itemTypeData.EquipmentKey
						and (self.props.equipment[self.state.itemTypeData.EquipmentKey] or {}).UUID
							== self.state.openedItem,
					gold = self.props.gold,
					item = self:FindByUUID(self.state.openedItem),
					itemTypeData = self.state.itemTypeData,
				}),

				Contents = e("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(1361, 1012),
				}, {
					Scale = e(Scale, {
						Size = Vector2.new(1361, 1012),
					}),

					Label = e(PerfectTextLabel, {
						Font = Enum.Font.GothamBlack,
						Text = "Upgrade / Sell",
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = 42,
					}),

					Inventory = e("ScrollingFrame", {
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						CanvasSize = UDim2.fromOffset(0, inventoryHeight),
						Position = UDim2.fromOffset(0, 62),
						Size = UDim2.new(1, 0, 0, 866),
						VerticalScrollBarInset = Enum.ScrollBarInset.Always,
					}, {
						UIGridLayout = e("UIGridLayout", {
							CellPadding = ITEM_PREVIEW_CELL_PADDING,
							CellSize = ITEM_PREVIEW_CELL_SIZE,
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),

						Items = Roact.createFragment(inventoryContents),
					}),

					Buttons = self.state.openedItem == nil and e("Frame", {
						AnchorPoint = Vector2.new(0, 1),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0, 1),
						Size = UDim2.new(1, 0, 0, 54),
					}, {
						UIListLayout = e("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							Padding = UDim.new(0, 28),
						}),

						BackButton = e(BackButton, {
							GoBack = self.props.close,
						}),

						SellAll = e(PerfectTextLabel, {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Font = Enum.Font.GothamSemibold,
							Position = UDim2.fromScale(0.5, 0.5),
							Text = "Sell ALL",
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 24,

							RenderParent = function(element, size)
								return e(GradientButton, {
									BackgroundColor3 = Color3.new(1, 1, 1),
									BackgroundTransparency = 1,
									Image = ImageFloat,
									LayoutOrder = 2,
									ScaleType = Enum.ScaleType.Slice,
									SliceCenter = Rect.new(6, 4, 86, 20),
									Size = UDim2.fromOffset(145, 54),
									Size = UDim2.new(0, size.X.Offset + 42, 1, 0),

									AnimateSpeed = 14,
									MinGradient = Color3.fromRGB(201, 51, 37),
									MaxGradient = Color3.fromRGB(175, 38, 25),
									HoveredMaxGradient = Color3.fromRGB(197, 44, 30),

									[Roact.Event.Activated] = self.openSellAll,
								}, {
									Label = element,
								})
							end,
						}),
					}),
				}),
			}),
		}),
	})
end

return RoactRodux.connect(function(state)
	local equippedItems = {}

	local equipment = state.equipment
	if equipment ~= nil then
		for _, data in pairs(ITEM_TYPES) do
			local equipped = equipment[data.EquipmentKey]
			if equipped then
				equippedItems[equipped.UUID] = true
			end
		end
	end

	return {
		equipment = equipment or {},
		equipped = equippedItems,
		gold = state.gold,
		inventory = state.inventory or {},
		visible = state.page.current == "Shopkeeper",
	}
end, function(dispatch)
	return {
		close = function()
			dispatch({
				type = "CloseShopkeeper",
			})
		end,
	}
end)(Shopkeeper2)
