local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local AttachmentsConstants = require(ReplicatedStorage.Core.AttachmentsConstants)
local CalculateGearScore = require(ReplicatedStorage.Core.CalculateGearScore)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local ItemImage = require(ReplicatedStorage.Core.UI.Components.ItemImage)
local Loot = require(ReplicatedStorage.Core.Loot)
local PerfectTextLabel = require(ReplicatedStorage.Core.UI.Components.PerfectTextLabel)
local PetsDictionary = require(ReplicatedStorage.Core.PetsDictionary)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local Upgrades = require(ReplicatedStorage.Core.Upgrades)

local e = Roact.createElement

local COLOR_BETTER = Color3.fromRGB(0, 184, 11)
local COLOR_SAME = Color3.new(0.4, 0.4, 0.4)
local COLOR_WORSE = Color3.fromRGB(182, 10, 0)
local TREAT_AS_ZERO = 0.09

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
	elseif Loot.IsPet(props.Item) then
		local pet, compareTo = PetsDictionary.Rarities[props.Item.Rarity], PetsDictionary.Rarities[props.CompareTo.Rarity]

		children.Luck = e(Stat, {
			LayoutOrder = 1,

			CompareTextSize = 18,
			TextSize = 30,

			Item = pet.Luck,
			CompareTo = compareTo.Luck,
			ShouldCompare = shouldCompare,

			TextFormat = "%d%%",

			HeaderText = "Luck",
			HeaderTextSize = 24,
		})

		children.FireRate = e(Stat, {
			LayoutOrder = 1,

			CompareTextSize = 18,
			TextSize = 30,

			Item = pet.FireRate,
			CompareTo = compareTo.FireRate,
			ShouldCompare = shouldCompare,

			TextFormat = "%.1f/sec",

			HeaderText = "Fire Rate",
			HeaderTextSize = 24,
		})

		children.Damage = e(Stat, {
			LayoutOrder = 3,

			CompareTextSize = 18,
			TextSize = 30,

			Item = pet.Damage * 100,
			CompareTo = compareTo.Damage * 100,
			ShouldCompare = shouldCompare,

			TextFormat = "%d%%",

			HeaderText = "Damage",
			HeaderTextSize = 24,
		})
	elseif Loot.IsAttachment(props.Item) then
		local compareToRarity = props.CompareTo and props.CompareTo.Rarity

		if props.Item.Type == "Silencer" then
			children.Damage = e(Stat, {
				CompareTextSize = 32,
				TextSize = 70,

				Item = AttachmentsConstants.SilencerDamage[props.Item.Rarity],
				CompareTo = AttachmentsConstants.SilencerDamage[compareToRarity],
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
				CompareTo = AttachmentsConstants.LaserSightCritChance[compareToRarity],
				ShouldCompare = shouldCompare and props.CompareTo and props.CompareTo.Type == "Laser",

				TextFormat = "%d%%",

				HeaderText = "Crit Chance+",
				HeaderTextSize = 24,
			})

			children.Recoil = e(Stat, {
				LayoutOrder = 2,

				CompareTextSize = 24,
				TextSize = 42,

				Item = AttachmentsConstants.LaserSightRecoil[props.Item.Rarity],
				CompareTo = AttachmentsConstants.LaserSightRecoil[compareToRarity],
				ShouldCompare = shouldCompare and props.CompareTo and props.CompareTo.Type == "Laser",

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
				ShouldCompare = shouldCompare and props.CompareTo and props.CompareTo.Type == "Magazine",

				TextFormat = "%d%%",

				HeaderText = "Ammo+",
				HeaderTextSize = 24,
			})
		end
	end

	if props.Scale then
		children.Scale = e("UIScale", {
			Scale = props.Scale,
		})
	end

	return e("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 200, 1, -300),
		Position = UDim2.new(0, 0, 1, -(props.Offset or 75)),
	}, children)
end

local function ItemDetails(props)
	return e("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	}, {
		ItemName = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Position = UDim2.fromOffset(0, 59),
			Size = UDim2.new(1, 0, 0, 59),
			Text = (props.GetName or Loot.GetLootName)(props.Item),
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextSize = 50,
			TextStrokeTransparency = 0.6,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, {
			UITextSizeConstraint = e("UITextSizeConstraint", {
				MaxTextSize = 50,
			}),
		}),

		ItemModel = e(ItemImage, {
			Distance = 1.2,
			Item = props.Item,
			SpinSpeed = 1,
		}),

		-- TODO: Toggle for cosmetics, cosmetic helmets count as wearable
		Stats = e(Stats, {
			CompareTo = props.CompareTo,
			Item = props.Item,
			Offset = props.StatsOffset,
			Scale = props.StatsScale,
			ShowGearScore = props.ShowGearScore,
		}),
	})
end

return ItemDetails
