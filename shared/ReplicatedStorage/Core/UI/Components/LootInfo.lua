local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local assign = require(ReplicatedStorage.Core.assign)
local Data = require(ReplicatedStorage.Core.Data)
local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local Loot = require(ReplicatedStorage.Core.Loot)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
local RuddevConfig = require(ReplicatedStorage.RuddevModules.Config)
local Upgrades = require(ReplicatedStorage.Core.Upgrades)
local ViewportFramePreviewComponent = require(ReplicatedStorage.Core.UI.Components.ViewportFramePreviewComponent)

local e = Roact.createElement
local LocalPlayer = Players.LocalPlayer
local LootInfo = Roact.PureComponent:extend("LootInfo")

local function formatNumber(format, number)
	if format then
		return format:format(number)
	else
		return EnglishNumbers(number)
	end
end

local function isAurora(loot)
	return loot.Type ~= "Helmet" and loot.Type ~= "Armor"
		and (loot.Model >= 6 and loot.Model <= 10)
end

local function getRarityText(loot, rarity)
	local infix = " "

	if isAurora(loot) then
		infix = " Aurora "
	end

	return rarity.Name .. infix .. loot.Type
end

local function Stat(props)
	local diffProps = {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamSemibold,
		LayoutOrder = 2,
		Size = UDim2.new(0.38, 0, 0.5, 0),
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	}

	local diff = props.Stat - props.Compare
	local diffText = formatNumber(props.Format, diff)

	local consideredZero = props.Zero or 0

	if diff > consideredZero then
		diffProps.Text = "+" .. diffText
		diffProps.TextColor3 = Color3.fromRGB(85, 255, 127)
	elseif diff < 0 then
		diffProps.Text = diffText
		diffProps.TextColor3 = Color3.fromRGB(232, 65, 24)
	else
		diffProps.Text = "+0"
		diffProps.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	end

	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
	}, {
		e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.04, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Label = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack,
			LayoutOrder = 0,
			Size = UDim2.new(0.4, 0, 1, 0),
			Text = props.StatName,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),

		Current = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			LayoutOrder = 1,
			Size = UDim2.new(0.25, 0, 0.5, 0),
			Text = formatNumber(props.Format, props.Stat),
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),

		Diff = e("TextLabel", diffProps),
	})
end

function LootInfo:init()
	self:UpdateModelState()
end

function LootInfo:render()
	local frameProps = assign(self.props.Native or {}, {
		BackgroundTransparency = 1,
	})

	local loot = self.props.Loot

	local rarity = Loot.Rarities[loot.Rarity]

	local levelTextColor3 = Color3.fromRGB(227, 227, 227)

	if LocalPlayer.PlayerData.Level.Value < loot.Level then
		levelTextColor3 = Color3.fromRGB(214, 48, 49)
	end

	local stats = {}

	if loot.Type == "Helmet" or loot.Type == "Armor" then
		local healthFunction = ArmorScaling[loot.Type .. "Health"]

		local currentItem = self.props.equipment["equipped" .. loot.Type]

		stats.UIGridLayout = e("UIGridLayout", {
			CellPadding = UDim2.new(0.1, 0, 0.02, 0),
			CellSize = UDim2.new(0.9, 0, 0.48, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})

		local currentHealth = healthFunction(
			currentItem.Level,
			currentItem.Rarity
		)
		currentHealth = currentHealth + Upgrades.GetArmorBuff(currentHealth, currentItem.Upgrades)

		local lootHealth = healthFunction(loot.Level, loot.Rarity)
		lootHealth = lootHealth + Upgrades.GetArmorBuff(lootHealth, loot.Upgrades)

		stats.Health = e(Stat, {
			Compare = currentHealth,
			Stat = lootHealth,
			StatName = "HP",
		})

		local currentRegen = ArmorScaling.ArmorRegen(currentItem.Level)
		currentRegen = currentRegen + Upgrades.GetRegenBuff(currentRegen, currentItem.Upgrades)

		local lootRegen = ArmorScaling.ArmorRegen(loot.Level)
		lootRegen = lootRegen + Upgrades.GetRegenBuff(lootRegen, loot.Upgrades)

		stats.Regen = e(Stat, {
			Compare = currentRegen,
			Stat = lootRegen,
			StatName = "HEAL",
		})
	else
		local currentGunItem = self.props.equipment.equippedWeapon
		local currentGun = GunScaling.BaseStats(
			currentGunItem.Type,
			currentGunItem.Level,
			currentGunItem.Rarity
		)

		local lootDamage, currentGunDamage = loot.Damage, currentGun.Damage

		if loot.Type == "Shotgun" then
			lootDamage = lootDamage * RuddevConfig.GetShotgunShotSize(loot.Level)
		end

		if currentGunItem.Type == "Shotgun" then
			currentGunDamage = currentGunDamage * RuddevConfig.GetShotgunShotSize(currentGunItem.Level)
		end

		currentGunDamage = currentGunDamage + Upgrades.GetDamageBuff(currentGunDamage, currentGunItem.Upgrades)
		lootDamage = lootDamage + Upgrades.GetDamageBuff(lootDamage, loot.Upgrades)

		currentGunDamage = currentGunDamage * (1 + currentGunItem.Bonus / 100)
		lootDamage = lootDamage * (1 + loot.Bonus / 100)

		stats.UIGridLayout = e("UIGridLayout", {
			CellPadding = UDim2.new(0.02, 0, 0.02, 0),
			CellSize = UDim2.new(0.48, 0, 0.48, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})

		stats.Damage = e(Stat, {
			LayoutOrder = 0,
			Compare = currentGunDamage,
			Stat = lootDamage,
			StatName = "DMG",
		})

		stats.FireRate = e(Stat, {
			LayoutOrder = 1,
			Compare = math.floor(currentGun.FireRate * 10 + 0.5) / 10,
			Stat = math.floor(loot.FireRate * 10 + 0.5) / 10,
			StatName = "RATE",
			Format = "%.1f",
			Zero = 0.009999,
		})

		stats.CritChance = e(Stat, {
			LayoutOrder = 2,
			Compare = math.floor(currentGun.CritChance * 100),
			Stat = math.floor(loot.CritChance * 100),
			StatName = "CRIT%",
			Format = "%d%%",
		})

		stats.MagSize = e(Stat, {
			LayoutOrder = 3,
			Compare = currentGun.Magazine,
			Stat = loot.Magazine,
			StatName = "AMMO",
		})
	end

	return e("Frame", frameProps, {
		e("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.01, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		Level = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = 0,
			Size = UDim2.new(0.9, 0, 0.06, 0),
			Text = "Level " .. loot.Level,
			TextColor3 = levelTextColor3,
			TextScaled = true,
		}),

		Rarity = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = 1,
			Size = UDim2.new(0.9, 0, 0.06, 0),
			Text = getRarityText(loot, rarity),
			TextColor3 = Color3.fromRGB(227, 227, 227),
			TextScaled = true,
		}),

		LootName = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			LayoutOrder = 2,
			Size = UDim2.new(0.9, 0, 0.1, 0),
			Text = Loot.GetLootName(loot),
			TextColor3 = Color3.fromRGB(227, 227, 227),
			TextScaled = true,
		}),

		Preview = e(ViewportFramePreviewComponent, {
			Model = self.state.Model,

			Native = {
				BackgroundColor3 = rarity.Color,
				BackgroundTransparency = 0.6,
				BorderSizePixel = 0,
				LayoutOrder = 3,
				Size = UDim2.new(0.5, 0, 0.5, 0),
			},
		}, {
			e("UIAspectRatioConstraint"),
			UpgradeStars = e("TextLabel", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBold,
				Position = UDim2.new(0.01, 0, 1, 0),
				Size = UDim2.new(0.9, 0, 0.2, 0),
				Text = string.rep("⭐", loot.Upgrades),
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		}),

		Stats = e("Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = 4,
			Size = UDim2.new(0.8, 0, 0.25, 0),
		}, stats),
	})
end

function LootInfo:didUpdate(oldProps)
	if self.props.Loot ~= oldProps.Loot then
		self:UpdateModelState()
	end
end

function LootInfo:UpdateModelState()
	local model = Data.GetModel(self.props.Loot)

	if isAurora(self.props.Loot) then
		model.PrimaryPart.Material = Enum.Material.Ice
		model.PrimaryPart.TextureID = ""
	end

	self:setState({
		Model = model,
	})
end

return RoactRodux.connect(function(state)
	return {
		equipment = state.equipment,
	}
end)(LootInfo)
