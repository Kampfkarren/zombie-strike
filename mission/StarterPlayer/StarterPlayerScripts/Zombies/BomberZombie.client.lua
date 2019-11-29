local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CircleEffect = require(ReplicatedStorage.Libraries.CircleEffect)
local Explosion = require(ReplicatedStorage.RuddevModules.Effects.Explosion)

local BomberZombieEffect = ReplicatedStorage.Remotes.Zombies.BomberZombieEffect

local EXPLOSION_RADIUS = 5

BomberZombieEffect.OnClientEvent:connect(function(model)
	CircleEffect.FromPreset(model.PrimaryPart.CFrame, CircleEffect.Presets.BOMBER_ZOMBIE)
	Explosion(model.PrimaryPart.Position, EXPLOSION_RADIUS)
end)
