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
preloadChildrenOf(Assets.Campaign["Campaign" .. Dungeon.GetDungeonData("Campaign")])
preloadChildrenOf(SoundService.SFX.Explosion)
