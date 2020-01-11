local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Core.Data)
local Loot = require(ReplicatedStorage.Core.Loot)
local Rodux = require(ReplicatedStorage.Vendor.Rodux)

local Store

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

Store = Rodux.Store.new(Rodux.combineReducers({
	brains = Rodux.createReducer(0, {
		UpdateBrains = function(_, action)
			return action.brains
		end,
	}),

	equipment = Rodux.createReducer(nil, {
		UpdateEquipment = function(_, action)
			local armor, helmet, weapon, attachment
				= action.newArmor, action.newHelmet, action.newWeapon, action.newAttachment
			local currentInventory = assert(Store:getState().inventory)

			Data.SetLocalPlayerData("EquippedArmor", armor)
			Data.SetLocalPlayerData("EquippedHelmet", helmet)
			Data.SetLocalPlayerData("EquippedWeapon", weapon)

			Data.SetLocalPlayerData("Armor", currentInventory[armor])
			Data.SetLocalPlayerData("Helmet", currentInventory[helmet])
			Data.SetLocalPlayerData("Weapon", currentInventory[weapon])

			return {
				armor = armor,
				helmet = helmet,
				weapon = weapon,
				attachment = attachment,

				equippedArmor = currentInventory[armor],
				equippedHelmet = currentInventory[helmet],
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

	page = Rodux.createReducer({
		current = nil,
	}, pageReducer({
		"Codes",
		"Friends",
		"Equipment",
		"Feedback",
		"Inventory",
		"Settings",
		"Shopkeeper",
		"Store",
		"Trading",
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
		UpdateSprays = function(state, action)
			local state = copy(state)

			-- network optimization: owned is nil when just an equipped update
			if action.owned then
				state.owned = action.owned
			end

			state.equipped = action.equipped
			return state
		end,
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
}))

ReplicatedStorage.Remotes.UpdateCosmetics.OnClientEvent:connect(function(contents, equipped)
	Store:dispatch({
		type = "UpdateCosmetics",
		contents = contents,
		equipped = equipped,
	})
end)

ReplicatedStorage.Remotes.UpdateEquipment.OnClientEvent:connect(function(armor, helmet, weapon, attachment)
	Store:dispatch({
		type = "UpdateEquipment",
		newArmor = armor,
		newHelmet = helmet,
		newWeapon = weapon,
		newAttachment = attachment,
	})
end)

ReplicatedStorage.Remotes.UpdateXPExpiration.OnClientEvent:connect(function(expiration)
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

ReplicatedStorage.Remotes.UpdateInventory.OnClientEvent:connect(function(inventory)
	local loot = Loot.DeserializeTableWithBase(inventory)

	Store:dispatch({
		type = "UpdateInventory",
		newInventory = loot,
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
