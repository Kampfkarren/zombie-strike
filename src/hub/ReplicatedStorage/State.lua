local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Data = require(ReplicatedStorage.Core.Data)
local GoldShopItemsUtil = require(ReplicatedStorage.Libraries.GoldShopItemsUtil)
local Loot = require(ReplicatedStorage.Core.Loot)
local Rodux = require(ReplicatedStorage.Vendor.Rodux)

local Store

local ENABLE_DEBUGGING = false

local loggerMiddleware

if RunService:IsStudio() and ENABLE_DEBUGGING then
	loggerMiddleware = Rodux.loggerMiddleware
end

local function copy(list)
	local copy = {}
	for key, value in pairs(list) do
		copy[key] = value
	end
	return copy
end

local function pageReducer(pages)
	local output = {}

	for _, name in ipairs(pages) do
		output["Toggle" .. name] = function(state)
			if state.current == name then
				return {
					current = nil
				}
			else
				return {
					current = name
				}
			end
		end

		output["Close" .. name] = function(state)
			if state.current == name then
				return {
					current = nil
				}
			else
				return state
			end
		end

		output["Open" .. name] = function()
			return {
				current = name
			}
		end
	end

	return output
end

local function updatePossessions(original, action)
	local possessions = copy(original)

	-- network optimization: owned is nil when just an equipped update
	if action.owned then
		possessions.owned = action.owned
	end

	possessions.equipped = action.equipped
	return possessions
end

Store = Rodux.Store.new(Rodux.combineReducers({
	brains = Rodux.createReducer(0, {
		UpdateBrains = function(_, action)
			return action.brains
		end,
	}),

	equipment = Rodux.createReducer(nil, {
		UpdateEquipment = function(_, action)
			local armor, helmet, weapon, pet
				= action.newArmor, action.newHelmet, action.newWeapon, action.newPet
			local currentInventory = assert(Store:getState().inventory)

			Data.SetLocalPlayerData("EquippedArmor", armor)
			Data.SetLocalPlayerData("EquippedHelmet", helmet)
			Data.SetLocalPlayerData("EquippedWeapon", weapon)
			Data.SetLocalPlayerData("EquippedPet", pet)

			Data.SetLocalPlayerData("Armor", currentInventory[armor])
			Data.SetLocalPlayerData("Helmet", currentInventory[helmet])
			Data.SetLocalPlayerData("Weapon", currentInventory[weapon])

			return {
				armor = armor,
				helmet = helmet,
				weapon = weapon,

				equippedArmor = currentInventory[armor],
				equippedHelmet = currentInventory[helmet],
				equippedPet = currentInventory[pet],
				equippedWeapon = currentInventory[weapon],
				equippedAttachment = currentInventory[weapon].Attachment,
			}
		end,
	}),

	gold = Rodux.createReducer(0, {
		UpdateGold = function(_, action)
			return action.gold
		end,
	}),

	inventory = Rodux.createReducer(nil, {
		UpdateInventory = function(_, action)
			return action.newInventory
		end,
	}),

	inventoryEquipment = Rodux.createReducer(nil, {
		UpdateEquipmentInventory = function(_, action)
			return action.newInventory
		end,
	}),

	itemsCollected = Rodux.createReducer({}, {
		UpdateItemsCollected = function(_, action)
			return action.itemsCollected
		end,
	}),

	goldShop = Rodux.createReducer({
		alreadyBought = {},
	}, {
		UpdateGoldShopAlreadyBought = function(state, action)
			local state = copy(state)
			state.alreadyBought = action.alreadyBought
			return state
		end,

		UpdateGoldShopTimestamp = function(state, action)
			local state = copy(state)
			state.timestamp = action.timestamp
			return state
		end,
	}),

	hideUi = Rodux.createReducer(0, {
		HideUI = function(state)
			return state + 1
		end,

		ShowUI = function(state)
			return state - 1
		end,
	}),

	page = Rodux.createReducer({
		current = nil,
	}, pageReducer({
		"Codes",
		"CollectionLog",
		"Friends",
		"Equipment",
		"Feedback",
		"GoldShop",
		"Inventory",
		"PetShop",
		"Settings",
		"Shopkeeper",
		"Store",
		"Trading",
		"Vouchers",
		"ZombiePass",
	})),

	quests = Rodux.createReducer({
		quests = {},
	}, {
		SetQuests = function(_, action)
			return {
				quests = action.quests,
			}
		end,
	}),

	sprays = Rodux.createReducer({
		owned = {},
	}, {
		UpdateSprays = updatePossessions,
	}),

	store = Rodux.createReducer({
		contents = {},
		equipped = {},
		page = "Shop",
		new = false,
		xpExpiration = 0,
	}, {
		OpenedStore = function(state)
			local state = copy(state)
			if state.new then
				ReplicatedStorage.Remotes.UpdateStoreLastSeen:FireServer()
			end
			state.new = false
			return state
		end,

		SetStorePage = function(state, action)
			local state = copy(state)
			state.page = action.page
			return state
		end,

		UpdateCosmetics = function(state, action, lastSeen)
			local state = copy(state)
			state.contents = action.contents or state.contents
			state.equipped = action.equipped
			state.new = lastSeen ~= os.date("!*t").yday
			return state
		end,

		UpdateXPExpiration = function(state, action)
			local state = copy(state)
			state.xpExpiration = action.expiration
			return state
		end,
	}),

	nametags = Rodux.createReducer({
		fonts = {
			equipped = nil,
			owned = {},
		},

		titles = {
			equipped = nil,
			owned = {},
		},
	}, {
		UpdateFonts = function(state, action)
			local state = copy(state)
			state.fonts = updatePossessions(state.fonts, action)
			return state
		end,

		UpdateTitles = function(state, action)
			local state = copy(state)
			state.titles = updatePossessions(state.titles, action)
			return state
		end,
	}),

	trading = Rodux.createReducer({
		trading = false,
		theirEquipment = {},
		theirInventory = {},
		theirOffer = {},
		yourOffer = {},
	}, {
		CloseTrade = function()
			return {
				trading = false,
				theirEquipment = {},
				theirInventory = {},
				theirOffer = {},
				yourOffer = {},
			}
		end,

		OpenNewTrade = function(_, action)
			return {
				trading = true,
				theirEquipment = action.theirEquipment,
				theirInventory = action.theirInventory,
				theirOffer = {},
				yourOffer = {},
			}
		end,

		OfferTrade = function(state, action)
			local state = copy(state)

			if action.who == "us" then
				local yourOffer = copy(state.yourOffer)
				table.insert(yourOffer, action.uuid)
				state.yourOffer = yourOffer
			else
				local theirOffer = copy(state.theirOffer)
				table.insert(theirOffer, action.uuid)
				state.theirOffer = theirOffer
			end

			return state
		end,

		TakeDownTrade = function(state, action)
			local state = copy(state)

			if action.who == "us" then
				local yourOffer = copy(state.yourOffer)
				table.remove(yourOffer, assert(table.find(yourOffer, action.uuid)))
				state.yourOffer = yourOffer
			else
				local theirOffer = copy(state.theirOffer)
				table.remove(theirOffer, assert(table.find(theirOffer, action.uuid)))
				state.theirOffer = theirOffer
			end

			return state
		end,
	}),

	vouchers = Rodux.createReducer(0, {
		UpdateVouchers = function(_, action)
			return action.vouchers
		end,
	}),

	zombiePass = Rodux.createReducer({
		level = nil,
		premium = nil,
		rewards = {},
		xp = nil,
	}, {
		SetRewards = function(state, action)
			local state = copy(state)
			state.rewards = action.rewards
			return state
		end,

		SetZombiePass = function(state, action)
			local state = copy(state)

			state.level = action.level
			state.premium = action.premium
			state.xp = action.xp

			if action.rewards then
				state.rewards = action.rewards
			end

			return state
		end,
	}),
}), nil, { loggerMiddleware })

ReplicatedStorage.Remotes.UpdateCollectionLog.OnClientEvent:connect(function(itemsCollected)
	Store:dispatch({
		type = "UpdateItemsCollected",
		itemsCollected = itemsCollected,
	})
end)

ReplicatedStorage.Remotes.UpdateCosmetics.OnClientEvent:connect(function(contents, equipped)
	Store:dispatch({
		type = "UpdateCosmetics",
		contents = contents,
		equipped = equipped,
	})
end)

ReplicatedStorage.Remotes.UpdateInventory.OnClientEvent:connect(function(inventory)
	local loot = Loot.DeserializeTableWithBase(inventory)

	Store:dispatch({
		type = "UpdateInventory",
		newInventory = loot,
	})
end)

ReplicatedStorage.Remotes.UpdateEquipment.OnClientEvent:connect(function(armor, helmet, weapon, pet)
	-- this has a very rare chance of happening, despite presumably being impossible
	while Store:getState().inventory == nil do
		warn("UpdateEquipment: inventory wasn't set yet!")
		Store:flush()
		RunService.Heartbeat:wait()
	end

	Store:dispatch({
		type = "UpdateEquipment",
		newArmor = armor,
		newHelmet = helmet,
		newWeapon = weapon,
		newPet = pet,
	})
end)

ReplicatedStorage.Remotes.XPMultipliers.OnClientEvent:connect(function(expiration)
	Store:dispatch({
		type = "UpdateXPExpiration",
		expiration = expiration,
	})
end)

ReplicatedStorage.Remotes.UpdateEquipmentInventory.OnClientEvent:connect(function(equipment)
	Store:dispatch({
		type = "UpdateEquipmentInventory",
		newInventory = equipment,
	})
end)

ReplicatedStorage.Remotes.UpdateFonts.OnClientEvent:connect(function(equipped, owned)
	Store:dispatch({
		type = "UpdateFonts",
		equipped = equipped,
		owned = owned,
	})
end)

ReplicatedStorage.Remotes.GoldShop.OnClientEvent:connect(function(packet, ...)
	if packet == GoldShopItemsUtil.GoldShopPacket.InitialData then
		local timestamp, alreadyBought = ...

		Store:dispatch({
			type = "UpdateGoldShopTimestamp",
			timestamp = timestamp,
		})

		if alreadyBought ~= nil then
			Store:dispatch({
				type = "UpdateGoldShopAlreadyBought",
				alreadyBought = alreadyBought,
			})
		end
	elseif packet == GoldShopItemsUtil.GoldShopPacket.BuyWeapon then
		local index = ...

		local alreadyBought = copy(Store:getState().goldShop.alreadyBought)
		table.insert(alreadyBought, index)

		Store:dispatch({
			type = "UpdateGoldShopAlreadyBought",
			alreadyBought = alreadyBought,
		})
	end
end)

ReplicatedStorage.Remotes.UpdateTitles.OnClientEvent:connect(function(equipped, owned)
	Store:dispatch({
		type = "UpdateTitles",
		equipped = equipped,
		owned = owned,
	})
end)

ReplicatedStorage.Remotes.UpdateQuests.OnClientEvent:connect(function(quests)
	Store:dispatch({
		type = "SetQuests",
		quests = quests,
	})
end)

ReplicatedStorage.Remotes.UpdateSprays.OnClientEvent:connect(function(equipped, owned)
	Store:dispatch({
		type = "UpdateSprays",
		equipped = equipped,
		owned = owned,
	})
end)

ReplicatedStorage.Remotes.UpdateVouchers.OnClientEvent:connect(function(vouchers)
	Store:dispatch({
		type = "UpdateVouchers",
		vouchers = vouchers,
	})
end)

ReplicatedStorage.Remotes.ZombiePass.OnClientEvent:connect(function(level, xp, premium, rewards)
	Store:dispatch({
		type = "SetZombiePass",
		level = level,
		premium = premium,
		rewards = rewards,
		xp = xp,
	})
end)

return Store
