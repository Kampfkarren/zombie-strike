local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local Data = require(ReplicatedStorage.Core.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local Maid = require(ReplicatedStorage.Core.Maid)
local ViewportFramePreview = require(ReplicatedStorage.Core.UI.ViewportFramePreview)

local function changeStat(statFrame, lootStat, currentStat, format, consizeredZero)
	consizeredZero = consizeredZero or 0
	format = format or "%d"
	statFrame.Current.Text = format:format(lootStat)

	local diff = lootStat - currentStat

	if diff > consizeredZero then
		statFrame.Diff.Text = "+" .. format:format(diff)
		statFrame.Diff.TextColor3 = Color3.fromRGB(85, 255, 127)
	elseif diff < 0 then
		statFrame.Diff.Text = format:format(diff)
		statFrame.Diff.TextColor3 = Color3.fromRGB(232, 65, 24)
	else
		statFrame.Diff.Text = "+0"
		statFrame.Diff.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	end
end

local function updateLootInfo(LootInfo, loot)
	local currentGun = Data.GetLocalPlayerData("Weapon")
	local rarity = Loot.Rarities[loot.Rarity]

	if rarity.Color then
		LootInfo.ViewportFrame.BackgroundColor3 = rarity.Color
	end

	ViewportFramePreview(LootInfo.ViewportFrame, Data.GetModel(loot))

	LootInfo.Level.Text = "Level " .. loot.Level
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
		changeStat(stats.Damage, loot.Damage, currentGun.Damage)

		changeStat(
			stats.CritChance,
			loot.CritChance * 100,
			currentGun.CritChance * 100,
			"%d%%",
			0.99999999
		)

		changeStat(stats.FireRate, loot.FireRate, currentGun.FireRate, "%.1f", 0.00999999)
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
