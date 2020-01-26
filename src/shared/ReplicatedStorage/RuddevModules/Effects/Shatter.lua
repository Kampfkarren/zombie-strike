-- services

local Debris = game:GetService("Debris")

-- constants

-- functions

return function(character, betterEquipment)
	local boost = "Health"
	local upperTorso = character.UpperTorso

	local icon = script[boost].IconEmitter:Clone()
	if betterEquipment then
		icon.Color = ColorSequence.new(Color3.new(1, 1, 0))
	end
	icon.Parent = upperTorso

	local spark = script[boost].SparkEmitter:Clone()
	spark.Parent = upperTorso

	--[[local sound	 = script[boost .. "Sound"]:Clone()
		sound.Parent = upperTorso]]

	icon:Emit(10)
	spark:Emit(25)
	--sound:Play()

	Debris:AddItem(icon, 2)
	Debris:AddItem(spark, 2)
	--Debris:AddItem(sound, sound.TimeLength)
end