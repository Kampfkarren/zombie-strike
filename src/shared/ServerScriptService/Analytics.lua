local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Data = require(ReplicatedStorage.Core.Data)
local inspect = require(ReplicatedStorage.Core.inspect)
local Perks = require(ReplicatedStorage.Core.Perks)
local Promise = require(ReplicatedStorage.Core.Promise)

local DEBUG_ANALYTICS = false

local Analytics = {}

function Analytics.Debug(...)
	if DEBUG_ANALYTICS then
		print("[Analytics]", ...)
	end
end

if RunService:IsStudio() then
	print("[Analytics] Debug place -- no analytics will be sent")
	Analytics.FireEvent = function(eventCategory, eventValue)
		Analytics.Debug("Firing:", eventCategory, "-", inspect(eventValue))
	end
else
	function Analytics.FireEvent(eventCategory, eventValue)
		Analytics.Debug("Firing:", eventCategory, "-", inspect(eventValue))
		AnalyticsService:FireEvent(eventCategory, eventValue)
	end
end

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local function getDungeonInfo()
	local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

	return Dungeon.GetDungeonTable():andThen(function(dungeonTable)
		return Promise.async(function(resolve)
			local dungeonTable = copy(dungeonTable)

			local newMembers = {}

			for _, userId in ipairs(dungeonTable.Members) do
				local newMember = { UserId = userId }

				local player = Players:GetPlayerByUserId(userId)
				if player ~= nil then
					newMember.Level = Data.GetPlayerData(player, "Level")
					newMember.Items = {}

					for equippable in pairs(Data.Equippable) do
						newMember.Items[equippable] = Data.GetPlayerData(player, equippable)
					end
				end

				table.insert(newMembers, newMember)
			end

			dungeonTable.Members = newMembers

			resolve(dungeonTable)
		end)
	end)
end

local timeStarted

-- DUNGEONS
function Analytics.DungeonStarted()
	getDungeonInfo():andThen(function(dungeonTable)
		timeStarted = os.time()
		Analytics.FireEvent("DungeonStarted", dungeonTable)
	end)
end

function Analytics.DungeonFinished()
	getDungeonInfo():andThen(function(dungeonTable)
		if timeStarted ~= nil then
			dungeonTable.TimeStarted = timeStarted
		end

		Analytics.FireEvent("DungeonFinished", dungeonTable)
	end)
end

-- COLLECTION LOG
function Analytics.CollectionLogRequested(player)
	Analytics.FireEvent("CollectionLogRequested", {
		UserId = player.UserId,
	})
end

-- PURCHASES
function Analytics.CapsBought(player, caps)
	Analytics.FireEvent("CapsBought", {
		UserId = player.UserId,
		Caps = caps,
	})
end

function Analytics.CosmeticBought(player, itemName)
	Analytics.FireEvent("CosmeticBought", {
		UserId = player.UserId,
		ItemName = itemName,
	})
end

-- WEAPON SHOP
function Analytics.WeaponShopRequested(player)
	Analytics.FireEvent("WeaponShopRequested", {
		UserId = player.UserId,
	})
end

function Analytics.WeaponShopBoughtItem(player, weapon)
	local GoldShopItemsUtil = require(ReplicatedStorage.Libraries.GoldShopItemsUtil)

	local perkNames = {}

	for _, perk in ipairs(weapon.Perks) do
		table.insert(perkNames, Perks.Perks[perk].Name)
	end

	Analytics.FireEvent("WeaponShopBoughtItem", {
		UserId = player.UserId,
		PlayerLevel = Data.GetPlayerData(player, "Level"),
		Level = math.min(
			GoldShopItemsUtil.MAX_LEVEL,
			Data.GetPlayerData(player, "Level") + weapon.LevelOffset
		),
		Gun = {
			Level = weapon.Gun.Level,
			Rarity = weapon.Gun.Rarity,
			Bonus = weapon.Gun.Bonus,
		},
		Perks = perkNames,
	})
end

return Analytics
