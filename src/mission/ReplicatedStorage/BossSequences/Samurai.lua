local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SequenceUtil = require(script.Parent.SequenceUtil)

local Sequence = {}

Sequence.Assets = { }

function Sequence.Start(boss)
	return SequenceUtil.Init(boss)
		:andThen(SequenceUtil.Finish)
end

return Sequence

