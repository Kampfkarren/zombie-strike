local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CosmeticsDictionary = require(ReplicatedStorage.Core.CosmeticsDictionary)
local FontsDictionary = require(ReplicatedStorage.Core.FontsDictionary)
local SpraysDictionary = require(ReplicatedStorage.Core.SpraysDictionary)
local TitlesDictionary = require(ReplicatedStorage.Core.TitlesDictionary)

local function level(freeLoot, paidLoot, gamesNeeded)
	if freeLoot == nil then
		freeLoot = {}
	elseif freeLoot.Type ~= nil then
		freeLoot = { freeLoot }
	end

	if paidLoot.Type ~= nil then
		paidLoot = { paidLoot }
	end

	return {
		FreeLoot = freeLoot,
		GamesNeeded = gamesNeeded,
		PaidLoot = paidLoot,
	}
end

local function search(dictionary, name)
	local selected, selectedIndex

	for index, thing in ipairs(dictionary) do
		if thing.Name == name then
			selected = thing
			selectedIndex = index
			break
		end
	end

	return assert(selected, name .. " cannot be found"), selectedIndex
end

local function searchable(type, dictionary)
	return function(name)
		local item, itemIndex = search(dictionary, name)

		return {
			Type = type,
			[type] = item,
			Index = itemIndex,
		}
	end
end

local emote = searchable("Emote", SpraysDictionary)
local font = searchable("Font", FontsDictionary)
local skin = searchable("Skin", CosmeticsDictionary)

local function brains(brains)
	return {
		Type = "Brains",
		Brains = brains,
	}
end

local function petCoins(petCoins)
	return {
		Type = "PetCoins",
		PetCoins = petCoins,
	}
end

local function title(name)
	return {
		Type = "Title",
		Title = name,
		Index = assert(table.find(TitlesDictionary, name), "can't find title " .. name),
	}
end

local function xp(xp)
	return {
		Type = "XP",
		XP = xp,
	}
end

local ZombiePassDictionary = {
	level(
		emote("Smile"),
		{
			brains(100),
			skin("Photographer"),
			skin("Biker"),
			emote("Treasure"),
		},
		1
	),

	level(nil, title("The Wise"), 2),
	level(brains(20), skin("The Noble"), 2),
	level(nil, xp(15), 3),
	level(skin("Sleepy"), title("The Fragger"), 3),
	level(nil, brains(100), 4),
	level(xp(10), emote("Winner"), 4),
	level(nil, skin("Athlete"), 4),
	level(emote("Meh"), title("The Pro"), 5),
	level(nil, skin("Red Lights"), 5),
	level(title("The Gamer"), brains(100), 5),
	level(nil, skin("The Leader"), 5),
	level(brains(40), title("The Unstoppable"), 5),
	level(nil, brains(100), 5),
	level(title("The Cool"), emote("Cute"), 5),
	level(nil, xp(10), 6),
	level(brains(45), title("The Elite"), 7),
	level(nil, brains(100), 7),
	level(emote("Sad"), emote("Gun"), 8),
	level(nil, skin("The Comedian"), 8),
	level(emote("Heart"), emote("Gold"), 11),
	level(nil, font("Fantasy"), 11),
	level(brains(50), title("The Maniac"), 11),
	level(nil, skin("The Quirky"), 11),
	level(title("The Crook"), emote("Zombie"), 18),
	level(nil, skin("Sea Agent"), 1),
	level(title("The Killer"), brains(100), 2),
	level(nil, skin("World View"), 2),
	level(brains(100), font("Cartoon"), 3),
	level(nil, skin("Wanwood"), 3),
	level(xp(15), petCoins(5000), 4),
	level(brains(100), brains(300), 4),
	level(nil, skin("Cat Vibes"), 4),
	level(brains(50), petCoins(2500), 5),
	level(title("The Sharpshot"), skin("Sea Agent"), 5),
	level(nil, skin("Operator"), 5),
	level(brains(200), font("Code"), 5),
	level(title("The Vigilante"), xp(15), 5),
	level(nil, title("The Ultimate"), 5),
	level(xp(10), font("Sci-Fi"), 5),
	level(title("The Master"), skin("Game Over"), 6),
	level(nil, skin("Fear Contestant"), 7),
	level(brains(300), title("The Legend"), 7),
	level(title("The Hero"), brains(200), 8),
	level(nil, skin("Bat & Ghost!"), 8),
	level(brains(200), brains(400), 11),
	level(title("The Sweeper"), brains(500), 11),
	level(nil, brains(600), 11),
	level(brains(400), font("Arcade"), 11),
	level(title("The Kawaii"), skin("Aesthetic Nerd"), 18),
}

return ZombiePassDictionary
