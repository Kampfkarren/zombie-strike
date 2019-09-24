local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local EnglishNumbers = require(ReplicatedStorage.Core.EnglishNumbers)

local xpGainTween = {
	TweenInfo.new(1.25, Enum.EasingStyle.Back, Enum.EasingDirection.In),
	{ Scale = 0 }
}

ReplicatedStorage.Remotes.XPGain.OnClientEvent:connect(function(position, xp)
	local attachment = Instance.new("Attachment")
	attachment.Position = position
	attachment.Parent = Workspace.Terrain

	local xpGain = ReplicatedStorage.XPGain:Clone()
	xpGain.TextLabel.Text = "+" .. EnglishNumbers(xp)
	xpGain.Parent = attachment

	TweenService:Create(xpGain.TextLabel.UIScale, unpack(xpGainTween)):Play()
end)
