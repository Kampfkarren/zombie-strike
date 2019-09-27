local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local Data = require(ReplicatedStorage.Core.Data)
local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)
local GunScaling = require(ReplicatedStorage.Core.GunScaling)
local Loot = require(ReplicatedStorage.Core.Loot)
local Maid = require(ReplicatedStorage.Core.Maid)
local RuddevConfig = require(ReplicatedStorage.RuddevModules.Config)
local ViewportFramePreview = require(ReplicatedStorage.Core.UI.ViewportFramePreview)

local LocalPlayer = Players.LocalPlayer

local function formatNumber(format, number)
	if format then
		return format:format(number)
	else
		return EnglishNumbers(number)
	end
end

local function changeStat(statFrame, lootStat, currentStat, format, consizeredZero)
	consizeredZero = consizeredZero or 0

	local diff = lootStat - currentStat

	local text = formatNumber(format, diff)
	statFrame.Current.Text = formatNumber(format, lootStat)

	if diff > consizeredZero then
		statFrame.Diff.Text = "+" .. text
		statFrame.Diff.TextColor3 = Color3.fromRGB(85, 255, 127)
	elseif diff < 0 then
		statFrame.Diff.Text = text
		statFrame.Diff.TextColor3 = Color3.fromRGB(232, 65, 24)
	else
		statFrame.Diff.Text = "+0"
		statFrame.Diff.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	end
end

local function updateLootInfo(LootInfo, loot)
	if loot.Type ~= "Helmet" and loot.Type ~= "Armor" then
		for key, value in pairs(GunScaling.BaseStats(loot.Type, loot.Level, loot.Rarity)) do
			if loot[key] == nil then
				loot[key] = value
			end
		end
	end

	local currentGun = Data.GetLocalPlayerData("Weapon")
	local rarity = Loot.Rarities[loot.Rarity]

	if rarity.Color then
		LootInfo.ViewportFrame.BackgroundColor3 = rarity.Color
	end

	ViewportFramePreview(LootInfo.ViewportFrame, Data.GetModel(loot))

	LootInfo.Level.Text = "Level " .. loot.Level
	local playerLevel = LocalPlayer.PlayerData.Level.Value

	if playerLevel >= loot.Level then
		LootInfo.Level.TextColor3 = Color3.fromRGB(227, 227, 227)
	else
		LootInfo.Level.TextColor3 = Color3.fromRGB(214, 48, 49)
	end

	LootInfo.LootName.Text = loot.Name
	LootInfo.Rarity.Text = rarity.Name .. " " .. loot.Type

	if loot.Type == "Armor" or loot.Type == "Helmet" then
		local currentArmor = Data.GetLocalPlayerData("Armor")
		local currentArmorBuff = ArmorScaling.ArmorHealth(currentArmor.Level, currentArmor.Rarity)

		local currentHelmet = Data.GetLocalPlayerData("Helmet")
		local currentHelmetBuff = ArmorScaling.HelmetHealth(currentHelmet.Level, currentHelmet.Rarity)

		LootInfo.WeaponStats.Visible = false
		LootInfo.ArmorStats.Visible = true

		local currentHealth, lootHealth
		if loot.Type == "Armor" then
			currentHealth = currentArmorBuff
			lootHealth = ArmorScaling.ArmorHealth(loot.Level, loot.Rarity)
		elseif loot.Type == "Helmet" then
			currentHealth = currentHelmetBuff
			lootHealth = ArmorScaling.HelmetHealth(loot.Level, loot.Rarity)
		end

		changeStat(LootInfo.ArmorStats.Health, lootHealth, currentHealth)
	else
		LootInfo.WeaponStats.Visible = true
		LootInfo.ArmorStats.Visible = false

		local stats = LootInfo.WeaponStats

		changeStat(stats.MagSize, loot.Magazine, currentGun.Magazine)

		local lootDamage, currentGunDamage = loot.Damage, currentGun.Damage

		if loot.Type == "Shotgun" then
			lootDamage = lootDamage * RuddevConfig.GetShotgunShotSize(loot.Level)
		end

		if currentGun.Type == "Shotgun" then
			currentGunDamage = currentGunDamage * RuddevConfig.GetShotgunShotSize(currentGun.Level)
		end

		changeStat(stats.Damage, lootDamage, currentGunDamage)

		changeStat(
			stats.CritChance,
			loot.CritChance,
			currentGun.CritChance,
			"%d%%",
			0.99999999
		)

		changeStat(
			stats.FireRate,
			loot.FireRate,
			currentGun.FireRate,
			"%.1f",
			0.00999999
		)
	end
end

local lootInfoStacks = {}

return function(lootButton, LootInfo, loot, callback)
	local maid = Maid.new()
	callback = callback or function() end

	local function lootInfo()
		updateLootInfo(LootInfo, loot)
	end

	local stack = lootInfoStacks[LootInfo]

	if not stack then
		stack = {}
		lootInfoStacks[LootInfo] = stack
	end

	local function hover()
		stack[lootButton] = true
		lootInfo()
		LootInfo.Visible = true
		callback(true)
	end

	local function unhover()
		stack[lootButton] = nil
		callback(false)
		if next(stack) == nil then
			LootInfo.Visible = false
		end
	end

	maid:GiveTask(lootButton.MouseEnter:connect(hover))
	maid:GiveTask(lootButton.MouseLeave:connect(unhover))

	maid:GiveTask(lootButton:GetPropertyChangedSignal("Visible"):connect(function()
		if not lootButton.Visible then
			unhover()
		end
	end))

	maid:GiveTask(lootButton.SelectionGained:connect(hover))
	maid:GiveTask(lootButton.SelectionLost:connect(unhover))
	maid:GiveTask(unhover)

	return maid
end
