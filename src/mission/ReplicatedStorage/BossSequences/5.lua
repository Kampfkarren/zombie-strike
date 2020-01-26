local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SequenceUtil = require(script.Parent.SequenceUtil)

local Sequence = {}

Sequence.Assets = {
	Spin = ReplicatedStorage.Assets.Campaign.Campaign5.Boss.SpinAnimation,
}

function Sequence.Start(boss)
	return SequenceUtil.Init(boss)
		:tap(function(boss)
			boss:SetPrimaryPartCFrame(boss.PrimaryPart.CFrame * CFrame.Angles(0, math.pi, 0))
		end)
		:andThen(SequenceUtil.TeleportToAttachment("BossSequenceStart1"))
		:andThen(SequenceUtil.Delay(0.3))
		:andThen(SequenceUtil.Emit("Tumbleweed", 1))
		:andThen(SequenceUtil.Animate(Sequence.Assets.Spin))
		:andThen(SequenceUtil.Delay(1.7))
		:andThen(SequenceUtil.MoveToAttachment("BossSequenceStart2", TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)))
		:andThen(SequenceUtil.Delay(1))
		:andThen(SequenceUtil.ShowName)
		:andThen(SequenceUtil.Delay(2))
		:tap(function(boss)
			boss:SetPrimaryPartCFrame(boss.PrimaryPart.CFrame * CFrame.Angles(0, math.pi, 0))
		end)
		:andThen(SequenceUtil.Finish)
end

return Sequence
