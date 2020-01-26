local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArmorScaling = require(ReplicatedStorage.Core.ArmorScaling)
local Data = require(ReplicatedStorage.Core.Data)
local Upgrades = require(ReplicatedStorage.Core.Upgrades)

local character = script.Parent
local player = Players:GetPlayerFromCharacter(character)

local regen = 0

local function giveHealthRegen(name)
	local loot = Data.GetPlayerData(player, name)

	local buff = ArmorScaling.ArmorRegen(loot.Level)
	buff = buff + Upgrades.GetRegenBuff(buff, loot.Upgrades)

	regen = regen + buff
end

giveHealthRegen("Armor")
giveHealthRegen("Helmet")

while character:IsDescendantOf(game) do
	character.Humanoid.Health = character.Humanoid.Health + regen
	wait(1)
end
