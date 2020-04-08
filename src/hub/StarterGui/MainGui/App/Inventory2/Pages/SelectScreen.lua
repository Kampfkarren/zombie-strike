local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryComponents = script.Parent.Parent.Components

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local AttachmentsConstants = require(ReplicatedStorage.Core.AttachmentsConstants)
local BackButton = require(InventoryComponents.BackButton)
local CalculateGearScore = require(ReplicatedStorage.Core.CalculateGearScore)
local ConfirmPrompt = require(ReplicatedStorage.Core.UI.Components.ConfirmPrompt)
local Counter = require(ReplicatedStorage.Core.UI.Components.Counter)
local Data = require(ReplicatedStorage.Core.Data)
local ItemModel = require(InventoryComponents.ItemModel)
local ItemType = require(InventoryComponents.ItemType)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local Loot = require(ReplicatedStorage.Core.Loot)
local HoverStack = require(ReplicatedStorage.Core.UI.Components.HoverStack)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local Rarity = require(InventoryComponents.Rarity)
local RarityTintedGradientButton = require(InventoryComponents.RarityTintedGradientButton)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local Scale = require(ReplicatedStorage.Core.UI.Components.Scale)
local SearchItemRelevancy = require(ReplicatedStorage.Libraries.SearchItemRelevancy)
local Upgrades = require(ReplicatedStorage.Core.Upgrades)

local ImageSearch = require(ReplicatedStorage.Assets.Tarmac.UI.search)
local ImageSelected2 = require(ReplicatedStorage.Assets.Tarmac.UI.selected2)
local ImageItemButton = require(ReplicatedStorage.Assets.Tarmac.UI.item_button)
local ImageStar = require(ReplicatedStorage.Assets.Tarmac.UI.star)

local e = Roact.createElement

local SelectScreen = Roact.Component:extend("SelectScreen")

local COLOR_BETTER = Color3.fromRGB(0, 184, 11)
local COLOR_SAME = Color3.new(0.4, 0.4, 0.4)
local COLOR_WORSE = Color3.fromRGB(182, 10, 0)

local CELL_PADDING = UDim2.fromOffset(20, 20)
local CELL_SIZE = UDim2.fromOffset(430, 160)

local IMAGE_TYPES = {
	Face = function(item)
		return item.Instance.Texture
	end,

	Spray = function(item)
		return item.Image
	end,

	Particle = function(item)
		return item.Image.Texture
	end,
}

local TREAT_AS_ZERO = 0.09

SelectScreen.defaultProps = {
	AllowUnequip = false,
	ShowGearScore = true,
}

local function roundToNearest(number, points)
	return math.floor((number * (points * 10)) + 0.5) / (points * 10)
end

local function getDamage(stats, item)
	if item.Type == "Shotgun" then
		return stats.Damage * stats.ShotSize
	end

	return stats.Damage
end

local function getHealth(item)
	local healthFunction = ArmorScaling[item.Type .. "Health"]
	local health = healthFunction(item.Level, item.Rarity)
	return health + Upgrades.GetArmorBuff(health, item.Upgrades or 0)
end

local function getRegen(item)
	local regen = ArmorScaling.ArmorRegen(item.Level)
	return regen + Upgrades.GetRegenBuff(regen, item.Upgrades or 0)
end

local function getId(item)
	if item == nil then
		return nil
	end

	return item.UUID or item.Index
end

local function ItemImage(props)
	-- TODO: Particle
	if IMAGE_TYPES[props.Item.Type] then
		local image = IMAGE_TYPES[props.Item.Type](props.Item)

		return e(Counter, {
			Render = function(total)
				return e("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = image,
					Position = total:map(function(total)
						return UDim2.fromScale(0.5, 0.5 + math.sin(total) * 1 / 20)
					end),
					Size = UDim2.fromScale(1, 1),
				}, {
					UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
				})
			end,
		})
	else
		return e(ItemModel, {
			Angle = props.Angle,
			Distance = props.Distance,
			Model = Data.GetModel(props.Item),
			SpinSpeed = props.SpinSpeed,
		}, props[Roact.Children])
	end
end

local function Stat(props)
	local textFormat = props.TextFormat or "%d"

	local compareValue
	if props.ShouldCompare then
		compareValue = props.Item - props.CompareTo
	end

	local compareFormat = "("

	if compareValue and compareValue > 0 then
		compareFormat = compareFormat .. "+"
	end

	if props.TextFormat then
		compareFormat = compareFormat .. props.TextFormat
	else
		compareFormat = compareFormat .. "%d"
	end

	compareFormat = compareFormat .. ")"

	local compareColor

	if compareValue ~= nil then
		if compareValue > TREAT_AS_ZERO then
			compareColor = COLOR_BETTER
		elseif compareValue < -TREAT_AS_ZERO then
			compareColor = COLOR_WORSE
		else
			compareColor = COLOR_SAME
		end
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.new(1, 0, 0, props.TextSize + 16),
	}, {
		Numbers = e("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, props.TextSize),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
			}),

			Value = e(PerfectTextLabel, {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				LayoutOrder = 1,
				Size = UDim2.fromOffset(80, props.TextSize),
				Text = textFormat:format(props.Item),
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = props.TextSize,
				TextStrokeTransparency = 0.6,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,
			}),

			Compare = compareValue and e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				LayoutOrder = 2,
				Size = UDim2.fromOffset(75, props.TextSize),
				Text = compareFormat:format(compareValue),
				TextColor3 = compareColor,
				TextSize = props.CompareTextSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),
		}),

		Header = e("TextLabel", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, props.HeaderTextSize),
			Text = props.HeaderText,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = props.HeaderTextSize,
			TextStrokeTransparency = 0.6,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Bottom,
		}),
	})
end

local function Stats(props)
	local children = {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}),
	}

	local shouldCompare = props.Item ~= props.CompareTo

	if props.ShowGearScore then
		children.GearScore = e(Stat, {
			LayoutOrder = 100,

			CompareTextSize = 24,
			TextSize = 70,

			Item = CalculateGearScore(props.Item),
			CompareTo = CalculateGearScore(props.CompareTo),
			ShouldCompare = shouldCompare,

			HeaderText = "Power",
			HeaderTextSize = 24,
		})
	end

	if Loot.IsWeapon(props.Item) and not Loot.IsGunSkin(props.Item) then
		-- TODO: This will probably have to be changed with perks
		local item = GunScaling.StatsFor(props.Item)
		local compareTo = GunScaling.StatsFor(props.CompareTo)

		children.CritChance = e(Stat, {
			LayoutOrder = 1,

			CompareTextSize = 18,
			TextSize = 30,

			Item = roundToNearest(item.CritChance * 100, 1),
			CompareTo = roundToNearest(compareTo.CritChance * 100, 1),
			ShouldCompare = shouldCompare,

			TextFormat = "%.1f%%",

			HeaderText = "Crit Chance",
			HeaderTextSize = 24,
		})

		children.CritDamage = e(Stat, {
			LayoutOrder = 2,

			CompareTextSize = 18,
			TextSize = 30,

			Item = item.CritDamage,
			CompareTo = compareTo.CritDamage,
			ShouldCompare = shouldCompare,

			HeaderText = "Crit Damage",
			HeaderTextSize = 24,
		})

		children.Damage = e(Stat, {
			LayoutOrder = 3,

			CompareTextSize = 18,
			TextSize = 30,

			Item = getDamage(item, props.Item),
			CompareTo = getDamage(compareTo, props.CompareTo),
			ShouldCompare = shouldCompare,

			HeaderText = "Damage",
			HeaderTextSize = 24,
		})

		children.Ammo = e(Stat, {
			LayoutOrder = 4,

			CompareTextSize = 18,
			TextSize = 30,

			Item = item.Magazine,
			CompareTo = compareTo.Magazine,
			ShouldCompare = shouldCompare
				and props.Item.Type ~= "Crystal"
				and props.CompareTo.Type ~= "Crystal",

			TextFormat = props.Item.Type == "Crystal"
				and utf8.char(0x221e) -- Infinite symbol
				or nil,

			HeaderText = "Ammo",
			HeaderTextSize = 24,
		})

		children.FireRate = e(Stat, {
			LayoutOrder = 5,

			CompareTextSize = 18,
			TextSize = 30,

			Item = item.FireRate,
			CompareTo = compareTo.FireRate,
			ShouldCompare = shouldCompare,

			TextFormat = "%.1f/sec",

			HeaderText = "Fire Rate",
			HeaderTextSize = 24,
		})
	elseif Loot.IsWearable(props.Item) and props.Item.Level ~= nil then
		children.Health = e(Stat, {
			LayoutOrder = 2,

			CompareTextSize = 18,
			TextSize = 30,

			Item = getHealth(props.Item),
			CompareTo = getHealth(props.CompareTo),
			ShouldCompare = shouldCompare,

			HeaderText = "Health",
			HeaderTextSize = 24,
		})

		children.Heal = e(Stat, {
			LayoutOrder = 1,

			CompareTextSize = 18,
			TextSize = 30,

			Item = getRegen(props.Item),
			CompareTo = getRegen(props.CompareTo),
			ShouldCompare = shouldCompare,

			HeaderText = "Heal",
			HeaderTextSize = 24,
		})
	elseif Loot.IsAttachment(props.Item) then
		if props.Item.Type == "Silencer" then
			children.Damage = e(Stat, {
				CompareTextSize = 32,
				TextSize = 70,

				Item = AttachmentsConstants.SilencerDamage[props.Item.Rarity],
				CompareTo = AttachmentsConstants.SilencerDamage[props.CompareTo and props.CompareTo.Rarity],
				ShouldCompare = shouldCompare and props.CompareTo and props.CompareTo.Type == "Silencer",

				TextFormat = "%d%%",

				HeaderText = "Damage+",
				HeaderTextSize = 24,
			})
		elseif props.Item.Type == "Laser" then
			children.CritChance = e(Stat, {
				LayoutOrder = 1,

				CompareTextSize = 24,
				TextSize = 42,

				Item = AttachmentsConstants.LaserSightCritChance[props.Item.Rarity],
				CompareTo = AttachmentsConstants.LaserSightCritChance[props.CompareTo.Rarity],
				ShouldCompare = shouldCompare and props.CompareTo.Type == "Laser",

				TextFormat = "%d%%",

				HeaderText = "Crit Chance+",
				HeaderTextSize = 24,
			})

			children.Recoil = e(Stat, {
				LayoutOrder = 2,

				CompareTextSize = 24,
				TextSize = 42,

				Item = AttachmentsConstants.LaserSightRecoil[props.Item.Rarity],
				CompareTo = AttachmentsConstants.LaserSightRecoil[props.CompareTo.Rarity],
				ShouldCompare = shouldCompare and props.CompareTo.Type == "Laser",

				TextFormat = "%d%%",

				HeaderText = "Recoil-",
				HeaderTextSize = 24,
			})
		elseif props.Item.Type == "Magazine" then
			children.Damage = e(Stat, {
				CompareTextSize = 32,
				TextSize = 70,

				Item = AttachmentsConstants.Magazine[props.Item.Rarity],
				CompareTo = AttachmentsConstants.Magazine[props.CompareTo.Rarity],
				ShouldCompare = shouldCompare and props.CompareTo.Type == "Magazine",

				HeaderText = "Ammo+",
				HeaderTextSize = 24,
			})
		end
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 200, 1, -300),
		Position = UDim2.new(0, 0, 1, -75),
	}, children)
end

local function ItemPreview(props)
	local rarityAndLevel = {
		UIListLayout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Gap = e("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Size = UDim2.fromOffset(14, 0),
		}),
	}

	if props.Item.Level then
		rarityAndLevel.LevelLabel = e(PerfectTextLabel, {
			Font = Enum.Font.Gotham,
			LayoutOrder = 1,
			Text = "LV",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		rarityAndLevel.Level = e(PerfectTextLabel, {
			Font = Enum.Font.GothamBold,
			LayoutOrder = 2,
			Text = props.Item.Level,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 19,
			TextXAlignment = Enum.TextXAlignment.Right,
		})
	end

	if props.Item.Rarity then
		rarityAndLevel.Rarity = e(Rarity, {
			LayoutOrder = 4,
			Rarity = props.Item.Rarity,
			Style = "Right",

			Padding = {
				Left = 11,
				Right = 11,
			},
		})
	end

	local gearScoreChildren

	if props.ShowGearScore then
		gearScoreChildren = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(25, 110),
			Size = UDim2.fromOffset(116, 42),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			ItemGearScore = e(PerfectTextLabel, {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBlack,
				Position = UDim2.fromOffset(25, 110),
				Text = CalculateGearScore(props.Item),
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 48,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			GearScoreLabel = e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				LayoutOrder = 2,
				Position = UDim2.fromOffset(90, 135),
				Size = UDim2.new(0, 47, 1, 0),
				Text = "Power",
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 30,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				TextTransparency = 0.01,
			}),
		})
	end

	local upgradeStars

	if props.Item.Upgrades then
		upgradeStars = {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 3),
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		}

		for _ = 1, props.Item.Upgrades do
			table.insert(upgradeStars, e("ImageLabel", {
				BackgroundTransparency = 1,
				Image = ImageStar,
				ImageColor3 = Color3.new(1, 1, 0.4),
				Size = UDim2.fromScale(1, 1),
			}, {
				UIAspectRatioConstraint = e("UIAspectRatioConstraint"),
			}))
		end
	end

	return e(RarityTintedGradientButton, {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder,
		Image = ImageItemButton,

		Rarity = props.Item.Rarity,

		[Roact.Event.MouseEnter] = props.Hover,
		[Roact.Event.MouseLeave] = props.Unhover,
		[Roact.Event.SelectionGained] = props.Hover,
		[Roact.Event.SelectionLost] = props.Unhover,
		[Roact.Event.Activated] = props.Equip,
	}, {
		Selected = props.Equipped and e("ImageLabel", {
			BackgroundTransparency = 1,
			Image = ImageSelected2,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
		}),

		ItemImage = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			ClipsDescendants = false,
			Position = UDim2.new(1, 40, 0, 0),
			Size = UDim2.new(0, 350, 1, 0),
			ZIndex = 0,
		}, {
			Model = e(ItemImage, {
				Angle = props.Angle,
				Item = props.Item,
			}, {
				Gradient = e("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.3),
						NumberSequenceKeypoint.new(0.8, 0.3),
						NumberSequenceKeypoint.new(1, 1),
					}),
				}),
			}),
		}),

		ItemTypeLabel = e(ItemType, {
			Native = {
				Position = UDim2.fromOffset(25, 25),
				ZIndex = 2,
			},
			Item = props.Item,
			TextSize = 20,
		}),

		ItemName = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = UDim2.fromOffset(25, 57),
			Size = UDim2.new(1, -150, 0, 72),
			Text = props.Name,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 32,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}),

		RarityAndLevel = e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 108),
			Size = UDim2.new(1, 0, 0, 32),
		}, rarityAndLevel),

		Upgrades = props.Item.Upgrades and e("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 7),
			Size = UDim2.new(1, props.Equipped and -45 or -12, 0, 22),
		}, upgradeStars),

		gearScoreChildren,
	})
end

function SelectScreen:init()
	self.initialEquip = self.props.Equipped
	self.frameRef = Roact.createRef()

	self:setState({
		equippingAttachment = nil,
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
					layoutOrder = inventoryItem == self.initialEquip and 0 or index
				else
					layoutOrder = SearchItemRelevancy(search, name, inventoryItem)
				end

				if layoutOrder ~= nil then
					local equipped = getId(inventoryItem) == getId(self.state.equipped)

					inventory[inventoryItem.UUID or inventoryItem.Name] = e(ItemPreview, {
						Angle = props.Angle,
						Equipped = equipped,
						Item = inventoryItem,
						LayoutOrder = layoutOrder,
						Name = name,
						ShowGearScore = props.ShowGearScore,

						Hover = hover(inventoryItem),
						Unhover = unhover(inventoryItem),
						Equip = self.equip(inventoryItem),
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

				AttachmentConfirmPrompt = self.state.equippingAttachment and e(ConfirmPrompt, {
					Window = self.frameRef,
					Text = string.format(
						"Are you sure you want to equip '%s'? It can not be removed from your gun later!",
						Loot.GetLootName(self.state.equippingAttachment)
					),

					Yes = function()
						self.equip(self.state.equippingAttachment)()
						self:setState({
							equippingAttachment = Roact.None,
						})
					end,

					No = function()
						self:setState({
							equippingAttachment = Roact.None,
						})
					end,
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

					Preview = previewItem and e("Frame", {
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
					}, {
						ItemName = e("TextLabel", {
							BackgroundTransparency = 1,
							Font = Enum.Font.GothamBold,
							Position = UDim2.fromOffset(0, 59),
							Size = UDim2.new(1, 0, 0, 59),
							Text = props.GetName(previewItem),
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 50,
							TextStrokeTransparency = 0.6,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Top,
						}),

						ItemModel = e(ItemImage, {
							Distance = 1.2,
							Item = previewItem,
							SpinSpeed = 1,
						}),

						-- TODO: Toggle for cosmetics, cosmetic helmets count as wearable
						Stats = e(Stats, {
							CompareTo = self.state.equipped,
							Item = previewItem,
							ShowGearScore = props.ShowGearScore,
						}),
					}),

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

					-- TODO: Focus on click
					SearchBar = #props.Inventory > 0 and e("ImageButton", {
						BackgroundTransparency = 1,
						Image = ImageSearch,
						Position = UDim2.fromOffset(0, 8),
						ScaleType = Enum.ScaleType.Crop,
						Size = UDim2.fromOffset(368, 54),
					}, {
						TextBox = e("TextBox", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = 1,
							Font = Enum.Font.Gotham,
							PlaceholderText = "Search for something...",
							Position = UDim2.new(0, 78, 0.5,0 ),
							Size = UDim2.fromOffset(270, 22),
							Text = self.state.search,
							TextColor3 = Color3.new(1, 1, 1),
							TextSize = 22,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,

							[Roact.Change.Text] = self.searchChanged,
						}),
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
