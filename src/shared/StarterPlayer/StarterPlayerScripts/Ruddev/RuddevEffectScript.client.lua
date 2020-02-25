-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")

-- constants

local REMOTES	= ReplicatedStorage:WaitForChild("RuddevRemotes")
local MODULES	= ReplicatedStorage:WaitForChild("RuddevModules")
	local EFFECTS	= require(MODULES:WaitForChild("Effects"))

-- events

REMOTES.Effect.OnClientEvent:connect(function(id, ...)
	EFFECTS.EffectById(id, ...)
end)