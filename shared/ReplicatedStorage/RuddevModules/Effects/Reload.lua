-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local Debris			= game:GetService("Debris")

-- constants

local MODULES	= ReplicatedStorage:WaitForChild("RuddevModules")
	local CONFIG	= require(MODULES:WaitForChild("Config"))

-- functions

return function(item)
	local handle	= item.Handle
	local config	= CONFIG:GetConfig(item)

	local sound		= handle.ReloadSound:Clone()
		sound.Name			= "ReloadSound_Clone"
		sound.Parent		= handle
		sound.PlaybackSpeed	= sound.TimeLength / config.ReloadTime

	sound:Play()
	Debris:AddItem(sound, sound.TimeLength / sound.PlaybackSpeed)
end