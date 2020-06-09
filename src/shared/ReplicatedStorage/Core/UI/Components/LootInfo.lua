local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local AttachmentsConstants = require(ReplicatedStorage.Core.AttachmentsConstants)
local assign = require(ReplicatedStorage.Core.assign)
local Data = require(ReplicatedStorage.Core.Data)
local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local Loot = require(ReplicatedStorage.Core.Loot)
local Perks = require(ReplicatedStorage.Core.Perks)
local PetsDictionary = require(ReplicatedStorage.Core.PetsDictionary)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local RoactRodux = require(ReplicatedStorage.Vendor.RoactRodux)
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

local function getRarityText(loot, rarity)
	local lootType = loot.Type
	local infix = " "

	if Loot.IsAurora(loot) then
		infix = " Aurora "
	end

	if Loot.IsAttachment(loot) then
		lootType = "Attachment"
	elseif Loot.IsRevolver(loot) then
		lootType = "Revolver"
	end

	return rarity.Name .. infix .. lootType
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

-- this sucks, should just be used in Stat :/
local function BasicStat(props)
	return e("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromScale(1, 1),
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
			Size = UDim2.new(0.6, 0, 1, 0),
			Text = props.StatName,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),

		Current = e("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			LayoutOrder = 1,
			Size = UDim2.new(0.35, 0, 0.5, 0),
			Text = props.StatNumber,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
		}),
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

	if loot.Level and LocalPlayer.PlayerData.Level.Value < loot.Level then
		levelTextColor3 = Color3.fromRGB(214, 48, 49)
	end

	local stats = {}

	if Loot.IsWearable(loot) then
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
	elseif Loot.IsWeapon(loot) then
		local currentGunItem = self.props.equipment.equippedWeapon
		local currentGun = GunScaling.StatsFor(currentGunItem)

		local lootDamage, currentGunDamage = loot.Damage, currentGun.Damage

		if loot.Type == "Shotgun" then
			lootDamage = lootDamage * loot.ShotSize
		end

		if currentGunItem.Type == "Shotgun" then
			currentGunDamage = currentGunDamage * currentGunItem.ShotSize
		end

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

		if loot.Type == "Crystal" then
			stats.MagSize = e(BasicStat, {
				StatName = "AMMO",
				StatNumber = "∞",
			})
		elseif currentGunItem.Type == "Crystal" then
			-- Don't compare with Crystal gun's magazine size
			stats.MagSize = e(BasicStat, {
				StatName = "AMMO",
				StatNumber = loot.Magazine,
			})
		else
			-- Neither are crystal guns, so neither have infinite ammo
			stats.MagSize = e(Stat, {
				LayoutOrder = 3,
				Compare = currentGun.Magazine,
				Stat = loot.Magazine,
				StatName = "AMMO",
			})
		end
	elseif Loot.IsAttachment(loot) then
		local statName, statNumber

		if loot.Type == "Magazine" then
			statName = "AMMO+"
			statNumber = AttachmentsConstants.Magazine[loot.Rarity] .. "%"
		elseif loot.Type == "Laser" then
			stats.UIGridLayout = e("UIGridLayout", {
				CellPadding = UDim2.new(0.1, 0, 0.02, 0),
				CellSize = UDim2.new(0.9, 0, 0.48, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			})

			stats.CritChance = e(BasicStat, {
				StatName = "CRITx",
				StatNumber = ("1.%.2dx"):format(AttachmentsConstants.LaserSightCritChance[loot.Rarity]),
			})

			stats.Recoil = e(BasicStat, {
				LayoutOrder = 2,
				StatName = "RECOIL",
				StatNumber = AttachmentsConstants.LaserSightCritChance[loot.Rarity] .. "%",
			})
		elseif loot.Type == "Silencer" then
			statName = "DMGx"
			statNumber = ("1.%02dx"):format(AttachmentsConstants.SilencerDamage[loot.Rarity])
		end

		if statName then
			stats.Stat = e(BasicStat, {
				StatName = statName,
				StatNumber = statNumber,
			})
		end
	elseif Loot.IsPet(loot) then
		stats.UIGridLayout = e("UIGridLayout", {
			CellPadding = UDim2.new(0.01, 0, 0.02, 0),
			CellSize = UDim2.new(0.48, 0, 0.48, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})

		local rarity = PetsDictionary.Rarities[loot.Rarity]

		stats.Damage = e(BasicStat, {
			StatName = "DMG%",
			StatNumber = ("%d%%"):format(rarity.Damage * 100),
		})

		stats.FireRate = e(BasicStat, {
			LayoutOrder = 2,
			StatName = "RATE",
			StatNumber = ("%.1f"):format(rarity.FireRate),
		})

		stats.Luck = e(BasicStat, {
			LayoutOrder = 3,
			StatName = "LUCK%",
			StatNumber = ("%d%%"):format(rarity.Luck),
		})
	else
		error("unreachable code! invalid loot type: " .. loot.Type)
	end

	local debugPerks = {
		e("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}),
	}

	if loot.Perks then
		for _, perkData in ipairs(loot.Perks) do
			table.insert(debugPerks, e("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Size = UDim2.fromScale(1, 1 / #loot.Perks),
				Text = Perks.Perks[perkData[1]].Name .. " - " .. perkData[2],
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextStrokeTransparency = 0.2,
				TextXAlignment = Enum.TextXAlignment.Left,
			}))
		end
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
			Text = "Level " .. (loot.Level or "oops"),
			TextColor3 = levelTextColor3,
			TextScaled = true,
			Visible = loot.Level ~= nil,
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
				Text = string.rep("⭐", (loot.Upgrades or 0)),
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			DebugPerks = e("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 0.3),
			}, debugPerks),
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

	if Loot.IsAurora(self.props.Loot) then
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
