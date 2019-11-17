local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CircleEffect = require(ReplicatedStorage.Libraries.CircleEffect)

local CircleEffectRemote = ReplicatedStorage.Remotes.CircleEffect

CircleEffectRemote.OnClientEvent:connect(function(cframe, preset)
	CircleEffect.FromPreset(cframe, preset)
end)
