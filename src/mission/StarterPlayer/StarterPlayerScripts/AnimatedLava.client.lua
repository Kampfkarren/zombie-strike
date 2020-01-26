local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Collection = require(ReplicatedStorage.Core.Collection)

local lavaTweenInfo = TweenInfo.new(
	5,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.InOut,
	-1,
	true
)

Collection("AnimatedLava", function(lava)
	for _, texture in pairs(lava:GetChildren()) do
		if texture:IsA("Texture") then
			TweenService:Create(
				texture,
				lavaTweenInfo,
				{
					OffsetStudsU = 5,
					OffsetStudsV = 5,
				}
			):Play()
		end
	end
end)
