local SequenceUtil = require(script.Parent.SequenceUtil)

local Sequence = {}

Sequence.Assets = {}

function Sequence.Start(boss)
	return SequenceUtil.Init(boss)
		:andThen(SequenceUtil.TeleportToAttachment("BossSequenceStart1"))
		:andThen(SequenceUtil.MoveToAttachment("BossSequenceStart2", TweenInfo.new(2, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)))
		:andThen(SequenceUtil.Delay(0.5))
		:andThen(SequenceUtil.Delay(1.5))
		:andThen(SequenceUtil.ShowName)
		:andThen(SequenceUtil.Delay(2.3))
		:andThen(SequenceUtil.Finish)
end

return Sequence
