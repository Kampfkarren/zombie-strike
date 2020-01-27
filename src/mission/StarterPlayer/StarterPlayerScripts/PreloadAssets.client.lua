local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local GetAssetsFolder = require(ReplicatedStorage.Libraries.GetAssetsFolder)

local Assets = ReplicatedStorage.Assets

local function preloadChildrenOf(instance)
	coroutine.wrap(function()
		ContentProvider:PreloadAsync(instance:GetDescendants())
	end)()
end

preloadChildrenOf(GetAssetsFolder())
preloadChildrenOf(Assets.Animations)
preloadChildrenOf(SoundService.SFX.Explosion)
