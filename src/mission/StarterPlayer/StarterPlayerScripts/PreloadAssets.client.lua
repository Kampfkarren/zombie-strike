local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Dungeon = require(ReplicatedStorage.Libraries.Dungeon)

local Assets = ReplicatedStorage.Assets

local function preloadChildrenOf(instance)
	coroutine.wrap(function()
		ContentProvider:PreloadAsync(instance:GetDescendants())
	end)()
end

preloadChildrenOf(Assets.Animations)

local campaign = Dungeon.GetDungeonData("Campaign")

if campaign then
	preloadChildrenOf(Assets.Campaign["Campaign" .. campaign])
elseif Dungeon.GetDungeonData("Gamemode") == "Boss" then
	preloadChildrenOf(Assets.Bosses[Dungeon.GetDungeonData("BossInfo").RoomName])
end

preloadChildrenOf(SoundService.SFX.Explosion)
