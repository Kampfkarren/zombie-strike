local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local DungeonTiming = require(ReplicatedStorage.Libraries.DungeonTiming)

local Countdown = script.Parent.Main.Countdown

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

ReplicatedStorage.JoinTimer.Changed:connect(function(timer)
	if timer < 0 then
		local timer = math.abs(timer)

		for index = 1, 4 do
			local image = Countdown[index]
			image.UIScale.Scale = 0

			if index == timer then
				local tween = TweenService:Create(image.UIScale, tweenInfo, { Scale = 1 })
				if index == 4 then
					DungeonTiming.DungeonStarted()
					tween.Completed:connect(function()
						TweenService:Create(
							image,
							TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{ Size = UDim2.new(), Rotation = 20 }
						):Play()
					end)
				end
				tween:Play()
			end
		end
	end

	Countdown.Visible = timer < 0
end)
