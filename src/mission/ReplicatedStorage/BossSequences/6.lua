local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SequenceUtil = require(script.Parent.SequenceUtil)

local Sequence = {}

Sequence.Assets = {
	TeleIn = ReplicatedStorage.Assets.Campaign.Campaign6.Boss.TeleIn,
}

function Sequence.Start(boss)
	return SequenceUtil.Init(boss)
		:andThen(SequenceUtil.TeleportToAttachment("PortalStart"))
		:andThen(SequenceUtil.MoveToAttachment(
			"PortalEnd",
			TweenInfo.new(2.0, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		))
		:andThen(SequenceUtil.Delay(2.0))
		:andThen(SequenceUtil.TeleportToAttachment("ArenaStart"))
		:andThen(SequenceUtil.MoveToAttachment(
			"ArenaEnd",
			TweenInfo.new(1.0, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		))
		:andThen(SequenceUtil.Emit("Dust", 10))
		:andThen(SequenceUtil.Emit("Magic", 10))
		:andThen(SequenceUtil.Delay(0.5))
		:andThen(SequenceUtil.Animate(Sequence.Assets.TeleIn))
		:andThen(SequenceUtil.Delay(0.5))
		:andThen(SequenceUtil.ShowName)
		:andThen(SequenceUtil.Delay(2.3))
		:andThen(SequenceUtil.Finish)
end

return Sequence

