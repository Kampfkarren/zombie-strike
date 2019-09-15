-- services

local TweenService	= game:GetService("TweenService")
local Workspace		= game:GetService("Workspace")
local Debris		= game:GetService("Debris")

-- constants

local EFFECTS	= Workspace:WaitForChild("Effects")

-- functions

return function(character)
	local boost = "Health"
	local upperTorso	= character.UpperTorso

	local icon		= script[boost].IconEmitter:Clone()
		icon.Parent		= upperTorso
	local spark		= script[boost].SparkEmitter:Clone()
		spark.Parent	= upperTorso

	--[[local sound		= script[boost .. "Sound"]:Clone()
		sound.Parent	= upperTorso]]

	icon:Emit(10)
	spark:Emit(25)
	--sound:Play()

	Debris:AddItem(icon, 2)
	Debris:AddItem(spark, 2)
	--Debris:AddItem(sound, sound.TimeLength)
end