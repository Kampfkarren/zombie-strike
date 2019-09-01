local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Blur = Lighting.Blur
local YouWin = script.Parent.Main.YouWin

local wordTweenIn = {
	TweenInfo.new(2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
	{ Position = UDim2.new(0.5, 0, 0.5, 0) },
}

local wordTweenOut = {
	TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	{ Position = UDim2.new(-0.5, 0, 0.5, 0) },
}

local tweenWord1In = TweenService:Create(
	YouWin.Word1,
	unpack(wordTweenIn)
)

local tweenWord1Out = TweenService:Create(
	YouWin.Word1,
	unpack(wordTweenOut)
)

local tweenWord2In = TweenService:Create(
	YouWin.Word2,
	unpack(wordTweenIn)
)

local tweenWord2Out = TweenService:Create(
	YouWin.Word2,
	unpack(wordTweenOut)
)

local tweenBlurIn = TweenService:Create(
	Blur,
	TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	{ Size = 20 }
)

local tweenBlurOut = TweenService:Create(
	Blur,
	TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	{ Size = 0 }
)

ReplicatedStorage.Remotes.MissionOver.OnClientEvent:connect(function()
	for _, frame in pairs(script.Parent.Main:GetChildren()) do
		if not CollectionService:HasTag(frame, "KeepUIAfterWin") then
			frame.Visible = false
		end
	end

	tweenWord1In:Play()
	tweenWord2In:Play()
	tweenBlurIn:Play()

	wait(4)

	tweenWord1Out:Play()
	tweenWord2Out:Play()
	tweenBlurOut:Play()
end)
