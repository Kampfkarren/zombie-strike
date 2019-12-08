local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local SequenceUtil = require(script.Parent.SequenceUtil)

local Sequence = {}

Sequence.Assets = {
	Roar = ReplicatedStorage
		.Assets
		.Campaign
		.Campaign4
		.Boss
		.RoarAnimation,
}

function Sequence.Start(boss)
	return SequenceUtil.Init(boss)
		:andThen(SequenceUtil.TeleportToAttachment("BossSequenceStart1"))
		:andThen(SequenceUtil.MoveToAttachment("BossSequenceStart2", TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)))
		:andThen(SequenceUtil.Delay(0.5))
		:andThen(SequenceUtil.Animate(Sequence.Assets.Roar))
		:andThen(SequenceUtil.Delay(1.5))
		:tap(function()
			SoundService.ZombieSounds["4"].Boss.Roar:Play()
		end)
		:andThen(SequenceUtil.Shake(Vector3.new(0, 30, 30)))
		:andThen(SequenceUtil.ShowName)
		:andThen(SequenceUtil.Delay(2.3))
		:andThen(SequenceUtil.Finish)
end

return Sequence
